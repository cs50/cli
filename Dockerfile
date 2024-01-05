# Build statge
FROM ubuntu:22.04 as builder
ARG DEBIAN_FRONTEND=noninteractive


# Suggested build environment for Python, per pyenv, even though we're building ourselves
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        curl ca-certificates build-essential git \
        libssl-dev libbz2-dev libreadline-dev libsqlite3-dev \
        llvm libncursesw5-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
        make tk-dev unzip wget xz-utils zlib1g-dev


# Install Python 3.11.x
# https://www.python.org/downloads/
RUN cd /tmp && \
    curl https://www.python.org/ftp/python/3.11.7/Python-3.11.7.tgz --output Python-3.11.7.tgz && \
    tar xzf Python-3.11.7.tgz && \
    rm --force Python-3.11.7.tgz && \
    cd Python-3.11.7 && \
    CFLAGS="-Os" ./configure --enable-optimizations --without-tests && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive Python-3.11.7 && \
    ln --relative --symbolic /usr/local/bin/pip3 /usr/local/bin/pip && \
    ln --relative --symbolic /usr/local/bin/python3 /usr/local/bin/python && \
    pip3 install --no-cache-dir --upgrade pip


# Install Ruby 3.3.x
# https://www.ruby-lang.org/en/downloads/
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        autoconf \
        libyaml-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    cd /tmp && \
    curl https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.0.tar.gz --output ruby-3.3.0.tar.gz && \
    tar xzf ruby-3.3.0.tar.gz && \
    rm --force ruby-3.3.0.tar.gz && \
    cd ruby-3.3.0 && \
    CFLAGS="-Os" ./configure --disable-install-doc --enable-load-relative && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive ruby-3.3.0


# Install Ruby packages
RUN gem install --no-document \
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
    curl --remote-name https://www.sqlite.org/2023/sqlite-amalgamation-3440200.zip && \
    unzip sqlite-amalgamation-3440200.zip && \
    rm --force sqlite-amalgamation-3440200.zip && \
    cd sqlite-amalgamation-3440200 && \
    patch shell.c < /tmp/shell.c.patch && \
    gcc -D HAVE_READLINE -D SQLITE_DEFAULT_FOREIGN_KEYS=1 -D SQLITE_OMIT_DYNAPROMPT=1 shell.c sqlite3.c -lpthread -ldl -lm -lreadline -lncurses -o /usr/local/bin/sqlite3 && \
    cd .. && \
    rm --force --recursive sqlite-amalgamation-3440200 && \
    rm --force /tmp/shell.c.patch


# Install Java 21.x
# http://jdk.java.net/21/
RUN cd /tmp && \
    curl --remote-name https://download.java.net/java/GA/jdk21.0.1/415e3f918a1f4062a0074a2794853d0d/12/GPL/openjdk-21.0.1_linux-x64_bin.tar.gz && \
    tar xzf openjdk-21.0.1_linux-x64_bin.tar.gz && \
    rm --force openjdk-21.0.1_linux-x64_bin.tar.gz && \
    mv jdk-21.0.1 /opt/ && \
    mkdir --parent /opt/bin && \
    ln --symbolic /opt/jdk-21.0.1/bin/* /opt/bin/ && \
    chmod a+rx /opt/bin/*


# Install Node.js 21.x
# https://nodejs.dev/en/download/
# https://github.com/tj/n#installation
RUN curl --location https://raw.githubusercontent.com/tj/n/master/bin/n --output /usr/local/bin/n && \
    chmod a+x /usr/local/bin/n && \
    n 21.5.0


# Install GitHub CLI
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt update && \
    apt install gh --no-install-recommends --no-install-suggests --yes


# Final stage
FROM ubuntu:22.04
LABEL maintainer="sysadmins@cs50.harvard.edu"
ARG DEBIAN_FRONTEND=noninteractive


# Copy files from builder
COPY --from=builder /usr /usr
COPY --from=builder /opt /opt


# Avoid "delaying package configuration, since apt-utils is not installed"
# Install locales
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        apt-utils \
        curl \
        ca-certificates \
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


# Install CS50, Ubuntu, and Python packages
RUN curl https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt update && \
    apt install --no-install-recommends --no-install-suggests --yes \
        astyle \
        bash-completion \
        build-essential `# dpkg-dev, libc, gcc, g++, make, etc.`\
        clang \
        coreutils `# For fold` \
        cowsay \
        dos2unix \
        dnsutils `# For nslookup` \
        fonts-noto-color-emoji `# For render50` \
        gdb \
        git \
        git-lfs \
        jq \
        less \
        libcs50 \
        libmagic-dev `# For style50` \
        libpango-1.0-0 libharfbuzz0b libpangoft2-1.0-0 `# For render50` \
        libyaml-0-2 `# Runtime package for gem` \
        man \
        man-db \
        nano \
        openssh-client `# For ssh-keygen` \
        psmisc `# For fuser` \
        ruby-dev `# Ruby development headers` \
        sudo \
        tzdata `# For TZ` \
        unzip \
        valgrind \
        vim \
        zip && \
        apt clean && \
    pip3 install --no-cache-dir \
        autopep8 \
        black \
        "check50<4" \
        compare50 \
        cs50 \
        Flask \
        Flask-Session \
        help50 \
        pytest \
        render50 \
        setuptools \
        style50 \
        "submit50<4"


# Install Node.js packages
RUN npm install --global \
    http-server


# Patch index.js in http-server
COPY index.js.patch /tmp
RUN cd /usr/local/lib/node_modules/http-server/lib/core/show-dir && \
    patch index.js < /tmp/index.js.patch && \
    rm --force /tmp/index.js.patch


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
    sed --expression="s/^Defaults\tsecure_path=.*/Defaults\t!secure_path/" --in-place /etc/sudoers


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
