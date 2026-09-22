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
