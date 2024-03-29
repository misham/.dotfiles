#!/bin/bash
#
#
# -----------------------------------------------------------------------------
# Setup rvmrc
#
if [[ -h $HOME/.rvmrc ]]; then
  rm $HOME/.rvmrc
elif [[ -e $HOME/.rvmrc ]]; then
  echo ".rvmrc exists, moving to $HOME/.rvmrc.orig"
  mv $HOME/.rvmrc $HOME/.rvmrc.orig
fi
ln -fs $DOTFILES/ruby/rvmrc $HOME/.rvmrc
# -----------------------------------------------------------------------------
# Setup gemrc
#
if [[ -h $HOME/.gemrc ]]; then
  rm $HOME/.gemrc
elif [[ -e $HOME/.gemrc ]]; then
  echo ".gemrc exists, moving to $HOME/.gemrc.orig"
  mv $HOME/.gemrc $HOME/.gemrc.orig
fi
ln -fs $DOTFILES/ruby/gemrc $HOME/.gemrc
# -----------------------------------------------------------------------------
# Setup irbrc
#
if [[ -h $HOME/.irbrc ]]; then
  rm $HOME/.irbrc
elif [[ -e $HOME/.irbrc ]]; then
  echo ".irbrc exists, moving to $HOME/.irbrc.orig"
  mv $HOME/.irbrc $HOME/.irbrc.orig
fi
ln -fs $DOTFILES/ruby/irbrc $HOME/.irbrc
