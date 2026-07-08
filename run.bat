@echo off
setlocal enabledelayedexpansion

echo === zig-stdlib-hashmap-churn-footgun-lab ===
echo.

REM Find python
where python >nul 2>nul
if errorlevel 1 (
  echo error: python not found in PATH
  exit /b 1
)

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
REM Common Windows install locations
if not defined ZIG_BIN if exist "C:\zig\zig.exe" set ZIG_BIN=C:\zig\zig.exe
if not defined ZIG_BIN if exist "%ProgramFiles%\zig\zig.exe" set ZIG_BIN=%ProgramFiles%\zig\zig.exe
if not defined ZIG_BIN if exist "%LOCALAPPDATA%\Programs\zig\zig.exe" set ZIG_BIN=%LOCALAPPDATA%\Programs\zig\zig.exe

if defined ZIG_BIN (
  echo [zig]
  "%ZIG_BIN%" version
  echo.
  set ZIG_PATH=%ZIG_BIN%
) else (
  echo [zig] not found - run_lab.py will record this honestly
  echo.
)

echo [3/4] run_lab.py
python run_lab.py
if errorlevel 1 goto :error
echo.

if defined ZIG_BIN (
  echo [4/4] Zig harness (direct)
  "%ZIG_BIN%" run hashmap_churn_lab.zig
  echo ...
  echo.
)

echo === done ===
echo Results: RESULTS.md  cases.json  results_rows.csv  results_rows.json
echo.
if exist RESULTS.md (
  findstr /C:"Zig version:" /C:"Zig compiler:" /C:"Pass:" /C:"Fail:" /C:"Skip" /C:"Cases:" /C:"Methods:" RESULTS.md
)
goto :eof

:error
echo.
echo *** FAILED with errorlevel %ERRORLEVEL%
exit /b %ERRORLEVEL%
