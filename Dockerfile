FROM cs50/baseimage
USER root

# Expose ports (just like Cloud9)
EXPOSE 8080 8081 8082

# Install packages
RUN add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apt-file \
        bash-completion \
        bc \
        bsdtar \
        build-essential \
        cmake \
        dnsutils \
        dos2unix \
        exiftool \
        gdb \
        gettext \
        ImageMagick \
        info \
        man \
        mysql-client \
        nano \
        openjdk-7-jdk \
        openjdk-7-jre-headless \
        npm \
        perl \
        libpcre3 `# https://github.com/oerdnj/deb.sury.org/issues/683#issuecomment-325576448 ` \
        php7.1-cli \
        php7.1-curl \
        php7.1-gmp \
        php7.1-intl \
        php7.1-mcrypt \
        rpm \
        s3cmd \
        telnet \
        tree \
        unzip \
        vim \
        zip && \
    apt-file update

# Install Composer
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-14-04
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js 10.0.0, suppressing CERT_UNTRUSTED (because Ubuntu 14.04's npm is deprecated)
RUN npm install -g --registry http://registry.npmjs.org/ n && PATH=/usr/local/bin:"$PATH" n 10.0.0

# Install Node.js packages
RUN npm install -g grunt http-server

# Install Ruby 2.4
# https://github.com/rbenv/rbenv/blob/master/README.md#installation
# https://github.com/rbenv/ruby-build/blob/master/README.md
ENV RBENV_ROOT /opt/rbenv
RUN apt-get update && \
    apt-get install -y libreadline-dev zlib1g-dev && \
    wget -P /tmp https://github.com/rbenv/rbenv/archive/master.zip && \
    unzip -d /tmp /tmp/master.zip && \
    rm -f /tmp/master.zip && \
    mv /tmp/rbenv-master "$RBENV_ROOT" && \
    chmod a+x "$RBENV_ROOT"/bin/rbenv && \
    wget -P /tmp https://github.com/rbenv/ruby-build/archive/master.zip && \
    unzip -d /tmp /tmp/master.zip && \
    rm -f /tmp/master.zip && \
    mkdir "$RBENV_ROOT"/plugins && \
    mv /tmp/ruby-build-master "$RBENV_ROOT"/plugins/ruby-build && \
    "$RBENV_ROOT"/bin/rbenv install 2.4.0 && \
    "$RBENV_ROOT"/bin/rbenv rehash && \
    "$RBENV_ROOT"/bin/rbenv global 2.4.0

# Install fpm, asciidoctor
# https://github.com/asciidoctor/jekyll-asciidoc/issues/135#issuecomment-241948040
# https://github.com/asciidoctor/jekyll-asciidoc#development
RUN PATH="$RBENV_ROOT"/shims:"$RBENV_ROOT"/bin:"$PATH" gem install \
    asciidoctor \
    bundler \
    fpm \
    jekyll-asciidoc \
    pygments.rb

# Install CS50 packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libcs50-java \
        php-cs50

# Install Python packages
RUN pip install \
    awsebcli \
    awscli `# must come after awsebcli to ensure supported version` \
    help50 \
    render50 \
    submit50

# Install hub
# https://hub.github.com/
# http://stackoverflow.com/a/27869453
RUN mkdir /tmp/hub-linux-amd64 && \
    curl -s -L https://github.com/github/hub/releases/latest | \
        egrep -o '/github/hub/releases/download/.*/hub-linux-amd64-.*.tgz' | \
        wget --base=http://github.com/ -i - -O - | \
        tar xvz -C /tmp/hub-linux-amd64 --strip-components 1 && \
    /tmp/hub-linux-amd64/install && \
    rm -rf /tmp/hub-linux-amd64

# Copy files to image
#RUN wget --directory-prefix /etc/profile.d/ https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
COPY ./etc/motd /etc/
COPY ./etc/profile.d/cli.sh /etc/profile.d/
COPY ./etc/vim/vimrc.local /etc/vim/

# Set PATH
ENV PATH /opt/cs50/bin:/usr/local/sbin:/usr/local/bin:"$RBENV_ROOT"/shims:"$RBENV_ROOT"/bin:"$PYENV_ROOT"/shims:"$PYENV_ROOT"/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN sed -e "s|^PATH=.*$|PATH='$PATH'|g" -i /etc/environment

# Add user to sudoers 
RUN echo "\n# CS50 CLI" >> /etc/sudoers
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "Defaults umask_override" >> /etc/sudoers
RUN sed -e "s|^Defaults\tsecure_path=.*|Defaults\t!secure_path|" -i /etc/sudoers
USER ubuntu
