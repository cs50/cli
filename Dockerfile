FROM cs50/baseimage
USER root
ARG DEBIAN_FRONTEND=noninteractive

# Expose ports (just like Cloud9)
EXPOSE 8080 8081 8082

# Do not exclude man pages & other documentation
# https://github.com/tianon/docker-brew-ubuntu-core/issues/122#issuecomment-380529430
RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes

# Reinstall all currently installed packages in order to get the man pages back
# https://github.com/tianon/docker-brew-ubuntu-core/issues/122#issuecomment-380529430
RUN apt-get update && \
    dpkg -l | grep ^ii | cut -d' ' -f3 | xargs apt-get install -y --reinstall && \
    rm -r /var/lib/apt/lists/*

# Install packages
RUN apt-get update && \
    apt-get install -y \
        apt-file \
        bash-completion \
        bc \
        bsdtar \
        cmake \
        dos2unix \
        dnsutils `# For nslookup` \
        exiftool \
        expect `# For unbuffer` \
        gettext \
        golang-go \
        imagemagick \
        info \
        man \
        mysql-client \
        nano \
        poppler-utils `# for pdftoppm` \
        rename `# For renaming files` \
        rpm \
        s3cmd \
        sudo \
        telnet \
        traceroute \
        tree \
        vim \
        wget \
        whois && \
    apt-file update
ENV EDITOR nano

# Install Node.js packages
RUN npm install -g grunt http-server nodemon

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
    pygments.rb

# Install Python packages
RUN pip3 install \
    awsebcli \
    awscli `# must come after awsebcli to ensure supported version` \
    compare50 \
    help50 \
    matplotlib \
    numpy \
    pandas \
    render50 \
    submit50 \
    virtualenv

# Copy files to image
RUN wget --directory-prefix /etc/profile.d/ https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
COPY ./etc/profile.d/cli.sh /etc/profile.d/
COPY ./etc/vim/vimrc.local /etc/vim/
RUN echo "This is CS50 CLI." > /etc/motd

# Add user to sudoers 
RUN echo "\n# CS50 CLI" >> /etc/sudoers
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "Defaults umask_override" >> /etc/sudoers
RUN echo "Defaults umask=0022" >> /etc/sudoers
RUN sed -e "s|^Defaults\tsecure_path=.*|Defaults\t!secure_path|" -i /etc/sudoers
USER ubuntu
