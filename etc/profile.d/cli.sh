# Interactive shells
if [ "$PS1" ]; then

    # Append trailing slashes
    cwdSlashAtEnd () {
        TITLE="$(dirs +0)"

        if [ -z "$1" ] ; then
            # no argument, full cwd
            TITLE="${TITLE%/}"
        else
            # one arg, basename only
            TITLE="${TITLE##*/}"
        fi

        echo -n "${TITLE}/"
    }

    # Default editor
    export EDITOR="nano"

    # History
    # https://www.shellhacks.com/tune-command-line-history-bash/
    export PROMPT_COMMAND='history -a' # Store Bash History Immediately

    # Prompt
    PS1='\[$(printf "\x0f")\033[01;34m\]$(cwdSlashAtEnd)\[\033[00m\]$(__git_ps1 " (%s)") $ '

    # Terminal windows' titles
    case "$TERM" in
    xterm-*|rxvt*|screen*)
        PS1='\[\e]0;\a\033k$(cwdSlashAtEnd base)\033\\\]'"$PS1"
        ;;
    *)
        ;;
    esac
fi

# If not root
if [ "$USER" != "root" ]; then

    # Clang

    # File mode creation mask
    umask 0077

    # Aliases
    alias cp="cp -i"
    alias gdb="gdb -q" # Suppress gdb's startup output
    alias grep="grep --color" # Suppress gdb's startup output
    alias ll="ls --color -F -l"
    alias ls="ls --color -F" # Add trailing slashes
    alias mv="mv -i"
    alias rm="rm -i"
    alias sudo="sudo " # Trailing space enables elevated command to be an alias

    # Make
    # Ensure no make targets end with .c
    make() {

        # Check for arguments ending with .c
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
        local CC="clang"
        local CFLAGS="-ggdb3 -O0 -std=c11 -Wall -Werror -Wextra -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wshadow"
        local LDLIBS="-lcrypt -lcs50 -lm"
        command make -B $*
    }

    # Valgrind
    valgrind() {
        for arg; do
            if echo "$arg" | grep -Eq "(^python|.py$)"; then
                echo "Afraid valgrind does not support Python programs!"
                return 1
            fi
        done
        local VALGRIND_OPTS="--memcheck:leak-check=full --memcheck:show-leak-kinds=all --memcheck:track-origins=yes"
        command valgrind $*
    }

    # Which manual sections to search
    export MANSECT=3,2,1

    # Localization
    export LANG="C.UTF-8"
    export LC_ALL="C.UTF-8"
    export LC_CTYPE="C.UTF-8"

fi

# If ubuntu
if [ "$USER" == "ubuntu" ]; then

    # Alias
    alias cd="HOME=~/workspace cd"
fi

# Aliases
alias pip="pip3 --no-cache-dir"
alias pip3="pip3 --no-cache-dir"
alias pylint="pylint3"
alias python="python3"
alias swift="swift 2> /dev/null"  # https://github.com/cs50/baseimage/issues/49

# Editor
export EDITOR="nano"

# Python
export PATH="$HOME"/.local/bin:"$PATH"
export PYTHONDONTWRITEBYTECODE="1"

# Ruby
export GEM_HOME="$HOME"/.gem
export PATH="$GEM_HOME"/bin:"$PATH"
