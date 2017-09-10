FROM ubuntu:14.04

# ports
EXPOSE 8080 8081 8082

# environment
RUN locale-gen "en_US.UTF-8" && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
ENV LANG "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"
ENV PATH /opt/cs50/bin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/sbin:/bin
ENV PYTHONDONTWRITEBYTECODE 1
ENV TERM xterm

# packages
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apt-file \
        apt-transport-https \
        bash-completion \
        bc \
        bsdtar \
        build-essential \
        clang-3.8 \
        cmake \
        curl \
        dnsutils \
        dos2unix \
        exiftool \
        gdb \
        gettext \
        git \
        ImageMagick \
        info \
        man \
        mysql-client \
        nano \
        openjdk-7-jdk \
        openjdk-7-jre-headless \
        npm \
        perl \
        php-cli \
        php-curl \
        php-gmp \
        php-intl \
        php-mcrypt \
        python \
        python-dev \
        python-pip \
        rpm \
        software-properties-common \
        sqlite3 \
        telnet \
        tree \
        unzip \
        valgrind \
        vim \
        wget \
        zip && \
    apt-file update && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.8 380 \
        --slave /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 \
        --slave /usr/bin/clang-check clang-check /usr/bin/clang-check-3.8 \
        --slave /usr/bin/clang-query clang-query /usr/bin/clang-query-3.8 \
        --slave /usr/bin/clang-rename clang-rename /usr/bin/clang-rename-3.8

# install Composer
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-14-04
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# install Node.js 7.6.0
RUN npm install -g n && PATH=/usr/local/bin:"$PATH" n 7.6.0

# install CoffeeScript
RUN npm install -g coffee-script

# install Ruby 2.4
# https://github.com/rbenv/rbenv/blob/master/README.md#installation
# https://github.com/rbenv/ruby-build/blob/master/README.md
ENV RBENV_ROOT /opt/rbenv
RUN apt-get update && \
    apt-get install -y libreadline-dev zlib1g-dev && \
    wget -P /tmp https://github.com/rbenv/rbenv/archive/master.zip && \
    unzip -d /tmp /tmp/master.zip && \
    rm -f /tmp/master.zip && \
    mv /tmp/rbenv-master /opt/rbenv && \
    chmod a+x /opt/rbenv/bin/rbenv && \ 
    wget -P /tmp https://github.com/rbenv/ruby-build/archive/master.zip && \
    unzip -d /tmp /tmp/master.zip && \
    rm -f /tmp/master.zip && \
    mkdir /opt/rbenv/plugins && \
    mv /tmp/ruby-build-master /opt/rbenv/plugins/ruby-build && \
    /opt/rbenv/bin/rbenv install 2.4.0 && \
    /opt/rbenv/bin/rbenv rehash && \
    /opt/rbenv/bin/rbenv global 2.4.0
ENV PATH "$RBENV_ROOT"/shims:"$RBENV_ROOT"/bin:"$PATH"

# install fpm, asciidoctor
# https://github.com/asciidoctor/jekyll-asciidoc/issues/135#issuecomment-241948040
# https://github.com/asciidoctor/jekyll-asciidoc#development
#RUN apt-add-repository -y ppa:brightbox/ruby-ng && \
#    apt-get update && \
#    DEBIAN_FRONTEND=noninteractive apt-get install -y ruby2.4 ruby2.4-dev
RUN gem install \
    asciidoctor \
    bundler \
    fpm \
    jekyll-redirect-from \
    pygments.rb \
    specific_install && \
    gem specific_install https://github.com/asciidoctor/jekyll-asciidoc.git

# install Python 3.6
# https://github.com/yyuu/pyenv/blob/master/README.md#installation
# https://github.com/yyuu/pyenv/wiki/Common-build-problems
ENV PYENV_ROOT /opt/pyenv
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
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

# install CS50 PPA and CS50-specific packages
RUN add-apt-repository -y ppa:cs50/ppa && \
    apt-get update && \
    apt-get install -y libcs50 libcs50-java php-cs50

RUN pip install cs50 help50 render50 submit50

# install git-lfs
# https://packagecloud.io/github/git-lfs/install#manual
RUN echo "deb https://packagecloud.io/github/git-lfs/ubuntu/ trusty main" > /etc/apt/sources.list.d/github_git-lfs.list && \
    echo "deb-src https://packagecloud.io/github/git-lfs/ubuntu/ trusty main" >> /etc/apt/sources.list.d/github_git-lfs.list && \
    curl -L https://packagecloud.io/github/git-lfs/gpgkey | sudo apt-key add - && \
    apt-get update && \
    apt-get install -y git-lfs && \
    git lfs install

# install hub
# https://hub.github.com/
# http://stackoverflow.com/a/27869453
RUN mkdir /tmp/hub-linux-amd64 && \
    curl -s -L https://github.com/github/hub/releases/latest | \
        egrep -o '/github/hub/releases/download/.*/hub-linux-amd64-.*.tgz' | \
        wget --base=http://github.com/ -i - -O - | \
        tar xvz -C /tmp/hub-linux-amd64 --strip-components 1 && \
    /tmp/hub-linux-amd64/install && \
    rm -rf /tmp/hub-linux-amd64

# /etc
COPY ./etc/motd /etc/
COPY ./etc/profile.d/cli.sh /etc/profile.d/
COPY ./etc/vim/vimrc.local /etc/vim/

# ubuntu 
RUN useradd --create-home --groups sudo --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu && \
    sed -i 's/^%sudo\s.*/%sudo ALL=NOPASSWD:ALL/' /etc/sudoers
WORKDIR /home/ubuntu/workspace
CMD ["bash", "-l"]
