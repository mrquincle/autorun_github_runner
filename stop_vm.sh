#!/bin/bash

usage="Usage: $0 <name virtual machine>"

vm=${1:? "$usage"}

vboxmanage controlvm "$vm" poweroff
