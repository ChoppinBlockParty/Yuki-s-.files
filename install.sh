#!/usr/bin/env bash
set -e
set +x

SCRIPT_DIR="$(realpath -s "$(dirname "$0")")"
INSTALL_PREFIX="${INSTALL_PREFIX:-`realpath -s $HOME`}"
BIN_INSTALL_PREFIX="$INSTALL_PREFIX/bin"
FZF_VERSION=0.17.5
RG_VERSION=0.10.0
FD_VERSION=7.1.0

function export_clang_toolchain {
  export CC=clang-7
  export CXX=clang++-7
  export AR=llvm-ar-7
  export RANLIB=llvm-ranlib-7
  export CFLAGS='-O3 -fomit-frame-pointer -fstrict-aliasing -flto -pthread'
  export CXXFLAGS='-O3 -fomit-frame-pointer -fstrict-aliasing -flto -pthread'
  export LDFLAGS='-flto -pthread'
  sudo rm /usr/bin/ld; sudo ln -s /usr/bin/x86_64-linux-gnu-ld.gold  /usr/bin/ld
  # FIXME: Find a way to make it automatically
  # sudo rm /usr/bin/ld; sudo ln -s /usr/bin/x86_64-linux-gnu-ld.bfd  /usr/bin/ld
}

function install_file {
  local new_filepath="${2:-"$INSTALL_PREFIX"}/$(basename "$1")"
  if [[ -f $new_filepath ]]; then
    if [[ $(realpath $new_filepath) = $1 ]]; then
      echo "  -- Does not install \"$1\": \"$new_filepath\" exists"
    else
      echo "  -- Failed to install \"$1\": file \"$new_filepath\" points to \"$(realpath "$new_filepath")\""
      exit 1
    fi
  else
    ln -s "$1" "$new_filepath"
    echo "  -- Install \"$1\" to \"$new_filepath\""
  fi
}

function install_dir {
  local new_dirpath="${2:-"$INSTALL_PREFIX"}/$(basename "$1")"
  if [[ -d $new_dirpath ]]; then
    if [[ $(realpath $new_dirpath) = $1 ]]; then
      echo "  -- Does not install \"$1\": \"$new_dirpath\" exists"
    else
      echo "  -- Failed to install \"$1\": file \"$new_dirpath\" points to \"$(realpath "$new_dirpath")\""
      exit 1
    fi
  else
    ln -s "$1" "$(dirname $new_dirpath)"
    echo "  -- Install \"$1\" to \"$new_dirpath\""
  fi
}

function clone_update_git_repo {
  local new_dirpath="`pwd`/$(basename "$1")"
  if [[ -d $new_dirpath ]]; then
    echo "  -- Does not clone \"$1\": \"$new_path\" exists"
  else
    git clone "$1"
    echo "  -- Cloned \"$1\" to \"$new_path\""
  fi
  local branch="${2:-master}"
  cd "$new_dirpath"
  git checkout "$branch"
  # FIXME: if `branch` is a tag, pull fails
  git pull origin || true
  git submodule update --recursive --init
  echo "  -- Update \"$1\", branch $branch"
}

mkdir -p "$BIN_INSTALL_PREFIX"


# {{{ awesome build
# mkdir -p "$SCRIPT_DIR/.xcb-util-xrm-build"
# cd "$SCRIPT_DIR/.xcb-util-xrm-build"
# clone_update_git_repo https://github.com/Airblader/xcb-util-xrm
# if [[ ! -d "`pwd`/.install" ]]; then
#   make clean || true
#   ./autogen.sh
#   ./configure --prefix="`pwd`/.install" --enable-shared=no --enable-static=yes
#   make
#   make install
# fi

# sudo apt-get -y install --no-install-recommends \
#        lua5.2 \
#        liblua5.2-dev \
#        lua-lgi-dev \
#        asciidoctor \
#        libxcb-cursor-dev \
#        libxcb-randr0-dev \
#        libxcb-xtest0-dev \
#        libxcb-xinerama0-dev \
#        libxcb-util-dev \
#        libxcb-keysyms1-dev \
#        libxcb-icccm4-dev \
#        libxcb-shape0-dev \
#        libxcb-xkb-dev \
#        libxkbcommon-x11-dev \
#        libstartup-notification0-dev \
#        libxdg-basedir-dev

# mkdir -p "$SCRIPT_DIR/.awesome-build"
# cd "$SCRIPT_DIR/.awesome-build"
# clone_update_git_repo https://github.com/awesomeWM/awesome

# if [[ ! -d "`pwd`/.install" ]]; then
#   rm -rf .build 2 > /dev/null || true
#   mkdir .build
#   cd .build
#   export PKG_CONFIG_PATH="$SCRIPT_DIR/.xcb-util-xrm-build/xcb-util-xrm/.install/lib/pkgconfig"
#   cmake -GNinja \
#         -DCMAKE_INSTALL_PREFIX="`pwd`/../.install" \
#         -DCMAKE_BUILD_TYPE=Release \
#         -DCMAKE_PREFIX_PATH="$SCRIPT_DIR/.xcb-util-xrm-build/xcb-util-xrm/.install/lib/pkgconfig" \
#         ../
#   ninja
#   ninja install
#   cd -
# fi
# cp -f "`pwd`/.install/bin/awesome" "`pwd`/.install/bin/awesome-client" "$BIN_INSTALL_PREFIX"
# }}} awesome build

export_clang_toolchain

mkdir -p "$SCRIPT_DIR/.fzf-build"
cd "$SCRIPT_DIR/.fzf-build"
if [[ ! -f fzf.tgz ]]; then
  curl -L "https://github.com/junegunn/fzf-bin/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tgz" > fzf.tgz
fi
tar -xzf fzf.tgz
mv -f fzf "$BIN_INSTALL_PREFIX"

mkdir -p "$SCRIPT_DIR/.rg-build"
cd "$SCRIPT_DIR/.rg-build"
if [[ ! -f rg.deb ]]; then
  curl -L "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb" > rg.deb
fi
sudo dpkg --install rg.deb

mkdir -p "$SCRIPT_DIR/.ag-build"
cd "$SCRIPT_DIR/.ag-build"
clone_update_git_repo https://github.com/ggreer/the_silver_searcher
if [[ ! -d "`pwd`/.install" ]]; then
  make clean || true
  ./autogen.sh
  ./configure --prefix="`pwd`/.install"
  make
  make install
fi
cp -f "`pwd`/.install/bin/ag" "$BIN_INSTALL_PREFIX"

mkdir -p "$SCRIPT_DIR/.fd-build"
cd "$SCRIPT_DIR/.fd-build"
if [[ ! -f fd.deb ]]; then
  curl -L "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb" > fd.deb
fi
sudo dpkg --install fd.deb

mkdir -p "$INSTALL_PREFIX/.config/tmux"
cd "$INSTALL_PREFIX/.config/tmux"

clone_update_git_repo https://github.com/Morantron/tmux-fingers
cd - 1 > /dev/null
clone_update_git_repo https://github.com/tmux-plugins/tmux-yank
cd - 1 > /dev/null

install_file "$SCRIPT_DIR/.tmux.conf"

mkdir -p "$INSTALL_PREFIX/.cache/zsh"
mkdir -p "$INSTALL_PREFIX/.config/zsh"
cd "$INSTALL_PREFIX/.config/zsh"

clone_update_git_repo https://github.com/zsh-users/zsh-syntax-highlighting
cd - 1 > /dev/null
clone_update_git_repo https://github.com/zsh-users/zsh-completions
cd - 1 > /dev/null

install_file "$SCRIPT_DIR/.zlogin"
install_file "$SCRIPT_DIR/.zshrc"
install_file "$SCRIPT_DIR/.zshenv"
if [[ ! -f "$INSTALL_PREFIX/.extra_aliases" ]]; then
  touch "$INSTALL_PREFIX/.extra_aliases"
fi

mkdir -p "$INSTALL_PREFIX/.config/git"
cd "$INSTALL_PREFIX/.config/git"

clone_update_git_repo https://github.com/so-fancy/diff-so-fancy
install_file "`pwd`/diff-so-fancy" "$BIN_INSTALL_PREFIX"
cd - 1 > /dev/null

install_file "$SCRIPT_DIR/.gitconfig"
install_file "$SCRIPT_DIR/.gitconfig_ignore"

install_file "$SCRIPT_DIR/.clang-format"
install_file "$SCRIPT_DIR/.ignore"
install_file "$SCRIPT_DIR/.Xresources"
install_file "$SCRIPT_DIR/.ycm_extra_conf.py"
install_dir "$SCRIPT_DIR/awesome" "$INSTALL_PREFIX/.config"
