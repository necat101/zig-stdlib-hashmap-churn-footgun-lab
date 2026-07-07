# zig-stdlib-hashmap-churn-footgun-lab – PowerShell runner
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "=== zig-stdlib-hashmap-churn-footgun-lab ==="
Write-Host ""

Write-Host "[1/4] py_compile generate_cases.py run_lab.py"
python -m py_compile generate_cases.py run_lab.py
Write-Host "  ok"
Write-Host ""

Write-Host "[2/4] generate_cases.py"
python generate_cases.py
Write-Host ""

# Find zig
$zigBin = $null
if ($env:ZIG_PATH -and (Test-Path $env:ZIG_PATH)) { $zigBin = $env:ZIG_PATH }
elseif (Get-Command zig -ErrorAction SilentlyContinue) { $zigBin = "zig" }

if ($zigBin) {
    Write-Host "[zig] " -NoNewline
    & $zigBin version
    Write-Host ""
}

Write-Host "[3/4] run_lab.py"
python run_lab.py
Write-Host ""

if ($zigBin) {
    Write-Host "[4/4] Zig harness (direct)"
    & $zigBin run hashmap_churn_lab.zig
    Write-Host ""
}

Write-Host "=== done ==="
Write-Host "Results: RESULTS.md  cases.json  results_rows.json  results_rows.csv"
