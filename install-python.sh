#! /usr/bin/env bash

set -e
set -x

version=3.10.9
NPROC=${NPROC:-`nproc --all | awk '{print ($1 - $1%3)*2/3}'`}

if [[ ! -d python-${version} ]]; then
    mkdir python-${version}
    cd python-${version}
    curl -O https://www.python.org/ftp/python/3.10.9/Python-${version}.tar.xz
    tar -xf ./Python-${version}.tar.xz
else
    cd python-${version}
fi

cd Python-${version}

./configure --prefix=/usr/local --enable-optimizations --enable-shared

make -j ${NPROC}

# Using make altinstall instead of make install avoids overwriting Python 3.8 with Python 3.9.
sudo make altinstall

#Do not know why otherwise won't find libpython.so
sudo ldconfig
