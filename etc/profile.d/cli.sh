# Interactive shells
if [ "$PS1" ]; then

    # MOTD
    cat /etc/motd

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

    # Aliases
    alias cd="HOME=~/workspace cd"
    alias cp="cp -i"
    alias ll="ls -l --color=auto"
    alias mv="mv -i"
    alias pip="pip3 --no-cache-dir"
    alias pip3="pip3 --no-cache-dir"
    alias python="python3"
    alias rm="rm -i"
    alias sudo="sudo "

    # Editor
    export EDITOR=nano

fi
