#!/bin/bash

# Generate and output a PIA auth token
#
# Requires jq and curl
#
# Options:
#  -u <username>
#  -p <password>
#
# Example:
#  pia-auth.sh -u p0000000 -p mypassword > ~/.pia-token
#
# deauth using:
# curl --silent --show-error --request POST \
#        --header "Content-Type: application/json" \
#        --header "Authorization: Token $(cat ~/.pia-token)" \
#        --data "{}" \
#        "https://www.privateinternetaccess.com/api/client/v2/expire_token"

while getopts ":u:p:" args; do
  case ${args} in
    u)
      user=$OPTARG
      ;;
    p)
      pass=$OPTARG
      ;;
    *)
      echo "$(date) pia-auth.sh Invalid input. Exiting"
      exit 1
      ;;
  esac
done

usage() {
  echo "Options:"
  echo " -u <username>"
  echo " -p <password>"
  exit 1
}

get_auth_token () {
    if ! TOK=$(set +H; curl --silent --show-error --request POST --max-time "$curl_max_time" \
        --header "Content-Type: application/json" \
        --data "{\"username\":\"$user\",\"password\":\"$pass\"}" \
        "https://www.privateinternetaccess.com/api/client/v2/token" | jq -r '.token'; set -H); then
      echo "Failed to acquire new auth token" && exit 1
    fi
    echo "$TOK"
}

if [ -z "$pass" ] || [ -z "$user" ]; then
  usage
fi

curl_max_time=15
get_auth_token
exit 0
