SCRIPT_DIR="$HOME"
CACHE_PREFIX="$HOME/.cache/zsh"
CONFIG_PREFIX="$HOME/.config/zsh"

###############################################################################
# Exports
###############################################################################
# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path
# Set the list of directories that Zsh searches for programs.
path=(
  /usr/local/{bin,sbin}
  $path
)
# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -w -X -z-4'
# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
export LESSOPEN='| pygmentize -f terminal256 -O style=native -g %s'

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
fi
TMPPREFIX="${TMPDIR%/}/zsh"

# ZSH ZLE reference, very handy
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html

# Options
setopt AUTO_CD              # Auto changes to a directory without typing cd.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given.
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt AUTO_NAME_DIRS       # Auto add variable-stored paths to ~ list.
setopt MULTIOS              # Write to multiple descriptors.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
unsetopt CLOBBER            # Do not overwrite existing files with > and >>.
# Aliases
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

#Enable vim
#When ZLE is reading a command from the terminal, it may read a sequence that is bound to some command and is also a prefix of a longer bound string. In this case ZLE will wait a certain time to see if more characters are typed, and if not (or they don't match any longer string) it will execute the binding. This timeout is defined by the KEYTIMEOUT parameter; its default is 0.4 sec. There is no timeout if the prefix string is not itself bound to a command.
# for vi <esc> hit to happen in 0.1s instead of 0.4s
export KEYTIMEOUT=1
bindkey -v
# Fixes backspace after vim mode
# https://superuser.com/questions/476532/how-can-i-make-zshs-vi-mode-behave-more-like-bashs-vi-mode/533685#533685
bindkey "^?" backward-delete-char

# autoload -U edit-command-line
# zle -N edit-command-line
bindkey "^Q" vi-beginning-of-line
bindkey "^A" vi-beginning-of-line
bindkey "^E" vi-end-of-line
# bindkey "^E" edit-command-line
# bindkey "^K" push-input
bindkey "^W" backward-kill-word

autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Enable completion
fpath=("$CONFIG_PREFIX/zsh-completions/src" $fpath)
autoload -U compinit && compinit
unsetopt CASE_GLOB
setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
setopt ALWAYS_TO_END       # Move cursor to the end of a completed word.
setopt PATH_DIRS           # Perform path search even on command names with slashes.
setopt AUTO_MENU           # Show completion menu on a successive tab press.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH    # If completed parameter is a directory, add a trailing slash.
unsetopt MENU_COMPLETE     # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL      # Disable start/stop characters in shell editor.
# Styles
# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$CACHE_PREFIX/.zcompcache"
# Case-insensitive (all), partial-word, and then substring completion.
# zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# setopt CASE_GLOB
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
unsetopt CASE_GLOB
# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
# Fuzzy match mistyped completions.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
# Increase the number of errors based on the length of the typed word. But make
# sure to cap (at 7) the max-errors to avoid hanging.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'
# Don't complete unavailable commands.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
# Directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true
# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes
# Environmental Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}
# Populate hostname completion.
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'
# Don't complete uninteresting users...
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
  dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
  hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
  mailman mailnull mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
  operator pcap postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'
# ... unless we really want to.
zstyle '*' single-ignored show
# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'
# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single
# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
# Media Players
zstyle ':completion:*:*:mpg123:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mocp:*' file-patterns '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):ogg\ files *(-/):directories'
# Mutt
if [[ -s "$HOME/.mutt/aliases" ]]; then
  zstyle ':completion:*:*:mutt:*' menu yes select
  zstyle ':completion:*:mutt:*' users ${${${(f)"$(<"$HOME/.mutt/aliases")"}#alias[[:space:]]}%%[[:space:]]*}
fi
# SSH/SCP/RSYNC
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# autoload -Uz promptinit && promptinit
# prompt 'my'
function setup_my_prompt {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  # http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Prompt-Expansion
  # Define prompts.
  PROMPT='%F{81}%~%f%(!. %B%F{red}#%f%b.)
%F{81}▶%f'
  # RPROMPT='%(?.%B%F{81}:)%f%b.%B%F{81}D:%f%b)'
  RPROMPT=
  # SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
}
setup_my_prompt

# By default, ^S freezes terminal output and ^Q resumes it. Disable that so
# that those keys can be used for other things.
unsetopt flowcontrol

#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/-completion.zsh
#
# - $FZF_TMUX               (default: 0)
# - $FZF_TMUX_HEIGHT        (default: '40%')
# - $FZF_COMPLETION_TRIGGER (default: '**')
# - $FZF_COMPLETION_OPTS    (default: empty)

# To use custom commands instead of find, override _fzf_compgen_{path,dir}
if ! declare -f _fzf_compgen_path > /dev/null; then
  _fzf_compgen_path() {
    echo "$1"
    command find -L "$1" \
      -name .git -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) \
      -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
  }
fi

if ! declare -f _fzf_compgen_dir > /dev/null; then
  _fzf_compgen_dir() {
    command find -L "$1" \
      -name .git -prune -o -name .svn -prune -o -type d \
      -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
  }
fi

###########################################################

__fzfcmd_complete() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

__fzf_generic_path_completion() {
  local base lbuf compgen fzf_opts suffix tail fzf dir leftover matches
  base=$1
  lbuf=$2
  compgen=$3
  fzf_opts=$4
  suffix=$5
  tail=$6
  fzf="$(__fzfcmd_complete)"

  setopt localoptions nonomatch
  eval "base=$base"
  [[ $base = *"/"* ]] && dir="$base"
  while [ 1 ]; do
    if [[ -z "$dir" || -d ${dir} ]]; then
      leftover=${base/#"$dir"}
      leftover=${leftover/#\/}
      [ -z "$dir" ] && dir='.'
      [ "$dir" != "/" ] && dir="${dir/%\//}"
      matches=$(eval "$compgen $(printf %q "$dir")" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_COMPLETION_OPTS" ${=fzf} ${=fzf_opts} -q "$leftover" | while read item; do
        echo -n "${(q)item}$suffix "
      done)
      matches=${matches% }
      if [ -n "$matches" ]; then
        LBUFFER="$lbuf$matches$tail"
      fi
      zle redisplay
      typeset -f zle-line-init >/dev/null && zle zle-line-init
      break
    fi
    dir=$(dirname "$dir")
    dir=${dir%/}/
  done
}

_fzf_path_completion() {
  __fzf_generic_path_completion "$1" "$2" _fzf_compgen_path \
    "-m" "" " "
}

_fzf_dir_completion() {
  __fzf_generic_path_completion "$1" "$2" _fzf_compgen_dir \
    "" "/" ""
}

_fzf_feed_fifo() (
  command rm -f "$1"
  mkfifo "$1"
  cat <&0 > "$1" &
)

_fzf_complete() {
  local fifo fzf_opts lbuf fzf matches post
  fifo="${TMPDIR:-/tmp}/fzf-complete-fifo-$$"
  fzf_opts=$1
  lbuf=$2
  post="${funcstack[2]}_post"
  type $post > /dev/null 2>&1 || post=cat

  fzf="$(__fzfcmd_complete)"

  _fzf_feed_fifo "$fifo"
  matches=$(cat "$fifo" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_COMPLETION_OPTS" ${=fzf} ${=fzf_opts} -q "${(Q)prefix}" | $post | tr '\n' ' ')
  if [ -n "$matches" ]; then
    LBUFFER="$lbuf$matches"
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  command rm -f "$fifo"
}

_fzf_complete_telnet() {
  _fzf_complete '+m' "$@" < <(
    command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0' |
        awk '{if (length($2) > 0) {print $2}}' | sort -u
  )
}

_fzf_complete_ssh() {
  _fzf_complete '+m' "$@" < <(
    command cat <(cat ~/.ssh/config /etc/ssh/ssh_config 2> /dev/null | command grep -i '^host ' | command grep -v '[*?]' | awk '{for (i = 2; i <= NF; i++) print $1 " " $i}') \
        <(command grep -oE '^[[a-z0-9.,:-]+' ~/.ssh/known_hosts | tr ',' '\n' | tr -d '[' | awk '{ print $1 " " $1 }') \
        <(command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0') |
        awk '{if (length($2) > 0) {print $2}}' | sort -u
  )
}

_fzf_complete_export() {
  _fzf_complete '-m' "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_fzf_complete_unset() {
  _fzf_complete '-m' "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_fzf_complete_unalias() {
  _fzf_complete '+m' "$@" < <(
    alias | sed 's/=.*//'
  )
}

fzf-completion() {
  local tokens cmd prefix trigger tail fzf matches lbuf d_cmds
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

  # http://zsh.sourceforge.net/FAQ/zshfaq03.html
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
  tokens=(${(z)LBUFFER})
  if [ ${#tokens} -lt 1 ]; then
    zle ${fzf_default_completion:-expand-or-complete}
    return
  fi

  cmd=${tokens[1]}

  # Explicitly allow for empty trigger.
  trigger=${FZF_COMPLETION_TRIGGER-'**'}
  [ -z "$trigger" -a ${LBUFFER[-1]} = ' ' ] && tokens+=("")

  tail=${LBUFFER:$(( ${#LBUFFER} - ${#trigger} ))}
  # Kill completion (do not require trigger sequence)
  if [ $cmd = kill -a ${LBUFFER[-1]} = ' ' ]; then
    fzf="$(__fzfcmd_complete)"
    matches=$(command ps -ef | sed 1d | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-50%} --min-height 15 --reverse $FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window down:3:wrap $FZF_COMPLETION_OPTS" ${=fzf} -m | awk '{print $2}' | tr '\n' ' ')
    if [ -n "$matches" ]; then
      LBUFFER="$LBUFFER$matches"
    fi
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
  # Trigger sequence given
  elif [ ${#tokens} -gt 1 -a "$tail" = "$trigger" ]; then
    d_cmds=(${=FZF_COMPLETION_DIR_COMMANDS:-cd pushd rmdir})

    [ -z "$trigger"      ] && prefix=${tokens[-1]} || prefix=${tokens[-1]:0:-${#trigger}}
    [ -z "${tokens[-1]}" ] && lbuf=$LBUFFER        || lbuf=${LBUFFER:0:-${#tokens[-1]}}

    if eval "type _fzf_complete_${cmd} > /dev/null"; then
      eval "prefix=\"$prefix\" _fzf_complete_${cmd} \"$lbuf\""
    elif [ ${d_cmds[(i)$cmd]} -le ${#d_cmds} ]; then
      _fzf_dir_completion "$prefix" "$lbuf"
    else
      _fzf_path_completion "$prefix" "$lbuf"
    fi
  # Fall back to default completion
  else
    zle ${fzf_default_completion:-expand-or-complete}
  fi
}

[ -z "$fzf_default_completion" ] && {
  binding=$(bindkey '^I')
  [[ $binding =~ 'undefined-key' ]] || fzf_default_completion=$binding[(s: :w)2]
  unset binding
}

zle     -N   fzf-completion
# bindkey '^F' fzf-completion
export FZF_COMPLETION_TRIGGER=''


# CTRL-T - Paste the selected file path(s) into the command line
__fsel() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . \
    -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzf_use_tmux__() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ]
}

__fzfcmd() {
  __fzf_use_tmux__ &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}


fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N   fzf-file-widget
bindkey '^T' fzf-file-widget
# Using highlight (http://www.andre-simon.de/doku/highlight/en/highlight.html)
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

# Ensure precmds are run after cd
fzf-redraw-prompt() {
  local precmd
  for precmd in $precmd_functions; do
    $precmd
  done
  zle reset-prompt
}
zle -N fzf-redraw-prompt

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  cd "$dir"
  local ret=$?
  zle fzf-redraw-prompt
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N    fzf-cd-widget
bindkey '^G' fzf-cd-widget

export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
  selected=( $(fc -rl 1 |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --expect=alt-r --expect=ctrl-r --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    local accept=0
    if [[ $selected[1] = ctrl-r ]] || [[ $selected[1] = alt-r ]]; then
      accept=1
      shift selected
    fi
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
      [[ $accept = 1 ]] && zle accept-line
    fi
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget
bindkey -M vicmd '^R' fzf-history-widget

eval "$(dircolors --sh)"

# alias e='setsid emacs'
e() {
  setsid env -u HTTPS_PROXY -u HTTP_PROXY -u https_proxy -u http_proxy emacs "$@"
}

alias sudo='sudo '

## get rid of command not found ##
alias cd..='cd ..'

## a quick way to get out of current directory ##
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'

function ls_or_less {
  if [ -f "$1" ]; then
    less "$1"
    return
  fi
  eval "${aliases[ls]:-ls} -lhAa "${1:-.}""
}
compdef -e '_less' ls_or_less

alias ls='ls --group-directories-first'
alias ls="${aliases[ls]:-ls} --color=auto"
alias ll='ls -lh'        # Lists human readable sizes.
alias la='ll -A'         # Lists human readable sizes, hidden files.
alias la='ls_or_less'
alias ld='ls -lah --color=always | ag --nocolor "^(d|l)"'
alias lf='ls -lah --color=always | ag --nocolor'

function mkcd {
  [[ -n "$1" ]] && mkdir -p "$1" && builtin cd "$1"
}
compdef -e '_cd' mkcd

imv() {
  local src dst
  for src; do
    [[ -e $src ]] || { print -u2 "$src does not exist"; continue }
    dst=$src
    vared dst
    [[ $src != $dst ]] && mkdir -p $dst:h && mv -n $src $dst
  done
}

alias fp='ps auxw | rg'

alias rg='rg -S --no-ignore-global --no-ignore-vcs --hidden --no-heading --line-number --color auto'
alias ag='ag --skip-vcs-ignores --hidden --ignore node_modules --ignore .git --ignore .build --ignore archive-contents --color'
alias fd='fd --hidden --no-ignore-vcs --color auto'
alias em='emacs -nw'

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

#mkdir command is used to create a directory:
alias mkdir='mkdir -pv'

alias path='echo -e ${PATH//:/\\n}'
alias q='tmux kill-session'

alias df='df -kh'
alias du='du -kh'
alias top=htop
# Displays user owned processes status.
function psu {
  ps -U "${1:-$LOGNAME}" -o 'pid,%cpu,%mem,command' "${(@)argv[2,-1]}"
}

alias gb="git branch"
alias gc="git add -A && git commit -m"
alias gch="git checkout"
alias gca="git add -A && git commit --amend"
alias gp="git push origin"
alias gpp="git push"
alias gs="git status"
alias gl="git log --pretty=oneline -10"

HISTFILE="$CACHE_PREFIX/.zhistory" # The path to the history file.
HISTSIZE=1000000                   # The maximum number of events to save in the internal history.
SAVEHIST=1000000                   # The maximum number of events to save in the history file.
setopt BANG_HIST                   # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY            # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY          # Write to the history file immediately, not when the shell exits.
unsetopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST      # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS            # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS        # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS           # Do not display a previously found event.
setopt HIST_IGNORE_SPACE           # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS           # Do not write a duplicate event to the history file.
setopt HIST_VERIFY                 # Do not execute immediately upon history expansion.
setopt HIST_BEEP                   # Beep when accessing non-existent history.
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"

# Return if requirements are not found.
alias tmux="env TERM=xterm-256color tmux"
alias tmuxa='tmux attach-session'
alias tmuxl='tmux list-sessions'
if [[ -z $INSIDE_EMACS && -z "$TMUX" && -z "$VIM" ]]; then
  exec tmux
fi

source "$CONFIG_PREFIX/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
declare -A ZSH_HIGHLIGHT_STYLES
# ZSH_HIGHLIGHT_STYLES[default]:=none}
# ZSH_HIGHLIGHT_STYLES[unknown-token]:=fg=red,bold}
# ZSH_HIGHLIGHT_STYLES[reserved-word]:=fg=yellow}
# ZSH_HIGHLIGHT_STYLES[suffix-alias]:=fg=green,underline}
ZSH_HIGHLIGHT_STYLES[precommand]=fg=81
# ZSH_HIGHLIGHT_STYLES[commandseparator]:=none}
ZSH_HIGHLIGHT_STYLES[path]=fg=218
# ZSH_HIGHLIGHT_STYLES[path_pathseparator]:=}
# ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]:=}
# ZSH_HIGHLIGHT_STYLES[globbing]:=fg=blue}
# ZSH_HIGHLIGHT_STYLES[history-expansion]:=fg=blue}
# ZSH_HIGHLIGHT_STYLES[single-hyphen-option]:=none}
# ZSH_HIGHLIGHT_STYLES[double-hyphen-option]:=none}
# ZSH_HIGHLIGHT_STYLES[back-quoted-argument]:=none}
# ZSH_HIGHLIGHT_STYLES[single-quoted-argument]:=fg=yellow}
# ZSH_HIGHLIGHT_STYLES[double-quoted-argument]:=fg=yellow}
# ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]:=fg=yellow}
# ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]:=fg=cyan}
# ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]:=fg=cyan}
# ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]:=fg=cyan}
# ZSH_HIGHLIGHT_STYLES[assign]:=none}
# ZSH_HIGHLIGHT_STYLES[redirection]:=none}
# ZSH_HIGHLIGHT_STYLES[comment]:=fg=black,bold}
ZSH_HIGHLIGHT_STYLES[arg0]=fg=203

source "$SCRIPT_DIR/.zshrc_extra"

if [[ -n $INSIDE_EMACS ]]; then
  # export TERM=xterm-256color
  # export COLORTERM=1
  # This shell runs inside an Emacs *shell*/*term* buffer.
  # Have to unset zle, it messes up with Emacs buffer.
  unsetopt zle
fi
