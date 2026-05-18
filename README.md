# Ansible-HandsOn
Containerized Learning Environment Ansible-HandsOn is a lightweight local lab environment designed for learning, testing, and mastering Ansible infrastructure automation.

Instead of relying on resource-heavy Virtual Machines (VMs), this project leverages Docker containers to simulate a real-world network infrastructure in seconds.

## System Overview

The system consists of 3 containers:

```
┌──────────────────────────────────────────────────┐
│              ansible_controller                  │
│  (Python + Ansible + code-server IDE)            │
│  Port 8080 - Browser-based IDE                   │
└────────────┬─────────────────────────┬───────────┘
             │                         │
             ▼                         ▼
┌──────────────────────┐  ┌──────────────────────┐
│   ansible_worker1    │  │   ansible_worker2    │
│   Ubuntu 22.04       │  │   Red Hat UBI 9      │
│   OpenSSH + Python   │  │   OpenSSH + Python   │
└──────────────────────┘  └──────────────────────┘
```

## Directory Contents

### `.config/` — Central Configuration Files

| File | Role |
|------|------|
| **ansible.cfg** | Main Ansible configuration. Sets inventory location, Vault password file, disables host key checking (suitable for Docker), and enables the timer callback. |
| **inventory.yaml** | Defines managed servers: `prod` (192.168.0.1), `dev` (192.168.0.2), and `testing` (worker1, worker2). The `testing` group uses `admin` as the default user. |
| **vault.secret** | Default Ansible Vault password (`devops`). Used for encrypting secrets like users and passwords. |
| **ansible-lint.yaml** | Configuration for ansible-lint. Set to offline mode, excludes vault files. |
| **yamllint.yaml** | Configuration for yamllint — limits line length to 100 characters and configures quote handling. |
| **markdown-lint.json** | Configuration for pymarkdown — limits line length to 120 characters (excluding code blocks). |
| **requirements.txt** | Python packages to install in the controller: ansible, ansible-lint, kubernetes, yamllint, pre-commit, and more. |

## Installition
### Docker Compose:
```yaml
---
services:
  ansible-controller:
    image: yoas1/ansible-handson:controller-0.0.1
    container_name: ansible_controller
    hostname: ansible_controller
    stdin_open: true
    tty: true
    ports:
      - 8080:8080
    volumes:
      - ./:/workspace
    networks:
      - ansible
    depends_on:
      - worker1
      - worker2
    restart: unless-stopped
  
  worker1:    
    image: yoas1/ansible-handson:worker1-0.0.1
    hostname: worker1
    container_name: ansible_worker1
    networks:
      - ansible
    restart: unless-stopped

  worker2:
    image: yoas1/ansible-handson:worker2-0.0.1
    hostname: worker2
    container_name: ansible_worker2
    networks:
      - ansible
    restart: unless-stopped


networks:
  ansible:
```
## Typical Workflow

1. **Spin up the environment:**
   ```bash
   docker compose up -d
   ```

2. **Access the IDE:**
   Open a browser at `http://localhost:8080` (code-server with no authentication).

3. **Run a Playbook:**
   Inside the controller (or from the IDE terminal):
   ```bash
   ansible-playbook playbooks/host_information.yaml
   ```

4. **Edit configs in real-time:**
   Modify files in the `.config/` directory — inotifywait on the controller will automatically run `update_config.sh` to apply changes.