FROM cs50/cli
ARG DEBIAN_FRONTEND=noninteractive

RUN sudo apt-get update && \
    sudo apt-get install -y r-base texlive-xetex && \
    sudo R -e "install.packages(c('bookdown'))"

# https://stackoverflow.com/a/20924082
RUN sudo apt-get update && \
    sudo apt-get install -y libcurl4-gnutls-dev libxml2-dev && \
    sudo R -e "install.packages('devtools')" && \
    sudo R -e "devtools::install_github('kbodwin/flair')"

RUN sudo wget --directory-prefix /tmp https://github.com/jgm/pandoc/releases/download/2.11.4/pandoc-2.11.4-1-amd64.deb && \
    sudo dpkg -i /tmp/pandoc-2.11.4-1-amd64.deb && \
    sudo rm -f /tmp/pandoc-2.11.4-1-amd64.deb
