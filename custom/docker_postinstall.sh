# After running "docker-compose up" we still miss a few items in the docker

container_id=$(docker ps -a -q)

# We can go into the container and do stuff there
#docker container exec -it $container_id /bin/bash

run_command="docker container exec -it $container_id"

# We upload an 00-do-not-ask file
rm -f 00-do-not-ask
touch 00-do-not-ask
echo 'APT::Get::Assume-Yes "true";' >> 00-do-not-ask
echo 'APT::Get::force-yes "true";' >> 00-do-not-ask

docker cp 00-do-not-ask $container_id:/etc/apt/apt.conf.d

# Or we can do it directly
$run_command apt update
$run_command apt-get install -f libusb-1.0-0
$run_command apt-get install -y cmake gcc g++ git make python3 python3-pip wget unzip libusb-1.0-0 libsm6

# The rest is not done by default
SETUP_BLUETOOTH=

if [ ! -n "${SETUP_BLUETOOTH}" ]; then
	echo 'No setup of bluetooth'
fi

# Download bluetooth-related stuff
$run_command apt-get install -y bluez

echo 'Now hciconfig should work (if not, disable on host)'
hciconfig

echo 'Make sure it is up'
hciconfig hci0 up

echo 'Type the following command to start dbus (takes a while)'
echo /etc/init.d/dbus start

echo 'Test scanning (should work)'
hcitool lescan

echo 'The tool bluetoothctl is not working.'
