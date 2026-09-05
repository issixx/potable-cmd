:: Copyright 2025 issixx. All Rights Reserved.
:: Licensed under the MIT License.
:: Repository: https://github.com/issixx/portable-cmd
:: This file must use CRLF line endings. See .gitattributes (`*.bat -text`).
::
:: Usage:
::   launch-vscode.bat           Launch VS Code with the portable environment
::   launch-vscode.bat cursor    Launch Cursor with the portable environment

@echo off

:: First argument is the editor CLI name. Default is VS Code (`code`).
set "EDITOR_NAME=%~1"
if "%EDITOR_NAME%"=="" set "EDITOR_NAME=code"

set "PORTABLE_CMD_BAT=%~dp0portable-cmd.bat"
set "PORTABLE_CMD_URL=https://raw.githubusercontent.com/issixx/portable-cmd/main/portable-cmd.bat"

::###################################################################################
:: activate environment
::###################################################################################

:: If portable-cmd.bat is missing, fetch it and normalize to CRLF so cmd.exe can run it.
if not exist "%PORTABLE_CMD_BAT%" (
    echo portable-cmd.bat not found. Downloading...
    powershell -NoProfile -Command "(New-Object Net.WebClient).DownloadString('%PORTABLE_CMD_URL%') -replace \"`r?`n\",\"`r`n\" | Set-Content -LiteralPath '%PORTABLE_CMD_BAT%' -Encoding ASCII"
    if ERRORLEVEL 1 goto :ERROR
    if not exist "%PORTABLE_CMD_BAT%" goto :ERROR
)

:: Activate Git / uv / Python and the rest so the editor process inherits those paths.
call "%PORTABLE_CMD_BAT%"
if ERRORLEVEL 1 goto :ERROR

::###################################################################################
:: main
::###################################################################################

call :LAUNCH_EDITOR "%EDITOR_NAME%"
if ERRORLEVEL 1 goto :ERROR
exit /b 0

::###################################################################################
:: functions
::###################################################################################

:ERROR
    echo ###################
    echo #   %~n0 failure
    echo ###################
    pause
exit /b 1

:LAUNCH_EDITOR
    :: Prefer the `.cmd` shim shipped by VS Code / Cursor, then any PATH match.
    set "EDITOR_PATH="
    call :FIND_EDITOR_COMMAND "%~1.cmd"
    if ERRORLEVEL 1 call :FIND_EDITOR_COMMAND "%~1"
    if not defined EDITOR_PATH (
        echo Editor CLI not found: %~1
        echo Install VS Code or Cursor and ensure its CLI is in PATH.
        exit /b 1
    )

    :: Start hidden so the `.cmd` console does not stay visible.
    :: Open `.` in this script's directory. Do not pass `%~dp0` (trailing `\` breaks quoting).
    echo Launching %~1 ...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%EDITOR_PATH%' -ArgumentList '.' -WorkingDirectory '%~dp0.' -WindowStyle Hidden"
    if ERRORLEVEL 1 exit /b 1
exit /b 0

:FIND_EDITOR_COMMAND
    :: Take the first `where` result for %1 and store it in EDITOR_PATH.
    for /f "delims=" %%I in ('where.exe "%~1" 2^>NUL') do (
        set "EDITOR_PATH=%%~I"
        exit /b 0
    )
exit /b 1
