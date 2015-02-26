#!/bin/bash
#
# Install local vim configs
#
if [[ -h $HOME/.vimrc ]]; then
  rm $HOME/.vimrc
elif [[ -e $HOME/.vimrc ]]; then
  echo "vimrc.local exists, moving to $HOME/.vimrc.local.orig"
  mv $HOME/.vimrc $HOME/.vimrc.orig
fi
ln -s $DOTFILES/vim/vimrc $HOME/.vimrc

if [[ -h $HOME/.vim ]]; then
  rm $HOME/.vim
elif [[ -e $HOME/.vim ]]; then
  echo "vim exists, moving to $HOME/.vim.orig"
  mv $HOME/.vim $HOME/.vim.orig
fi
ln -s $DOTFILES/vim/vim $HOME/.vim

