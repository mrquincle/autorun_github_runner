#!/bin/sh

usage="Usage: $0 <private key> <user>"

key=${1:? "$usage"}
user=${2:? "$usage"}

echo "Wait till userkey.pub is served from the http server"
echo "Local ssh on port 2222 (already set up at ./create_vm.sh)"
TERM=xterm ssh $user@localhost -i "$key" -p 2222
