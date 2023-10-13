#! /usr/bin/env bash

set -e
set -x

cd ../

if [[ ! -d ycmd ]]; then
    git clone https://github.com/ycm-core/ycmd.git
    cd ycmd
    git submodule update --init --recursive
else
    cd ycmd
    git pull origin
fi

go version
go install github.com/nsf/gocode@latest
go install github.com/rogpeppe/godef@latest
# Does not work on go below 1.16
# go get golang.org/x/tools/gopls

python3 build.py --clang-completer --go-completer
