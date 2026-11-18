#!/bin/sh
set -eu
umask 077

if common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
	project=$(CDPATH= cd -- "$common" && pwd -P)
else
	project=$(pwd -P)
fi
key=$(printf '%s' "$project" | git hash-object --stdin)
root=${X_IMPL_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/x-impl}
case $root in /*) ;; *) echo 'x-impl state directory must be absolute' >&2; exit 1 ;; esac
dir=$root/$key
mkdir -p "$dir"
printf '%s\n' "$dir"
