#!/bin/bash
#
# Install Git configs
#
if [[ -h $HOME/.gitconfig ]]; then
  rm $HOME/.gitconfig
elif [[ -e $HOME/.gitconfig ]]; then
  echo "gitconfig exists, moving to $HOME/.gitconfig.orig"
  mv $HOME/.gitconfig $HOME/.gitconfig.orig
fi
if [[ -h $HOME/.gitignore ]]; then
  rm $HOME/.gitignore
elif [[ -e $HOME/.gitignore ]]; then
  echo "gitignore exists, moving to $HOME/.gitignore.orig"
  mv $HOME/.gitignore $HOME/.gitignore.orig
fi
ln -s $DOTFILES/git/gitconfig $HOME/.gitconfig
ln -s $DOTFILES/git/gitignore $HOME/.gitignore

ln -s $DOTFILES/git/git_template $HOME/.git_template
