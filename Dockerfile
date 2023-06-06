FROM ubuntu:22.04
LABEL maintainer="sysadmins@cs50.harvard.edu"
ARG DEBIAN_FRONTEND=noninteractive


# Avoid "delaying package configuration, since apt-utils is not installed"
RUN apt update && \
    apt install --no-install-recommends --yes apt-utils


# Install locales
RUN apt update && \
    apt install --yes locales && \
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
        hu_HU.utf8
ENV LANG=C.UTF-8


# Install curl
RUN apt update && \
    apt install --no-install-recommends --yes \
        ca-certificates \
        curl


# Install Java 19.x
# http://jdk.java.net/19/
RUN cd /tmp && \
    curl --remote-name https://download.java.net/java/GA/jdk19.0.2/fdb695a9d9064ad6b064dc6df578380c/7/GPL/openjdk-19.0.2_linux-x64_bin.tar.gz && \
    tar xzf openjdk-19.0.2_linux-x64_bin.tar.gz && \
    rm --force openjdk-19.0.2_linux-x64_bin.tar.gz && \
    mv jdk-19.0.2 /opt/ && \
    mkdir --parent /opt/bin && \
    ln --symbolic /opt/jdk-19.0.2/bin/* /opt/bin/ && \
    chmod a+rx /opt/bin/*


# Install Node.js 19.x
# https://nodejs.dev/en/download/
# https://github.com/tj/n#installation
RUN curl --location https://raw.githubusercontent.com/tj/n/master/bin/n --output /usr/local/bin/n && \
    chmod a+x /usr/local/bin/n && \
    n 19.8.1


# Suggested build environment for Python, per pyenv, even though we're building ourselves
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN apt update && \
    apt install --no-install-recommends --yes \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev llvm ca-certificates curl wget unzip \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev


# Install Python 3.11.x
# https://www.python.org/downloads/
RUN cd /tmp && \
    curl https://www.python.org/ftp/python/3.11.3/Python-3.11.3.tgz --output Python-3.11.3.tgz && \
    tar xzf Python-3.11.3.tgz && \
    rm --force Python-3.11.3.tgz && \
    cd Python-3.11.3 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive Python-3.11.3 && \
    ln --relative --symbolic /usr/local/bin/pip3 /usr/local/bin/pip && \
    ln --relative --symbolic /usr/local/bin/python3 /usr/local/bin/python && \
    pip3 install --upgrade pip


# Install Ruby 3.2.x
# https://www.ruby-lang.org/en/downloads/
RUN apt update && \
    apt install --no-install-recommends --yes \
        autoconf \
        libyaml-dev && \
    cd /tmp && \
    curl https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.2.tar.gz --output ruby-3.2.2.tar.gz && \
    tar xzf ruby-3.2.2.tar.gz && \
    rm --force ruby-3.2.2.tar.gz && \
    cd ruby-3.2.2 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive ruby-3.2.2


# Install SQLite 3.x
# https://www.sqlite.org/download.html
# https://www.sqlite.org/howtocompile.html#compiling_the_command_line_interface
COPY shell.c.patch /tmp
RUN cd /tmp && \
    curl --remote-name https://www.sqlite.org/2023/sqlite-amalgamation-3420000.zip && \
    unzip sqlite-amalgamation-3420000.zip && \
    rm --force sqlite-amalgamation-3420000.zip && \
    cd sqlite-amalgamation-3420000 && \
    patch shell.c < /tmp/shell.c.patch && \
    gcc -D HAVE_READLINE -D SQLITE_DEFAULT_FOREIGN_KEYS=1 -D SQLITE_OMIT_DYNAPROMPT=1 shell.c sqlite3.c -lpthread -ldl -lm -lreadline -lncurses -o /usr/local/bin/sqlite3 && \
    cd .. && \
    rm --force --recursive sqlite-amalgamation-3420000 && \
    rm --force /tmp/shell.c.patch


# Install GitHub CLI
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt update && \
    apt install gh --no-install-recommends --yes


# Install CS50 packages
RUN curl https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt update && \
    apt install --no-install-recommends --yes \
        libcs50


# Install Ubuntu packages
RUN apt update && \
    apt install --no-install-recommends --yes \
        astyle \
        bash-completion \
        clang \
        coreutils `# for fold` \
        cowsay \
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
        tzdata `# For TZ` \
        valgrind \
        vim \
        weasyprint `# For render50` \
        zip


# Install Node.js packages
RUN npm install --global http-server


# Install Python packages
RUN apt update && \
    apt install --no-install-recommends --yes libmagic-dev `# For style50` && \
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


# Install Ruby packages
RUN gem install \
        bundler \
        jekyll \
        minitest `# So that Bundler needn't install` \
        pygments.rb \
        specific_install && \
    gem specific_install https://github.com/cs50/jekyll-theme-cs50 develop


# Temporary fix for "libssl.so.1.1: cannot open shared object file: No such file or directory" on Ubuntu 22.04
# https://stackoverflow.com/questions/72133316/ubuntu-22-04-libssl-so-1-1-cannot-open-shared-object-file-no-such-file-or-di
RUN cd /tmp && \
    curl --remote-name http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb && \
    curl --remote-name http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb && \
    (dpkg --install libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb || dpkg --install libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb) && \
    rm --force --recursive libssl1.1_1.1.1f-1ubuntu2.19*


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
    chown --recursive ubuntu:ubuntu /home/ubuntu


# Add user to sudoers
RUN echo "\n# CS50 CLI" >> /etc/sudoers && \
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
