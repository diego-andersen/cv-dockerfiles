#! /usr/bin/env bash

# Rapidly add multiple users to a fresh Debian-derivative machine
# Use GROUPS variable to select which groups users are added to,
# e.g. $ GROUPS=sudo,adm ./add_users.sh alice bob charlie

if [ "$(id -u)" -ne 0 ]; then echo "Please run as super-user." >&2; exit 1; fi

if [ "$#" -eq 0 ]; then
    echo "Please supply a space-delimited list of usernames"
    exit 1
else
    usernames=( "$@" )
fi

GROUPS=${GROUPS:-sudo,docker,plugdev}

for username in "${usernames[@]}"
do
    useradd -mU -G $GROUPS -s /bin/bash $username
    echo -e "$username\n$username" | passwd $username
    passwd -e $username

    echo "Added user: $username"
done

echo "Finished"
exit 0
