SCRIPT_DIR="$HOME"

export PATH="$HOME/.local/bin:$HOME/bin:$HOME/node_modules/.bin:$PATH"
export BROWSER='brave-browser'
export EDITOR='setsid emacs'
export VISUAL='setsid emacs'
export PAGER='less'
export FZF_DEFAULT_OPTS="--bind=ctrl-j:down,ctrl-k:up,alt-j:down,alt-k:up,ctrl-s:kill-line"
export FZF_DEFAULT_COMMAND='fd --hidden --no-ignore-vcs --color never --type f'

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi
if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

# Start the gpg-agent if not already running
if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
  gpg-connect-agent /bye >/dev/null 2>&1
fi

source "$SCRIPT_DIR/.zshenv_extra"
