:: Copyright 2025 issixx. All Rights Reserved.
:: Licensed under the MIT License.
:: Repository: https://github.com/issixx/portable-cmd

@echo off

:: Do nothing if called recursively
if "%PORTABLE_CMD_CALLED%" equ "1" exit /b 0
set PORTABLE_CMD_CALLED=1

:: Prevent output from clearing when entering venv
chcp 65001 > NUL

:: nkf: https://github.com/kkato233/nkf/releases
set PATH=%~dp0bin;%PATH%
:: use to opencode.json
set OPENCODE_ROOT=%~dp0
set OPENCODE_ROOT=%OPENCODE_ROOT:\=/%
set PYTHONUTF8=1
set SHELL=bash.exe

::###################################################################################
:: feature settings
::###################################################################################

:: Set to 1 to enable each feature
if "%ENABLE_GIT%"         equ "" set ENABLE_GIT=1
if "%ENABLE_CMAKE%"       equ "" set ENABLE_CMAKE=0
if "%ENABLE_UV%"          equ "" set ENABLE_UV=1
if "%ENABLE_CUDA%"        equ "" set ENABLE_CUDA=0
if "%ENABLE_VULKAN%"      equ "" set ENABLE_VULKAN=0
if "%ENABLE_CHROME%"      equ "" set ENABLE_CHROME=0
if "%ENABLE_FFMPEG%"      equ "" set ENABLE_FFMPEG=0
if "%ENABLE_NODEJS%"      equ "" set ENABLE_NODEJS=0
if "%ENABLE_GO%"          equ "" set ENABLE_GO=0
if "%ENABLE_BUN%"         equ "" set ENABLE_BUN=0
if "%ENABLE_SVN%"         equ "" set ENABLE_SVN=0
if "%ENABLE_OPENCODE%"    equ "" set ENABLE_OPENCODE=0
if "%ENABLE_GRAFANA%"     equ "" set ENABLE_GRAFANA=0

:: If even one Windows hard link is in use,
:: you cannot delete any of the hard links that share the same original file.
:: For example, if the server is running or VS Code is open
:: with the .venv still activated, you will not be able to delete
:: a .venv located in a completely different place.
:: Therefore, although this sacrifices the advantages of uv's hard links,
:: we use copy mode to prioritize operational convenience.
if "%UV_LINK_MODE%"      equ "" set UV_LINK_MODE=copy

:: Old python setup method
if "%ENABLE_PYTHON%"      equ "" set ENABLE_PYTHON=0
if "%ENABLE_PYTHON_VENV%" equ "" set ENABLE_PYTHON_VENV=0
if "%PORTABLE_PYTHON_REQUIREMENT_MODULES_BASE%" equ "" set PORTABLE_PYTHON_REQUIREMENT_MODULES_BASE=
if "%PORTABLE_PYTHON_REQUIREMENT_MODULES_DEFAULT%" equ "" set PORTABLE_PYTHON_REQUIREMENT_MODULES_DEFAULT=
::if "%PORTABLE_NODEJS_REQUIREMENT_MODULES%" equ "" set PORTABLE_NODEJS_REQUIREMENT_MODULES=
::if "%PORTABLE_BUN_REQUIREMENT_MODULES%" equ "" set PORTABLE_BUN_REQUIREMENT_MODULES=

if "%ENABLE_OPENCODE%" equ "1" (
    set ENABLE_NODEJS=1
    set PORTABLE_NODEJS_REQUIREMENT_MODULES=-g opencode-ai
)

if "%ENABLE_GRAFANA%" equ "1" (
    if "%ENABLE_LOKI%"  equ "" set ENABLE_LOKI=1
    if "%ENABLE_PROMETHEUS%"  equ "" set ENABLE_PROMETHEUS=0
    if "%ENABLE_ALLOY%"  equ "" set ENABLE_ALLOY=1
)

::###################################################################################
:: workspace settings
::###################################################################################
if "%CUR_DIR%" equ "" set CUR_DIR=%~dp0

:: Search parent folders for the workspace folder
if "%SEARCH_PARENT_WORKSPACE%" equ "" set SEARCH_PARENT_WORKSPACE=0
if "%BASE_DIR_NAME%"        equ "" (for %%A in ("%CUR_DIR%.") do set BASE_DIR_NAME=%%~nA)
if "%WORKSPACE_NAME%"       equ "" set WORKSPACE_NAME=.portable
set WORKSPACE_ROOT_DEFAULT=%CUR_DIR%%WORKSPACE_NAME%
if "%WORKSPACE_ROOT%"       equ "" set WORKSPACE_ROOT=%WORKSPACE_ROOT_DEFAULT%
:: Use this shorter path if %WORKSPACE_ROOT% is too long and causes build failures
if "%WORKSPACE_SHORT_ROOT%" equ "" set WORKSPACE_SHORT_ROOT=%USERPROFILE%\%BASE_DIR_NAME%\%WORKSPACE_NAME%
if "%LIB_DIR_NAME%"         equ "" set LIB_DIR_NAME=lib
if "%PYTHON_VENV_DIR_NAME%" equ "" set PYTHON_VENV_DIR_NAME=.venv

::###################################################################################
:: installer settings
::###################################################################################
if "%PORTABLE_GIT_URL%"        equ "" set PORTABLE_GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/PortableGit-2.47.0.2-64-bit.7z.exe
::if "%PORTABLE_CMAKE_URL%"    equ "" set PORTABLE_CMAKE_URL=https://github.com/Kitware/CMake/releases/download/v3.30.5/cmake-3.30.5-windows-x86_64.zip
if "%PORTABLE_CMAKE_URL%"      equ "" set PORTABLE_CMAKE_URL=https://github.com/Kitware/CMake/releases/download/v3.28.6/cmake-3.28.6-windows-x86_64.zip
::if "%PORTABLE_UV_URL%"         equ "" set PORTABLE_UV_URL=https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-pc-windows-msvc.zip
if "%PORTABLE_UV_URL%"         equ "" set PORTABLE_UV_URL=https://github.com/astral-sh/uv/releases/download/0.10.7/uv-x86_64-pc-windows-msvc.zip
if "%PORTABLE_UV_PY_VER%"      equ "" set PORTABLE_UV_PY_VER=3.12.9
::if "%PORTABLE_PYTHON_URL%"   equ "" set PORTABLE_PYTHON_URL=https://www.python.org/ftp/python/3.13.0/python-3.13.0-embed-amd64.zip
if "%PORTABLE_PYTHON_URL%"     equ "" set PORTABLE_PYTHON_URL=https://www.python.org/ftp/python/3.12.9/python-3.12.9-embed-amd64.zip
if "%PORTABLE_PYTHON_PIP_URL%" equ "" set PORTABLE_PYTHON_PIP_URL=https://bootstrap.pypa.io/get-pip.py
if "%CUDA_URL%"                equ "" set CUDA_URL=https://developer.download.nvidia.com/compute/cuda/12.6.2/local_installers/cuda_12.6.2_560.94_windows.exe
if "%VULKAN_URL%"              equ "" set VULKAN_URL=https://sdk.lunarg.com/sdk/download/1.3.296.0/windows/VulkanSDK-1.3.296.0-Installer.exe
if "%PORTABLE_CHROME_URL%"     equ "" set PORTABLE_CHROME_URL=https://storage.googleapis.com/chrome-for-testing-public/151.0.7922.47/win64/chrome-win64.zip
if "%PORTABLE_CHROME_DRIVER_URL%" equ "" set PORTABLE_CHROME_DRIVER_URL=https://storage.googleapis.com/chrome-for-testing-public/151.0.7922.47/win64/chromedriver-win64.zip
if "%PORTABLE_FFMPEG_URL%"     equ "" set PORTABLE_FFMPEG_URL=https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip
if "%PORTABLE_NODEJS_URL%"     equ "" set PORTABLE_NODEJS_URL=https://nodejs.org/download/release/v22.19.0/node-v22.19.0-win-x64.zip
if "%PORTABLE_GO_URL%"         equ "" set PORTABLE_GO_URL=https://go.dev/dl/go1.25.1.windows-amd64.zip
if "%PORTABLE_BUN_URL%"        equ "" set PORTABLE_BUN_URL=https://github.com/oven-sh/bun/releases/latest/download/bun-windows-x64.zip
if "%PORTABLE_SVN_URL%"        equ "" set PORTABLE_SVN_URL=https://www.visualsvn.com/files/Apache-Subversion-1.14.5-3.zip
if "%PORTABLE_GRAFANA_URL%"    equ "" set PORTABLE_GRAFANA_URL=https://dl.grafana.com/grafana/release/13.1.0/grafana_13.1.0_28013217238_windows_amd64.tar.gz
if "%PORTABLE_LOKI_URL%"       equ "" set PORTABLE_LOKI_URL=https://github.com/grafana/loki/releases/download/v3.7.3/loki-windows-amd64.exe.zip
if "%PORTABLE_PROMETHEUS_URL%" equ "" set PORTABLE_PROMETHEUS_URL=https://github.com/prometheus/prometheus/releases/download/v3.12.0/prometheus-3.12.0.windows-amd64.zip
if "%PORTABLE_ALLOY_URL%"      equ "" set PORTABLE_ALLOY_URL=https://github.com/grafana/alloy/releases/download/v1.17.0/alloy-windows-amd64.exe.zip

::###################################################################################
:: etc settings
::###################################################################################

:: The build succeeded with up to 107 characters in the current environment,
:: but it is set to 100 as a precaution.
if "%CUR_DIR_LEN_MAX%" equ "" set CUR_DIR_LEN_MAX=100

:: Set to 1 to use pre-installed exe
if "%USE_SYSTEM_EXE%" equ "" set USE_SYSTEM_EXE=0

:: Use venv if system exe is used
if "%USE_SYSTEM_EXE%" equ "1" (
    set ENABLE_PYTHON_VENV=1
)

::###################################################################################
:: check path length and deside workspace path
::###################################################################################

:: Check if the current directory path is too long to avoid build failure
:: and decide the workspace path
call :DESIDE_WORKSPACE_ROOT_LEN
if ERRORLEVEL 1 goto :ERROR

::###################################################################################
:: main
::###################################################################################
set LIB_DIR=%WORKSPACE_ROOT%\%LIB_DIR_NAME%

:: make lib directory
if not exist "%LIB_DIR%\" ( mkdir "%LIB_DIR%" )

if "%ENABLE_GIT%" equ "1" (
    call :ACTIVATE_GIT
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_CMAKE%" equ "1" (
    call :ACTIVATE_CMAKE
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_UV%" equ "1" (
    call :ACTIVATE_UV
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_PYTHON%" equ "1" (
    call :ACTIVATE_PYTHON
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_CUDA%" equ "1" (
    call :ACTIVATE_CUDA
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_VULKAN%" equ "1" (
    call :ACTIVATE_VULKAN
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_CHROME%" equ "1" (
    call :ACTIVATE_CHROME
    if ERRORLEVEL 1 goto :ERROR

    call :ACTIVATE_CHROME_DRIVER
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_FFMPEG%" equ "1" (
    call :ACTIVATE_FFMPEG
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_NODEJS%" equ "1" (
    call :ACTIVATE_NODEJS
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_GO%" equ "1" (
    call :ACTIVATE_GO
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_BUN%" equ "1" (
    call :ACTIVATE_BUN
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_SVN%" equ "1" (
    call :ACTIVATE_SVN
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_GRAFANA%" equ "1" (
    call :ACTIVATE_GRAFANA
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_LOKI%" equ "1" (
    call :ACTIVATE_LOKI
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_PROMETHEUS%" equ "1" (
    call :ACTIVATE_PROMETHEUS
    if ERRORLEVEL 1 goto :ERROR
)

if "%ENABLE_ALLOY%" equ "1" (
    call :ACTIVATE_ALLOY
    if ERRORLEVEL 1 goto :ERROR
)

echo.
goto :SUCCESS
:ERROR
    echo #################################
    echo #   portable-cmd launch error   #
    echo #################################
    pause
exit /b 1

:SUCCESS
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo ###################################
        echo #   portable-cmd launch success   #
        echo ###################################
        echo.
    )
    
    :: Switch to interactive mode if the script is called directly
    :: (Check if this batch filename is included in the startup command)
    echo %CMDCMDLINE:"=% | find /I "%~f0" >nul
    if not ERRORLEVEL 1 (
        cmd /K
    )
exit /b 0

::###################################################################################
:: utility function
::###################################################################################

:: Find the exe and display the version
:WHERE_EXE
    set EXE_CMD=%1
    set VER_OPTION=%2

    :: find
    where "%EXE_CMD%" >nul 2>&1
    if ERRORLEVEL 1 (
        exit /b 1
    )

    :: get first line of where command
    for /f "tokens=1* delims=" %%A in ('where "%EXE_CMD%"') do (
        set "FIRST_LINE=%%A"
        goto :L_WHERE_EXE_0
    )
    :L_WHERE_EXE_0

    :: output exe path and version
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo %EXE_CMD% used is located at "%FIRST_LINE%"
        if "%VER_OPTION%" neq "" (
            %*
        )
    )
exit /b 0

:: find installed exe
:FIND_SYSTEM_EXE
    if "%USE_SYSTEM_EXE%" neq "1" exit /b 1
    call :WHERE_EXE %*
    if ERRORLEVEL 1 exit /b 1
exit /b 0


:: Update the environment variable without restarting the command prompt
:UPDATE_SYSTEM_ENV
    set ENV_NAME=%1
    for /f "delims=" %%i in ('powershell -command "[System.Environment]::GetEnvironmentVariable('%ENV_NAME%', 'Machine')"') do set "%ENV_NAME%=%%i"
exit /b 0

:: Update the all argment name environment variable without restarting the command prompt
:UPDATE_SYSTEM_ENVS
    set ENV_FILETER=%1
    for /f %%i in ('powershell -command "[System.Environment]::GetEnvironmentVariables('Machine')"') do (
        echo %%i | findstr "^%ENV_FILETER%" >nul
        if not ERRORLEVEL 1 (
            call :UPDATE_SYSTEM_ENV %%i
        )
    )
exit /b 0

:: Get the length of the string
:: Usage: call :STRLEN "%~dp0" ENV_NAME
:STRLEN
    setlocal EnableDelayedExpansion
    set "_str=%~1"
    set "_count=0"

    :_STRLEN_LOOP
    if defined _str (
        set "_str=!_str:~1!"
        set /a _count+=1
        goto :_STRLEN_LOOP
    )

    ( endlocal & set "%~2=%_count%" )
exit /b 0

:: Find the parent directory of the workspace
:FIND_PARENT_DIR_WORKSPACE
    set "%~1="
    
    :: Traverse parent directories to find %WORKSPACE_NAME%
    set "SEARCH_DIR=%CUR_DIR%"
    :FIND_WORKSPACE
    
    if exist "%SEARCH_DIR%%WORKSPACE_NAME%\" (
        set "%~1=%SEARCH_DIR%%WORKSPACE_NAME%"
        exit /b 0
    )
    set "PARENT_DIR=%SEARCH_DIR:~0,-1%"
    if "%PARENT_DIR:~-1%" equ ":" exit /b 1

    for %%A in ("%PARENT_DIR%") do set "SEARCH_DIR=%%~dpA"
    if "%SEARCH_DIR%" equ "" exit /b 1
    goto :FIND_WORKSPACE
exit /b 1

:: Check if the current directory path is too long to avoid build failure
:: and decide the workspace path
:DESIDE_WORKSPACE_ROOT_LEN

    :: Use the shorter path if it already exists
    if "%WORKSPACE_SHORT_ROOT%" neq "" (
        if exist "%WORKSPACE_SHORT_ROOT%" (
            set WORKSPACE_ROOT=%WORKSPACE_SHORT_ROOT%
        )
    )

    :: if the workspace path is not set, use the default path
    if "%SEARCH_PARENT_WORKSPACE%" equ "1" (
        if "%WORKSPACE_ROOT%" equ "%WORKSPACE_ROOT_DEFAULT%" (
            call :FIND_PARENT_DIR_WORKSPACE WORKSPACE_ROOT_TEMP
        )
    )
    if "%WORKSPACE_ROOT_TEMP%" neq "" (
        set WORKSPACE_ROOT=%WORKSPACE_ROOT_TEMP%
        echo Found workspace path: %WORKSPACE_ROOT_TEMP%
    )

    :: Check if the current directory path is too long
    call :STRLEN "%WORKSPACE_ROOT%" CUR_DIR_LEN
    if %CUR_DIR_LEN% LEQ %CUR_DIR_LEN_MAX% (
        :: ok
        exit /b 0
    )
    :: failure
    echo #Error# The current directory path ["%WORKSPACE_ROOT%"] is too long! [Now:%CUR_DIR_LEN%, Max:%CUR_DIR_LEN_MAX%]

    ::######################
    :: Use shorter path
    ::######################

    if "%WORKSPACE_SHORT_ROOT%" equ "%WORKSPACE_ROOT%" (
        echo Please move to a shorter path.
        echo Long file names may not only cause %BASE_DIR_NAME% build failures but also lead to internal failures in UE5's Generate Solution, resulting in unusable .sln files.
        exit /b 1
    )

    :: ask to create a workspace in the shorter path
    echo Do you want to create a workspace in "%WORKSPACE_SHORT_ROOT%"?
    set /p INPUT=[y/n]:
    if /I "%INPUT%" neq "y" (
        exit /b 1
    )

    set WORKSPACE_ROOT=%WORKSPACE_SHORT_ROOT%
    call :STRLEN "%WORKSPACE_ROOT%" CUR_DIR_LEN
    if %CUR_DIR_LEN% LEQ %CUR_DIR_LEN_MAX% (
        :: ok
        exit /b 0
    )
exit /b 1

::###################################################################################
:: git
::###################################################################################

:ACTIVATE_GIT
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed git...
    )
    for %%A in ("%PORTABLE_GIT_URL:/=" "%") do set "PORTABLE_GIT_FILENAME=%%~nxA"
    set PORTABLE_GIT_DL=%LIB_DIR%\%PORTABLE_GIT_FILENAME%
    set PORTABLE_GIT_ROOT=%LIB_DIR%\git
    set PORTABLE_GIT_CMD=%PORTABLE_GIT_ROOT%\bin\git.exe

    :: find system git
    call :FIND_SYSTEM_EXE git --version
    if ERRORLEVEL 1 (
        :: check already installed portable git
        if not exist "%PORTABLE_GIT_CMD%" (
            echo git is not installed

            :: install portable git
            call :INSTALL_GIT
            if ERRORLEVEL 1 exit /b 1
        )

        :: append portable git path
        set "PATH=%PORTABLE_GIT_ROOT%\bin;%PATH%"

        :: output git path and version
        call :WHERE_EXE git --version
        if ERRORLEVEL 1 exit /b 1
    )

    set ACTIVE_GIT=1
exit /b 0

:INSTALL_GIT
    echo ##### downloading portable git...
    curl -L %PORTABLE_GIT_URL% -o "%PORTABLE_GIT_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_GIT_URL% download failed
        exit /b 1
    )
    echo ##### installing portable git...
    :: Execute the self-extracting exe file
	"%PORTABLE_GIT_DL%" -o "%PORTABLE_GIT_ROOT%" -y
    if ERRORLEVEL 1 (
        echo %PORTABLE_GIT_DL% install failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_GIT_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_GIT_DL% delete failed
        exit /b 1
    )

    echo git installed
exit /b 0

::###################################################################################
:: cmake
::###################################################################################

:ACTIVATE_CMAKE
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed cmake...
    )
    for %%A in ("%PORTABLE_CMAKE_URL:/=" "%") do set "PORTABLE_CMAKE_FILENAME=%%~nxA"
    set PORTABLE_CMAKE_DL=%LIB_DIR%\%PORTABLE_CMAKE_FILENAME%
    set PORTABLE_CMAKE_ROOT=%LIB_DIR%\cmake

    :: find system cmake
    call :FIND_SYSTEM_EXE cmake --version
    if ERRORLEVEL 1 (
        :: check already installed portable cmake
        if not exist "%PORTABLE_CMAKE_ROOT%\bin\cmake.exe" (
            echo cmake is not installed

            :: install portable cmake
            call :INSTALL_CMAKE
            if ERRORLEVEL 1 exit /b 1
        )
        :: append portable cmake path
        set "PATH=%PORTABLE_CMAKE_ROOT%\bin;%PATH%"

        :: output cmake path and version
        call :WHERE_EXE cmake --version
        if ERRORLEVEL 1 exit /b 1
    )
    
    set ACTIVE_CMAKE=1
exit /b 0

:INSTALL_CMAKE
    echo ##### downloading portable cmake...
    curl -L %PORTABLE_CMAKE_URL% -o "%PORTABLE_CMAKE_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_CMAKE_URL% download failed
        exit /b 1
    )
    echo ##### installing portable cmake...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_CMAKE_DL%' -DestinationPath '%LIB_DIR%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_CMAKE_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_CMAKE_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_CMAKE_DL% delete failed
        exit /b 1
    )

    :: Extract folder name from full path
    for %%A in ("%PORTABLE_CMAKE_DL:/=" "%") do set "_DL_NAME=%%~nA"
    for %%A in ("%PORTABLE_CMAKE_ROOT:\=" "%") do set "_NAME=%%~nA"
    
    :: rename
    ren "%LIB_DIR%\%_DL_NAME%" "%_NAME%"
    if ERRORLEVEL 1 (
        echo %LIB_DIR%\%_DL_NAME% rename failed
        exit /b 1
    )
    echo ##### cmake installed
exit /b 0

::###################################################################################
:: uv
::###################################################################################

:ACTIVATE_UV
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed uv...
    )
    for %%A in ("%PORTABLE_UV_URL:/=" "%") do set "PORTABLE_UV_FILENAME=%%~nxA"
    set PORTABLE_UV_DL=%LIB_DIR%\%PORTABLE_UV_FILENAME%
    set PORTABLE_UV_ROOT=%LIB_DIR%\uv

    :: check already installed portable uv
    call :FIND_SYSTEM_EXE uv --version
    if ERRORLEVEL 1 (
        if not exist "%PORTABLE_UV_ROOT%\uv.exe" (
            echo uv is not installed

            :: install portable uv
            call :INSTALL_UV
            if ERRORLEVEL 1 exit /b 1
        ) else (
            :: append portable uv path
            set "PATH=%PORTABLE_UV_ROOT%;%PATH%"
        )

        :: output uv path and version
        call :WHERE_EXE uv --version
        if ERRORLEVEL 1 exit /b 1
    )

    :: initialize uv project
    if not exist "%CUR_DIR%pyproject.toml" (
        :: Create .venv and pyproject.toml
        uv init --bare --python %PORTABLE_UV_PY_VER% --directory %CUR_DIR%
        if ERRORLEVEL 1 exit /b 1

        :: Create .python-version. (Fix python version)
        uv python pin %PORTABLE_UV_PY_VER% --directory %CUR_DIR%
        if ERRORLEVEL 1 exit /b 1
    )
    
    :: update modules
    if exist "%CUR_DIR%pyproject.toml" (
        if "%PORTABLE_CMD_SILENT%" neq "1" (
            uv sync --directory %CUR_DIR%
        ) else (
            uv sync --directory %CUR_DIR% >nul 2>&1
        )
    )

    :: activate venv
    if exist "%CUR_DIR%.venv\Scripts\activate.bat" (
        call "%CUR_DIR%.venv\Scripts\activate.bat"
        if ERRORLEVEL 1 exit /b 1
    )
    
    set ACTIVE_UV=1
exit /b 0

:INSTALL_UV
    echo ##### downloading portable uv...
    curl -L %PORTABLE_UV_URL% -o "%PORTABLE_UV_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_UV_URL% download failed
        exit /b 1
    )
    
    echo ##### installing portable uv...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_UV_DL%' -DestinationPath '%PORTABLE_UV_ROOT%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_UV_DL% unzip failed
        exit /b 1
    )
    
    :: delete dl file
    del "%PORTABLE_UV_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_UV_DL% delete failed
        exit /b 1
    )
    
    set "PATH=%PORTABLE_UV_ROOT%;%PATH%"
    
    echo ##### uv installed
exit /b 0

::###################################################################################
:: python
::###################################################################################

:ACTIVATE_PYTHON
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed python...
    )
    for %%A in ("%PORTABLE_PYTHON_URL:/=" "%") do set "PORTABLE_PYTHON_FILENAME=%%~nxA"
    set PORTABLE_PYTHON_DL=%LIB_DIR%\%PORTABLE_PYTHON_FILENAME%
    set PORTABLE_PYTHON_ROOT=%LIB_DIR%\python
    set PORTABLE_PYTHON_CMD=%PORTABLE_PYTHON_ROOT%\python.exe
    ::set VENV_DIR=%WORKSPACE_ROOT%\%PYTHON_VENV_DIR_NAME%
    set VENV_DIR=%CUR_DIR%%PYTHON_VENV_DIR_NAME%

    :: find system python
    call :FIND_SYSTEM_EXE python --version
    if ERRORLEVEL 1 (
        :: check already installed portable python
        if not exist "%PORTABLE_PYTHON_CMD%" (
            echo ##### python is not installed

            :: install portable python
            call :INSTALL_PYTHON
            if ERRORLEVEL 1 exit /b 1

            set SETUPED_PYTHON=1
        )

        :: append portable python path
        set "PATH=%PORTABLE_PYTHON_ROOT%\Scripts;%PORTABLE_PYTHON_ROOT%;%PATH%"
        :: disable user site-packages
        set PYTHONNOUSERSITE=1
        
        :: output python path and version
        call :WHERE_EXE python --version
        if ERRORLEVEL 1 exit /b 1
    )
    
    :: activate venv
    if "%ENABLE_PYTHON_VENV%" equ "1" (
        call :ACTIVATE_PYTHON_VENV
        if ERRORLEVEL 1 exit /b 1
    )
    
    :: install required python module if setuped python or venv
    if "%SETUPED_PYTHON%%SETUPED_VENV%" neq "" (
        call :INSTALL_REQUIRED_PYTHON_MODULE
        if ERRORLEVEL 1 exit /b 1
    )
    :: Check and install for new module
    if exist "%CUR_DIR%requirements.txt" (
        python -m pip install -r requirements.txt -q
        if ERRORLEVEL 1 exit /b 1
    )
    
    set ACTIVE_PYTHON=1
exit /b 0

:INSTALL_PYTHON
    echo ##### downloading portable ython...
    curl -L %PORTABLE_PYTHON_URL% -o "%PORTABLE_PYTHON_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_PYTHON_URL% download failed
        exit /b 1
    )
    echo ##### installing portable python...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_PYTHON_DL%' -DestinationPath '%PORTABLE_PYTHON_ROOT%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_PYTHON_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_PYTHON_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_PYTHON_DL% delete failed
        exit /b 1
    )
    
    echo ## enabling 'site' module...
    :: find pythonXXX._pth. and replace '#import site' to 'import site'
    for /r "%PORTABLE_PYTHON_ROOT%" %%f in (python*._pth) do (
    	powershell "&{(Get-Content '%%f') -creplace '#import site', 'import site' | Set-Content '%%f' }"
        if ERRORLEVEL 1 (
            echo '%%f' replace failed
            exit /b 1
        )
    )
    
    :: add current directory to sys.path
    echo import sys; sys.path.append('') >> "%PORTABLE_PYTHON_ROOT%\current.pth"

    echo ## downloading pip...
    curl -sSL "%PORTABLE_PYTHON_PIP_URL%" -o "%PORTABLE_PYTHON_ROOT%\get-pip.py"
    if ERRORLEVEL 1 (
        echo %PORTABLE_PYTHON_PIP_URL% download failed
        exit /b 1
    )
    
    echo ## installing pip...
	"%PORTABLE_PYTHON_CMD%" "%PORTABLE_PYTHON_ROOT%\get-pip.py" --no-warn-script-location
    if ERRORLEVEL 1 (
        echo pip install failed
        exit /b 1
    )
    
    echo ## installing virtualenv...
    "%PORTABLE_PYTHON_CMD%" -m pip install virtualenv --no-warn-script-location
    if ERRORLEVEL 1 (
        echo virtualenv install failed
        exit /b 1
    )

    echo ##### python installed
exit /b 0

:ACTIVATE_PYTHON_VENV
    :: check venv directory and activate venv
    if exist "%VENV_DIR%\" (
        call "%VENV_DIR%\Scripts\activate.bat"
        if ERRORLEVEL 1 exit /b 1
        exit /b 0
    )

    echo ##### venv directory not found.
    echo ## creating python venv...

    :: check venv module (python standard module)
    "%PORTABLE_PYTHON_CMD%" -c "import venv" >nul 2>&1
    if ERRORLEVEL 1 (
        :: use virtualenv (installed virtualenv module)
        "%PORTABLE_PYTHON_CMD%" -m virtualenv "%VENV_DIR%"
        if ERRORLEVEL 1 (
            echo virtualenv create failed
            exit /b 1
        )
    ) else (
        :: use venv (python standard module)
        "%PORTABLE_PYTHON_CMD%" -m venv "%VENV_DIR%"
        if ERRORLEVEL 1 (
            echo venv create failed
            exit /b 1
        )
    )

    set SETUPED_VENV=1

    :: activate venv
    call "%VENV_DIR%\Scripts\activate.bat"
    if ERRORLEVEL 1 exit /b 1
exit /b 0

:INSTALL_REQUIRED_PYTHON_MODULE
    echo ## installing required modules...
    if "%PORTABLE_PYTHON_REQUIREMENT_MODULES_BASE%" neq "" (
        python -m pip install %PORTABLE_PYTHON_REQUIREMENT_MODULES_BASE%
        if ERRORLEVEL 1 exit /b 1
    )
    if "%PORTABLE_PYTHON_REQUIREMENT_MODULES_DEFAULT%" neq "" (
        python -m pip install %PORTABLE_PYTHON_REQUIREMENT_MODULES_DEFAULT%
        if ERRORLEVEL 1 exit /b 1

        :: install Playwright Chromium if playwright is in requirement modules
        echo %PORTABLE_PYTHON_REQUIREMENT_MODULES_DEFAULT% | findstr /i "playwright" >nul
        if not ERRORLEVEL 1 (
            echo ## installing Playwright Chromium...
            python -m playwright install chromium
            if ERRORLEVEL 1 exit /b 1
        )
    )
    if exist "%CUR_DIR%requirements.txt" (
        python -m pip install -r requirements.txt
        if ERRORLEVEL 1 exit /b 1
    )
exit /b 0


::###################################################################################
:: CUDA Toolkit
::###################################################################################

:ACTIVATE_CUDA
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed CUDA Toolkit...
    )
    for %%A in ("%CUDA_URL:/=" "%") do set "CUDA_FILENAME=%%~nxA"
    set CUDA_DL=%LIB_DIR%\%CUDA_FILENAME%

    :: check installed CUDA Toolkit
    if exist "%CUDA_PATH%\bin\nvcc.exe" (
        echo CUDA Toolkit is installed.
        set ACTIVE_CUDA=1
        exit /b 0
    )
    echo CUDA Toolkit is not installed.
    echo;
    echo Do you want to install CUDA Toolkit?
    echo ^(CUDA will not be built if not installed CUDA Toolkit.^)
    set /p INPUT=[y/n]:
    if /I "%INPUT%" neq "y" (
        echo CUDA Toolkit was not installed.
        exit /b 0
    )
    
    :: install cuda Toolkit
    call :INSTALL_CUDA
    if ERRORLEVEL 1 exit /b 1
    
    set ACTIVE_CUDA=1
exit /b 0

:INSTALL_CUDA
    echo ##### downloading CUDA Toolkit...
    curl -L %CUDA_URL% -o "%CUDA_DL%"
    if ERRORLEVEL 1 (
        echo %CUDA_URL% download failed
        exit /b 1
    )
    echo ##### installing CUDA Toolkit...
    :: silent install.
    :: echo Please wait until the installation is complete. This may take some time.
	:: "%CUDA_DL%" -s
    start /wait "" "%CUDA_DL%"
    if ERRORLEVEL 1 (
        echo %CUDA_DL% install failed
        exit /b 1
    )

    :: delete dl file
	del "%CUDA_DL%"
    if ERRORLEVEL 1 (
        echo %CUDA_DL% delete failed
        exit /b 1
    )

    :: Update the "CUDA_*" environment variable without restarting the command prompt
    call :UPDATE_SYSTEM_ENVS CUDA_

    :: check installed cuda Toolkit
    if not exist "%CUDA_PATH%\bin\nvcc.exe" (
        echo CUDA Toolkit install failed
        exit /b 1
    )

    :: Update PATH without restarting the command prompt
    set "PATH=%CUDA_PATH%\libnvvp;%PATH%"
    set "PATH=%CUDA_PATH%\bin;%PATH%"
    
    echo CUDA Toolkit installed
exit /b 0

::###################################################################################
:: Vulkan SDK
::###################################################################################

:ACTIVATE_VULKAN
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed Vulkan SDK...
    )
    for %%A in ("%VULKAN_URL:/=" "%") do set "VULKAN_FILENAME=%%~nxA"
    set VULKAN_DL=%LIB_DIR%\%VULKAN_FILENAME%

    :: check installed Vulkan SDK
    if exist "%VULKAN_SDK%\Bin\glslc.exe" (
        echo Vulkan SDK is installed.
        set ACTIVE_VULKAN=1
        exit /b 0
    )

    echo Vulkan SDK is not installed.
    echo;
    echo Do you want to install Vulkan SDK?
    echo ^(Vulkan will not be built if not installed Vulkan SDK.^)
    echo ^(If installing, Only the Core installation configuration is required. The default settings are fine.^)
    set /p INPUT=[y/n]:
    if /I "%INPUT%" neq "y" (
        echo Vulkan SDK was not installed.
        exit /b 0
    )
    
    :: install Vulkan SDK
    call :INSTALL_VULKAN
    if ERRORLEVEL 1 exit /b 1
    
    set ACTIVE_VULKAN=1
exit /b 0

:INSTALL_VULKAN
    echo ##### downloading Vulkan SDK...
    curl -L %VULKAN_URL% -o "%VULKAN_DL%"
    if ERRORLEVEL 1 (
        echo %VULKAN_URL% download failed
        exit /b 1
    )
    echo ##### installing Vulkan SDK...
    :: silent install.
    :: echo Please wait until the installation is complete. This may take some time.
	:: "%VULKAN_DL%" -s
    start /wait "" "%VULKAN_DL%"
    if ERRORLEVEL 1 (
        echo %VULKAN_DL% install failed
        exit /b 1
    )

    :: delete dl file
	del "%VULKAN_DL%"
    if ERRORLEVEL 1 (
        echo %VULKAN_DL% delete failed
        exit /b 1
    )

    :: Update the "VK_SDK_PATH" and "VULKAN_SDK" environment variable without restarting the command prompt
    call :UPDATE_SYSTEM_ENV VK_SDK_PATH
    call :UPDATE_SYSTEM_ENV VULKAN_SDK

    :: check installed Vulkan SDK
    if not exist "%VULKAN_SDK%\Bin\glslc.exe" (
        echo Vulkan SDK install failed
        exit /b 1
    )

    :: Update PATH without restarting the command prompt
    set "PATH=%VULKAN_SDK%\Bin;%PATH%"
    
    echo Vulkan SDK installed
exit /b 0

::###################################################################################
:: chrome
::###################################################################################

:ACTIVATE_CHROME
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed chrome...
    )
    for %%A in ("%PORTABLE_CHROME_URL:/=" "%") do set "PORTABLE_CHROME_FILENAME=%%~nxA"
    set PORTABLE_CHROME_DL=%LIB_DIR%\%PORTABLE_CHROME_FILENAME%
    set PORTABLE_CHROME_ROOT=%LIB_DIR%\chrome

    :: check already installed portable chrome
    if not exist "%PORTABLE_CHROME_ROOT%\chrome.exe" (
        echo chrome is not installed

        :: install portable chrome
        call :INSTALL_CHROME
        if ERRORLEVEL 1 exit /b 1
    )

    :: check already installed portable chrome
    if not exist "%PORTABLE_CHROME_ROOT%\chrome.exe" (
        echo chrome driver install failed
        exit /b 1
    )
    
    set ACTIVE_CHROME=1
exit /b 0

:INSTALL_CHROME
    echo ##### downloading portable chrome...
    curl -L %PORTABLE_CHROME_URL% -o "%PORTABLE_CHROME_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_CHROME_URL% download failed
        exit /b 1
    )
    echo ##### installing portable chrome...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_CHROME_DL%' -DestinationPath '%LIB_DIR%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_CHROME_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_CHROME_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_CHROME_DL% delete failed
        exit /b 1
    )

    :: Extract folder name from full path
    for %%A in ("%PORTABLE_CHROME_DL:/=" "%") do set "_DL_NAME=%%~nA"
    for %%A in ("%PORTABLE_CHROME_ROOT:\=" "%") do set "_NAME=%%~nA"
    
    :: rename
    ren "%LIB_DIR%\%_DL_NAME%" "%_NAME%"
    if ERRORLEVEL 1 (
        echo %LIB_DIR%\%_DL_NAME% rename failed
        exit /b 1
    )
    echo ##### chrome installed
exit /b 0

::###################################################################################
:: chrome driver
::###################################################################################

:ACTIVATE_CHROME_DRIVER
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed chrome driver...
    )
    for %%A in ("%PORTABLE_CHROME_DRIVER_URL:/=" "%") do set "PORTABLE_CHROME_DRIVER_FILENAME=%%~nxA"
    set PORTABLE_CHROME_DRIVER_DL=%LIB_DIR%\%PORTABLE_CHROME_DRIVER_FILENAME%
    set PORTABLE_CHROME_DRIVER_ROOT=%LIB_DIR%\chrome_driver

    :: check already installed portable chrome
    if not exist "%PORTABLE_CHROME_DRIVER_ROOT%\chromedriver.exe" (
        echo chrome driver is not installed

        :: install portable chrome
        call :INSTALL_CHROME_DRIVER
        if ERRORLEVEL 1 exit /b 1
    )

    :: check already installed portable chrome
    if not exist "%PORTABLE_CHROME_DRIVER_ROOT%\chromedriver.exe" (
        echo chrome driver install failed
        exit /b 1
    )
    
    set ACTIVE_CHROME_DRIVER=1
exit /b 0

:INSTALL_CHROME_DRIVER
    echo ##### downloading portable chrome...
    curl -L %PORTABLE_CHROME_DRIVER_URL% -o "%PORTABLE_CHROME_DRIVER_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_CHROME_DRIVER_URL% download failed
        exit /b 1
    )
    echo ##### installing portable chrome...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_CHROME_DRIVER_DL%' -DestinationPath '%LIB_DIR%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_CHROME_DRIVER_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_CHROME_DRIVER_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_CHROME_DRIVER_DL% delete failed
        exit /b 1
    )

    :: Extract folder name from full path
    for %%A in ("%PORTABLE_CHROME_DRIVER_DL:/=" "%") do set "_DL_NAME=%%~nA"
    for %%A in ("%PORTABLE_CHROME_DRIVER_ROOT:\=" "%") do set "_NAME=%%~nA"
    
    :: rename
    ren "%LIB_DIR%\%_DL_NAME%" "%_NAME%"
    if ERRORLEVEL 1 (
        echo %LIB_DIR%\%_DL_NAME% rename failed
        exit /b 1
    )
    echo ##### chrome driver installed
exit /b 0

::###################################################################################
:: ffmpeg
::###################################################################################

:ACTIVATE_FFMPEG
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed ffmpeg...
    )
    for %%A in ("%PORTABLE_FFMPEG_URL:/=" "%") do set "PORTABLE_FFMPEG_FILENAME=%%~nxA"
    set PORTABLE_FFMPEG_DL=%LIB_DIR%\%PORTABLE_FFMPEG_FILENAME%
    set PORTABLE_FFMPEG_ROOT=%LIB_DIR%\ffmpeg

    :: check already installed portable ffmpeg
    if not exist "%PORTABLE_FFMPEG_ROOT%\bin\ffmpeg.exe" (
        echo ffmpeg is not installed

        :: install portable ffmpeg
        call :INSTALL_FFMPEG
        if ERRORLEVEL 1 exit /b 1
    )
    :: append portable ffmpeg path
    set "PATH=%PORTABLE_FFMPEG_ROOT%\bin;%PATH%"

    :: output ffmpeg path and version
    call :WHERE_EXE ffmpeg.exe -version
    if ERRORLEVEL 1 exit /b 1
    
    set ACTIVE_FFMPEG=1
exit /b 0

:INSTALL_FFMPEG
    echo ##### downloading portable ffmpeg...
    curl -L %PORTABLE_FFMPEG_URL% -o "%PORTABLE_FFMPEG_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_FFMPEG_URL% download failed
        exit /b 1
    )
    echo ##### installing portable ffmpeg...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_FFMPEG_DL%' -DestinationPath '%LIB_DIR%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_FFMPEG_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_FFMPEG_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_FFMPEG_DL% delete failed
        exit /b 1
    )

    :: Extract folder name from full path
    for %%A in ("%PORTABLE_FFMPEG_DL:/=" "%") do set "_DL_NAME=%%~nA"
    for %%A in ("%PORTABLE_FFMPEG_ROOT:\=" "%") do set "_NAME=%%~nA"
    
    :: rename
    ren "%LIB_DIR%\%_DL_NAME%" "%_NAME%"
    if ERRORLEVEL 1 (
        echo %LIB_DIR%\%_DL_NAME% rename failed
        exit /b 1
    )
    echo ##### ffmpeg installed
exit /b 0

::###################################################################################
:: nodejs
::###################################################################################

:ACTIVATE_NODEJS
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed nodejs...
    )
    for %%A in ("%PORTABLE_NODEJS_URL:/=" "%") do set "PORTABLE_NODEJS_FILENAME=%%~nxA"
    set PORTABLE_NODEJS_DL=%LIB_DIR%\%PORTABLE_NODEJS_FILENAME%
    set PORTABLE_NODEJS_ROOT=%LIB_DIR%\nodejs

    :: check already installed portable nodejs
    call :FIND_SYSTEM_EXE npm --version
    if ERRORLEVEL 1 (
	    if not exist "%PORTABLE_NODEJS_ROOT%\npm" (
	        echo nodejs is not installed

	        :: install portable nodejs
	        call :INSTALL_NODEJS
	        if ERRORLEVEL 1 exit /b 1
	    ) else (
		    :: append portable nodejs path
		    set "PATH=%PORTABLE_NODEJS_ROOT%;%PATH%"
	    )

	    :: output nodejs path and version
	    call :WHERE_EXE npm --version
	    if ERRORLEVEL 1 exit /b 1
    )

    if exist "%CUR_DIR%opencode.json" (
        set "OPENCODE_CONFIG=%CUR_DIR%opencode.json"
    )
    
    set ACTIVE_NODEJS=1
exit /b 0

:INSTALL_NODEJS
    echo ##### downloading portable nodejs...
    curl -L %PORTABLE_NODEJS_URL% -o "%PORTABLE_NODEJS_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_NODEJS_URL% download failed
        exit /b 1
    )
    echo ##### installing portable nodejs...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_NODEJS_DL%' -DestinationPath '%LIB_DIR%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_NODEJS_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_NODEJS_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_NODEJS_DL% delete failed
        exit /b 1
    )

    :: Extract folder name from full path
    for %%A in ("%PORTABLE_NODEJS_DL:/=" "%") do set "_DL_NAME=%%~nA"
    for %%A in ("%PORTABLE_NODEJS_ROOT:\=" "%") do set "_NAME=%%~nA"
    
    :: rename
    ren "%LIB_DIR%\%_DL_NAME%" "%_NAME%"
    if ERRORLEVEL 1 (
        echo %LIB_DIR%\%_DL_NAME% rename failed
        exit /b 1
    )
    
    set "PATH=%PORTABLE_NODEJS_ROOT%;%PATH%"
    
    if "%PORTABLE_NODEJS_REQUIREMENT_MODULES%" neq "" (
        call npm install %PORTABLE_NODEJS_REQUIREMENT_MODULES%
        if ERRORLEVEL 1 exit /b 1
    )
    
    if exist "%CUR_DIR%package.json" (
        call npm install
        if ERRORLEVEL 1 exit /b 1
    )
    
    echo ##### nodejs installed
exit /b 0

::###################################################################################
:: go
::###################################################################################

:ACTIVATE_GO
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed go...
    )
    for %%A in ("%PORTABLE_GO_URL:/=" "%") do set "PORTABLE_GO_FILENAME=%%~nxA"
    set PORTABLE_GO_DL=%LIB_DIR%\%PORTABLE_GO_FILENAME%
    set PORTABLE_GO_ROOT=%LIB_DIR%\go

    :: check already installed portable go
    call :FIND_SYSTEM_EXE go version
    if ERRORLEVEL 1 (
	    if not exist "%PORTABLE_GO_ROOT%\bin\go.exe" (
	        echo go is not installed

	        :: install portable go
	        call :INSTALL_GO
	        if ERRORLEVEL 1 exit /b 1
	    )
	    :: append portable go path
	    set "PATH=%PORTABLE_GO_ROOT%\bin;%PATH%"

	    :: output nodejs path and version
	    call :WHERE_EXE go version
	    if ERRORLEVEL 1 exit /b 1
    )
    
    set ACTIVE_GO=1
exit /b 0

:INSTALL_GO
    echo ##### downloading portable go...
    curl -L %PORTABLE_GO_URL% -o "%PORTABLE_GO_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_GO_URL% download failed
        exit /b 1
    )
    echo ##### installing portable go...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_GO_DL%' -DestinationPath '%LIB_DIR%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_GO_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_GO_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_GO_DL% delete failed
        exit /b 1
    )
    
    echo ##### go installed
exit /b 0

::###################################################################################
:: bun
::###################################################################################

:ACTIVATE_BUN
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed bun...
    )
    for %%A in ("%PORTABLE_BUN_URL:/=" "%") do set "PORTABLE_BUN_FILENAME=%%~nxA"
    set PORTABLE_BUN_DL=%LIB_DIR%\%PORTABLE_BUN_FILENAME%
    set PORTABLE_BUN_ROOT=%LIB_DIR%\bun

    :: check already installed portable bun
    call :FIND_SYSTEM_EXE bun --version
    if ERRORLEVEL 1 (
        if not exist "%PORTABLE_BUN_ROOT%\bun.exe" (
            echo bun is not installed

            :: install portable bun
            call :INSTALL_BUN
            if ERRORLEVEL 1 exit /b 1
        ) else (
            :: append portable bun path
            set "PATH=%PORTABLE_BUN_ROOT%;%PATH%"
        )

        :: output bun path and version
        call :WHERE_EXE bun --version
        if ERRORLEVEL 1 exit /b 1
    )
    
    set ACTIVE_BUN=1
exit /b 0

:INSTALL_BUN
    echo ##### downloading portable bun...
    curl -L %PORTABLE_BUN_URL% -o "%PORTABLE_BUN_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_BUN_URL% download failed
        exit /b 1
    )
    echo ##### installing portable bun...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_BUN_DL%' -DestinationPath '%LIB_DIR%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_BUN_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
    del "%PORTABLE_BUN_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_BUN_DL% delete failed
        exit /b 1
    )
    
    :: Extract folder name from full path
    for %%A in ("%PORTABLE_BUN_DL:/=" "%") do set "_DL_NAME=%%~nA"
    for %%A in ("%PORTABLE_BUN_ROOT:\=" "%") do set "_NAME=%%~nA"
    
    :: rename
    ren "%LIB_DIR%\%_DL_NAME%" "%_NAME%"
    if ERRORLEVEL 1 (
        echo %LIB_DIR%\%_DL_NAME% rename failed
        exit /b 1
    )
    
    set "PATH=%PORTABLE_BUN_ROOT%;%PATH%"
    
    :: ensure bunx exists (bun.exe x wrapper)
    call :CREATE_BUNX
    if ERRORLEVEL 1 exit /b 1
    
    if "%PORTABLE_BUN_REQUIREMENT_MODULES%" neq "" (
        call %PORTABLE_BUN_REQUIREMENT_MODULES%
        if ERRORLEVEL 1 exit /b 1
    )
    
    echo ##### bun installed
exit /b 0

:CREATE_BUNX
    :: Create bunx.cmd next to bun.exe so `bunx ...` works on Windows.
    :: The official installer does this via `bun.exe completions` (see https://bun.com/install.ps1).
    if "%PORTABLE_BUN_ROOT%" equ "" exit /b 0
    if not exist "%PORTABLE_BUN_ROOT%\bun.exe" exit /b 0
    if exist "%PORTABLE_BUN_ROOT%\bunx.cmd" exit /b 0

    echo ##### creating bunx.cmd shim...
    > "%PORTABLE_BUN_ROOT%\bunx.cmd" (
        echo @echo off
        echo "%%~dp0bun.exe" x %%*
        echo exit /b %%ERRORLEVEL%%
    )

    if not exist "%PORTABLE_BUN_ROOT%\bunx.cmd" (
        echo bunx.cmd create failed
        exit /b 1
    )
exit /b 0

::###################################################################################
:: svn
::###################################################################################

:ACTIVATE_SVN
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed svn...
    )
    for %%A in ("%PORTABLE_SVN_URL:/=" "%") do set "PORTABLE_SVN_FILENAME=%%~nxA"
    set PORTABLE_SVN_DL=%LIB_DIR%\%PORTABLE_SVN_FILENAME%
    set PORTABLE_SVN_ROOT=%LIB_DIR%\svn

    :: check already installed portable svn
    call :FIND_SYSTEM_EXE svn --version --quiet
    if ERRORLEVEL 1 (
	    if not exist "%PORTABLE_SVN_ROOT%\bin\svn.exe" (
	        echo svn is not installed

	        :: install portable svn
	        call :INSTALL_SVN
	        if ERRORLEVEL 1 exit /b 1
	    )
	    :: append portable svn path
	    set "PATH=%PORTABLE_SVN_ROOT%\bin;%PATH%"

	    :: output nodejs path and version
	    call :WHERE_EXE svn --version --quiet
	    if ERRORLEVEL 1 exit /b 1
    )
    
    set ACTIVE_SVN=1
exit /b 0

:INSTALL_SVN
    echo ##### downloading portable svn...
    curl -L %PORTABLE_SVN_URL% -o "%PORTABLE_SVN_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_SVN_URL% download failed
        exit /b 1
    )
    echo ##### installing portable svn...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_SVN_DL%' -DestinationPath '%PORTABLE_SVN_ROOT%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_SVN_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_SVN_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_SVN_DL% delete failed
        exit /b 1
    )
    
    echo ##### svn installed
exit /b 0

::###################################################################################
:: grafana
::###################################################################################

:ACTIVATE_GRAFANA
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed grafana...
    )
    for %%A in ("%PORTABLE_GRAFANA_URL:/=" "%") do set "PORTABLE_GRAFANA_FILENAME=%%~nxA"
    set PORTABLE_GRAFANA_DL=%LIB_DIR%\%PORTABLE_GRAFANA_FILENAME%
    set PORTABLE_GRAFANA_ROOT=%LIB_DIR%\grafana

    :: check already installed portable grafana
    if not exist "%PORTABLE_GRAFANA_ROOT%\bin\grafana.exe" (
        echo grafana is not installed

        :: install portable grafana
        call :INSTALL_GRAFANA
        if ERRORLEVEL 1 exit /b 1
    )
    :: append portable grafana path
    set "PATH=%PORTABLE_GRAFANA_ROOT%\bin;%PATH%"

    :: output grafana path and version
    call :WHERE_EXE grafana.exe -v
    if ERRORLEVEL 1 exit /b 1
    
    set ACTIVE_GRAFANA=1
exit /b 0

:INSTALL_GRAFANA
    echo ##### downloading portable grafana...
    curl -L %PORTABLE_GRAFANA_URL% -o "%PORTABLE_GRAFANA_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_GRAFANA_URL% download failed
        exit /b 1
    )
    echo ##### installing portable grafana...
    :: extract tar.gz
    tar -xzf "%PORTABLE_GRAFANA_DL%" -C "%LIB_DIR%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_GRAFANA_DL% extract failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_GRAFANA_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_GRAFANA_DL% delete failed
        exit /b 1
    )

    :: find extracted grafana directory (folder name differs from zip file name)
    for /d %%D in ("%LIB_DIR%\grafana-*") do (
        ren "%%D" "grafana"
        goto :L_INSTALL_GRAFANA_RENAMED
    )
    echo %LIB_DIR%\grafana-* rename failed
    exit /b 1
    :L_INSTALL_GRAFANA_RENAMED
    echo ##### grafana installed
exit /b 0

::###################################################################################
:: loki
::###################################################################################

:ACTIVATE_LOKI
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed loki...
    )
    for %%A in ("%PORTABLE_LOKI_URL:/=" "%") do set "PORTABLE_LOKI_FILENAME=%%~nxA"
    set PORTABLE_LOKI_DL=%LIB_DIR%\%PORTABLE_LOKI_FILENAME%
    set PORTABLE_LOKI_ROOT=%LIB_DIR%\loki

    :: check already installed portable loki
    if not exist "%PORTABLE_LOKI_ROOT%\loki-windows-amd64.exe" (
        echo loki is not installed

        :: install portable loki
        call :INSTALL_LOKI
        if ERRORLEVEL 1 exit /b 1
    )
    :: append portable loki path
    set "PATH=%PORTABLE_LOKI_ROOT%;%PATH%"

    :: output loki path and version
    call :WHERE_EXE loki-windows-amd64.exe --version
    if ERRORLEVEL 1 exit /b 1
    
    set ACTIVE_LOKI=1
exit /b 0

:INSTALL_LOKI
    echo ##### downloading portable loki...
    curl -L %PORTABLE_LOKI_URL% -o "%PORTABLE_LOKI_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_LOKI_URL% download failed
        exit /b 1
    )
    echo ##### installing portable loki...
    :: unzip (archive contains a single executable at root)
    powershell -Command "Expand-Archive -Path '%PORTABLE_LOKI_DL%' -DestinationPath '%LIB_DIR%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_LOKI_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_LOKI_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_LOKI_DL% delete failed
        exit /b 1
    )

    :: move executable into loki root directory
    if not exist "%PORTABLE_LOKI_ROOT%\" mkdir "%PORTABLE_LOKI_ROOT%"
    move "%LIB_DIR%\loki-windows-amd64.exe" "%PORTABLE_LOKI_ROOT%\"
    if ERRORLEVEL 1 (
        echo %LIB_DIR%\loki-windows-amd64.exe move failed
        exit /b 1
    )
    echo ##### loki installed
exit /b 0

::###################################################################################
:: prometheus
::###################################################################################

:ACTIVATE_PROMETHEUS
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed prometheus...
    )
    for %%A in ("%PORTABLE_PROMETHEUS_URL:/=" "%") do set "PORTABLE_PROMETHEUS_FILENAME=%%~nxA"
    set PORTABLE_PROMETHEUS_DL=%LIB_DIR%\%PORTABLE_PROMETHEUS_FILENAME%
    set PORTABLE_PROMETHEUS_ROOT=%LIB_DIR%\prometheus

    :: check already installed portable prometheus
    if not exist "%PORTABLE_PROMETHEUS_ROOT%\prometheus.exe" (
        echo prometheus is not installed

        :: install portable prometheus
        call :INSTALL_PROMETHEUS
        if ERRORLEVEL 1 exit /b 1
    )
    :: append portable prometheus path
    set "PATH=%PORTABLE_PROMETHEUS_ROOT%;%PATH%"

    :: output prometheus path and version
    call :WHERE_EXE prometheus.exe --version
    if ERRORLEVEL 1 exit /b 1
    
    set ACTIVE_PROMETHEUS=1
exit /b 0

:INSTALL_PROMETHEUS
    echo ##### downloading portable prometheus...
    curl -L %PORTABLE_PROMETHEUS_URL% -o "%PORTABLE_PROMETHEUS_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_PROMETHEUS_URL% download failed
        exit /b 1
    )
    echo ##### installing portable prometheus...
    :: unzip
    powershell -Command "Expand-Archive -Path '%PORTABLE_PROMETHEUS_DL%' -DestinationPath '%LIB_DIR%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_PROMETHEUS_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_PROMETHEUS_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_PROMETHEUS_DL% delete failed
        exit /b 1
    )

    :: Extract folder name from full path
    for %%A in ("%PORTABLE_PROMETHEUS_DL:/=" "%") do set "_DL_NAME=%%~nA"
    for %%A in ("%PORTABLE_PROMETHEUS_ROOT:\=" "%") do set "_NAME=%%~nA"
    
    :: rename
    ren "%LIB_DIR%\%_DL_NAME%" "%_NAME%"
    if ERRORLEVEL 1 (
        echo %LIB_DIR%\%_DL_NAME% rename failed
        exit /b 1
    )
    echo ##### prometheus installed
exit /b 0

::###################################################################################
:: alloy (promtail の後継。syslog 受信 -^> Loki push)
::###################################################################################

:ACTIVATE_ALLOY
    if "%PORTABLE_CMD_SILENT%" neq "1" (
        echo;
        echo ##### checking installed alloy...
    )
    for %%A in ("%PORTABLE_ALLOY_URL:/=" "%") do set "PORTABLE_ALLOY_FILENAME=%%~nxA"
    set PORTABLE_ALLOY_DL=%LIB_DIR%\%PORTABLE_ALLOY_FILENAME%
    set PORTABLE_ALLOY_ROOT=%LIB_DIR%\alloy

    :: check already installed portable alloy
    if not exist "%PORTABLE_ALLOY_ROOT%\alloy-windows-amd64.exe" (
        echo alloy is not installed

        :: install portable alloy
        call :INSTALL_ALLOY
        if ERRORLEVEL 1 exit /b 1
    )
    :: append portable alloy path
    set "PATH=%PORTABLE_ALLOY_ROOT%;%PATH%"

    :: output alloy path and version
    call :WHERE_EXE alloy-windows-amd64.exe --version
    if ERRORLEVEL 1 exit /b 1

    set ACTIVE_ALLOY=1
exit /b 0

:INSTALL_ALLOY
    echo ##### downloading portable alloy...
    curl -L %PORTABLE_ALLOY_URL% -o "%PORTABLE_ALLOY_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_ALLOY_URL% download failed
        exit /b 1
    )
    echo ##### installing portable alloy...
    :: unzip (archive contains a single executable at root)
    powershell -Command "Expand-Archive -Path '%PORTABLE_ALLOY_DL%' -DestinationPath '%LIB_DIR%'"
    if ERRORLEVEL 1 (
        echo %PORTABLE_ALLOY_DL% unzip failed
        exit /b 1
    )

    :: delete dl file
	del "%PORTABLE_ALLOY_DL%"
    if ERRORLEVEL 1 (
        echo %PORTABLE_ALLOY_DL% delete failed
        exit /b 1
    )

    :: move executable into alloy root directory
    if not exist "%PORTABLE_ALLOY_ROOT%\" mkdir "%PORTABLE_ALLOY_ROOT%"
    move "%LIB_DIR%\alloy-windows-amd64.exe" "%PORTABLE_ALLOY_ROOT%\"
    if ERRORLEVEL 1 (
        echo %LIB_DIR%\alloy-windows-amd64.exe move failed
        exit /b 1
    )
    echo ##### alloy installed
exit /b 0

