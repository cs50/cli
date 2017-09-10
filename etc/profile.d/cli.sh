# if not root
if [ "$(id -u)" != "0" ]; then

	# prompt
	export PROMPT_COMMAND='__git_ps1 "\w/" " \\\$ "'

    # set umask
    umask 0077

    # configure clang
    export CC="clang"
    export CFLAGS="-fsanitize=integer -fsanitize=undefined -ggdb3 -O0 -std=c11 -Wall -Werror -Wextra -Wno-sign-compare -Wshadow"
    export LDLIBS="-lcrypt -lcs50 -lm"

    # protect user
    alias cp="cp -i"
    alias mv="mv -i"
    alias rm="rm -i"

    # suppress gdb's startup output
    alias gdb="gdb -q"

    # unconditionally make all targets
    alias make="make -B"

    # shift out and in of block character palettes
    alias break50="printf '\x0e'"
    alias fix50="printf '\x0f'"

	# message of the day
	if [ -f /etc/motd ]; then
		cat /etc/motd
	fi

fi

# java
export CLASSPATH=".:/usr/share/java/cs50.jar"

# python3
export PYENV_ROOT=/opt/pyenv
export PATH="$PYENV_ROOT"/shims:"$PYENV_ROOT"/bin:"$PATH"
alias pip="pip3"
alias pylint="pylint3"
alias python="python3"
export PYTHONDONTWRITEBYTECODE="1"

# ruby
export RBENV_ROOT=/opt/rbenv
export PATH="$RBENV_ROOT"/shims:"$RBENV_ROOT"/bin:"$PATH"

# sqlite3
alias sqlite3="sqlite3 -column -header"

# sudo
# trailing space enables elevated command to be an alias
alias sudo="sudo "

# apt-get
export DEBIAN_FRONTEND=noninteractive

# flask
export FLASK_APP="application.py"
export FLASK_DEBUG="1"
flask()
{
    # flask run
    if [ "$1" == "run" ]; then

        # otherwise FLASK_DEBUG=1 suppresses this error in shell
        if [ "$FLASK_DEBUG" ] && [ ! -z "$FLASK_APP" ] && [ ! -f "$FLASK_APP" ]; then
            echo "Usage: flask run [OPTIONS]"
            echo
            echo "Error: The file/path provided ($FLASK_APP) does not appear to exist.  Please verify the path is correct.  If app is not on PYTHONPATH, ensure the extension is .py"
            return 1
        fi

        # default options
        host="--host=0.0.0.0"
        port="--port=8080"
        threads="--with-threads"

        # override default options
        shift
        while test ${#} -gt 0
        do
            if echo "$1" | egrep -q "^--host="; then
                host="$1"
            elif echo "$1" | egrep -q "^--port="; then
                port="$1"
            elif echo "$1" | egrep -q "^--with(out)?-threads$"; then
                threads="$1"
            else
                if [ -z "$options" ]; then
                    options="$1"
                else
                    options="$options $1"
                fi
            fi
            shift
        done

        # spawn flask
        script --flush --quiet --return /dev/null --command "FLASK_APP=\"$FLASK_APP\" FLASK_DEBUG=\"$FLASK_DEBUG\" flask run $host $port $threads $options" |
            while IFS= read -r line
            do
                # rewrite address as hostname50
                echo "$line" | sed "s#\( *Running on http://\)[^:]\+\(:.\+\)#\1$(hostname50)\2#"
            done
    else
        command flask "$@"
    fi
}

# http-server
http_server()
{
    # default options
    a="-a 0.0.0.0"
    c="-c-1"
    cors="--cors"
    i="-i false"
    p="-p 8080"

    # override default options
    while test ${#} -gt 0
    do
        if echo "$1" | egrep -q "^-a$"; then
            a="$1 $2"
            shift
            shift
        elif echo "$1" | egrep -q "^-c-?[0-9]+$"; then
            c="$1"
            shift
        elif echo "$1" | egrep -q "^--cors(=.*)?$"; then
            cors="$1"
            shift
        elif echo "$1" | egrep -q "^-i$"; then
            i="$1 $2"
            shift
            shift
        elif echo "$1" | egrep -q "^-p$"; then
            p="$1 $2"
            shift
            shift
        else
            if [ -z "$options" ]; then
                options="$1"
            else
                options+=" $1"
            fi
            shift
        fi
    done

    # spawn http-server, retaining colorized output
    script --flush --quiet --return /dev/null --command "http-server $a $c $cors $i $p $options" |
        while IFS= read -r line
        do
            # rewrite address as hostname50
            if command -v hostname50 > /dev/null 2>&1 && echo "$line" | egrep -q "Available on:"; then
                echo "$line"
                IFS= read -r line
                echo "$line" | sed "s#\(.*http://\)[^:]\+\(:.\+\)#\1$(hostname50)\2#"
                while IFS= read -r line
                do
                    if echo "$line" | egrep -q "Hit CTRL-C to stop the server"; then
                        echo "$line"
                        break
                    fi
                done
            else
                echo "$line"
            fi
        done
}

# can't have dash in sh function names
alias http-server="http_server"

# valgrind defaults
export VALGRIND_OPTS="--memcheck:leak-check=full --memcheck:track-origins=yes"

# set editor
export EDITOR="nano"

# set locale
export LANG="C"

# Node.js
export NODE_ENV="dev"

# web application environment
export APPLICATION_ENV="dev"

# short-circuit RVM's cd script
# https://news.ycombinator.com/item?id=1637354
export rvm_project_rvmrc="0"
