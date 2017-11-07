pip3 install PyDispatcher==2.0.5
pip3 install six
#pip3 install urwid==1.1.1
#pip3 install python_openzwave --install-option="--flavor=embed_shared"
pip3 -vvvv install --use-wheel  --find-links=https://s3.eu-west-2.amazonaws.com:443/pumpco/index.html python_openzwave
pip3 -vvvv install --use-wheel  --find-links=https://s3.eu-west-2.amazonaws.com:443/pumpco/index.html urwid
ln -sf /usr/local/lib/python3.5/dist-packages/python_openzwave/ozw_config /usr/local/etc/openzwave
