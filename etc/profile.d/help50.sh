# Directory with helpers
HELPERS="/opt/cs50/lib/help50"

# Disable yes, lest students type it at prompt
if command -v yes &> /dev/null; then
    alias yes=":"
fi

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
    echo "HELPER: $helper"
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
    if [[ "$RUBBERDUCKING" != "0" ]]; then
        if [[ -f "$HELPFUL" ]]; then
            _helpful "$(cat "$HELPFUL")"
        elif [[ -f "$HELPLESS" ]]; then
            _helpless "$(cat "$HELPLESS")"
        fi
    fi
    rm --force "$HELPFUL" "$HELPLESS"
}

_helpful() {
    echo "$1"
}

_helpless() { :; }

duck() {
    if [[ "$1" == "off" ]]; then
        export RUBBERDUCKING=0
    elif [[ "$1" == "on" ]]; then
        unset RUBBERDUCKING
    elif [[ "$1" == "status" ]]; then
        if [[ "$RUBBERDUCKING" == "0" ]]; then
            echo "off"
        else
            echo "on"
        fi
    fi
}

export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_help50"
duck on
