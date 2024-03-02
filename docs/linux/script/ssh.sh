#!/usr/bin/env bash
set -e

AUTHORIZED_KEYS_PATH=~/.ssh/authorized_keys

PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYV5Hoaed4dQSmRoZrX+x6p+r16uBHVgv1Zkl8DOMRD 117503445-gen3"

mkdir -p ~/.ssh && touch $AUTHORIZED_KEYS_PATH

if ! grep -q "$PUBLIC_KEY" $AUTHORIZED_KEYS_PATH; then
    echo "" >> $AUTHORIZED_KEYS_PATH
    echo "$PUBLIC_KEY" >> $AUTHORIZED_KEYS_PATH
fi

sed -i '/^$/d' $AUTHORIZED_KEYS_PATH
