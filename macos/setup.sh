#!/usr/bin/env bash

# TODO make sure running as root

#find / -name *.DS_Store -depth -exec rm {} \;

# show file extensions
defaults write -g AppleShowAllExtensions -bool true
# show hidden files
defaults write com.apple.finder AppleShowAllFiles true
# show ~/Library folder
chflags nohidden ~/Library
# search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
# Hide mounted volumes on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
# Restart Finder/Dock
killall Finder
rm ~/Library/Application\ Support/Dock/*.db
killall Dock
# Expand save panel by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true
# Disable natural scroll
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
# Allow applications from anywhere
spctl --master-disable
# TouchID for sudo
if ! [[ `cat /etc/pam.d/sudo | grep pam_tid.so` ]]; then
  tmpfile=`mktemp`
  awk 'NR==1{ print; print "auth       sufficient     pam_tid.so"; next }1' /etc/pam.d/sudo > tmpfile
  cp -f tmpfile /etc/pam.d/sudo
else
  echo "Touch ID for sudo is already enabled."
fi
# Disable smart quotes/dashes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
