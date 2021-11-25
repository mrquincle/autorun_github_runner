#!/bin/sh

usage="Usage: $0 <public key>"

key=${1:? "$usage"}

mkdir -p ./tmp
cp $key ./tmp/userkey.pub

__cleanup()
{
	SIGNAL=$1

	rm -f ./tmp/userkey.pub
	rmdir ./tmp

	# when this function was called due to receiving a signal
	# disable the previously set trap and kill yourself with
	# the received signal
	if [ -n "$SIGNAL" ]
	then
		trap $SIGNAL
		kill -${SIGNAL} $$
	fi
}

trap __cleanup EXIT

echo 'Start python3 http server on port 80 to serve "./tmp" directory (requires sudo)'
sudo python3 -m http.server --directory ./tmp 80

