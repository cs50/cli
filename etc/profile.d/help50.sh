# Directory with helpers
HELPERS="/opt/cs50/lib/help50"

# Temporary files
FILE="/tmp/help50.$$" # Use PID to support multiple terminals
HELPFUL="${FILE}.help"
HELPLESS="${FILE}.output"

# Supported helpers
for helper in "$HELPERS"/*; do
    name=$(basename "$helper")
    eval "function ${name}() { help50 "$name" \"\$@\"; }"
done

help50() {

    # Duplicate file descriptors
    exec 3>&1 4>&2

    # Redirect output to a file too
    exec > >(tee -a "$FILE") 2>&1

    # Execute command
    if [[ "$(type -P -t "$1")" == "file" ]]; then
        unbuffer "$@" # Else, e.g., ls isn't colorized
    else
        command "$@" # Can't unbuffer builtins (e.g., cd)
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

    # Try to get help
    local helper="${HELPERS}/${command}"
    if [[ -f "$helper" && -x "$helper" ]]; then
        local help=$("$helper" "$@" <<< "$output")
    fi
    if [[ -n "$help" ]]; then # If helpful
        echo "$help" > "$HELPFUL"
    elif [[ $status -ne 0 ]]; then # If helpless
        echo "$output" > "$HELPLESS"
    fi
}

_help50() {
    if [[ -f "$HELPFUL" ]]; then
        _helpful "$HELPFUL"
    elif [[ -f "$HELPLESS" ]]; then
        _helpless "$HELPLESS"
    fi
    rm --force "$HELPFUL" "$HELPLESS"
}

_helpful() {
    echo -n "🦆 "
    cat "$1" | _help
}

_helpless() { :; }

export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_help50"
