FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USER_NAME=builder
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
    gawk \
    wget \
    git \
    diffstat \
    unzip \
    texinfo \
    gcc \
    build-essential \
    chrpath \
    socat \
    cpio \
    python3 \
    python3-pip \
    python3-pexpect \
    python3-jinja2 \
    python3-git \
    xz-utils \
    debianutils \
    iputils-ping \
    libsdl1.2-dev \
    xterm \
    zstd \
    lz4 \
    file \
    locales \
    rsync \
    ca-certificates \
    sudo \
    vim-tiny \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN groupadd --gid ${USER_GID} ${USER_NAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USER_NAME} \
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME}

ENV TEMPLATECONF=
WORKDIR /workspace
USER ${USER_NAME}

CMD ["/bin/bash"]
