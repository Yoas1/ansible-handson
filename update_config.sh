#!/bin/bash

config=$(pwd)/.config

_link() {
    local source="${config}/${1}"

    if [[ -f "${source}" ]]; then
        echo "Linking '.config/${1}'"
        cp "${source}" "${2}"

        chmod -x "${2}"
    else
        echo "Missing '.config/${1}'"
    fi
}

_link ansible.cfg /etc/ansible/ansible.cfg
_link vault.secret /etc/ansible/vault.secret
_link inventory.yaml /etc/ansible/inventory.yaml
_link kubeconfig ~/.kube/config

if (( $# != 0 )); then
    echo "Launched from entrypoint"
    exec "$@"
else
    echo "Launched manually from setup.sh"
fi