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

echo "OK"
