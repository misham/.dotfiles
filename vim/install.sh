#!/bin/bash
#
# Install local vim configs
#
if [[ -h $HOME/.vimrc.local ]]; then
  rm $HOME/.vimrc.local
elif [[ -e $HOME/.vimrc.local ]]; then
  echo "vimrc.local exists, moving to $HOME/.vimrc.local.orig"
  mv $HOME/.vimrc.local $HOME/.vimrc.local.orig
fi
ln -s $DOTFILES/vim/vimrc.local $HOME/.vimrc.local

