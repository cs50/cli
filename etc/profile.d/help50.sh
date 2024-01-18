# Directory with helpers
HELPERS="/opt/cs50/lib/help50"

# Disable yes, lest users type it at prompt
if command -v yes &> /dev/null; then
    alias yes=":"
fi

# Ignore duplicates (but not commands that begin with spaces)
export HISTCONTROL="ignoredups"

function _help50() {

    # Exit status of last command
    local status=$?

    # Append to history right away
    history -a

    # Parse command line in case we want ${argv[0]}
    read -a argv <<< $(history 1 | cut -c 8-)

    # If no typescript yet
    if [[ -z "$SCRIPT" ]]; then

        # Use this shell's PID as typescript's name, exporting so that subshells know script is already running
        export SCRIPT="/tmp/help50.$$"

        # Make a typescript of everything displayed in terminal (without using exec, which breaks sudo);
        # --append avoids `bash: warning: command substitution: ignored null byte in input`;
        # --quiet suppresses `Script started...`
        script --append --command "bash --login" --flush --quiet "$SCRIPT"

        # Remove typescript before exiting this shell
        rm --force "$SCRIPT"

        # Now exit this shell too
        exit
    fi

    # If last command erred (and not ctl-z)
    # https://tldp.org/LDP/abs/html/exitcodes.html
    if [[ $status -ne 0 && $status -ne 148 ]]; then

        # Read typescript from disk
        local typescript=$(cat "$SCRIPT")

        # Remove script's own output (if this is user's first command)
        typescript=$(echo "$typescript" | sed '1{/^Script started on .*/d}')

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
        for helper in "$HELPERS"/*; do
            if [[ -f "$helper" && -x "$helper" ]]; then
                local help=$(. $helper <<< "$typescript")
                if [[ -n "$help" ]]; then
                    break
                fi
            fi
        done
        if [[ -n "$help" ]]; then # If helpful
            _helpful "$help"
        elif [[ $status -ne 0 ]]; then # If helpless
            _helpless "$text"
        fi
    fi

    # Truncate typescript
    truncate -s 0 "$SCRIPT"
}

function _find() {

    # In $1 is path to find
    if [[ $# -ne 1 ]]; then
        return
    fi

    # Find absolute paths of any $1 relative to `cd`
    pushd "$(cd && pwd)" > /dev/null
    paths=$(find $(pwd) -name "$1" 2> /dev/null)
    popd > /dev/null

    # Resolve absolute paths to relative paths
    local line
    while IFS= read -r path; do
        realpath --relative-to=. "$(dirname "$path")"
    done <<< "$paths"
}

if ! type _helpful >/dev/null 2>&1; then
    function _helpful() {
        echo "$1"
    }
fi

if ! type _helpless >/dev/null 2>&1; then
    function _helpless() { :; }
fi

export PROMPT_COMMAND="_help50${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
