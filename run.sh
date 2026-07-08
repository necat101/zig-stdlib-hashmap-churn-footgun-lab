#!/usr/bin/env bash
# zig-stdlib-hashmap-churn-footgun-lab – Linux / macOS runner
set -euo pipefail
cd "$(dirname "$0")"

echo "=== zig-stdlib-hashmap-churn-footgun-lab ==="
echo

# Find python
if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 not found" >&2
  exit 1
fi

echo "[1/4] py_compile generate_cases.py run_lab.py"
python3 -m py_compile generate_cases.py run_lab.py
echo "  ok"
echo

echo "[2/4] generate_cases.py"
python3 generate_cases.py
echo

# Find zig (optional – run_lab.py handles missing zig gracefully)
ZIG_BIN="${ZIG_PATH:-$(command -v zig || true)}"
for cand in \
  "/tmp/zig-linux-x86_64-0.14.0/zig" \
  "/opt/zig/zig" \
  "$HOME/zig/zig" \
  "/usr/local/bin/zig"; do
  if [ -z "$ZIG_BIN" ] && [ -x "$cand" ]; then ZIG_BIN="$cand"; fi
done

if [ -n "${ZIG_BIN:-}" ] && [ -x "$ZIG_BIN" ]; then
  echo "[zig] $("$ZIG_BIN" version 2>/dev/null || echo unknown)"
  export ZIG_PATH="$ZIG_BIN"
  echo
else
  echo "[zig] not found – run_lab.py will record this honestly"
  echo
fi

echo "[3/4] run_lab.py"
python3 run_lab.py
echo

if [ -n "${ZIG_BIN:-}" ] && [ -x "$ZIG_BIN" ]; then
  echo "[4/4] Zig harness (direct)"
  "$ZIG_BIN" run hashmap_churn_lab.zig 2>&1 | head -40
  echo "..."
  echo
fi

echo "=== done ==="
echo "Results: RESULTS.md  cases.json  results_rows.csv  results_rows.json"
if [ -f RESULTS.md ]; then
  echo
  grep -E "^(Pass|Fail|Skip|Cases|Methods|Zig version):|Zig compiler:|Zig harness validated:" RESULTS.md | head -20 || true
fi
