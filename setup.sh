#!/bin/sh

DEBUG=false

function log_info() {
    echo "$@"
}

function log_debug() {
    if [ $DEBUG = true ]; then
        echo "$@"
    fi
}


log_info "Bootstrapping the installer."

if ! xcode-select -p &> /dev/null; then
    xcode-select --install
fi

if ! type "brew" &> /dev/null; then
    log_debug "Installing brew."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    log_debug "brew already installed."
fi

if ! type "ansible" &> /dev/null; then
    log_debug "Installing ansible."
    brew install ansible
else
    log_debug "ansible already installed."
fi


log_info "Updating the installer."
git pull


ansible-playbook tasks/main.yml -i "localhost," --become-user=$USER --ask-become-pass
