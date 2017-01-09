FROM ubuntu:14.04

# ENV
RUN locale-gen "en_US.UTF-8" && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
ENV FLASK_APP application.py
ENV FLASK_DEBUG 1
ENV LANG "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"
ENV PATH /root/.local/bin:/opt/cs50/bin:"$PATH"
ENV PYTHONDONTWRITEBYTECODE 1
ENV TERM xterm

# packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apt-file \
        bash-completion \
        bc \
        bsdtar \
        build-essential \
        clang-3.6 \
        curl \
        dnsutils \
        dos2unix \
        exiftool \
        gdb \
        gettext-base \
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
        php5-cli \
        php5-curl \
        php5-gmp \
        php5-intl \
        php5-mcrypt \
        python \
        python-dev \
        python-pip \
        python3 \
        python3-dev \
        python3-pip \
        rpm \
        ruby \
        ruby-dev \
        software-properties-common \
        sqlite3 \
        telnet \
        unzip \
        valgrind \
        vim \
        wget \
        zip && \
    apt-file update

# install composer
RUN curl -L -o /usr/local/bin/composer https://getcomposer.org/composer.phar && chmod a+x /usr/local/bin/composer

# upgrade node
RUN npm install -g coffee-script n && n stable

# install jekyll-asciidoc
# https://github.com/asciidoctor/jekyll-asciidoc/issues/135#issuecomment-241948040
# https://github.com/asciidoctor/jekyll-asciidoc#development
RUN apt-get update && \
    apt-add-repository -y ppa:brightbox/ruby-ng && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y ruby2.3 ruby2.3-dev
RUN gem install \
    asciidoctor \
    bundler \
    fpm \
    jekyll-asciidoc \
    jekyll-redirect-from \
    pygments.rb

# environment
COPY ./etc/motd /etc/
COPY ./etc/profile.d/cli50.sh /etc/profile.d/
COPY ./etc/vim/vimrc.local /etc/vim/

# ubuntu
# TODO: decide if this breaks child files
#RUN useradd --create-home --groups sudo --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
#    chown -R ubuntu:ubuntu /home/ubuntu && \
#    sed -i 's/^%sudo\s.*/%sudo ALL=NOPASSWD:ALL/' /etc/sudoers

# entrypoint
#ENTRYPOINT ["sudo", "-i", "-u", "ubuntu", "sh", "-c"]
#CMD ["cd workspace ; bash -l"]
WORKDIR /root
CMD ["bash", "-l"]
