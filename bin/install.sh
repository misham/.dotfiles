#!/bin/bash
#
# Setup ~/bin
#
if [[ -h $HOME/bin ]]; then
  rm $HOME/bin
elif [[ -e $HOME/bin ]]; then
  echo "bin exists, moving to $HOME/bin.orig"
  mv $HOME/bin $HOME/bin.orig
fi
ln -s $DOTFILES/bin $HOME/bin

