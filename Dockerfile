FROM cs50/baseimage:bionic
USER root
ARG DEBIAN_FRONTEND=noninteractive

# Expose ports (just like Cloud9)
EXPOSE 8080 8081 8082

# Install packages
RUN apt-get update && \
    apt-get install -y \
        bc \
        dos2unix \
        dnsutils `# for nslookup` \
        golang-go \
        man \
        nano \
        mysql-client \
        npm \
        php \
        ruby \
        ruby-dev `# Avoid "can't find header files for ruby" for gem` \
        s3cmd \
        sudo \
        telnet \
        tree \
        vim

# TODO: decide which needed
#        apt-file \
#        bash-completion \
#        bsdtar \
#        build-essential \
#        cmake \
#        exiftool \
#        gettext \
#        ImageMagick \
#        info \
#        openjdk-7-jdk \
#        openjdk-7-jre-headless \
#        libpcre3 `# https://github.com/oerdnj/deb.sury.org/issues/683#issuecomment-325576448 ` \
#        rpm \
#        vim && \
#    apt-file update

# Install Composer
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer | php -- --quiet

# Install Node.js 10.1.0
RUN npm install -g n && n 10.1.0

# Install Node.js packages
RUN npm install -g grunt http-server

# Install fpm, asciidoctor
# https://github.com/asciidoctor/jekyll-asciidoc/issues/135#issuecomment-241948040
# https://github.com/asciidoctor/jekyll-asciidoc#development
RUN gem install \
    asciidoctor \
    bundler \
    fpm \
    jekyll-asciidoc \
    pygments.rb

## Install CS50 packages
#RUN apt-get update && \
#    apt-get install -y \
#        libcs50-java \
#        php-cs50

# Install Python packages
RUN pip3 install \
    awsebcli \
    awscli `# must come after awsebcli to ensure supported version` \
    help50 \
    render50 \
    submit50

# Install hub
# https://hub.github.com/
RUN git clone https://github.com/github/hub.git /tmp/hub && \
    cd /tmp/hub && \
    script/build -o /usr/local/bin/hub && \
    rm -rf /tmp/hub

# Copy files to image
#RUN wget --directory-prefix /etc/profile.d/ https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
COPY ./etc/motd /etc/
COPY ./etc/profile.d/cli.sh /etc/profile.d/
COPY ./etc/vim/vimrc.local /etc/vim/

# Add user to sudoers 
RUN echo "\n# CS50 CLI" >> /etc/sudoers
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "Defaults umask_override" >> /etc/sudoers
RUN sed -e "s|^Defaults\tsecure_path=.*|Defaults\t!secure_path|" -i /etc/sudoers
USER ubuntu
