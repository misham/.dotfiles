#!/bin/bash
#
# Setup Bash
#
if [[ -h $HOME/.bash_profile ]]; then
  rm $HOME/.bash_profile
elif [[ -e $HOME/.bash_profile ]]; then
  echo "bash_profile exists, moving to $HOME/.bash_profile.orig"
  mv $HOME/.bash_profile $HOME/.bash_profile.orig
fi
if [[ -h $HOME/.bashrc ]]; then
  rm $HOME/.bashrc
elif [[ -e $HOME/.bashrc ]]; then
  echo "bashrc exists, moving to $HOME/.bashrc.orig"
  mv $HOME/.bashrc $HOME/.bashrc.orig
fi
ln -s $DOTFILES/bash/bash_profile $HOME/.bash_profile
ln -s $DOTFILES/bash/bashrc $HOME/.bashrc

