#! /usr/bin/env bash

set -e
set -x

sudo -E apt-get install --no-install-recommends -y binutils-dev cmake make g++

# Sometimes fails if not set.
`ulimit -n | grep -q "65535"` || ulimit -n 65535
sudo ln -sf /usr/bin/x86_64-linux-gnu-ld.gold /usr/bin/x86_64-linux-gnu-ld

SCRIPT_DIR="$(realpath -s "$(dirname "$0")")"
BRANCH=${1:-release/15.x}
NPROC=${NPROC:-`nproc --all | awk '{print ($1 - $1%3)*2/3}'`}

function clone_update_git_repo {
  local new_dirpath="`pwd`/$(basename "$1" | sed s/\.git$//)"
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

clone_update_git_repo https://github.com/llvm/llvm-project.git $BRANCH

cd "$SCRIPT_DIR/llvm-project"
mkdir -p .build
cd .build
### Need `-DLLVM_USE_LINKER=gold` to enable `-flto` flag
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DLLVM_USE_LINKER=gold -DLLVM_BINUTILS_INCDIR=/usr/include -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" ../llvm
make -j $NPROC
sudo make install

ld_conf_file=/etc/ld.so.conf.d/my-usr-local.conf
if ! grep -q '^/usr/local/lib$' ${ld_conf_file} 2>/dev/null; then
    echo "/usr/local/lib" | sudo tee ${ld_conf_file}
fi

sudo ldconfig
