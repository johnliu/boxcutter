#!/bin/sh

if ! xcode-select -p &> /dev/null; then
    xcode-select --install
fi

mkdir -p ~/Projects
cd ~/Projects
git clone https://github.com/johnliu/setup.git

echo "Configure the machine via defaults.yml and run make."
open -a Terminal ~/Projects/setup

