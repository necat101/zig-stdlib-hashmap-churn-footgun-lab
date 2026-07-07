@echo off
setlocal enabledelayedexpansion

echo === zig-stdlib-hashmap-churn-footgun-lab ===
echo.

echo [1/4] py_compile generate_cases.py run_lab.py
python -m py_compile generate_cases.py run_lab.py
if errorlevel 1 goto :error
echo   ok
echo.

echo [2/4] generate_cases.py
python generate_cases.py
if errorlevel 1 goto :error
echo.

REM Find zig
set ZIG_BIN=
if defined ZIG_PATH set ZIG_BIN=%ZIG_PATH%
if not defined ZIG_BIN (
  where zig >nul 2>nul
  if not errorlevel 1 set ZIG_BIN=zig
)
if defined ZIG_BIN (
  echo [zig] 
  "%ZIG_BIN%" version
  echo.
)

echo [3/4] run_lab.py
python run_lab.py
if errorlevel 1 goto :error
echo.

if defined ZIG_BIN (
  echo [4/4] Zig harness (direct)
  "%ZIG_BIN%" run hashmap_churn_lab.zig
  echo.
)

echo === done ===
echo Results: RESULTS.md  cases.json  results_rows.json  results_rows.csv
goto :eof

:error
echo.
echo *** FAILED with errorlevel %ERRORLEVEL%
exit /b %ERRORLEVEL%
