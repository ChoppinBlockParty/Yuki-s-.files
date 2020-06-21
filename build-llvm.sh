#! /usr/bin/env bash

set -e
set +x

sudo apt-get install --no-install-recommends -y binutils-dev cmake make g++

sudo ln -sf /usr/bin/x86_64-linux-gnu-ld.gold /usr/bin/x86_64-linux-gnu-ld

SCRIPT_DIR="$(realpath -s "$(dirname "$0")")"
BRANCH=release_70

function clone_update_git_repo {
  local new_dirpath="`pwd`/$(basename "$1")"
  if [[ -d $new_dirpath ]]; then
    echo "  -- Does not clone \"$1\": \"$new_dirpath\" exists"
  else
    git clone "$1"
    echo "  -- Cloned \"$1\" to \"$new_dirpath\""
  fi
  local branch="${2:-master}"
  cd "$new_dirpath"
  git checkout "$branch"
  # FIXME: if `branch` is a tag, pull fails
  git pull origin || true
  git submodule update --recursive --init
  echo "  -- Update \"$1\", branch $branch"
}

clone_update_git_repo https://github.com/llvm-mirror/llvm $BRANCH

cd "$SCRIPT_DIR/llvm/tools"
clone_update_git_repo https://github.com/llvm-mirror/clang $BRANCH

cd "$SCRIPT_DIR/llvm/tools/clang/tools"
clone_update_git_repo https://github.com/llvm-mirror/clang-tools-extra $BRANCH

### Checkout LLD linker [Optional]:
# cd "$SCRIPT_DIR/llvm/tools"
# clone_update_git_repo https://github.com/llvm-mirror/lld

### Checkout Polly Loop Optimizer [Optional]:
# cd "$SCRIPT_DIR/llvm/tools"
# svn co http://llvm.org/svn/llvm-project/polly/trunk polly

### Checkout Compiler-RT (required to build the sanitizers) [Optional]:
cd "$SCRIPT_DIR/llvm/projects"
clone_update_git_repo https://github.com/llvm-mirror/compiler-rt $BRANCH

### Checkout Libomp (required for OpenMP support) [Optional]:
# cd "$SCRIPT_DIR/llvm/projects"
# svn co http://llvm.org/svn/llvm-project/openmp/trunk openmp

### Checkout libcxx and libcxxabi [Optional]:
# cd "$SCRIPT_DIR/llvm/projects"
# svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx
# svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk libcxxabi

### Get the Test Suite Source Code [Optional]
# cd "$SCRIPT_DIR/llvm/projects"
# svn co http://llvm.org/svn/llvm-project/test-suite/trunk test-suite

cd "$SCRIPT_DIR/llvm"
mkdir -p .build
cd .build
### Need `-DLLVM_USE_LINKER=gold` to enable `-flto` flag
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DLLVM_USE_LINKER=gold -DLLVM_BINUTILS_INCDIR=/usr/include ../
make -j $NPROC
sudo make install

echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/my-usr-local.conf
sudo ldconfig
