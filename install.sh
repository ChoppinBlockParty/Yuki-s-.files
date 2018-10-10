#!/usr/bin/env bash
set -e
set +x

SCRIPT_DIR="$(realpath -s "$(dirname "$0")")"
INSTALL_PREFIX="${INSTALL_PREFIX:-`realpath -s $HOME`}"
BIN_INSTALL_PREFIX="$INSTALL_PREFIX/bin"

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

install_file "$SCRIPT_DIR/.zshrc"
install_file "$SCRIPT_DIR/.zlogin"
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
