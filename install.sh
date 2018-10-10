#!/usr/bin/env bash
set -e
set +x

SCRIPT_DIR="$(realpath -s "$(dirname "$0")")"
INSTALL_PREFIX="${INSTALL_PREFIX:-`realpath -s $HOME`}"
BIN_INSTALL_PREFIX="$INSTALL_PREFIX/bin"
FZF_VERSION=0.17.5
RG_VERSION=0.10.0
FD_VERSION=7.1.0

export CC=clang-7
export CXX=clang++-7
export AR=llvm-ar-7
export RANLIB=llvm-ranlib-7
export CFLAGS='-O3 -fomit-frame-pointer -fstrict-aliasing -flto -pthread'
export CXXFLAGS='-O3 -fomit-frame-pointer -fstrict-aliasing -flto -pthread'
export LDFLAGS='-flto -pthread'

function install_file {
  local new_filepath="${2:-"$INSTALL_PREFIX"}/$(basename "$1")"
  if [[ -f $new_filepath ]]; then
    if [[ $(realpath $new_filepath) = $1 ]]; then
      echo "  -- Does not install \"$1\": \"$new_filepath\" exists"
    else
      echo "  -- Failed to install \'$1\': file \"$new_filepath\" points to\" $(realpath "$new_filepath")\""
      exit 1
    fi
  else
    ln -s "$1" "$new_filepath"
    echo "  -- Install \"$1\" to \"$new_filepath\""
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
  git pull origin
  echo "  -- Update \"$1\", branch $branch"
}

mkdir -p "$BIN_INSTALL_PREFIX"

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
  ./autoge
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
cd -
clone_update_git_repo https://github.com/tmux-plugins/tmux-yank
cd -

install_file "$SCRIPT_DIR/.tmux.conf"

mkdir -p "$INSTALL_PREFIX/.cache/zsh"
mkdir -p "$INSTALL_PREFIX/.config/zsh"
cd "$INSTALL_PREFIX/.config/zsh"

clone_update_git_repo https://github.com/zsh-users/zsh-syntax-highlighting
cd -
clone_update_git_repo https://github.com/zsh-users/zsh-completions
cd -

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
cd -

install_file "$SCRIPT_DIR/.gitconfig"
install_file "$SCRIPT_DIR/.gitconfig_ignore"

install_file "$SCRIPT_DIR/.clang-format"
install_file "$SCRIPT_DIR/.ignore"
install_file "$SCRIPT_DIR/.Xresources"
install_file "$SCRIPT_DIR/.ycm_extra_conf.py"
