#!/bin/sh

if ! xcode-select -p &> /dev/null; then
    xcode-select --install
fi

mkdir -p ~/Projects
cd ~/Projects
git clone https://github.com/johnliu/setup.git

cd setup
make

