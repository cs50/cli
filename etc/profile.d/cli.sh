# Interactive shells
if [ "$PS1" ]; then

    # Append trailing slashes
    _cwdSlashAtEnd () {
        TITLE="$(dirs +0)"

        # No argument, full cwd
        if [ -z "$1" ] ; then
            TITLE="${TITLE%/}"

        # One arg, basename only
        else
            TITLE="${TITLE##*/}"
        fi

        echo -n "${TITLE}/"
    }

    # Editor
    export EDITOR="nano"

    # History
    # https://www.shellhacks.com/tune-command-line-history-bash/
    export HISTCONTROL='ignoreboth' # Ignore duplicates and command lines starting space
    export PROMPT_COMMAND='history -a' # Store Bash History Immediately

    # Prompt
    if type __git_ps1 > /dev/null 2>&1; then
        PS1='\[$(printf "\x0f")\033[01;34m\]$(_cwdSlashAtEnd)\[\033[00m\]$(__git_ps1 " (%s)") $ '
    fi
fi

# If not root
if [ "$(whoami)" != "root" ]; then

    # File mode creation mask
    umask 0077

    # Aliases
    alias cp="cp -i"
    alias gdb="gdb -q" # Suppress gdb's startup output
    alias grep="grep --color" # Suppress gdb's startup output
    alias ll="ls --color -F -l --ignore=lost+found"
    alias ls="ls --color -F --ignore=lost+found" # Add trailing slashes
    alias mv="mv -i"
    alias pip="pip --no-cache-dir"
    alias rm="rm -i"
    alias sudo="sudo " # Trailing space enables elevated command to be an alias

    # Localization
    export LANG="C.UTF-8"
    export LC_ALL="C.UTF-8"
    export LC_CTYPE="C.UTF-8"

    # Make
    export CC="clang"
    export CFLAGS="-ferror-limit=1 -ggdb3 -O0 -std=c11 -Wall -Werror -Wextra -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wshadow"
    export LDLIBS="-lcrypt -lcs50 -lm"
    make() {

        # Ensure no make targets end with .c
        local args=""
        local invalid_args=0
        for arg; do
            case "$arg" in
                (*.c) arg=${arg%.c}; invalid_args=1;;
            esac
            args="$args $arg"
        done
        if [ $invalid_args -eq 1 ]; then
            echo "Did you mean 'make$args'?"
            return 1
        fi

        # Run make
        command make -B -s $*
    }

    # Manual sections to search
    export MANSECT=3,2,1

    # Python
    export PYTHONDONTWRITEBYTECODE="1"

    # Valgrind
    export VALGRIND_OPTS="--memcheck:leak-check=full --memcheck:show-leak-kinds=all --memcheck:track-origins=yes"
    valgrind() {
        for arg; do
            if echo "$arg" | grep -Eq "(^python|\.py$)"; then
                echo "Afraid valgrind does not support Python programs!"
                return 1
            fi
        done
        command valgrind $*
    }
fi

# Python
export PATH="$HOME"/.local/bin:"$PATH"

# Ruby
export GEM_HOME="$HOME"/.gem
export PATH="$GEM_HOME"/bin:"$PATH"
