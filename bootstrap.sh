#!/bin/sh

if ! xcode-select -p &> /dev/null; then
    xcode-select --install
fi

# Sleep until xcode-select finishes.
until xcode-select -p &> /dev/null; do
    echo "Waiting for command line tools to finish installation."
    sleep 1;
done

mkdir -p ~/Projects/$USER
cd ~/Projects/$USER
git clone https://github.com/johnliu/boxcutter.git

echo "Configure the machine via defaults.yml and run make."
open -a Terminal ~/Projects/$USER/boxcutter
