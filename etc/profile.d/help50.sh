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

        # Cap typescript, else `read` below is slow. Keep the first few lines, where the
        # command line itself is echoed (found below), plus the last 1K lines, where
        # errors tend to be (tracebacks, `make: *** Error`, segfaults); a long-running
        # program that prints a lot and then crashes would otherwise lose its error.
        typescript=$(echo "$typescript" | cut -b 1-1048576)
        local total=$(echo "$typescript" | wc -l)
        if [[ $total -gt 1088 ]]; then
            typescript=$(echo "$typescript" | head -n 64; echo "[... $((total - 1088)) lines omitted ...]"; echo "$typescript" | tail -n 1024)
        fi

        # Remove ANSI characters
        typescript=$(echo "$typescript" | ansi2txt)

        # Remove control characters
        # https://superuser.com/a/237154
        typescript=$(echo "$typescript" | col -bp)

        # Remove everything through the command line itself, as echoed by the terminal.
        # It's usually the first line, but tab completion, history browsing, etc. echo
        # more before it (e.g., a listing of completions, then a redrawn prompt), which
        # would otherwise be mistaken for the command's output. So look for the first
        # line that ends with the command (per history), joining any line continuations
        # (and dropping their PS2 prompts) along the way; if not found, fall back to
        # removing just the first (logical) line.
        local command="${argv%"${argv##*[![:space:]]}"}" # Right-trimmed
        local after_first="" after_command="" logical="" first="" found=""
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -n "$found" ]] && after_command+="$line"$'\n'
            [[ -n "$first" ]] && after_first+="$line"$'\n'
            [[ -n "$found" ]] && continue
            [[ -n "$logical" ]] && line="${line#"$PS2"}"
            if [[ "$line" =~ \\$ ]]; then
                logical+="${line%\\}"
                continue
            fi
            logical+="$line"
            first=1
            local trimmed="${logical%"${logical##*[![:space:]]}"}"
            if [[ -n "$command" && "$trimmed" == *"$command" ]]; then
                found=1
            fi
            logical=""
        done <<< "$typescript"
        if [[ -n "$found" ]]; then
            typescript="$after_command"
        else
            typescript="$after_first"
        fi

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

            # Pass the output (capped, e.g., since ddb50 rejects > 10,000 characters, keeping the end,
            # where errors tend to be) and the command line itself, so that whatever explains the
            # output can see what was run
            _helpless "$(echo "$typescript" | tail -c 8192)" "$argv"
        fi
    else
        _helped
    fi

    # Truncate typescript
    truncate -s 0 $HELP50
}

function _rhetorical() {
    _alert "That was a rhetorical question. <3"
}

# Default helpers, overridable (e.g., by cs50/codespace) by defining them before this file is sourced:
#   _helped              last command succeeded
#   _helpful ADVICE      a helper had advice for the failed command
#   _helpless OUTPUT CMD no helper had advice; OUTPUT is the failed command's (cleaned, capped)
#                        output, possibly empty, and CMD its command line
if ! type _helped >/dev/null 2>&1; then
    function _helped() { :; } # Silent
fi
if ! type _helpful >/dev/null 2>&1; then
    function _helpful() {

        # Intercept accidental invocation of `yes` and `n`, which are actual programs
        for name in n no y yes; do
            alias $name=_rhetorical
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
