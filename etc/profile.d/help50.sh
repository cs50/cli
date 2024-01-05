# Directory with helpers
HELPERS="/opt/cs50/lib/help50"

# TEMP
alias make="help50 make"

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
    local file="/tmp/help50.$$" # Use PID to support multiple terminals
    exec > >(tee -a "$file") 2>&1

    # Execute command
    if [[ "$(type -P -t "$1")" == "file" ]]; then
        unbuffer "$@" # Else, e.g., ls isn't colorized
    else
        "$@" # Can't unbuffer builtins (e.g., cd)
    fi

    # Remember status
    local status=$?

    # Remember command
    local command="$1"

    # Remove command from $@
    shift

    # Get redirected output
    local output=$(cat "$file")

    # Remove any ANSI codes
    output=$(echo "$output" | ansi2txt | col -b)

    # Restore file descriptors
    exec 1>&3 2>&4

    # Close file descriptors
    exec 3>&- 4>&-

    # Remove file
    rm --force "$file"

    # Preserve command's status for helpers
    (exit $status)

    # Try to get help
    local help=$( . "${HELPERS}/${command}.sh" <<< "$output" )
    if [[ -n "$help" ]]; then
        echo "🦆 $help"
    fi
}
