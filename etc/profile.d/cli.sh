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

    # Aliases
    alias cp="cp -i"
    alias gdb="gdb -q" # Suppress gdb's startup output
    alias ll="ls --color -F -l"
    alias ls="ls --color -F" # Add trailing slashes
    alias mv="mv -i"
    alias rm="rm -i"
    alias sqlite3="sqlite3 -column -header"
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
    export VALGRIND_OPTS="--memcheck:leak-check=full --memcheck:track-origins=yes"

    # Which manual sections to search
    export MANSECT=3,2,1
fi
