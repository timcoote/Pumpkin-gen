#!/bin/bash -ex
pip3 install netifaces
pip3 install PyDispatcher==2.0.5
pip3 install six
#pip3 install urwid==1.1.1
#pip3 install python_openzwave --install-option="--flavor=embed_shared"
#pip3 -vvvv install --use-wheel  --find-links=https://s3.eu-west-2.amazonaws.com:443/pumpco/index.html python_openzwave
# this doesn't work: reworking to establish why
pip3 install python-openzwave==0.4.18
# overridden, anyway? pip3 -vvvv install --use-wheel  --find-links=https://s3.eu-west-2.amazonaws.com:443/pumpco/index.html urwid
ln -sf /usr/local/lib/python3.5/dist-packages/python_openzwave/ozw_config /usr/local/etc/openzwave

pip3 install pika
# pip3 install yeelight

# currently has to be after pip3 installation as pre.sh uses it
# 2019-11-18: AMONIS, uncommneted. 2019-10-29: mtc temp removal to get the card to build
# remove again to shrink dependencies - 2022-8-15: mtc
# apt install -y bcg-presenceservice

# AMONIS: 14/06/2018: NPM test
# The test proved successful and built image image_1.37-1.37.dev8-4GB.zip ( in the bucket )
# Commented now for reference 
# echo "NPM Install global components"
# node -v
# npm -v
# npm config set unsafe-perm true
# npm install uglify-js -g

