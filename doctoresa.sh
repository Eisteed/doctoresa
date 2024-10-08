#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ "$#" -ne 2 ]; then
    echo "Utilisation: $0 <URL> <EMAIL> (url et mail entre guillemets)"
    exit 1
fi

URL=$1
TO=$2

# SMTP
SMTP_SERVER="mail.example.com"
USERNAME="user@example.com"
PASSWORD=""
FROM="user@example.com"

SEARCH_TEXT="Désolé, la réservation est impossible"

# Delai en secondes si un email à déjà été envoyé, par défaut 3h
DELAY=$((3 * 60 * 60))
LOCKFILE="./email_delai.lock"

PAGE_CONTENT=$(./curl_chrome110 $URL \
  -H 'authority: www.doctolib.fr' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' \
  -H 'cache-control: max-age=0' \
  -H 'if-none-match: W/"363291d1faae7973b0c8b7aa7aa0856a"' \
  -H 'sec-ch-ua: "Not.A/Brand";v="8", "Chromium";v="114", "Google Chrome";v="114"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'sec-fetch-dest: document' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-user: ?1' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36' \
  --compressed)
  
if [ -z "$PAGE_CONTENT" ]; then
    echo "Erreur curl, page vide."
    exit 0
fi

if echo "$PAGE_CONTENT" | grep -q "$SEARCH_TEXT"; then
    echo "Texte '$SEARCH_TEXT' trouvé. Pas d'envoi de mail."
else
    if [ -f "$LOCKFILE" ]; then
        LAST_SENT_TIME=$(cat "$LOCKFILE")
        CURRENT_TIME=$(date +%s)
        TIME_SINCE_LAST_SENT=$((CURRENT_TIME - LAST_SENT_TIME))

        if [ "$TIME_SINCE_LAST_SENT" -lt "$DELAY" ]; then
            echo "Email déjà envoyé, en attente du délai."
            exit 0
        fi
    fi

    SUBJECT="Réservation disponible"
    MESSAGE="La réservation est possible à l'URL : $URL"

    swaks --to "$TO" --from "$FROM" --header "Subject: '$SUBJECT'" --body "$MESSAGE" \
        --auth LOGIN --auth-user "$USERNAME" --auth-password "$PASSWORD" \
        --server "$SMTP_SERVER"

    echo $(date +%s) > "$LOCKFILE"
fi
