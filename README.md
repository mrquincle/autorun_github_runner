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

# Workflow

## Configure VM

```
USER=...
PASSWORD=...
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
./create_vm --path ~/virtualbox --virtual-machine-name github-action-runner --disk-name github-action-disk --iso-file ~/virtualbox/ubuntu-20.04.3-desktop-amd64.iso --user $USER --password $PASSWORD
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
./ssh_into_vm --key ~/.ssh/virtualmachine/id_rsa256 --user $USER
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

# Copyright

Author: A.C. van Rossum
