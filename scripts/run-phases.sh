#!/usr/bin/env bash
# Run a mixedmodelplan folder's phases in order, each as its own headless
# Claude Code session on the model and effort named in its front matter.
#
# Usage: run-phases.sh PLAN_DIR [--from N] [--only N] [--dry-run] [-- CLAUDE_FLAGS...]
#
# Run it from the directory the phases work in (usually the repo root).
# CLAUDE_FLAGS go to every `claude -p` call, for example:
#   -- --permission-mode acceptEdits --max-budget-usd 40
#
# Stops when claude exits with an error, when a phase's report doesn't start
# with "Status: done", or after a phase whose front matter says "gate: after".
# Run it again to resume: phases whose report already says done are skipped.
set -euo pipefail

die() { printf 'run-phases: %s\n' "$*" >&2; exit 1; }
usage="usage: run-phases.sh PLAN_DIR [--from N] [--only N] [--dry-run] [-- CLAUDE_FLAGS...]"

plan="" from=0 only="" dry=0
extra=()
while [ $# -gt 0 ]; do
  case "$1" in
    --from) [ $# -ge 2 ] || die "$usage"; from=$((10#$2)); shift 2 ;;
    --only) [ $# -ge 2 ] || die "$usage"; only=$((10#$2)); shift 2 ;;
    --dry-run) dry=1; shift ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --) shift; extra=("$@"); break ;;
    *) [ -z "$plan" ] || die "$usage"; plan=$1; shift ;;
  esac
done
[ -n "$plan" ] && [ -d "$plan" ] || die "$usage"
command -v claude >/dev/null || die "the claude CLI isn't on PATH"
command -v jq >/dev/null || die "jq isn't on PATH"
plan=$(cd "$plan" && pwd)
log="$plan/RUN-LOG.md"
[ "$dry" = 1 ] || mkdir -p "$plan/reports" "$plan/logs"
[ "$dry" = 1 ] || [ -f "$log" ] || printf '# Run log\n\n| Phase | Model | Effort | Started | Ended | Models used | Cost (USD, list price) | How | Status |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- |\n' > "$log"

# A front matter value: field FILE KEY. Front matter is the block between a
# first line of "---" and the next "---"; trailing "# comments" are ignored.
field() {
  awk -v k="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, k ":") == 1 {
      v = substr($0, length(k) + 2); sub(/[ \t]+#.*/, "", v)
      gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit
    }' "$1"
}
# The prompt: everything after the front matter.
body() { awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { fm = 0; next } !fm' "$1"; }

shopt -s nullglob
phases=("$plan"/[0-9][0-9]-*.md)
[ ${#phases[@]} -gt 0 ] || die "no phase files (NN-*.md) in $plan"

for file in "${phases[@]}"; do
  name=$(basename "$file" .md)
  num=$((10#${name%%-*}))
  if [ -n "$only" ] && [ "$num" -ne "$only" ]; then continue; fi
  if [ "$num" -lt "$from" ]; then continue; fi

  model=$(field "$file" model)
  effort=$(field "$file" effort)
  gate=$(field "$file" gate)
  report=$(field "$file" report)
  [ -n "$model" ] || die "$name: no model in its front matter"
  report="$plan/${report:-reports/$name.md}"

  if [ -f "$report" ] && head -n 1 "$report" | grep -q '^Status: done'; then
    echo "== $name: already done, skipping"
    continue
  fi

  cmd=(claude -p --model "$model")
  [ -z "$effort" ] || cmd+=(--effort "$effort")
  cmd+=(--output-format json --name "mmp $name")
  [ ${#extra[@]} -eq 0 ] || cmd+=("${extra[@]}")

  if [ "$dry" = 1 ]; then
    printf '== %s: %s < %s (body)\n' "$name" "${cmd[*]}" "${file#"$plan"/}"
    continue
  fi

  started=$(date '+%Y-%m-%d %H:%M')
  echo "== $name: $model, effort ${effort:-default}, started $started"
  out="$plan/logs/$name.json"
  set +e
  body "$file" | "${cmd[@]}" > "$out" 2> "$plan/logs/$name.err"
  code=$?
  set -e
  ended=$(date '+%Y-%m-%d %H:%M')

  used=$(jq -r '(.modelUsage // {}) | keys | join(", ")' "$out" 2>/dev/null || true)
  cost=$(jq -r '.total_cost_usd // empty | . * 100 | round / 100' "$out" 2>/dev/null || true)
  if [ -f "$report" ]; then status=$(head -n 1 "$report"); else status="Status: missing (no ${report#"$plan"/})"; fi
  printf '| %s | %s | %s | %s | %s | %s | %s | headless | %s |\n' \
    "$name" "$model" "${effort:-default}" "$started" "$ended" "${used:-?}" "${cost:-?}" "$status" >> "$log"

  case "$used" in *"$model"*) ;; *) echo "== $name: warning: asked for $model, session used: ${used:-unknown}" >&2 ;; esac
  [ "$code" -eq 0 ] || die "$name: claude exited with $code (see logs/$name.err); stopping"
  case "$status" in
    "Status: done"*) echo "== $name: done" ;;
    *) die "$name: $status. Read ${report#"$plan"/}, then run again to resume." ;;
  esac
  if [ "$gate" = after ]; then
    echo "== $name: gate after this phase. Review ${report#"$plan"/}, then run again to continue."
    exit 0
  fi
done
if [ "$dry" = 1 ]; then echo "== dry run: nothing ran"; else echo "== all phases done"; fi
