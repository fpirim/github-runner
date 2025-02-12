FROM ubuntu:20.04

ARG RUNNER_VERSION="2.319.1"
ARG DOCKER_VERSION="27.2.0"
ARG DOCKER_COMPOSE_VERSION="2.29.2"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y 
RUN apt install -y --no-install-recommends \
    sudo curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

RUN groupadd -g 999 docker && \ 
    groupadd -g 1001 ubuntu && \
    useradd -rm -d /home/ubuntu -s /bin/bash -g ubuntu -G docker,sudo -u 1001 ubuntu && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN cd /home/ubuntu && mkdir actions-runner && cd actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz

RUN curl -fsSL https://download.docker.com/linux/static/stable/armel/docker-${DOCKER_VERSION}.tgz | tar zxvf - --strip 1 -C /usr/bin docker/docker
RUN mkdir -p /usr/local/lib/docker/cli-plugins
RUN curl -SL https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-armv7 -o /usr/local/lib/docker/cli-plugins/docker-compose
RUN chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

RUN chown -R ubuntu ~ubuntu && /home/ubuntu/actions-runner/bin/installdependencies.sh

COPY --chown=ubuntu:ubuntu start.sh .
RUN sudo chmod u+x start.sh

COPY start.sh start.sh
RUN chmod +x start.sh

USER ubuntu

ENTRYPOINT ["./start.sh"]