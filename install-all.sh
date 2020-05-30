#! /usr/bin/env bash

set -e

./build-llvm.sh
./install.sh

git clone git@github.com:choppinblockparty/yuki-s-dwm dwm

yuki-s-dwm

./install.sh

# for now disable, have troubles finding why the system startup fails
exit 0

sudo cp -f etc/startup-service.sh  /etc
sudo cp -f etc/startup.service /etc/systemd/system
sudo systemctl enable startup
sudo systemctl start startup
