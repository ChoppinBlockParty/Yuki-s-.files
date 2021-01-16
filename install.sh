#! /usr/bin/env bash

set -e
set +x

sudo apt-get install -y --no-install-recommends \
                                   rxvt-unicode \
                                   zsh \
                                   zsh-common \
                                   tmux \
                                   curl \
                                   automake \
                                   cmake \
                                   libpcre3-dev \
                                   pkg-config \
                                   liblzma-dev \
                                   zlib1g-dev \
                                   xsel \
                                   htop \
                                   g++ \
                                   clang \
                                   clang-format \
                                   clang-tidy \
                                   clang-tools \
                                   make \
                                   golang-go \
                                   npm \
                                   python3-dev

SCRIPT_DIR="$(realpath -s "$(dirname "$0")")"
INSTALL_PREFIX="${INSTALL_PREFIX:-`realpath -s $HOME`}"
BIN_INSTALL_PREFIX="$INSTALL_PREFIX/bin"
FZF_VERSION=0.21.1
RG_VERSION=12.1.1
FD_VERSION=8.1.1

function install_file {
  local new_filepath="${2:-"$INSTALL_PREFIX"}/${3:-$(basename "$1")}"
  if [[ -f $new_filepath ]]; then
    if [[ $(realpath $new_filepath) = $1 ]]; then
      echo "  -- Does not install \"$1\": \"$new_filepath\" exists"
    else
      echo "  -- Failed to install \"$1\": file \"$new_filepath\" points to \"$(realpath "$new_filepath")\""
      exit 1
    fi
  else
    ln -fs "$1" "$new_filepath"
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

mkdir -p "$BIN_INSTALL_PREFIX"

curl -LO  'https://github.com/powerline/fonts/raw/master/Inconsolata-g/Inconsolata-g%20for%20Powerline.otf'
mkdir -p ~/.local/share/fonts
mv -f Inconsolata-g%20for%20Powerline.otf ~/.local/share/fonts/Inconsolata-g\ for\ Powerline.otf
sudo fc-cache -f

mkdir -p "$SCRIPT_DIR/.fzf-build"
cd "$SCRIPT_DIR/.fzf-build"
if [[ ! -f fzf.tgz ]]; then
  curl -L "https://github.com/junegunn/fzf-bin/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tgz" > fzf.tgz
fi
tar -xzf fzf.tgz
mv -f fzf "$BIN_INSTALL_PREFIX"

# mkdir -p "$SCRIPT_DIR/.ag-build"
# cd "$SCRIPT_DIR/.ag-build"
# clone_update_git_repo https://github.com/ggreer/the_silver_searcher
# if [[ ! -d "`pwd`/.install" ]]; then
#   make clean || true
#   ./autogen.sh
#   ./configure --prefix="`pwd`/.install"
#   make
#   make install
# fi
# cp -f "`pwd`/.install/bin/ag" "$BIN_INSTALL_PREFIX"

if [[ -x $(command -v dpkg) ]]; then
  mkdir -p "$SCRIPT_DIR/.rg-build"
  cd "$SCRIPT_DIR/.rg-build"
  if [[ ! -f rg.deb ]]; then
    curl -L "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb" > rg.deb
  fi
  sudo dpkg --install rg.deb

  mkdir -p "$SCRIPT_DIR/.fd-build"
  cd "$SCRIPT_DIR/.fd-build"
  if [[ ! -f fd.deb ]]; then
    curl -L "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb" > fd.deb
  fi
  sudo dpkg --install fd.deb
fi

mkdir -p "$INSTALL_PREFIX/.config/tmux"
cd "$INSTALL_PREFIX/.config/tmux"

clone_update_git_repo https://github.com/Morantron/tmux-fingers
cd - 1>/dev/null
clone_update_git_repo https://github.com/tmux-plugins/tmux-yank
cd - 1>/dev/null

install_file "$SCRIPT_DIR/.tmux.conf"

mkdir -p "$INSTALL_PREFIX/.cache/zsh"
mkdir -p "$INSTALL_PREFIX/.config/zsh"
cd "$INSTALL_PREFIX/.config/zsh"

clone_update_git_repo https://github.com/zsh-users/zsh-syntax-highlighting
cd - 1>/dev/null
clone_update_git_repo https://github.com/zsh-users/zsh-completions
cd - 1>/dev/null

install_file "$SCRIPT_DIR/.zlogin"
install_file "$SCRIPT_DIR/.zshrc"
install_file "$SCRIPT_DIR/.zshenv"
if [[ ! -f "$INSTALL_PREFIX/.zshrc_extra" ]]; then
  touch "$INSTALL_PREFIX/.zshrc_extra"
fi
if [[ ! -f "$INSTALL_PREFIX/.zshenv_extra" ]]; then
  touch "$INSTALL_PREFIX/.zshenv_extra"
fi
chsh -s /usr/bin/zsh yuki

mkdir -p "$INSTALL_PREFIX/.config/git"
cd "$INSTALL_PREFIX/.config/git"

clone_update_git_repo https://github.com/so-fancy/diff-so-fancy
install_file "`pwd`/diff-so-fancy" "$BIN_INSTALL_PREFIX"
cd - 1>/dev/null

install_file "$SCRIPT_DIR/.gitconfig"
install_file "$SCRIPT_DIR/.gitconfig_ignore"
if [[ ! -f "$INSTALL_PREFIX/.gitconfig_extra" ]]; then
  echo -n "  -- "
  cp -v "$SCRIPT_DIR/.gitconfig_extra" "$INSTALL_PREFIX/.gitconfig_extra"
fi

install_file "$SCRIPT_DIR/.clang-format"
install_file "$SCRIPT_DIR/.ignore"
install_file "$SCRIPT_DIR/.ignore" "$INSTALL_PREFIX" ".fdignore"
install_file "$SCRIPT_DIR/.Xresources"
install_file "$SCRIPT_DIR/.ycm_extra_conf.py"
