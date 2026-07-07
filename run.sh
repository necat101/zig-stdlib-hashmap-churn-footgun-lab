#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== zig-stdlib-hashmap-churn-footgun-lab ==="
echo

echo "[1/4] py_compile generate_cases.py run_lab.py"
python3 -m py_compile generate_cases.py run_lab.py
echo "  ok"
echo

echo "[2/4] generate_cases.py"
python3 generate_cases.py
echo

ZIG_BIN="${ZIG_PATH:-$(command -v zig || echo /tmp/zig-x86_64-linux-0.17.0-dev.1267+300116b02/zig)}"
if [ -x "$ZIG_BIN" ]; then
  echo "[zig] $("$ZIG_BIN" version 2>/dev/null || echo "unknown")"
  echo
fi

echo "[3/4] run_lab.py"
python3 run_lab.py
echo

if [ -x "$ZIG_BIN" ]; then
  echo "[4/4] Zig harness (direct)"
  "$ZIG_BIN" run hashmap_churn_lab.zig 2>&1 | head -30
  echo "..."
  echo
fi

echo "=== done ==="
echo "Results: RESULTS.md  cases.json  results_rows.json  results_rows.csv"
