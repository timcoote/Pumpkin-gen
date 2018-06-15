#!/bin/bash -ex
pip3 install netifaces
pip3 install PyDispatcher==2.0.5
pip3 install six
#pip3 install urwid==1.1.1
#pip3 install python_openzwave --install-option="--flavor=embed_shared"
#pip3 -vvvv install --use-wheel  --find-links=https://s3.eu-west-2.amazonaws.com:443/pumpco/index.html python_openzwave
# this doesn't work: reworking to establish why
pip3 install python-openzwave==0.4.4
# overridden, anyway? pip3 -vvvv install --use-wheel  --find-links=https://s3.eu-west-2.amazonaws.com:443/pumpco/index.html urwid
ln -sf /usr/local/lib/python3.5/dist-packages/python_openzwave/ozw_config /usr/local/etc/openzwave

pip3 install pika
pip3 install yeelight

# AMONIS: 14/06/2018: NPM test
echo "NPM Install global components"
node -v
npm -v
npm config set unsafe-perm true
npm install uglify-js -g