#!/bin/bash
#
# Setup dotfiles
#
# -----------------------------------------------------------------------------
# Get environment variables
#
. scripts/functions
# -----------------------------------------------------------------------------
# Install environments
#
ENVIRONMENTS=`ls $DOTFILES/ | grep -v janus`
for env in $ENVIRONMENTS; do
  if [[ -d "$DOTFILES/$env" ]] ; then
    if [ -e "$DOTFILES/$env/install.sh" ]; then
      . $DOTFILES/$env/install.sh
    fi
  fi
done

