FROM cs50/baseimage:ubuntu
USER root

# Expose ports
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

# Install Composer
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-14-04
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js 8.4.0
RUN npm install -g n && PATH=/usr/local/bin:"$PATH" n 8.4.0

# Install fpm, asciidoctor
# https://github.com/asciidoctor/jekyll-asciidoc/issues/135#issuecomment-241948040
# https://github.com/asciidoctor/jekyll-asciidoc#development
RUN gem install \
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
    awscli \
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

# ensure /usr/local/{bin,sbin} are (still) first in PATH
ENV PATH /usr/local/sbin:/usr/local/bin:"$PATH"

# Add user to sudoers 
RUN echo "\n# CS50 CLI" >> /etc/sudoers
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "Defaults umask_override" >> /etc/sudoers
RUN sed -e "s|^Defaults\tsecure_path=.*|Defaults\t!secure_path|" -i /etc/sudoers
USER ubuntu
