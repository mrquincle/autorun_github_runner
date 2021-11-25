#!/bin/sh

usage="Usage: $0 <private key> <user> <runner name> <github> <labels> <token>"

key=${1:? "$usage"}
user=${2:? "$usage"}
runner_name=${3:? "$usage"}
github=${4:? "$usage"}
labels=${5:? "$usage"}
token=${6:? "$usage"}

dockerfile=custom/.docker-compose.yml.private
echo "Create private file: $dockerfile"
cp custom/docker-compose.yml "$dockerfile"

sed -i "s|@@RUNNER_NAME@@|$runner_name|g" "$dockerfile"
sed -i "s|@@RUNNER_REPOSITORY@@|$github|g" "$dockerfile"
sed -i "s|@@RUNNER_LABELS@@|$labels|g" "$dockerfile"
sed -i "s|@@RUNNER_TOKEN@@|$token|g" "$dockerfile"

rsync -avzul -e "ssh -i $key -p 2222" ./custom $user@localhost:~

