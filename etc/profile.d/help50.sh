# Directory with helpers
HELPERS="/opt/cs50/lib/help50"

# Temporary files
FILE="/tmp/help50.$$" # Use PID to support multiple terminals
HELP="${FILE}.help"
OUTPUT="${FILE}.output"

# Supported helpers
#for helper in "$HELPERS"/*.sh; do
#    command=$(basename "$helper" .sh)
#    echo "$command"="help50 $command"
#done

# Formatting
bold=$(tput bold)
normal=$(tput sgr0)

help50() {

    # Check for helper
    if [[ $# -gt 0 && ! -f "${HELPERS}/${1}.sh" ]]; then
        echo "Sorry, ${bold}help50${normal} does not yet know how to help with this!"
        return 1
    fi

    # Duplicate file descriptors
    exec 3>&1 4>&2

    # Redirect output to a file too
    exec > >(tee -a "$FILE") 2>&1

    # Execute command
    if [[ "$(type -P -t "$1")" == "file" ]]; then
        unbuffer "$@" # Else, e.g., ls isn't colorized
    else
        "$@" # Can't unbuffer builtins (e.g., cd)
    fi

    # Remember these
    local status=$?
    local command="$1"

    # Remove command from $@
    shift

    # Get tee'd output
    local output=$(cat "$FILE")

    # Remove any ANSI codes
    output=$(echo "$output" | ansi2txt | col -b)

    # Restore file descriptors
    exec 1>&3 2>&4

    # Close file descriptors
    exec 3>&- 4>&-

    # Remove tee'd output
    rm --force "$file"

    # Restore $? to that of original command
    (exit $status)

    # Try to get help
    local help=$( . "${HELPERS}/${command}.sh" <<< "$output" )
    if [[ -n "$help" ]]; then
        echo "$help" > "$HELP"
    elif [[ $status -ne 0 ]]; then
        echo "$output" > "$OUTPUT"
    fi
}

_help50() {
    #history -a
    if [[ -f "$HELP" ]]; then
        echo -n "🦆 "
        cat "$HELP"
        rm --force "$HELP"
    elif [[ -f "$OUTPUT" ]]; then
        echo non-zero but no helper
        rm --force "$OUTPUT"
    else
        echo zero
    fi
}

_help50() {
    echo 222
}

export PROMPT_COMMAND=_help50
