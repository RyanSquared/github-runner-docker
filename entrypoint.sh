#!/bin/sh

set -x

for key in /opt/keys/gpg/*; do
  gpg --import $key
done
cat /opt/signing_keys.txt | while read key; do
  gpg --recv-keys $key;
done
mkdir -p config
sudo chown runner:runner persistent

if [ -f persistent/runner ]; then
  cp persistent/runner .runner
  cp persistent/credentials .credentials
  cp persistent/credentials_rsaparams .credentials_rsaparams
else
  ./config.sh --url "$1" --token "$2" --unattended --disableupdate
  cp .runner persistent/runner
  cp .credentials persistent/credentials
  cp .credentials_rsaparams persistent/credentials_rsaparams
fi

./run.sh
