# If not root
if [ "$(whoami)" != "root" ]; then

    # $PATH
    export PATH="/opt/cs50/bin":"/opt/bin":"$PATH"

    # $PS1
    _cwdSlashAtEnd () {
        TITLE="$(dirs +0)"
        TITLE="${TITLE%/}"
        echo -n "${TITLE}/"
    }
    if type __git_ps1 > /dev/null 2>&1; then
        PS1='\[$(printf "\x0f")\033[01;34m\]$(_cwdSlashAtEnd)\[\033[00m\]$(__git_ps1 " (%s)") $ '
    fi

    # Aliases
    alias cd="HOME=\"$WORKDIR\" cd"
    alias cowsay="/usr/games/cowsay"
    alias cp="cp -i"
    alias gdb="gdb -q" # Suppress gdb's startup output
    alias grep="grep --color" # Suppress gdb's startup output
    alias ls="ls --color -F --ignore=lost+found" # Add trailing slashes
    alias mv="mv -i"
    alias pip="pip --no-cache-dir"
    alias python="python -q"
    alias rm="rm -i"
    alias sudo="sudo " # Trailing space enables elevated command to be an alias

    # Editor
    export EDITOR="nano"

    # File mode creation mask
    umask 0077

    # History
    # https://www.shellhacks.com/tune-command-line-history-bash/
    export HISTCONTROL='ignoreboth' # Ignore duplicates and command lines starting space
    export PROMPT_COMMAND='history -a' # Store Bash History Immediately

    # Java
    export JAVA_HOME="/opt/jdk-19.0.2"

    # Localization
    export LANG="C.UTF-8"
    export LC_ALL="C.UTF-8"
    export LC_CTYPE="C.UTF-8"

    # Make
    export CC="clang"
    export CFLAGS="-ferror-limit=1 -gdwarf-4 -ggdb3 -O0 -std=c11 -Wall -Werror -Wextra -Wno-gnu-folding-constant -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wno-unused-but-set-variable -Wshadow"
    export LDLIBS="-lcrypt -lcs50 -lm"

    # Manual sections to search
    export MANSECT=3,2,1

    # Node.js
    export NODE_ENV="dev"

    # Python
    export PATH="$HOME"/.local/bin:"$PATH"
    export PYTHONDONTWRITEBYTECODE="1"

    # Ruby
    export GEM_HOME="$HOME"/.gem
    export PATH="$GEM_HOME"/bin:"$PATH"

    # Valgrind
    export VALGRIND_OPTS="--memcheck:leak-check=full --memcheck:show-leak-kinds=all --memcheck:track-origins=yes"
fi
