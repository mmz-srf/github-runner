ARG FROM=debian:buster-slim
FROM ${FROM}

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_VERSION="2.26.2"
ARG GH_RUNNER_VERSION
ARG DOCKER_COMPOSE_VERSION="1.27.4"

ENV RUNNER_NAME=""
ENV RUNNER_WORK_DIRECTORY="_work"
ENV RUNNER_TOKEN=""
ENV RUNNER_REPOSITORY_URL=""
ENV RUNNER_LABELS=""
ENV RUNNER_ALLOW_RUNASROOT=true
ENV GITHUB_ACCESS_TOKEN=""
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
ENV PHP_VERSION=7.4

# Labels.
LABEL maintainer="me@tcardonne.fr" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="tcardonne/github-runner" \
    org.label-schema.description="Dockerized GitHub Actions runner." \
    org.label-schema.url="https://github.com/tcardonne/docker-github-runner" \
    org.label-schema.vcs-url="https://github.com/tcardonne/docker-github-runner" \
    org.label-schema.vendor="Thomas Cardonne" \
    org.label-schema.docker.cmd="docker run -it tcardonne/github-runner:latest"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y \
        curl \
        wget \
        unzip \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
        sudo \
        supervisor \
        jq \
        iputils-ping \
        build-essential \
        zlib1g-dev \
        gettext \
        liblttng-ust0 \
        libcurl4-openssl-dev \
        openssh-client \
        software-properties-common \
        libnss3-dev \
        libgdbm-dev \
        libncurses5-dev \
        libssl-dev \
        libffi-dev \
        libreadline-dev \
        libsqlite3-dev \
        libbz2-dev && \

    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# install latest composer
COPY --from=composer /usr/bin/composer /usr/bin/composer
# copy php installation script
COPY install-php.sh /install-php.sh
RUN chmod +x /install-php.sh

# install buildah
RUN echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list && \
    curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/Release.key | sudo apt-key add - && \
    sudo apt-get update && \
    sudo apt-get -y install buildah && \
    apt-get clean


# install python 3.9.5
RUN wget https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tgz && \
    tar xvf Python-3.9.5.tgz && \
    cd Python-3.9.5/ && \
    ./configure --enable-optimizations && \
    make altinstall


# install python 3.8.10
RUN wget https://www.python.org/ftp/python3.8.10/Python-3.8.10.tgz && \
    tar xvf Python-3.8.10.tgz && \
    cd Python-3.8.10/ && \
    ./configure --enable-optimizations && \
    make altinstall


# supervisor config to keep github-runner running
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

# install git
RUN cd /tmp && \
    curl -sL -o git.tgz \
    https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz && \
    tar zxf git.tgz  && \
    cd git-${GIT_VERSION}  && \
    ./configure --prefix=/usr  && \
    make && \
    make install && \
    rm -rf /tmp/*

# install yq
RUN wget https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

RUN mkdir -p /home/runner ${AGENT_TOOLSDIRECTORY}

WORKDIR /home/runner

# github runner installation
RUN GH_RUNNER_VERSION=${GH_RUNNER_VERSION:-$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')} \
    && curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && tar -zxf actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && rm -f actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R root: /home/runner \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# set python3 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1


# entrypoints
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
