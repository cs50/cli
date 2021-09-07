FROM ubuntu:20.04
LABEL maintainer="sysadmins@cs50.harvard.edu"
ARG DEBIAN_FRONTEND=noninteractive


# Expose ports (just like Cloud9)
EXPOSE 8080 8081 8082


# Avoid "delaying package configuration, since apt-utils is not installed"
RUN apt update && apt install --yes apt-utils


# Environment
RUN apt update && \
    apt install --yes locales && \
    locale-gen "en_US.UTF-8" && dpkg-reconfigure locales
ENV LANG "C.UTF-8"
ENV LC_ALL "C.UTF-8"
ENV LC_CTYPE "C.UTF-8"


# Unminimize system
RUN yes | unminimize


# Install Ubuntu packages
RUN apt update && \
    apt install --no-install-recommends --yes \
        astyle \
        bash-completion \
        ca-certificates `# for curl` \
        clang \
        coreutils `# for fold` \
        curl \
        dos2unix \
        dnsutils `# For nslookup` \
        gdb \
        git \
        git-lfs \
        jq \
        make \
        man \
        man-db \
        nano \
        openssh-client `# For ssh-keygen` \
        sudo \
        unzip \
        valgrind \
        vim \
        wget \
        zip
ENV EDITOR nano


# Install CS50 packages
RUN curl https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt update && \
    apt install --yes \
        libcs50


# Install Java 16.x
# http://jdk.java.net/16/
RUN cd /tmp && \
    wget https://download.java.net/java/GA/jdk16.0.2/d4a915d82b4c4fbb9bde534da945d746/7/GPL/openjdk-16.0.2_linux-x64_bin.tar.gz && \
    tar xzf openjdk-16.0.2_linux-x64_bin.tar.gz && \
    rm --force openjdk-16.0.2_linux-x64_bin.tar.gz && \
    mv jdk-16.0.2 /opt/ && \
    mkdir --parent /opt/bin && \
    ln --symbolic /opt/jdk-16.0.2/bin/* /opt/bin/ && \
    chmod a+rx /opt/bin/*
ENV JAVA_HOME "/opt/jdk-16.0.2"


# Install Node.js 16.x
# https://github.com/tj/n#installation
RUN curl --location https://raw.githubusercontent.com/tj/n/master/bin/n --output /usr/local/bin/n && \
    chmod a+x /usr/local/bin/n && \
    n 16.6.2
ENV NODE_ENV "dev"


# Install Node.js packages
RUN npm install -g http-server


# Suggested build environment for Python, per pyenv, even though we're building ourselves
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN apt update && \
    apt install --no-install-recommends --yes \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev


# Install Python 3.9.x
# https://www.python.org/downloads/
RUN cd /tmp && \
    curl https://www.python.org/ftp/python/3.9.7/Python-3.9.7.tgz --output Python-3.9.7.tgz && \
    tar xzf Python-3.9.7.tgz && \
    rm --force Python-3.9.7.tgz && \
    cd Python-3.9.7 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive Python-3.9.7 && \
    ln --relative --symbolic /usr/local/bin/python3 /usr/local/bin/python && \
    pip3 install --upgrade pip


# Install Python packages
RUN pip3 install \
    awscli \
    "check50<4" \
    compare50 \
    cs50 \
    Flask \
    Flask-Session \
    help50 \
    render50 \
    s3cmd \
    style50 \
    "submit50<4"


# Install Ruby 3.0.x
# https://www.ruby-lang.org/en/downloads/
RUN cd /tmp && \
    curl https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.2.tar.gz --output ruby-3.0.2.tar.gz && \
    tar xzf ruby-3.0.2.tar.gz && \
    rm --force ruby-3.0.2.tar.gz && \
    cd ruby-3.0.2 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive ruby-3.0.2


# Install Ruby packages
RUN gem install \
    bundler \
    jekyll \
    jekyll-theme-cs50 \
    minitest `# so that Bundler needn't install` \
    pygments.rb


# Install SQLite 3.x
# https://www.sqlite.org/download.html
RUN cd /tmp && \
    wget https://www.sqlite.org/2021/sqlite-tools-linux-x86-3360000.zip && \
    unzip sqlite-tools-linux-x86-3360000.zip && \
    rm --force sqlite-tools-linux-x86-3360000.zip && \
    mv sqlite-tools-linux-x86-3360000/* /usr/local/bin/ && \
    rm --force --recursive sqlite-tools-linux-x86-3360000


# Copy files to image
COPY ./etc /etc
COPY ./opt /opt
RUN chmod a+rx /opt/cs50/bin/*


# Update environment
ENV PATH=/opt/cs50/bin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN sed -i "s|^PATH=.*|PATH=$PATH|" /etc/environment


# Ready /opt
RUN mkdir -p /opt/bin /opt/cs50/bin


# Add user
RUN useradd --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    umask 0077 && \
    mkdir -p /home/ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu


# Add user to sudoers
RUN echo "\n# CS50 CLI" >> /etc/sudoers
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "Defaults umask_override" >> /etc/sudoers
RUN echo "Defaults umask=0022" >> /etc/sudoers
RUN sed -e "s|^Defaults\tsecure_path=.*|Defaults\t!secure_path|" -i /etc/sudoers


# Set user
USER ubuntu
WORKDIR /home/ubuntu
