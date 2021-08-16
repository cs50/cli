FROM ubuntu:20.04
LABEL maintainer="sysadmins@cs50.harvard.edu"
ARG DEBIAN_FRONTEND=noninteractive


# Expose ports (just like Cloud9)
EXPOSE 8080 8081 8082


# Avoid "delaying package configuration, since apt-utils is not installed"
RUN apt-get update && apt-get install -y apt-utils


# Environment
RUN apt-get update && apt-get install -y locales && \
    locale-gen "en_US.UTF-8" && dpkg-reconfigure locales
ENV LANG "C.UTF-8"
ENV LC_ALL "C.UTF-8"
ENV LC_CTYPE "C.UTF-8"


# Unminimize system
RUN yes | unminimize


# Install packages
RUN apt-get update && \
    apt-get install -y \
        apt-file \
        apt-transport-https \
        astyle \
        bash-completion \
        bc \
        clang \
        cmake \
        coreutils `# for fold` \
        curl \
        dos2unix \
        dnsutils `# For nslookup` \
        exiftool \
        expect `# For unbuffer` \
        gettext \
        git \
        git-lfs \
        golang-go \
        imagemagick \
        info \
        jq \
        libmysqlclient-dev \
        libtinfo5 `# for clang, https://stackoverflow.com/a/62721741/5156190` \
        lua5.3 \
        man \
        man-db \
        mlocate \
        mysql-client \
        nano \
        ncurses-bin `# for tput` \
        php \
        poppler-utils `# for pdftoppm` \
        rename `# For renaming files` \
        rpm \
        subversion \
        sudo \
        telnet \
        tmux \
        traceroute \
        tree \
        unrar \
        unzip \
        valgrind \
        vim \
        wget \
        whois \
        yarn \
        zip && \
    apt-file update
ENV EDITOR nano


# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | \
        php -- --install-dir=/usr/local/bin --filename=composer


# Install Heroku CLI
RUN curl https://cli-assets.heroku.com/install.sh | sh


# Install Java 16.x
# http://jdk.java.net/16/
RUN cd /tmp && \
    wget https://download.java.net/java/GA/jdk16.0.2/d4a915d82b4c4fbb9bde534da945d746/7/GPL/openjdk-16.0.2_linux-x64_bin.tar.gz && \
    tar xzf openjdk-16.0.2_linux-x64_bin.tar.gz && \
    rm -f openjdk-16.0.2_linux-x64_bin.tar.gz && \
    mv jdk-16.0.2 /opt/ && \
    mkdir -p /opt/bin && \
    ln -s /opt/jdk-16.0.2/bin/* /opt/bin/ && \
    chmod a+rx /opt/bin/*
ENV JAVA_HOME "/opt/jdk-16.0.2"


# Install Node.js 16.x
# https://github.com/tj/n#installation
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /usr/local/bin/n && \
    chmod a+x /usr/local/bin/n && \
    n 16.6.2
ENV NODE_ENV "dev"


# Install Node.js packages
RUN npm install -g http-server


# Suggested build environment for Python, per pyenv, even though we're building ourselves
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    libssl-dev \
    libbz2-dev \
    libncurses5-dev \
    libffi-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev \
    libxml2-dev \
    libxmlsec1-dev \
    llvm \
    make \
    tk-dev \
    wget \
    xz-utils \
    zlib1g-dev

# Install Python 3.9.x
# https://www.python.org/downloads/
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz && \
    tar xzf Python-3.9.6.tgz && \
    rm -f Python-3.9.6.tgz && \
    cd Python-3.9.6 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf Python-3.9.6 && \
    pip3 install --upgrade pip


# Install Python packages
RUN pip3 install \
    authlib \
    awscli `# must come after awsebcli to ensure supported version` \
    "check50<=3" \
    compare50 \
    cs50 \
    Flask \
    Flask-Session \
    help50 \
    matplotlib \
    numpy \
    pandas \
    render50 \
    s3cmd \
    style50 \
    "submit50<=3" \
    virtualenv


# Install Ruby 2.7.x
# https://www.ruby-lang.org/en/downloads/
RUN cd /tmp && \
    wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.4.tar.gz && \
    tar xzf ruby-2.7.4.tar.gz && \
    rm -f ruby-2.7.4.tar.gz && \
    cd ruby-2.7.4 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf ruby-2.7.4


# Install Ruby packages
RUN gem install \
    asciidoctor \
    bundler \
    fpm \
    github-pages \
    jekyll \
    jekyll-asciidoc \
    jekyll-theme-cs50 \
    minitest `# so that Bundler needn't install` \
    pygments.rb


# Install SQLite 3.x
RUN cd /tmp && \
    wget https://www.sqlite.org/2020/sqlite-tools-linux-x86-3340000.zip && \
    unzip sqlite-tools-linux-x86-3340000.zip && \
    rm -f sqlite-tools-linux-x86-3340000.zip && \
    mv sqlite-tools-linux-x86-3340000/* /usr/local/bin/ && \
    rm -rf sqlite-tools-linux-x86-3340000


# Install CS50 packages
RUN curl --silent https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt-get install -y \
        libcs50 \
        libcs50-java \
        php-cs50
ENV CLASSPATH ".:/usr/share/java/cs50.jar"


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


# Update mlocate database in background
CMD (sudo updatedb &) && (bash -l)
