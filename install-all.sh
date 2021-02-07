#! /usr/bin/env bash

set -e
set -x

export NPROC=${NPROC:-4}

# ./build-llvm.sh
#
# # ## -flto required ld.gold, otherwise results in segmentation faults
# # # Set ld.gold as default
# # sudo rm /usr/bin/ld; sudo ln -s /usr/bin/x86_64-linux-gnu-ld.gold  /usr/bin/ld
# # # Restore ld.bfd
# # sudo rm /usr/bin/ld; sudo ln -s /usr/bin/x86_64-linux-gnu-ld.bfd  /usr/bin/ld
# if [ -x "$(command -v clang 2>/dev/null)" ]; then
#   export CC=clang
#   export CXX=clang++
#   export AR=llvm-ar
#   export RANLIB=llvm-ranlib
# fi

export CFLAGS='-O3 -fomit-frame-pointer -fstrict-aliasing -flto'
export CXXFLAGS='-O3 -fomit-frame-pointer -fstrict-aliasing -flto'
export LDFLAGS="-flto"

./install.sh

cd ../

if [[ ! -d ycmd ]]; then
    git clone https://github.com/ycm-core/ycmd.git
    cd ycmd
    git submodule update --init --recursive
else
    cd ycmd
fi

python3 build.py --clang-completer --go-completer --rust-completer --ts-completer

go get github.com/nsf/gocode
go get github.com/rogpeppe/godef

if node --version 2>&1 1>/dev/null; then
    cd ~/
    npm install prettier
else
    echo "Need to install latest node from https://nodejs.org/en/download/"
fi

cd ~/yuki

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
  git submodule update --init --recursive
else
  cd .emacs.d
  git pull
fi

./tools/install-prerequisits.sh

./tools/install-emacs.sh /opt/emacs

cd ~/yuki

if [[ ! -d keyboard-hook ]]; then
  git clone https://github.com/ChoppinBlockParty/keyboard-hook.git
  cd keyboard-hook
else
  cd keyboard-hook
  git pull
fi

./install.sh
