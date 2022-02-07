#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [ -n "$USER" ] && [ -n "$PASS" ]; then
    /usr/bin/transmission-remote -n "$USER":"$PASS" -p "$1"
else
    /usr/bin/transmission-remote -p "$1"
fi
echo "$(date): Updated transmission forwarded port to $1"
