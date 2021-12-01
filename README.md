# Intro

Automatically does the following:

* Set up a virtual machine using VirtualBox including disk (of 20 GB).
* Run a python server to be able to serve a public SSH key.
* Configure `debian_postinstall.sh` which will be present on the virtual optical drive to set up SSH access.

# Prequisites

Install virtualbox, guest additions, python, and jq.

```
sudo apt install virtualbox virtualbox-guest-additions-iso
sudo apt install python
sudo apt install jq
```

Configure user

```
sudo adduser $USER vboxusers
newgrp vboxusers
```

# Workflow

## Configure VM

```
VM_USER=...
VM_PASSWORD=...
mkdir -p ~/virtualbox
```

Get Ubuntu 20.04 (desktop edition!)

```
cd ~/virtualbox
wget https://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-desktop-amd64.iso
```

Navigate back to this repository and configure a VM.

First edit `custom/debian_postinstall.sh` and replace `HOST_IP` with the IP of your machine.
Use `ip a` to see the IP of your machine.

```
./create_vm --path ~/virtualbox --virtual-machine-name github-action-runner --disk-name github-action-disk --iso-file ~/virtualbox/ubuntu-20.04.3-desktop-amd64.iso --user $VM_USER --password $VM_PASSWORD
```

Check if HOST is set correctly (in the logs)! If not, just run:

```
./delete_vm --virtual-machine-name github-action-runner
```

And run `create_vm` again.

Generate SSH key for the virtual machine and serve it through python

```
mkdir -p ~/.ssh/virtualmachine
ssh-keygen -t rsa -f ~/.ssh/virtualmachine/id_rsa256
./serve_contents --key ~/.ssh/virtualmachine/id_rsa256.pub
```

Start the VM

```
./start_vm --virtual-machine-name github-action-runner
```

Get a token for the action runner:

```
GITHUB_USER=
GITHUB_USER_TOKEN=
GITHUB_ORGANISATION=crownstone
GITHUB_REPOSITORY=bluenet
./get_runner_token --user $GITHUB_USER --user-token $GITHUB_USER_TOKEN --organisation $GITHUB_ORGANISATION --repository $GITHUB_REPOSITORY
RUNNER_TOKEN=
```

Warning! You can also get tokens for the organisation, make sure you get one for the repository. If everything fails, just navigate to your repository similar to <https://github.com/crownstone/bluenet/settings/actions/runners/new> and copy the token from there.

Copy files to the VM:

```
./setup_runner --key ~/.ssh/virtualmachine/id_rsa256 --user crown --runner-name 'UbuntuDocker' --github 'https://github.com/crownstone/bluenet' --labels 'self-hosted, Linux, X64' --token $RUNNER_TOKEN
```

SSH into the VM

```
./ssh_into_vm --key ~/.ssh/virtualmachine/id_rsa256 --user $VM_USER
```

## On the VM itself, install docker

Now install docker in the VM

```
cd custom
./docker.sh
```

Run docker

```
cd docker
docker-compose up
```

It probably took too long for the key above. Just run `get_runner_token` again to get a new key on your host computer.

It might be that you need some additional magic here. Here we can download some more stuff for the docker (make sure it is up).

```
cd custom
./docker_postinstall.sh
```

There is still a bit to be figured out to have a Nordic development kit attached to it and working flawlessly, but we're almost there!

To stop everything:

```
docker-compose down
```

Exit VM and:

```
./stop_vm --virtual-machine-name github-action-runner
```

## Extras

It might be the case that you want USB access in your VM. Type on your host:

```
vboxmanage list usbhost
```

This should give a list. If not, check if you've executed the commands about the `vboxusers` group at the start.

Now, check the UUIDs and attach a USB device, say with something like:

```
vboxmanage controlvm "github-action-runner" usbattach cc4cf1d7-df03-4920-834b-9c3ac98ad6bb
```

This would maybe add a device to `lsusb`. In my case:

```
Bus 001 Device 002: ID 04ca:3015 Lite-On Technology Corp.
```

And suddenly `hciconfig` starts working. Yes. We have bluetooth now as well:

```
bluetoothctl

Agent registered
[CHG] Controller 98:22:EF:85:0E:62 Pairable: yes
```

You can to the same with e.g. the Segger JLink device. Add it with the `usbattach` command while the VM is running.

# Copyright

Author: A.C. van Rossum
