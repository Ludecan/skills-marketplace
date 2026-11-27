#!/usr/bin/env bash
# Copy plugin skills into a repo, for harnesses that read skill folders but not Claude Code plugins.
#
#   install.sh --harness LIST [--dest DIR] [--check] PLUGIN[,PLUGIN...] TARGET_REPO
#   install.sh --update [--dest DIR] [--check] TARGET_REPO...
#
# --harness LIST  the harnesses the project uses, comma separated: claude, opencode, codex, zed.
#                 Ask the user, do not guess.
#                   claude only      nothing to install: enable the plugins in .claude/settings.json
#                   opencode         copy the plugin skills into DIR (OpenCode reads .claude/skills itself)
#                   codex or zed     copy the plugin skills into DIR, and link the project skills of
#                                    TARGET_REPO/.claude/skills into DIR (these harnesses do not read .claude)
# --dest DIR      skill folder inside TARGET_REPO (default: .agents/skills)
# --check         change nothing; exit 1 if the copies or links differ from what the script would make
# --update        for each TARGET_REPO, install again with the harnesses and plugins recorded in DIR/.source
#
# The script writes DIR/.source with the commit, the harnesses, the skills it copied and the links it made. It never
# touches a folder that is not listed there, and it stops if a local skill has the same name.
set -euo pipefail

dest=.agents/skills
check=0
harness=
update=0
while [ $# -gt 0 ]; do
  case "$1" in
    --harness) harness=$2; shift 2 ;;
    --dest) dest=$2; shift 2 ;;
    --check) check=1; shift ;;
    --update) update=1; shift ;;
    -h|--help) sed -n '2,19p' "$0"; exit 0 ;;
    --) shift; break ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) break ;;
  esac
done
if [ "$update" -eq 1 ]; then
  [ $# -ge 1 ] || { echo "usage: install.sh --update [--dest DIR] [--check] TARGET_REPO..." >&2; exit 2; }
  status=0
  for t in "$@"; do
    f=$t/$dest/.source
    h=$(awk '$1 == "harness" { print $2 }' "$f" 2>/dev/null || true)
    p=$(awk '$1 == "skill" { sub("/.*", "", $2); print $2 }' "$f" 2>/dev/null | sort -u | paste -sd, - || true)
    if [ -z "$h" ] || [ -z "$p" ]; then
      echo "$t: $f has no harness or skill lines; run a full install once" >&2; status=1; continue
    fi
    echo "== $t"
    if [ "$check" -eq 1 ]; then "$0" --harness "$h" --dest "$dest" --check "$p" "$t" || status=1
    else "$0" --harness "$h" --dest "$dest" "$p" "$t" || status=1; fi
  done
  exit $status
fi
[ $# -eq 2 ] || { echo "usage: install.sh --harness LIST [--dest DIR] [--check] PLUGIN[,PLUGIN...] TARGET_REPO" >&2; exit 2; }
[ -n "$harness" ] || { echo "missing --harness: ask the user which of claude, opencode, codex, zed the project uses" >&2; exit 2; }

copies=0; links=0
for h in ${harness//,/ }; do
  case "$h" in
    claude) ;;
    opencode) copies=1 ;;
    codex|zed) copies=1; links=1 ;;
    *) echo "unknown harness: $h (use claude, opencode, codex, zed)" >&2; exit 2 ;;
  esac
done
if [ "$copies" -eq 0 ]; then
  echo "claude only: nothing to copy. Enable the plugins in .claude/settings.json and install them with --scope local (see AGENTS.md)."
  exit 0
fi

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
previous_links=()
[ -f "$managed_file" ] && while read -r kind name; do
  [ "$kind" = skill ] && previous+=("$name")
  [ "$kind" = link ] && previous_links+=("$name")
done < "$managed_file"
# project skills to link: real folders in .claude/skills, relative links from DIR
want_links=()
if [ "$links" -eq 1 ] && [ -d "$target/.claude/skills" ]; then
  for d in "$target/.claude/skills"/*/; do
    [ -d "$d" ] && [ ! -L "${d%/}" ] && want_links+=("$(basename "$d")")
  done
fi
up=""; for _ in $(echo "$dest" | tr '/' ' '); do up="../$up"; done
is_managed_link() { local s; for s in "${previous_links[@]:-}"; do [ "$s" = "$1" ] && return 0; done; return 1; }
is_managed() { local s; for s in "${previous[@]:-}"; do [ "${s#*/}" = "$1" ] && return 0; done; return 1; }

if [ "$check" -eq 1 ]; then
  status=0
  for s in "${want[@]}"; do
    if ! diff -rq "$src/plugins/${s%%/*}/skills/${s#*/}" "$out/${s#*/}" >/dev/null 2>&1; then echo "differs or missing: ${s#*/}"; status=1; fi
  done
  for n in "${want_links[@]:-}"; do
    [ -n "$n" ] || continue
    [ "$(readlink "$out/$n" 2>/dev/null)" = "${up}.claude/skills/$n" ] || { echo "link differs or missing: $n"; status=1; }
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

for n in "${want_links[@]:-}"; do
  [ -n "$n" ] || continue
  if [ -e "$out/$n" ] || [ -L "$out/$n" ]; then
    { [ -L "$out/$n" ] && is_managed_link "$n"; } || { echo "refusing: $out/$n exists and is not a link made by this script" >&2; exit 1; }
  fi
done

mkdir -p "$out"
for s in "${previous[@]:-}"; do [ -n "$s" ] && rm -rf "${out:?}/${s#*/}"; done
for n in "${previous_links[@]:-}"; do [ -n "$n" ] && [ -L "$out/$n" ] && rm -f "$out/$n"; done
for n in "${want_links[@]:-}"; do [ -n "$n" ] && ln -s "${up}.claude/skills/$n" "$out/$n"; done
for s in "${want[@]}"; do cp -r "$src/plugins/${s%%/*}/skills/${s#*/}" "$out/${s#*/}"; done
{ echo "commit $commit"; echo "harness $harness"; for s in "${want[@]}"; do echo "skill $s"; done; for n in "${want_links[@]:-}"; do [ -n "$n" ] && echo "link $n"; done; } > "$managed_file"
echo "installed ${#want[@]} skills and linked ${#want_links[@]} project skills into $out ($commit)"
