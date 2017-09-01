#!/usr/bin/env bash
#
# Copyright (C) 2017 KuoE0 <kuoe0.tw@gmail.com>
#
# Distributed under terms of the MIT license.

if [ "$#" != "1" ]; then
	echo
	echo "usage: ./setup.sh <hostname>"
	echo
	echo "       <hostname>    the new hostname for this machine"
	echo
	exit
fi

# create temporal directory
TMP_DIR=/tmp/$(date +%Y%m%d-%H%M%S)
if [ -d $TMP_DIR ] || [ -f $TMP_DIR ]; then
	rm -r $TMP_DIR
fi
mkdir $TMP_DIR

################################################################################
### System Setup
################################################################################

# change hostname
hostname=$1
sudo scutil --set HostName $hostname

################################################################################
### command line tools
################################################################################
xcode-select -p > /dev/null 2>&1
if [ "$?" != "0" ]; then
	echo "Installing Xcode Command Line Tools..."
	osascript installCommandLineTools.AppleScript
else
	echo "Xcode already installed."
fi

################################################################################
### Homebrew
################################################################################

# brew does not exist
if ! which brew &> /dev/null; then
	# install homebrew
	echo "Install Homebrew..."
	# send ENTER keystroke to install automatically
	echo | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# homebrew install failed
if ! which brew &> /dev/null; then
	echo "Homebrew failed to install!"
	exit 255
else
	brew doctor
	if [ "$?" = "0" ]; then
		# use llvm to build
		brew --env --use-llvm
	else
		echo "Something going wrong with Homebrew!"
		exit 255
	fi
fi

ruby installPackages.rb

################################################################################
### Shell
################################################################################
# make it as a regular shell
ZSH_REGULAR=$(grep '/usr/local/bin/zsh' /etc/shells)
if [ "${ZSH_REGULAR:-x}" = x ]; then
	sudo sh -c "echo '/usr/local/bin/zsh' >> /etc/shells"
fi

# use zsh as my defaut shell
chsh -s /usr/local/bin/zsh $USER
