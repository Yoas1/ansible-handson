# Ansible-HandsOn
Containerized Learning Environment Ansible-HandsOn is a lightweight, local lab environment designed for learning, testing, and mastering Ansible infrastructure automation. Instead of relying on resource-heavy Virtual Machines (VMs), this project leverages Docker containers to simulate a real-world network infrastructure in seconds.


### Compose:
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
### Access the Web Interface
Once the containers are up and running, open your browser and navigate to [http://localhost:8080](http://localhost:8080) to interact with the environment.
