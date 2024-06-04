#! /usr/bin/env bash

set -e
set -x

SCRIPT_DIR="$(realpath $(realpath "$(dirname "$0")")/..)"
INSTALL_PREFIX="${INSTALL_PREFIX:-`realpath $HOME`}"
BIN_INSTALL_PREFIX="$INSTALL_PREFIX/bin"

mkdir -p ${SCRIPT_DIR}/temp

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

inconsolate_path="~/.local/share/fonts/Inconsolata-g\ for\ Powerline.otf"
if [ ! -f ${inconsolata_path} ]; then
    curl -LO  'https://github.com/powerline/fonts/raw/master/Inconsolata-g/Inconsolata-g%20for%20Powerline.otf'
    mkdir -p ~/.local/share/fonts
    mv -f Inconsolata-g%20for%20Powerline.otf ${inconsolate_path}
    sudo fc-cache -f
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
install_file "$SCRIPT_DIR/.alacritty.toml"
if [[ ! -f "$INSTALL_PREFIX/.zshrc_extra" ]]; then
  touch "$INSTALL_PREFIX/.zshrc_extra"
fi
if [[ ! -f "$INSTALL_PREFIX/.zshenv_extra" ]]; then
  touch "$INSTALL_PREFIX/.zshenv_extra"
fi

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
