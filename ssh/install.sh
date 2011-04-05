#!/bin/bash
#
# Install ssh
#
# :NOTE: Disable this for now
# :TODO: Figure out a way to merge this config with system config on install
#
if [[ 1 -eq 0 ]]; then
  if [[ -h $HOME/.ssh/config ]]; then
    rm $HOME/.ssh/config
  elif [[ -e $HOME/.ssh/config ]]; then
    echo "SSH config exists, moving to $HOME/.ssh/config.orig"
    mv $HOME/.ssh/config $HOME/.ssh/config.orig
  fi
  ln -s $DOTFILES/ssh/ssh_config $HOME/.ssh/config
  chmod 700 $HOME/.ssh/config
fi

