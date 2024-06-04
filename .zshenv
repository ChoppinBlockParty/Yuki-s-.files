SCRIPT_DIR="$HOME"

export BROWSER='brave-browser'
export EDITOR='setsid emacsclient -a "" -c'
export VISUAL='setsid emacsclient -a "" -c'
if [[ $(uname) == "Darwin" ]]; then
    eval $(/opt/homebrew/bin/brew shellenv)
    export PATH="/Applications/Emacs.app/Contents/MacOS/bin:$PATH"
else
    export PATH="$HOME/.local/bin:$HOME/bin:$HOME/node_modules/.bin:$PATH"
fi
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

export GO111MODULE=on

source "$SCRIPT_DIR/.zshenv_extra"
