# After running "docker-compose up" we still miss a few items in the docker

container_id=$(docker ps -a -q)

# We can go into the container and do stuff there
#docker container exec -it $container_id /bin/bash

# Or we can do it directly
docker container exec -it $container_id apt update
docker container exec -it $container_id apt-get install -y cmake gcc g++ git make python3 python3-pip wget unzip libusb-1.0-0 libsm6

# Download bluetooth-related stuff
docker container exec -it $container_id apt-get install bluez

echo 'Now hciconfig should work (if not, disable on host)'
hciconfig

echo 'Make sure it is up'
hciconfig hci0 up

echo 'Type the following command to start dbus (takes a while)'
echo /etc/init.d/dbus start

echo 'Test scanning (should work)'
hcitool lescan

echo 'The tool bluetoothctl is not working.'
