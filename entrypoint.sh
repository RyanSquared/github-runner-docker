#!/bin/sh
for key in /opt/keys/gpg/*; do
  gpg --import $key
done
./config.sh --url "$1" --token "$2" --unattended
./run.sh
