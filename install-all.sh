#! /usr/bin/env bash

set -e
set -x

./build-llvm.sh
./install.sh

cd ../

if [[ ! -d dwm ]]; then
  git clone https://github.com/choppinblockparty/yuki-s-dwm dwm
  cd dwm
else
  cd dwm
  git pull
fi

./install.sh

cd ~

if [[ ! -d .emacs.d ]]; then
  git clone https://github.com/choppinblockparty/yuki-s-.emacs.d .emacs.d
  cd .emacs.d
else
  cd .emacs.d
  git pull
fi

./tools/install-prerequisits.sh

./tools/build-emacs.sh /opt

# for now disable, have troubles finding why the system startup fails
exit 0

sudo cp -f etc/startup-service.sh  /etc
sudo cp -f etc/startup.service /etc/systemd/system
sudo systemctl enable startup
sudo systemctl start startup
