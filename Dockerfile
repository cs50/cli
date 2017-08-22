FROM ubuntu:14.04

# packages
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y \
        apt-transport-https \
        clang \
        curl \
        git \
        sqlite3 \
        unzip \
        valgrind \
        wget

# install Python 3.6
# https://github.com/yyuu/pyenv/blob/master/README.md#installation
# https://github.com/yyuu/pyenv/wiki/Common-build-problems
ENV PYENV_ROOT /opt/pyenv
RUN apt-get install -y \
        build-essential \
        curl \
        libbz2-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        llvm \
        wget \
        xz-utils \
        zlib1g-dev && \
    wget -P /tmp https://github.com/yyuu/pyenv/archive/master.zip && \
    unzip -d /tmp /tmp/master.zip && \
    rm -f /tmp/master.zip && \
    mv /tmp/pyenv-master /opt/pyenv && \
    chmod a+x /opt/pyenv/bin/pyenv && \ 
    /opt/pyenv/bin/pyenv install 3.6.0 && \
    /opt/pyenv/bin/pyenv rehash && \
    /opt/pyenv/bin/pyenv global 3.6.0
ENV PATH "$PYENV_ROOT"/shims:"$PYENV_ROOT"/bin:"$PATH"

# install CS50-specific packages
RUN pip install cs50 check50 style50 submit50

# clone checks
RUN git clone -b master https://github.com/cs50/checks.git /home/ubuntu/.local/share/check50/cs50/checks

# check50 wrapper
COPY ./check50-wrapper /usr/local/bin/ 
RUN chmod a+x /usr/local/bin/check50-wrapper

# install libcs50
RUN sudo add-apt-repository ppa:cs50/ppa && \
    sudo apt-get update && \
    sudo apt-get install -y astyle libcs50

# install astyle (after adding cs50 ppa so we get latest version)
RUN sudo apt-get install -y astyle

# install git-lfs
# https://packagecloud.io/github/git-lfs/install#manual
RUN echo "deb https://packagecloud.io/github/git-lfs/ubuntu/ trusty main" > /etc/apt/sources.list.d/github_git-lfs.list && \
    echo "deb-src https://packagecloud.io/github/git-lfs/ubuntu/ trusty main" >> /etc/apt/sources.list.d/github_git-lfs.list && \
    curl -L https://packagecloud.io/github/git-lfs/gpgkey | sudo apt-key add - && \
    apt-get update && \
    apt-get install -y git-lfs && \
    git lfs install

COPY ./etc/profile.d/cli.sh /etc/profile.d/

# configure git
RUN git config --global user.name bot50 && \
    git config --global user.email bot@cs50.harvard.edu

# run shell in /root
RUN useradd --create-home --user-group ubuntu
WORKDIR /home/ubuntu/check/
RUN chown -R ubuntu:ubuntu /home/ubuntu/ && chmod -R 755 /home/ubuntu/
USER ubuntu
