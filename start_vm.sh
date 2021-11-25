#!/bin/bash

usage="Usage: $0 <name virtual machine>"

vm=${1:? "$usage"}

echo "Make sure you also serve the userkey.pub if you run this for the first time"
echo "By ./serve_contents.sh"

vboxmanage startvm "$vm" --type headless

echo "You can probably see when the key is being served. Afterwards you can ssh into the VM"
echo "You can use the VirtualBox GUI if you run the VM locally to see the progress as well"
echo
echo "./ssh_into_vm.sh <ssh key>"
