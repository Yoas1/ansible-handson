#!/bin/bash

_set_pass() {
    echo "${1}:devops" | chpasswd
}

_create_user() {
    useradd --uid "${2}" --create-home "${1}"
    _set_pass "${1}"
}

_setup_ssh() {
    local authorized_keys='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxTxnaZw2yWoFdBlhyKzD5lZqljIxfbYXG8m5fQLGfq root@53cfdafe26d3'

    mkdir -p "/home/${1}/.ssh"
    echo "${authorized_keys}" > "/home/${1}/.ssh/authorized_keys"
    chmod -R 700 "/home/${1}/.ssh"
    chmod 644 "/home/${1}/.ssh/authorized_keys"
    chown -R "${1}:${1}" "/home/${1}"
}

_setup_sudo() {
    echo "${1} ALL=(ALL) ${2:-}ALL" >> /etc/sudoers.d/sudoers
}

_set_pass root

_create_user admin 1000
_create_user devops 2000
_create_user bob 3000
_create_user joe 4000

_setup_ssh admin
_setup_ssh devops
_setup_ssh joe

_setup_sudo admin NOPASSWD:
_setup_sudo devops

{
    echo 'PasswordAuthentication yes'
    echo 'PermitRootLogin no'
    echo 'PubkeyAuthentication yes'
} >> /etc/ssh/sshd_config

if [ -d "/etc/update-motd.d" ]; then
    chmod -x /etc/update-motd.d/*
fi

ln -fs /usr/bin/python3 /usr/bin/python