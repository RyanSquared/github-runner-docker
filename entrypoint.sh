#!/bin/sh

set -x

if ! sudo chown root:docker /var/run/docker.sock; then
  echo "NOTE: We don't have a Docker socket"
fi

url="--url $1"
token="--token $2"
[ ! -z "$3" ] && labels="--labels $3"

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
  # Note: this passes both the option and the value, quoting the following
  # variables would result in INVALID BEHAVIOR, do NOT quote the variables.
  ./config.sh $url $token $labels --unattended --disableupdate
  cp .runner persistent/runner
  cp .credentials persistent/credentials
  cp .credentials_rsaparams persistent/credentials_rsaparams
fi

./run.sh
