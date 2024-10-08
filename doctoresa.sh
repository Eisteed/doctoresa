#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Utilisation: $0 <URL> <EMAIL> (url et mail entre guillemets)"
    exit 1
fi

URL=$1
EMAIL=$2

# SMTP server details
SMTP_SERVER="mail.example.com"
USERNAME="user@example.com"
PASSWORD=""

# Email details
TO="monmail@example.com"
FROM="user@example.com"

SEARCH_TEXT="Désolé, la réservation est impossible"

# Delai en secondes si un email à déjà été envoyé, par défaut 3h
DELAY=$((3 * 60 * 60))
LOCKFILE="/tmp/last_email_sent.lock"

PAGE_CONTENT=$(curl -A "Mozilla/5.0 (Linux; Android 10; SM-G996U Build/QP1A.190711.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Mobile Safari/537.36" -s $URL)

if echo "$PAGE_CONTENT" | grep -q "$SEARCH_TEXT"; then
    echo "The text '$SEARCH_TEXT' was found. No email will be sent."
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

    # Send the email using swaks
    swaks --to "$TO" --from "$FROM" --header "Subject: '$SUBJECT'" --body "$MESSAGE" \
        --auth LOGIN --auth-user "$USERNAME" --auth-password "$PASSWORD" \
        --server "$SMTP_SERVER"

    echo $(date +%s) > "$LOCKFILE"
fi
