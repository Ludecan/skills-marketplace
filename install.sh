#!/usr/bin/env bash
# Copy plugin skills into a repo, for harnesses that read skill folders but not Claude Code plugins.
#
#   install.sh [--dest DIR] [--check] PLUGIN[,PLUGIN...] TARGET_REPO
#
# --dest DIR  skill folder inside TARGET_REPO (default: .agents/skills)
# --check     change nothing; exit 1 if the installed copies differ from this repo
#
# The script writes DIR/.source with the commit and the skills it manages. It never touches
# a skill folder that is not listed there, and it stops if a local skill has the same name.
set -euo pipefail

dest=.agents/skills
check=0
while [ $# -gt 0 ]; do
  case "$1" in
    --dest) dest=$2; shift 2 ;;
    --check) check=1; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    --) shift; break ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) break ;;
  esac
done
[ $# -eq 2 ] || { echo "usage: install.sh [--dest DIR] [--check] PLUGIN[,PLUGIN...] TARGET_REPO" >&2; exit 2; }

src=$(cd "$(dirname "$0")" && pwd)
plugins=${1//,/ }
target=$(cd "$2" && pwd)
out=$target/$dest
managed_file=$out/.source

commit=$(git -C "$src" rev-parse HEAD 2>/dev/null || echo unknown)
git -C "$src" diff --quiet 2>/dev/null || commit=$commit-dirty

# skills to install, as "plugin/name"
want=()
for p in $plugins; do
  [ -d "$src/plugins/$p/skills" ] || { echo "no such plugin: $p" >&2; exit 2; }
  for d in "$src/plugins/$p/skills"/*/; do want+=("$p/$(basename "$d")"); done
done

previous=()
[ -f "$managed_file" ] && while read -r kind name; do [ "$kind" = skill ] && previous+=("$name"); done < "$managed_file"
is_managed() { local s; for s in "${previous[@]:-}"; do [ "${s#*/}" = "$1" ] && return 0; done; return 1; }

if [ "$check" -eq 1 ]; then
  status=0
  for s in "${want[@]}"; do
    if ! diff -rq "$src/plugins/${s%%/*}/skills/${s#*/}" "$out/${s#*/}" >/dev/null 2>&1; then echo "differs or missing: ${s#*/}"; status=1; fi
  done
  [ "$status" -eq 0 ] && echo "up to date ($commit)"
  exit $status
fi

for s in "${want[@]}"; do
  name=${s#*/}
  if [ -e "$out/$name" ] && ! is_managed "$name"; then
    echo "refusing: $out/$name exists and is not managed by this script" >&2; exit 1
  fi
done

mkdir -p "$out"
for s in "${previous[@]:-}"; do [ -n "$s" ] && rm -rf "${out:?}/${s#*/}"; done
for s in "${want[@]}"; do cp -r "$src/plugins/${s%%/*}/skills/${s#*/}" "$out/${s#*/}"; done
{ echo "commit $commit"; for s in "${want[@]}"; do echo "skill $s"; done; } > "$managed_file"
echo "installed ${#want[@]} skills into $out ($commit)"
