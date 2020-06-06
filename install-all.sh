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

./tools/install-emacs.sh /opt

cd ~/yuki

if [[ ! -d keyboard-hook ]]; then
  git clone https://github.com/ChoppinBlockParty/keyboard-hook.git
  cd keyboard-hook
else
  cd keyboard-hook
  git pull
fi

./install.sh
