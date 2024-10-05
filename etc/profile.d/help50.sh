# If not started
if [[ -z "$HELP50" ]]; then
    return
fi

# Directory with helpers
HELPERS="/opt/cs50/lib/help50"

# Library
. /opt/cs50/lib/cli

# Ignore duplicates (but not commands that begin with spaces)
export HISTCONTROL="ignoredups"

function _help50() {

    # Get exit status of last command
    local status=$?

    # Get last command line, independent of user's actual history
    histfile=$(mktemp)
    HISTFILE=$histfile history -a
    local argv=$(HISTFILE=$histfile history 1 | cut -c 8-) # Could technically contain multiple commands, separated by ; or &&
    rm --force $histfile
    local argv0=$(echo "$argv" | awk '{print $1}') # Assume for simplicity it's just a single command

    # Remove any of these aliases
    for name in n no y yes; do
        unalias $name 2> /dev/null
    done

    # If last command was ./*
    # touch foo.c && make foo && touch foo.c && ./foo
    if [[ "$argv" =~ ^\./(.*)$ ]]; then
        local src="${BASH_REMATCH[1]}.c"
        local dst="${BASH_REMATCH[1]}"
        if [[ -f "$src" && $(file --brief --mime-type "$src") == "text/x-c" ]]; then
            if [[ -x "$dst" && $(file --brief --mime-type "$dst") == "application/x-pie-executable" ]]; then
                if [[ "$src" -nt "$dst" ]]; then
                    _helpful "It looks like \`$src\` has changed. Did you mean to run \`make $dst\` again?"
                fi
            fi
        fi
    fi

    # If last command erred (and is not ctl-c or ctl-z)
    # https://tldp.org/LDP/abs/html/exitcodes.html
    if [[ $status -ne 0 && $status -ne 130 && $status -ne 148 ]]; then

        # Read typescript from disk
        local typescript=$(cat $HELP50)

        # Remove script's own output (if this is user's first command)
        typescript=$(echo "$typescript" | sed '1{/^Script started on .*/d}')

        # Cap typescript at MIN(1K lines, 1M bytes), else `read` is slow
        typescript=$(echo "$typescript" | head -n 1024 | cut -b 1-1048576)

        # Remove any line continuations from command line
        local lines=""
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ -z $done && $line =~ \\$ ]]; then
                lines+="${line%\\}"
            else
                lines+="$line"$'\n'
                local done=1
            fi
        done <<< "$typescript"
        typescript="$lines"

        # Remove command line from typescript
        typescript=$(echo "$typescript" | sed '1d')

        # Remove ANSI characters
        typescript=$(echo "$typescript" | ansi2txt)

        # Remove control characters
        # https://superuser.com/a/237154
        typescript=$(echo "$typescript" | col -bp)

        # Try to get help
        for helper in $HELPERS/*; do
            if [[ -f $helper && -x $helper ]]; then
                local help=$($helper $argv <<< "$typescript")
                if [[ -n "$help" ]]; then
                    break
                fi
            fi
        done
        if [[ -n "$help" ]]; then # If helpful
            _helpful "$help"
        elif [[ $status -ne 0 ]]; then # If helpless
            _helpless "$typescript"
        fi
    fi

    # Truncate typescript
    truncate -s 0 $HELP50
}

function _question() {
    _alert "That was a rhetorical question. <3"
}

# Default helpers
if ! type _helpful >/dev/null 2>&1; then
    function _helpful() {

        # Intercept accidental invocation of `yes` and `n`, which are actual programs
        for name in n no y yes; do
            alias $name=_question
        done

        # Output help
        local output=$(_ansi "$1")
        _alert "$output"
    }
fi
if ! type _helpless >/dev/null 2>&1; then
    function _helpless() { :; } # Silent
fi

export PROMPT_COMMAND=_help50
