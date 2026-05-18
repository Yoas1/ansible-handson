ARG image=python
ARG tag=3.12
ARG k8s_version=1.35.4
ARG shellcheck_version=v0.11.0

FROM alpine/k8s:${k8s_version} as k8s
FROM koalaman/shellcheck:${shellcheck_version} as shellcheck

FROM ${image}:${tag}
WORKDIR /workspace

#ENV ANSIBLE_GALAXY_IGNORE=true
ENV YAMLLINT_CONFIG_FILE=/workspace/.config/yamllint.yaml


RUN mkdir /etc/ansible && \
    mkdir ~/.kube && \
    mkdir ~/.ssh && \
    mkdir -p ~/.oh-my-zsh/completions/

COPY --chmod=600 ssh/id_ed25519 /root/.ssh/id_ed25519
COPY --from=k8s /usr/bin/helm /usr/local/bin/helm
COPY --from=k8s /usr/bin/kubectl /usr/local/bin/kubectl
COPY --from=k8s /usr/bin/kustomize /usr/local/bin/kustomize
COPY --from=shellcheck /bin/shellcheck /usr/local/bin/shellcheck
COPY setup.sh /tmp/setup.sh
COPY update_config.sh /tmp/update_config.sh
COPY playbooks /tmp/playbooks
COPY .pre-commit-config.yaml /tmp/.pre-commit-config.yaml
COPY .config /tmp/.config

RUN apt update && \
    helm completion zsh > ~/.oh-my-zsh/completions/_helm && \
    kubectl completion zsh > ~/.oh-my-zsh/completions/_kubectl && \
    kustomize completion zsh > ~/.oh-my-zsh/completions/_kustomize && \
    apt install -y sshpass iputils-ping zsh inotify-tools


RUN pip install --no-cache-dir -r /tmp/.config/requirements.txt
#   ansible-galaxy collection install --offline -r .config/requirements.yaml

# Install code-server using the official script
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Pre-create the workspace directory
RUN mkdir -p /workspace

ENTRYPOINT [ "/tmp/setup.sh" ]
#CMD [ "zsh" ]