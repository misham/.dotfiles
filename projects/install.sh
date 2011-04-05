#!/bin/bash
#
# Setup project config
#
if [[ -h $HOME/.project.env ]]; then
  rm $HOME/.project.env
elif [[ -e $HOME/.project.env ]]; then
  echo "project.env exists, moving to $HOME/.project.env.orig"
  mv $HOME/.project.env $HOME/.project.env.orig
fi
ln -s $DOTFILES/bash/project.env $HOME/.project.env

