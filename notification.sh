#!/bin/bash
# sends an email to NOTIFICATION_EMAIL using the strings in email_messages.json

subject=$(jq -r ".$NOTIFYTYPE.subject // empty" /etc/nut/email_messages.json)
if [ -z "$subject" ]; then
   subject="$UPS_DESCRIPTION state $NOTIFYTYPE"
fi

body=$(jq -r ".$NOTIFYTYPE.body // empty" /etc/nut/email_messages.json)
if [ -z "$body" ]; then
   body="UPS '$UPS_DESCRIPTION' changed state to $NOTIFYTYPE."
fi

subject=$(printf "$subject" "$UPS_DESCRIPTION")
body=$(printf "$(date -R)\n\n$body" "$UPS_DESCRIPTION")

echo -e "Subject: $subject\nFrom: $NOTIFICATION_FROM_NAME <$NOTIFICATION_FROM>\n\n$body" | msmtp $NOTIFICATION_EMAIL