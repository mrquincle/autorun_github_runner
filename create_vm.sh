#!/bin/bash

usage="Usage: $0 <path> <name virtual machine> <name disk> <ubuntu iso> <user> <password>"

__cleanup()
{
	SIGNAL=$1

	echo ""
	echo "Usage:"
	echo "  <path>: path that will be used to write the disk and the vm to"
	echo "  <name virtual machine>: free to choose name for the VM"

	if [ -n "$SIGNAL" ]
	then
		trap $SIGNAL
		kill -${SIGNAL} $$
	fi
}

trap __cleanup EXIT

path=${1:? "$usage"}
vm=${2:? "$usage"}
disk=${3:? "$usage"}
iso=${4:? "$usage"}
user=${5:? "$usage"}
password=${6:? "$usage"}

# Only tested with
echo "Only tested with ubuntu-20.04.3-desktop-amd64.iso"

# Create a disk of 20 GB
disk_vdi="$path/$disk/$disk.vdi"
echo "Create disk of 20 GB at $disk_vdi"
vboxmanage createhd \
	--filename "$disk_vdi" \
	--format VDI \
	--size 20480

# Create a VM
echo "Create a vm at location $path and and name $vm"
vboxmanage createvm \
	--ostype Ubuntu_64 \
	--basefolder "$path" \
	--register \
	--name "$vm"

vboxmanage storagectl "$vm" \
	--name "SATA" \
	--add sata

vboxmanage storageattach "$vm" \
	--storagectl SATA \
	--port 0 \
	--type hdd \
	--medium "$disk_vdi"

echo "Insert $iso to virtual optical drive"
vboxmanage storageattach "$vm" \
	--storagectl SATA --port 15 --type dvddrive \
	--medium "$iso"

guest_additions_iso="/usr/share/virtualbox/VBoxGuestAdditions.iso"
echo "Only tested with $guest_additions_iso that comes with this Ubuntu distro"

# First we experimented with:
# --script-template="custom/ubuntu_preseed.cfg"
# It is written to /cdrom/preseed.cfg, but lot's of functions don't work.
# For example, package installation,
#   not by d-i pkgsel/include, nor by ubiquity ubiquity/success_command string.
# Using vboxpostinstall.sh is much more convenient.
# We use ./custom/debian_postinstall.sh
post_install_template="./custom/debian_postinstall.sh"

echo "Use host"
cat $post_install_template | grep ^HOST_IP
echo "The line above should not be empty (and same as e.g. hostname -I)"

vboxmanage unattended install "$vm" \
	--user=$user \
	--password=$password \
	--country=NL \
	--hostname=testserver.local \
	--iso="$iso" \
	--additions-iso="$guest_additions_iso" \
	--install-additions \
	--post-install-template="$post_install_template"

# Adjust memory and CPUs.
vboxmanage modifyvm "$vm" \
	--memory 2048 \
	--vram 256 \
	--graphicscontroller vmsvga \
	--cpus 2

echo "Set up normal NAT for the virtual machine"
vboxmanage modifyvm "${vm}" --nic1 NAT --nictype1 virtio

echo "Forward port 2222 on the host to 22 on the client"
vboxmanage modifyvm "$vm" --natpf1 "guestssh,tcp,,2222,,22"

echo "Done!"

echo "Call ./serve_contents.sh"

echo "And then ./start_vm.sh $vm"
