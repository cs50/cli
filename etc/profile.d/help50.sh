# If root
if [ "$(whoami)" == "root" ]; then
    return
fi

. /opt/cs50/lib/cli

# Directory with helpers
HELPERS="/opt/cs50/lib/help50"

# Disable yes, lest users type it at prompt
if command -v yes &> /dev/null; then
    function yes() {
        if [[ -t 0 ]]; then
            :
        else
            command yes
        fi
    }
fi

# Ignore duplicates (but not commands that begin with spaces)
export HISTCONTROL="ignoredups"

function _help50() {

    # Get exit status of last command
    local status=$?

    # Get last command, independent of user's actual history
    histfile=/tmp/help50.$$.history
    HISTFILE=$histfile history -a
    local argv0=$(HISTFILE=$histfile history 1 | cut -c 8- | awk '{print $1}')
    rm --force $histfile

    # If no typescript yet
    if [[ -z $TYPESCRIPT ]]; then

        # Use this shell's PID as typescript's name, exporting so that subshells know script is already running
        export TYPESCRIPT=/tmp/help50.$$.typescript

        # Make a typescript of everything displayed in terminal (without using exec, which breaks sudo);
        # --append avoids `bash: warning: command substitution: ignored null byte in input`;
        # --quiet suppresses `Script started...`
        script --append --command "bash --login" --flush --quiet $TYPESCRIPT

        # Remove typescript before exiting this shell
        rm --force $TYPESCRIPT

        # Now exit this shell too
        exit
    fi

    # If last command erred (and not ctl-z)
    # https://tldp.org/LDP/abs/html/exitcodes.html
    if [[ $status -ne 0 && $status -ne 148 && ! "$command" =~ ^\./ ]]; then

        # Ignore ./* if executable file
        if [[ "$argv" =~ ^\./ && -f "$argv" && -x "$argv" ]]; then
            break
        fi

        # Read typescript from disk
        local typescript=$(cat $TYPESCRIPT)

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
                local help=$($helper <<< "$typescript")
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
    truncate -s 0 "$TYPESCRIPT"
}

# Default helpers
if ! type _helpful >/dev/null 2>&1; then
    function _helpful() {
        local output=$(_ansi "$1")
        echo -e "\033[7m${output}\033[27m" # Reverse video
    }
fi
if ! type _helpless >/dev/null 2>&1; then
    function _helpless() { :; } # Silent
fi

export PROMPT_COMMAND="_help50${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
