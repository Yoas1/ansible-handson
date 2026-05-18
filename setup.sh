#!/bin/bash

if [ -d "/workspace/.config" ]; then
    echo "Exists"
else
    mv /tmp/.config /workspace/.config
fi

if [ -d "/workspace/playbooks" ]; then
    echo "Exists"
else
    mv /tmp/playbooks /workspace/playbooks
fi

mv /tmp/update_config.sh /workspace/update_config.sh
chmod +x /workspace/update_config.sh
mv /tmp/.pre-commit-config.yaml /workspace/.pre-commit-config.yaml

config=/workspace/.config


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


(
    echo "Starting background file monitor on /workspace/.config..."
    inotifywait -m -r -e modify,create,moved_to /workspace/.config | while read -r directory events filename; do
        echo "File event detected: $events on $filename. Running update script..."
        /workspace/update_config.sh
    done
) &


export EXT_DIR="$HOME/.local/share/code-server/extensions"
export USER_DATA_DIR="$HOME/.local/share/code-server"
mkdir -p "$EXT_DIR"
mkdir -p "$USER_DATA_DIR/User"

cat <<EOF > "$USER_DATA_DIR/User/settings.json"
{
    "workbench.colorTheme": "Visual Studio Dark",
    "files.autoSave": "afterDelay",
    "terminal.integrated.defaultProfile.linux": "zsh",
    "editor.unicodeHighlight.nonBasicASCII": false,
    "editor.fontFamily": "'Courier New', monospace",
    "terminal.integrated.gpuAcceleration": "on"
}
EOF

chown "root:root" "$USER_DATA_DIR/User/settings.json"


code-server --extensions-dir "$EXT_DIR" --install-extension redhat.ansible \
 --install-extension ms-python.python \

exec code-server \
    --bind-addr 0.0.0.0:8080 \
    --auth none \
    --user-data-dir "$USER_DATA_DIR" \
    --extensions-dir "$EXT_DIR" \
    /workspace