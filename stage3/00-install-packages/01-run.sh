#!/bin/bash -ex

pwd
ls -l

on_chroot << EOF
dpkg --print-architecture
#echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
apt update
apt install -y ansible
cd /pi-gen/smart-home
ls -l
ansible --version
free
ANSIBLE_KEEP_REMOTE_FILES=1
ansible-playbook -vvvvv -i 'localhost ansible_connection=local,' site.yml

EOF
