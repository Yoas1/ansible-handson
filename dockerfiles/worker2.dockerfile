ARG image=redhat/ubi9
ARG tag=9.7

FROM ${image}:${tag}
EXPOSE 22

COPY --chmod=744 dockerfiles/build.sh /tmp/build.sh

RUN yum update -y && \
    yum install -y openssh-server python3 sudo && \
    /tmp/build.sh && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -b 521


CMD ["/usr/sbin/sshd", "-D"]
