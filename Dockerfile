FROM cs50/baseimage

# ports
EXPOSE 8080 8081 8082

# packages
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
        php-cli \
        php-curl \
        php-gmp \
        php-intl \
        php-mcrypt \
        python \
        python-dev \
        python-pip \
        rpm \
        telnet \
        tree \
        unzip \
        vim \
        zip && \
    apt-file update

# install Composer
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-14-04
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# install Node.js 8.4.0
RUN npm install -g n && PATH=/usr/local/bin:"$PATH" n 8.4.0

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

# install CS50 PPA and CS50-specific packages
RUN add-apt-repository -y ppa:cs50/ppa && \
    apt-get update && \
    apt-get install -y astyle libcs50 libcs50-java php-cs50

# install Python packages
RUN pip install awscli help50 render50

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
#RUN wget --directory-prefix /etc/profile.d/ https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
COPY ./etc/motd /etc/
COPY ./etc/vim/vimrc.local /etc/vim/

# TODO: decide if this breaks child files
#RUN useradd --create-home --groups sudo --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
#    chown -R ubuntu:ubuntu /home/ubuntu && \
#    sed -i 's/^%sudo\s.*/%sudo ALL=NOPASSWD:ALL/' /etc/sudoers
#ENTRYPOINT ["sudo", "-i", "-u", "ubuntu", "sh", "-c"]
#CMD ["cd workspace ; bash -l"]

# ensure /usr/local/{bin,sbin} are (still) first in PATH
ENV PATH /usr/local/sbin:/usr/local/bin:"$PATH"

# run shell in /root
WORKDIR /root
CMD ["bash", "-l"]
