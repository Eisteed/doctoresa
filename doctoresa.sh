#!/bin/bash

# Verification des arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <URL> <EMAIL>"
    exit 1
fi

# Variables depuis arguments
URL="$1"
EMAIL="$2"

# Quel texte à chercher dans la page pour savoir si la réservation n'est PAS disponible.
# Peut être modifié pour chercher sur d'autres sites (maiia, docteur rendez vous, etc..)
SEARCH_TEXT="Désolé, la réservation est impossible"

# Details SMTP pour l'envoi de mail, à remplir avec vos details de mail
SMTP_SERVER="" # localhost / mail.example.com
SMTP_PORT="" # 465 ou 25
USERNAME="" # mail@example.com
PASSWORD="" # motdepasse
FROM="" # mail@example.com

# Chargement de l'url fourni
PAGE_CONTENT=$(curl -s "$URL")

# Verification du texte à chercher
if ! echo "$PAGE_CONTENT" | grep -q "$SEARCH_TEXT"; then
    echo "The text '$SEARCH_TEXT' was found. No email will be sent."
else

    # Texte non trouvé, envoi du mail via port 465 (SSL) ou 25 (Non SSL)
    SUBJECT="Réservation disponible"
    MESSAGE="La réservation est possible à l'URL : $URL"

    AUTH_LOGIN=$(echo -ne "\0$USERNAME\0$PASSWORD" | base64)

    if [ "$SMTP_PORT" -eq "25" ]; then
        {
            echo "EHLO localhost"
            echo "AUTH PLAIN $AUTH_LOGIN"
            echo "MAIL FROM:<$FROM>"
            echo "RCPT TO:<$EMAIL>"
            echo "DATA"
            echo "From: $FROM"
            echo "To: $EMAIL"
            echo "Subject: $SUBJECT"
            echo
            echo "$MESSAGE"
            echo "."
            echo "QUIT"
        } | nc "$SMTP_SERVER" "$SMTP_PORT"
    elif [ "$SMTP_PORT" -eq "465" ]; then
        {
            echo "EHLO localhost"
            echo "AUTH PLAIN $AUTH_LOGIN"
            echo "MAIL FROM:<$FROM>"
            echo "RCPT TO:<$EMAIL>"
            echo "DATA"
            echo "From: $FROM"
            echo "To: $EMAIL"
            echo "Subject: $SUBJECT"
            echo
            echo "$MESSAGE"
            echo "."
            echo "QUIT"
        } | openssl s_client -quiet -crlf -connect "$SMTP_SERVER:$SMTP_PORT"
    else
        echo "Unsupported port: $SMTP_PORT"
        exit 1
fi
