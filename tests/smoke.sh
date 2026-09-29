#!/bin/bash
# Smoke-tests a built cs50/cli image. Usage: tests/smoke.sh [IMAGE]
# Each check has a timeout so that a regression that hangs the shell fails loudly.

set -o errexit -o nounset -o pipefail

IMAGE="${1:-cs50/cli}"
run() { timeout 60 docker run --rm "$@"; }

echo "Checking $IMAGE"

echo "- non-interactive login shell exits (help50 must not start without a terminal)"
run "$IMAGE" bash --login -c 'echo ok' | grep -qx ok
echo true | run --interactive "$IMAGE" bash --login

echo "- runtime dependencies of help50 are installed"
run "$IMAGE" bash --login -c 'for c in ansi2txt col file script fold; do command -v "$c" > /dev/null || { echo "missing $c" >&2; exit 1; }; done'

echo "- help50 controller is the Bash version, on PATH, and enabled by default"
run "$IMAGE" bash --login -c 'test "$(type -P help50)" = /opt/cs50/bin/help50 && help50 is-enabled && test "$(help50 status)" = stopped' > /dev/null

echo "- wrappers print their message even when stdin is redirected"
run "$IMAGE" bash --login -c 'valgrind python x.py < /dev/null; test $? -eq 1' 2>&1 | grep -q 'does not support Python'

echo "- _fold wraps without a terminal"
run "$IMAGE" bash --login -c '. /opt/cs50/lib/cli; TERM= _fold "$(printf "a %.0s" {1..100})"' | head -n 1 | grep -qE '^.{1,80}$'

echo "- _helpless gets the end of a failed command's long output, plus its command line"
run "$IMAGE" bash --login -c '
    export HELP50=$(mktemp)
    _helpless() { printf "%s" "$1" > /tmp/output; printf "%s" "$2" > /tmp/cmd; }
    . /etc/profile.d/help50.sh

    # A command that prints 3000 lines and then fails, as script(1) records it
    { printf "$ ./slow\r\n"; seq 3000 | sed "s/$/\r/"; printf "Error: boom\r\n"; } > "$HELP50"
    set -o history; history -s ./slow; set +o history
    false; _help50
    test "$(cat /tmp/cmd)" = ./slow &&
    test "$(head -n 1 /tmp/output)" = 1 &&
    grep -qx "\[... 1914 lines omitted ...\]" /tmp/output &&
    ! grep -qx 1000 /tmp/output &&
    test "$(tail -n 1 /tmp/output)" = "Error: boom" || exit 1

    # A command that fails without output
    : > "$HELP50"
    set -o history; history -s ./slow; set +o history
    false; _help50
    test "$(cat /tmp/cmd)" = ./slow && test ! -s /tmp/output || exit 1

    # A command run via help50 is reported as the command itself
    : > "$HELP50"
    set -o history; history -s "help50 ./slow"; set +o history
    false; _help50
    test "$(cat /tmp/cmd)" = ./slow || exit 1
'

echo "- the prompt hook stays fast after a failed command printed a huge amount of output"
run "$IMAGE" bash --login -c '
    export HELP50=$(mktemp)
    _helpless() { printf "%s" "$1" > /tmp/output; }
    . /etc/profile.d/help50.sh

    # 35 MB (4 million lines) of output, then an error, as script(1) records it.
    # Reading the whole file into a variable took ~2.4 s here and scaled linearly.
    { printf "$ ./huge\r\n"; seq 1 4000000 | sed "s/$/\r/"; printf "Error: boom\r\n"; } > "$HELP50"
    size=$(stat -c %s "$HELP50")
    set -o history; history -s ./huge; set +o history
    start=$(date +%s%N); false; _help50; elapsed=$(( ($(date +%s%N) - start) / 1000000 ))
    echo "  hook took ${elapsed} ms for a ${size}-byte typescript"
    test "$elapsed" -lt 1000 &&
    test "$(tail -n 1 /tmp/output)" = "Error: boom" || exit 1
'

echo "- a helper that hangs cannot stall the prompt"
run --user root "$IMAGE" bash --login -c '
    printf "#!/bin/bash\ncat > /dev/null\nsleep 60\n" > /opt/cs50/lib/help50/zz_hang && chmod 755 /opt/cs50/lib/help50/zz_hang
    su ubuntu -c "bash --login -c '"'"'
        export HELP50=\$(mktemp); . /etc/profile.d/help50.sh
        printf \"\$ ./x\\r\\nsome error\\r\\n\" > \"\$HELP50\"
        set -o history; history -s ./x; set +o history
        start=\$(date +%s); false; _help50; elapsed=\$(( \$(date +%s) - start ))
        echo \"hook took \${elapsed} s with a hung helper\"; test \"\$elapsed\" -lt 15
    '"'"'"
'

echo "- HELP50_DISABLED in the environment keeps help50 from starting, and says so"
run "$IMAGE" bash --login -c 'help50 is-enabled | grep -qx enabled'
run --env HELP50_DISABLED=1 "$IMAGE" bash --login -c '
    out=$(help50 is-enabled); test $? -eq 1 && [[ "$out" == *HELP50_DISABLED=1* && "$out" == *unset* ]] || exit 1'
# Values that read as false count as unset, so that setting the secret to 0 re-enables help50, as deleting it would
for value in 0 false FALSE no off ""; do
    run --env HELP50_DISABLED="$value" "$IMAGE" bash --login -c 'help50 is-enabled | grep -qx enabled'
done
# The lock file (help50 disable) is still honored when the environment doesn't disable
run --env HELP50_DISABLED=0 "$IMAGE" bash --login -c 'help50 disable && ! help50 is-enabled && help50 enable && help50 is-enabled' > /dev/null
# In an interactive shell on a pty (script provides one), help50 starts by default but not when disabled
run "$IMAGE" bash -c 'echo "help50 status; exit" | script -qc "bash --login -i" /dev/null' | grep -q '^started'
run --env HELP50_DISABLED=1 "$IMAGE" bash -c 'echo "help50 status; exit" | script -qc "bash --login -i" /dev/null' | grep -q '^stopped'

echo "- help50 COMMAND runs COMMAND, with its exit status"
run "$IMAGE" bash --login -c 'help50 true && ! help50 false && test "$(help50 echo x)" = x'
run "$IMAGE" bash --login -c 'help50 valgrind python x.py < /dev/null; test $? -eq 1' 2>&1 | grep -q 'does not support Python'

echo "- help50 COMMAND fails as COMMAND would have, so that helpers recognize the error"
run "$IMAGE" bash --login -c 'out=$(help50 1s 2>&1); test $? -eq 127 && test "$out" = "bash: 1s: command not found"'
run "$IMAGE" bash --login -c 'out=$(help50 --version 2>&1); test $? -eq 127 && test "$out" = "bash: --version: command not found"'
run "$IMAGE" bash --login -c 'out=$(help50 cd nothere 2>&1); test $? -eq 1 && test "$out" = "bash: cd: nothere: No such file or directory"'
run "$IMAGE" bash --login -c 'cd "$(mktemp -d)" && touch foo.c && out=$(help50 ./foo.c 2>&1); test $? -eq 126 && test "$out" = "bash: ./foo.c: Permission denied"'
run "$IMAGE" bash --login -c 'cd "$(mktemp -d)" && mkdir foo && out=$(help50 ./foo 2>&1); test $? -eq 126 && test "$out" = "bash: ./foo: Is a directory"'

echo "- help50 alone prints usage and exits 0"
run "$IMAGE" bash --login -c 'help50 | grep -q "^Usage: help50 COMMAND" && help50 -h > /dev/null && help50 --help > /dev/null'

echo "- root (as via sudo) may run help50 COMMAND but not its subcommands"
run "$IMAGE" bash --login -c 'test "$(sudo help50 echo x)" = x && test -z "$(sudo help50 is-enabled 2>&1)"'

echo "- within a help50 session, help50 COMMAND runs in the shell itself, so cd and aliases apply"
run "$IMAGE" bash --login -c '
    export HELP50=$(mktemp)
    . /etc/profile.d/help50.sh
    shopt -s expand_aliases
    alias rm="echo aliased"
    help50 cd /tmp && test "$PWD" = /tmp || exit 1
    test "$(help50 rm x)" = "aliased x" || exit 1
    help50 false; test $? -eq 1 || exit 1
    out=$(help50 cd nothere 2>&1); test $? -eq 1 && [[ "$out" == *"cd: nothere: No such file or directory" ]] || exit 1
    help50 is-enabled > /dev/null && test "$(help50 status)" = started || exit 1
'

echo "OK"
