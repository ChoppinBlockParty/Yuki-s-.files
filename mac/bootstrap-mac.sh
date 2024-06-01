#! /usr/bin/env bash

username=`whoami`

defaults write -g ApplePressAndHoldEnabled -bool false

if [ ! -f /opt/homebrew/bin/brew ]; then
    #export HOMEBREW_BREW_GIT_REMOTE="..."  # put your Git mirror of Homebrew/brew here
    #export HOMEBREW_CORE_GIT_REMOTE="..."  # put your Git mirror of Homebrew/homebrew-core here
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/${username}/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)" 
fi

brew bundle
git clone git@github.com:ChoppinBlockParty/Yuki-s-.files.git 
git clone https://github.com/ChoppinBlockParty/Yuki-s-.files.git
git clone https://github.com/ChoppinBlockParty/Yuki-s-.emacs.d.git