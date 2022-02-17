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
ln -fs $DOTFILES/git/gitconfig $HOME/.gitconfig
ln -fs $DOTFILES/git/gitignore $HOME/.gitignore

ln -fs $DOTFILES/git/git_template $HOME/.git_template
ln -fs $DOTFILES/git/gitattributes $HOME/.gitattributes
