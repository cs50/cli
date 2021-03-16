FROM cs50/cli
ARG DEBIAN_FRONTEND=noninteractive

# LaTeX
RUN sudo apt-get update && \
    sudo apt-get install -y \
        texlive-extra-utils `# for pdfcrop` \
        texlive-fonts-extra `# for fontawesome5.sty` \
        texlive-xetex

# R
RUN sudo apt-get update && \
    sudo apt-get install -y \
        r-base

# devtools::install_github
# https://stackoverflow.com/a/58804942/5156190
RUN sudo apt-get update && \
    sudo apt-get install -y \
        libcurl4-gnutls-dev && \
    sudo R -e "install.packages('devtools')"

# Bookdown
RUN sudo R -e "install.packages('bookdown')"

# pandoc
# https://pandoc.org/installing.html#linux
RUN apt-get remove -y pandoc && \
    sudo wget --directory-prefix /tmp https://github.com/jgm/pandoc/releases/download/2.11.4/pandoc-2.11.4-1-amd64.deb && \
    sudo dpkg -i /tmp/pandoc-2.11.4-1-amd64.deb && \
    sudo rm -f /tmp/pandoc-2.11.4-1-amd64.deb

# pandoc-include
# https://github.com/DCsunset/pandoc-include
RUN sudo pip3 install \
    pandoc-include

# pandoc-include-code
# https://github.com/owickstrom/pandoc-include-code
RUN sudo apt-get update && \
    sudo apt-get install -y \
        cabal-install && \
    sudo cabal v1-update && \
    sudo wget --directory-prefix /tmp https://github.com/owickstrom/pandoc-include-code/archive/master.zip && \
    sudo unzip -d /tmp /tmp/master.zip && \
    cd /tmp/pandoc-include-code-master && \
    sudo cabal v1-install pandoc-types unordered-containers `# dependencies` && \
    sudo cabal v1-configure && \
    sudo mkdir -p /root/.cabal/bin `# https://github.com/haskell/cabal/issues/5240#issuecomment-615196339` && \
    sudo cabal v1-install --bindir=/usr/local/bin

# pandoc-latex-environment
# https://github.com/chdemko/pandoc-latex-environment
RUN sudo pip3 install \
        pandoc-latex-environment
