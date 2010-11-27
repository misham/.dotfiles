#!/bin/bash
#
# Setup dotfiles
#
# -----------------------------------------------------------------------------
# Setup Bash
#
if [[ -h $HOME/.bash_profile ]]; then
  rm $HOME/.bash_profile
elif [[ -e $HOME/.bash_profile ]]; then
  echo "bash_profile exists, moving to $HOME/.bash_profile.orig"
  mv $HOME/.bash_profile $HOME/.bash_profile.orig
fi
ln -s $HOME/.dotfiles/bash/bash_profile $HOME/.bash_profile
# -----------------------------------------------------------------------------
# Setup SSH
#
# :NOTE: Disable this for now
# :TODO: Figure out a way to merge this config with system config on install
#
if [[ 1 -eq 0 ]]; then
if [[ -h $HOME/.ssh/config ]]; then
  rm $HOME/.ssh/config
elif [[ -e $HOME/.ssh/config ]]; then
  echo "SSH config exists, moving to $HOME/.ssh/config.orig"
  mv $HOME/.ssh/config $HOME/.ssh/config.orig
fi
ln -s $HOME/.dotfiles/ssh/config $HOME/.ssh/config
chmod 700 $HOME/.ssh/config
fi
# -----------------------------------------------------------------------------
# Setup Git
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
ln -s $HOME/.dotfiles/git/gitconfig $HOME/.gitconfig
ln -s $HOME/.dotfiles/git/gitignore $HOME/.gitignore
# -----------------------------------------------------------------------------
# Setup vim local configs
#
if [[ -h $HOME/.vimrc.local ]]; then
  rm $HOME/.vimrc.local
elif [[ -e $HOME/.vimrc.local ]]; then
  echo "vimrc.local exists, moving to $HOME/.vimrc.local.orig"
  mv $HOME/.vimrc.local $HOME/.vimrc.local.orig
fi
ln -s $HOME/.dotfiles/vim/vimrc.local $HOME/.vimrc.local
# -----------------------------------------------------------------------------
# Setup janus vim stuff
#   From: git://github.com/misham/janus.git
#
# Setup .vim
#
if [[ -h $HOME/.vim ]]; then
  rm $HOME/.vim
elif [[ -e $HOME/.vim ]]; then
  echo ".vim/ exists, moving to $HOME/.vim.orig/"
  mv $HOME/.vim $HOME/.vim.orig
fi
ln -s $HOME/.dotfiles/janus $HOME/.vim
#
# Setup vimrc and gvimrc
#
if [[ -h $HOME/.vimrc ]]; then
  rm $HOME/.vimrc
elif [[ -e $HOME/.vimrc ]]; then
  echo "vimrc exists, moving to $HOME/.vimrc.orig"
  mv $HOME/.vimrc $HOME/.vimrc.orig
fi
if [[ -h $HOME/.gvimrc ]]; then
  rm $HOME/.gvimrc
elif [[ -e $HOME/.gvimrc ]]; then
  echo "vimrc exists, moving to $HOME/.vimrc.orig"
  mv $HOME/.gvimrc $HOME/.gvimrc.orig
fi
ln -s $HOME/.vim/vimrc $HOME/.vimrc
ln -s $HOME/.vim/gvimrc $HOME/.gvimrc
#
# Install plugins, etc.
#
cd $HOME/.vim && rake

