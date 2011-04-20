#!/bin/bash
#
# -----------------------------------------------------------------------------
# Install nvm
#
git clone https://github.com/creationix/nvm.git $HOME/.nvm
# -----------------------------------------------------------------------------
# Install npmrc
#
if [[ -h $HOME/.npmrc ]]; then
  rm $HOME/.npmrc
elif [[ -e $HOME/.npmrc ]]; then
  echo "npmrc exists, moving to $HOME/.npmrc.orig"
  mv $HOME/.npmrc $HOME/.npmrc.orig
fi
ln -s $DOTFILES/js/npmrc $HOME/.npmrc

