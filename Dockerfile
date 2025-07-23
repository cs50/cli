# Ubuntu version
ARG RELEASE=24.04

# Build stage
FROM ubuntu:${RELEASE} AS builder


# Build-time variables
ARG DEBIAN_FRONTEND=noninteractive
ARG BUILDARCH


# Stage-wide dependencies
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        build-essential \
        ca-certificates \
        curl


# Install Java 24.x
# http://jdk.java.net/24/
RUN cd /tmp && \
    if [ "$BUILDARCH" = "arm64" ]; then ARCH="aarch64"; else ARCH="x64"; fi && \
    curl --remote-name https://download.java.net/java/GA/jdk24/1f9ff9062db4449d8ca828c504ffae90/36/GPL/openjdk-24_linux-${ARCH}_bin.tar.gz && \
    tar xzf openjdk-24_linux-${ARCH}_bin.tar.gz && \
    rm --force openjdk-24_linux-${ARCH}_bin.tar.gz && \
    mv jdk-24 /opt/jdk && \
    mkdir --parent /opt/bin && \
    ln --symbolic /opt/jdk/bin/* /opt/bin/ && \
    chmod a+rx /opt/bin/*


# Install Node.js 22.x
# https://nodejs.dev/en/download/
# https://github.com/tj/n#installation
RUN curl --location https://raw.githubusercontent.com/tj/n/master/bin/n --output /usr/local/bin/n && \
    chmod a+x /usr/local/bin/n && \
    n 22.16.0


# Install Node.js packages
RUN npm install --global \
    http-server


# Patch index.js in http-server
COPY index.js.patch /tmp
RUN cd /usr/local/lib/node_modules/http-server/lib/core/show-dir && \
    patch index.js < /tmp/index.js.patch && \
    rm --force /tmp/index.js.patch


# Suggested build environment for Python, per pyenv, even though we're building ourselves
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        build-essential ca-certificates curl git \
        libssl-dev libbz2-dev libreadline-dev libsqlite3-dev \
        llvm libncursesw5-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
        make tk-dev unzip wget xz-utils zlib1g-dev


# Install Python 3.13.x
# https://www.python.org/downloads/
RUN cd /tmp && \
    curl --remote-name https://www.python.org/ftp/python/3.13.5/Python-3.13.5.tgz && \
    tar xzf Python-3.13.5.tgz && \
    rm --force Python-3.13.5.tgz && \
    cd Python-3.13.5 && \
    CFLAGS="-Os" ./configure --disable-static --enable-optimizations --enable-shared --with-lto --without-tests && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive Python-3.13.5 && \
    ln --relative --symbolic /usr/local/bin/pip3 /usr/local/bin/pip && \
    ln --relative --symbolic /usr/local/bin/python3 /usr/local/bin/python && \
    pip3 install --no-cache-dir --upgrade pip


# Install Ruby 3.4.x
# https://www.ruby-lang.org/en/downloads/
# https://bugs.ruby-lang.org/issues/20085#note-5
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        autoconf \
        libyaml-dev && \
    apt clean && \
    rm --force --recursive /var/lib/apt/lists/* && \
    cd /tmp && \
    curl https://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.4.tar.gz --output ruby-3.4.4.tar.gz && \
    tar xzf ruby-3.4.4.tar.gz && \
    rm --force ruby-3.4.4.tar.gz && \
    cd ruby-3.4.4 && \
    if [ "$BUILDARCH" = "arm64" ]; then ASFLAGS=-mbranch-protection=pac-ret; else ASFLAGS=; fi && \
    ASFLAGS=${ASFLAGS} CFLAGS=-Os ./configure --disable-install-doc --enable-load-relative && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive ruby-3.4.4


# Install Ruby packages
RUN echo "gem: --no-document" > /etc/gemrc && \
    gem install \
        jekyll \
        minitest `# So that Bundler needn't install` \
        pygments.rb \
        specific_install && \
    gem specific_install https://github.com/cs50/jekyll-theme-cs50 develop && \
    gem cleanup


# Install SQLite 3.4x
# https://www.sqlite.org/download.html
# https://www.sqlite.org/howtocompile.html#compiling_the_command_line_interface
COPY shell.c.patch /tmp
RUN cd /tmp && \
    curl --remote-name https://www.sqlite.org/2025/sqlite-amalgamation-3490200.zip && \
    unzip sqlite-amalgamation-3490200.zip && \
    rm --force sqlite-amalgamation-3490200.zip && \
    cd sqlite-amalgamation-3490200 && \
    patch shell.c < /tmp/shell.c.patch && \
    gcc -D HAVE_READLINE -D SQLITE_DEFAULT_FOREIGN_KEYS=1 -D SQLITE_OMIT_DYNAPROMPT=1 shell.c sqlite3.c -lpthread -ldl -lm -lreadline -lncurses -o /usr/local/bin/sqlite3 && \
    cd .. && \
    rm --force --recursive sqlite-amalgamation-3490200 && \
    rm --force /tmp/shell.c.patch


# Final stage
FROM ubuntu:${RELEASE}
LABEL maintainer="sysadmins@cs50.harvard.edu"
ARG DEBIAN_FRONTEND=noninteractive


# Remove exisiting ubuntu user (if any) and home directory
RUN userdel --force --remove ubuntu && \
    rm --force --recursive /home/ubuntu


# Copy files from builder
COPY --from=builder /opt /opt
COPY --from=builder /usr/local /usr/local


# Avoid "delaying package configuration, since apt-utils is not installed"
# Install locales
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        apt-utils \
        locales && \
    locale-gen \
        en_US.utf8 \
        zh_CN.utf8 \
        zh_TW.utf8 \
        fr_FR.utf8 \
        de_DE.utf8 \
        it_IT.utf8 \
        es_ES.utf8 \
        ja_JP.utf8 \
        ko_KR.utf8 \
        ru_RU.utf8 \
        pt_BR.utf8 \
        tr_TR.utf8 \
        pl_PL.utf8 \
        cs_CZ.utf8 \
        hu_HU.utf8 \
        bg_BG.UTF-8
ENV LANG=C.UTF-8


# Install Ubuntu packages
RUN apt update && \
    apt upgrade --yes && \
    apt install --no-install-recommends --no-install-suggests --yes \
        astyle \
        bash-completion \
        build-essential `# dpkg-dev, libc, gcc, g++, make, etc.` \
        ca-certificates \
        clang \
        clang-format \
        coreutils `# For fold` \
        cowsay \
        curl \
        dos2unix \
        dnsutils `# For nslookup` \
        fonts-noto-color-emoji `# For render50` \
        gdb \
        git \
        git-lfs \
        jq \
        less \
        libclang-rt-18-dev `# For clang` \
        liblapack3 `# For R` \
        libmagic-dev `# For style50` \
        libncurses-dev \
        libpango-1.0-0 libharfbuzz0b libpangoft2-1.0-0 `# For render50` \
        libpangocairo-1.0-0 `# For R` \
        libtiff6 `# For R` \
        libxt6 `# For R` \
        libgmp-dev `# For gem` \
        libffi-dev `# For gem` \
        libyaml-0-2 `# Runtime package for gem` \
        man \
        man-db \
        nano \
        openssh-client `# For ssh-keygen` \
        psmisc `# For fuser` \
        sudo \
        tzdata `# For TZ` \
        unzip \
        valgrind \
        vim \
        wget \
        zip \
        zlib1g-dev `# For bundle` && \
    apt clean


# Install CS50 library
RUN curl https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt update && \
    apt install --yes \
        libcs50


# Install Docker CLI
# https://docs.docker.com/engine/install/ubuntu/
# https://docs.docker.com/engine/install/linux-postinstall/
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        ca-certificates \
        curl \
        socat && \
    install -d /etc/apt/keyrings -m 0755 && \
    curl --fail --location --show-error --silent https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update && \
    sudo apt install --no-install-recommends --no-install-suggests --yes \
        docker-ce-cli && \
    groupadd docker


# Install Python packages
RUN pip3 install --no-cache-dir \
        autopep8 \
        cachelib \
        "check50<4" \
        cli50 \
        compare50 \
        cs50==9.4.0 \
        Flask \
        Flask-Session \
        help50 \
        pytest \
        render50 \
        setuptools \
        "style50>2.10.0" \
        "submit50<4"


# Copy files to image
COPY ./etc /etc
COPY ./opt /opt
RUN chmod a+rx /opt/cs50/bin/*


# Disable bracketed paste
# https://bugs.launchpad.net/ubuntu/+source/bash/+bug/1926256
RUN echo >> /etc/inputrc && \
    echo "# Disable bracketed paste" >> /etc/inputrc && \
    echo "set enable-bracketed-paste off" >> /etc/inputrc


# Add user
RUN useradd --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    umask 0077 && \
    mkdir --parents /home/ubuntu && \
    chown --recursive ubuntu:ubuntu /home/ubuntu && \
    echo "\n# CS50 CLI" >> /etc/sudoers && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "Defaults umask_override" >> /etc/sudoers && \
    echo "Defaults umask=0022" >> /etc/sudoers && \
    sed --expression="s/^Defaults\tsecure_path=.*/Defaults\t!secure_path/" --in-place /etc/sudoers && \
    usermod --append --groups docker ubuntu


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
