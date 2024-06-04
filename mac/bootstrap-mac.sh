#! /usr/bin/env bash

username=`whoami`

defaults write -g ApplePressAndHoldEnabled -bool false

if [ ! -f /opt/homebrew/bin/brew ]; then
    #export HOMEBREW_BREW_GIT_REMOTE="..."  # put your Git mirror of Homebrew/brew here
    #export HOMEBREW_CORE_GIT_REMOTE="..."  # put your Git mirror of Homebrew/homebrew-core here
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" 
fi

brew bundle
./install-configs.sh
git clone git@github-choppin:ChoppinBlockParty/Yuki-s-.emacs.d.git ~/.emacs.d
git submodule update --init --recursive
