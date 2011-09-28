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

if [[ -e $HOME/bin/gist.sh ]]; then
  rm $HOME/bin/gist.sh
fi
ln -s $DOTFILES/gist/gist.sh $HOME/bin/gist.sh

