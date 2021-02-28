FROM cs50/cli
ARG DEBIAN_FRONTEND=noninteractive

RUN sudo apt-get update && \
    sudo apt-get install -y \
        r-base \
        texlive-extra-utils `# for pdfcrop` \
        texlive-xetex

# devtools::install_github
# https://stackoverflow.com/a/58804942/5156190
RUN sudo apt-get update && \
    sudo apt-get install -y \
        libcurl4-gnutls-dev && \
    sudo R -e "install.packages('devtools')"

# https://github.com/owickstrom/pandoc-include-code
RUN sudo apt-get update && \
    sudo apt-get install -y \
        cabal-install && \
    cabal update && \
    cabal install pandoc-include-code

# https://github.com/chdemko/pandoc-latex-environment
RUN sudo pip3 install -y \
    pandoc-latex-environment

# https://pandoc.org/installing.html#linux
RUN sudo wget --directory-prefix /tmp https://github.com/jgm/pandoc/releases/download/2.11.4/pandoc-2.11.4-1-amd64.deb && \
    sudo dpkg -i /tmp/pandoc-2.11.4-1-amd64.deb && \
    sudo rm -f /tmp/pandoc-2.11.4-1-amd64.deb
