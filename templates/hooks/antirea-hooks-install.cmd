@echo off
REM antirea hooks installer — Windows
REM Run from the project root: templates\hooks\antirea-hooks-install.cmd

for /f "tokens=*" %%i in ('git rev-parse --show-toplevel 2^>nul') do set REPO_ROOT=%%i
if "%REPO_ROOT%"=="" (
  echo [antirea] ERROR: Not inside a git repository.
  exit /b 1
)

set HOOKS_DIR=%REPO_ROOT%\.git\hooks
set SCRIPT_DIR=%~dp0

REM Save barrier content into .git
copy /Y "%SCRIPT_DIR%\..\agents-inject.md" "%REPO_ROOT%\.git\antirea-barrier.md" >nul
echo [antirea] Barrier content saved to .git\antirea-barrier.md

REM Install post-checkout hook
call :install_hook post-checkout
call :install_hook post-merge
call :install_hook pre-commit

echo [antirea] Git hooks installed. Barrier files will self-heal on checkout, merge, and commit.
exit /b 0

:install_hook
set HOOK=%1
set TARGET=%HOOKS_DIR%\%HOOK%
if exist "%TARGET%" (
  findstr /C:"antirea" "%TARGET%" >nul 2>&1
  if errorlevel 1 (
    echo. >> "%TARGET%"
    echo # antirea self-heal >> "%TARGET%"
    type "%SCRIPT_DIR%%HOOK%" >> "%TARGET%"
    echo [antirea] Appended to existing hook: %HOOK%
  ) else (
    echo [antirea] Hook already contains antirea: %HOOK% (skipped)
  )
) else (
  copy /Y "%SCRIPT_DIR%%HOOK%" "%TARGET%" >nul
  echo [antirea] Installed hook: %HOOK%
)
exit /b 0