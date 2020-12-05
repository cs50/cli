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
RUN echo y | unminimize

# Do not exclude man pages & other documentation
# https://github.com/tianon/docker-brew-ubuntu-core/issues/122#issuecomment-380529430
#RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes


# TODO
# Reinstall all currently installed packages in order to get the man pages back
# https://github.com/tianon/docker-brew-ubuntu-core/issues/122#issuecomment-380529430
#RUN apt-get update && \
#    dpkg -l | grep ^ii | cut -d' ' -f3 | xargs apt-get install -y --reinstall && \
#    rm -r /var/lib/apt/lists/*


# Install packages
RUN apt-get update && \
    apt-get install -y \
        apt-file \
        apt-transport-https \
        astyle \
        bash-completion \
        bc \
        #bsdtar \
        clang \
        cmake \
        composer \
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
        ruby \
        ruby-dev `# Avoid "can't find header files for ruby" for gem` \
        sudo \
        telnet \
        traceroute \
        tree \
        unrar \
        unzip \
        valgrind \
        vim \
        wget \
        whois \ 
        yarn && \
    apt-file update
ENV EDITOR nano


# Install Java 15
# http://jdk.java.net/15/
RUN cd /tmp && \
    wget https://download.java.net/java/GA/jdk15.0.1/51f4f36ad4ef43e39d0dfdbaf6549e32/9/GPL/openjdk-15.0.1_linux-x64_bin.tar.gz && \
    tar xzf openjdk-15.0.1_linux-x64_bin.tar.gz && \
    rm -f openjdk-15.0.1_linux-x64_bin.tar.gz && \
    mv jdk-15.0.1 /opt/ && \
    mkdir -p /opt/bin && \
    ln -s /opt/jdk-15.0.1/bin/* /opt/bin/ && \
    chmod a+rx /opt/bin/*
ENV JAVA_HOME "/opt/jdk-15.0.1"


# Install Node.js 15.x
# https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions-enterprise-linux-fedora-and-snap-packages
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm `# Upgrades npm to latest`
ENV NODE_ENV "dev"


# Install Node.js packages
RUN npm install -g grunt http-server nodemon


# Install Python 3.7.x
# https://www.python.org/downloads/
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz && \
    tar xzf Python-3.9.0.tgz && \
    rm -f Python-3.9.0.tgz && \
    cd Python-3.9.0 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf Python-3.9.0 && \
    pip3 install --upgrade pip
ENV PYTHONDONTWRITEBYTECODE "1"


# Install Python packages
RUN pip3 install \
    authlib \
    awscli `# must come after awsebcli to ensure supported version` \
    check50 \
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
    submit50 \
    virtualenv


# Install SQLite 3.34
RUN cd /tmp && \
    wget https://www.sqlite.org/2020/sqlite-tools-linux-x86-3340000.zip && \
    unzip sqlite-tools-linux-x86-3340000.zip && \
    mv sqlite-tools-linux-x86-3340000/* /usr/local/bin/ && \
    rm -rf sqlite-tools-linux-x86-3340000 sqlite-tools-linux-x86-3340000.zip

# Install Swift 5.3
RUN cd /tmp && \
    wget https://swift.org/builds/swift-5.3.1-release/ubuntu1804/swift-5.3.1-RELEASE/swift-5.3.1-RELEASE-ubuntu18.04.tar.gz && \
    tar xzf swift-5.3.1-RELEASE-ubuntu18.04.tar.gz --strip-components=1 -C / && \
    rm -f swift-5.3.1-RELEASE-ubuntu18.04.tar.gz && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libpython2.7


# Install fpm, asciidoctor
# https://github.com/asciidoctor/jekyll-asciidoc/issues/135#issuecomment-241948040
# https://github.com/asciidoctor/jekyll-asciidoc#development
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


# Install CS50 packages
RUN curl --silent https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt-get install -y \
        libcs50 \
        libcs50-java \
        php-cs50
ENV CLASSPATH ".:/usr/share/java/cs50.jar"



# Install Heroku CLI
RUN curl https://cli-assets.heroku.com/install.sh | sh


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
USER ubuntu
WORKDIR /home/ubuntu/workspace


# Update mlocate database in background
CMD (sudo updatedb &) && (bash -l)
