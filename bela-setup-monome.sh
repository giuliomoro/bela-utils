#!/bin/bash

# Install all that is required to use a monome device on a vanilla bela board,
# start the serialosc daemon on boot using systemd.
# Requires an internet connection to use apt and git.

sudo apt install libudev-dev liblo-dev libavahi-compat-libdnssd-dev

git clone https://github.com/monome/libmonome.git
cd libmonome
./waf configure
./waf
sudo ./waf install
cd ..

git clone https://github.com/monome/serialosc.git
cd serialosc
git submodule init
git submodule update
./waf configure
./waf
sudo ./waf install
cd ..
ldconfig

cat << EOF > serialoscd.service
[Unit]
Description=serialosc daemon
[Service]
Type=simple
ExecStart=/usr/local/bin/serialoscd
PIDFile=/var/run/serialoscd.pid
RemainAfterExit=no
Restart=on-failure
RestartSec=5s
[Install]
WantedBy=multi-user.target
EOF

mv serialoscd.service /lib/systemd/system/serialoscd.service
systemctl enable serialoscd
systemctl start serialoscd
