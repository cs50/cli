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
if [ "$(id -u)" != "0" ]; then

    # Clang
    export CC="clang"
    export CFLAGS="-ggdb3 -O0 -std=c11 -Wall -Werror -Wextra -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wshadow"
    export LDLIBS="-lcrypt -lcs50 -lm"

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
    alias sqlite3="sqlite3 -header -separator ' | '"
    alias sudo="sudo " # Trailing space enables elevated command to be an alias

    # Make
    # Ensure no make targets end with .c
    make () {
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
        else
            command make -B $*
        fi
    }

    # Valgrind
    export VALGRIND_OPTS="--memcheck:leak-check=full --memcheck:show-leak-kinds=all --memcheck:track-origins=yes"

    # Which manual sections to search
    export MANSECT=3,2,1
fi

# Aliases
alias pip="pip3 --no-cache-dir"
alias pip3="pip3 --no-cache-dir"
alias pylint="pylint3"
alias python="python3"
alias swift="swift 2> /dev/null"  # https://github.com/cs50/baseimage/issues/49

# Flask
export FLASK_APP="application.py"
export FLASK_DEBUG="0"
export FLASK_ENV="development"

# Python
export PATH="$HOME"/.local/bin:"$PATH"

# Ruby
export GEM_HOME="$HOME"/.gem
export PATH="$GEM_HOME"/bin:"$PATH"
