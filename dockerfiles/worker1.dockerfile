ARG image=ubuntu
ARG tag=22.04

FROM ${image}:${tag}
EXPOSE 22

ENV DEBIAN_FRONTEND=noninteractive

COPY --chmod=744 dockerfiles/build.sh /tmp/build.sh

RUN apt update && \
    apt install -y openssh-server python3 sudo && \
    /tmp/build.sh && \
    service ssh start

CMD ["/usr/sbin/sshd", "-D"]
