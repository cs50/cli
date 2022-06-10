FROM ubuntu:20.04
LABEL maintainer="sysadmins@cs50.harvard.edu"
ARG DEBIAN_FRONTEND=noninteractive


# Avoid "delaying package configuration, since apt-utils is not installed"
RUN apt update && apt install --yes apt-utils


# Environment
RUN apt update && \
    apt install --yes locales && \
    locale-gen "en_US.UTF-8" && dpkg-reconfigure locales


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
        fonts-noto-color-emoji `# For render50` \
        gdb \
        git \
        git-lfs \
        jq \
        less \
        make \
        man \
        man-db \
        nano \
        openssh-client `# For ssh-keygen` \
        psmisc `# For fuser` \
        sudo \
        unzip \
        valgrind \
        vim \
        weasyprint `# For render50` \
        wget \
        zip


# Install CS50 packages
RUN curl https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt update && \
    apt install --yes \
        libcs50


# Install Java 18.x
# http://jdk.java.net/18/
RUN cd /tmp && \
    wget https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_linux-x64_bin.tar.gz && \
    tar xzf openjdk-18.0.1.1_linux-x64_bin.tar.gz && \
    rm --force openjdk-18.0.1.1_linux-x64_bin.tar.gz && \
    mv jdk-18.0.1.1 /opt/ && \
    mkdir --parent /opt/bin && \
    ln --symbolic /opt/jdk-18.0.1.1/bin/* /opt/bin/ && \
    chmod a+rx /opt/bin/*


# Install Node.js 18.x
# https://nodejs.dev/download
# https://github.com/tj/n#installation
RUN curl --location https://raw.githubusercontent.com/tj/n/master/bin/n --output /usr/local/bin/n && \
    chmod a+x /usr/local/bin/n && \
    n 18.2.0


# Install Node.js packages
RUN npm install -g http-server


# Patch http-server, until https://github.com/http-party/http-server/pull/811 is released
RUN sed -i "s/if (details.family === 'IPv4') {/if (details.family === 4) {/" /usr/local/lib/node_modules/http-server/bin/http-server


# Suggested build environment for Python, per pyenv, even though we're building ourselves
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN apt update && \
    apt install --no-install-recommends --yes \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev


# Install Python 3.10.x
# https://www.python.org/downloads/
RUN cd /tmp && \
    curl https://www.python.org/ftp/python/3.10.4/Python-3.10.4.tgz --output Python-3.10.4.tgz && \
    tar xzf Python-3.10.4.tgz && \
    rm --force Python-3.10.4.tgz && \
    cd Python-3.10.4 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive Python-3.10.4 && \
    ln --relative --symbolic /usr/local/bin/pip3 /usr/local/bin/pip && \
    ln --relative --symbolic /usr/local/bin/python3 /usr/local/bin/python && \
    pip3 install --upgrade pip


# Install Python packages
RUN apt update && \
    apt install --yes libmagic-dev `# For style50` && \
    pip3 install \
        awscli \
        "check50<4" \
        compare50 \
        cs50 \
        Flask \
        Flask-Session \
        help50 \
        pytest \
        render50 \
        s3cmd \
        style50 \
        "submit50<4"


# Install Ruby 3.1.x
# https://www.ruby-lang.org/en/downloads/
RUN cd /tmp && \
    curl https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.2.tar.gz --output ruby-3.1.2.tar.gz && \
    tar xzf ruby-3.1.2.tar.gz && \
    rm --force ruby-3.1.2.tar.gz && \
    cd ruby-3.1.2 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive ruby-3.1.2


# Install Ruby packages
RUN gem install \
    bundler \
    jekyll \
    jekyll-theme-cs50 \
    minitest `# So that Bundler needn't install` \
    pygments.rb


# Install SQLite 3.x
# https://www.sqlite.org/download.html
RUN cd /tmp && \
    wget https://www.sqlite.org/2022/sqlite-tools-linux-x86-3380500.zip && \
    unzip sqlite-tools-linux-x86-3380500.zip && \
    rm --force sqlite-tools-linux-x86-3380500.zip && \
    mv sqlite-tools-linux-x86-3380500/* /usr/local/bin/ && \
    rm --force --recursive sqlite-tools-linux-x86-3380500


# Copy files to image
COPY ./etc /etc
COPY ./opt /opt
RUN chmod a+rx /opt/cs50/bin/*


# Add user
RUN useradd --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    umask 0077 && \
    mkdir -p /home/ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu


# Add user to sudoers
RUN echo "\n# CS50 CLI" >> /etc/sudoers && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "Defaults umask_override" >> /etc/sudoers && \
    echo "Defaults umask=0022" >> /etc/sudoers && \
    sed -e "s/^Defaults\tsecure_path=.*/Defaults\t!secure_path/" -i /etc/sudoers



# Version the image (and any descendants)
ARG VCS_REF
RUN echo "$VCS_REF" > /etc/issue
ONBUILD USER root
ONBUILD ARG VCS_REF
ONBUILD RUN echo "$VCS_REF" >> /etc/issue
ONBUILD USER ubuntu


# Set user
USER ubuntu
WORKDIR /home/ubuntu
ENV WORKDIR=/home/ubuntu
