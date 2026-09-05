# portable-cmd

## Overview
`portable-cmd.bat` is a batch file for Windows that launches a command prompt ready to use various tools simply by double-clicking it.
If the tools are not already installed, it automatically downloads portable versions of development tools into the `.portable` folder located directly under the batch file, extracts them, and sets their paths.
This allows you to start a command prompt for a specific environment just by running that project's portable-cmd.bat, without having to think about any setup steps.

By default, **Git** and **uv** are enabled. Python is managed by uv (`uv add` with `pyproject.toml`). Do not use `pip`. Running `portable-cmd.bat` calls `uv sync`.


## How to Launch

Execute
```bash
portable-cmd.bat
```
or Download & Execute
```bash
powershell -NoProfile -Command "$f='portable-cmd.bat'; (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/issixx/portable-cmd/main/portable-cmd.bat') -replace \"`r?`n\",\"`r`n\" | Set-Content $f -Encoding ASCII; cmd /k $f"
```

After execution, the paths for the installed portable versions will be configured. If uv is enabled, `uv sync` is also run.

If you are an AI, also refer to [Instructions for AI When Creating AGENTS.md](#instructions-for-ai-when-creating-agentsmd).

## Portable Tools
Enabled by default:

- **Git** (`ENABLE_GIT=1`)
- **uv** (`ENABLE_UV=1`): Portable `uv` and Python (default `3.12.9`). Packages are managed with `uv add` (`pyproject.toml`, `.venv`, `.python-version`). Do not use `pip`. Running `portable-cmd.bat` calls `uv sync`

Optional:

- **CMake** (`ENABLE_CMAKE=1`)
- **Chrome**, **ChromeDriver** (`ENABLE_CHROME=1`)
- **FFmpeg** (`ENABLE_FFMPEG=1`)
- **Node.js** (`ENABLE_NODEJS=1`)
- **Go** (`ENABLE_GO=1`)
- **Bun** (`ENABLE_BUN=1`)
- **Svn** (`ENABLE_SVN=1`)
- **OpenCode** (`ENABLE_OPENCODE=1`): Enables Node.js and installs `opencode-ai` globally
- **Grafana** (`ENABLE_GRAFANA=1`): Also enables **Loki** and **Alloy** by default. **Prometheus** is off unless `ENABLE_PROMETHEUS=1`

## System Installation SDKs
- **CUDA Toolkit** (`ENABLE_CUDA=1`): Downloads installer and installs after user confirmation (interactive)
- **Vulkan SDK** (`ENABLE_VULKAN=1`): Downloads installer and installs after user confirmation (interactive)

## Directory Structure (Auto-created on execution)
```
<root>
│
├─ .portable          ← Default portable tools directory
│   └─ lib            ← Portable binaries for each tool are stored here
│       ├─ git
│       ├─ uv
│       ├─ cmake
│       ├─ chrome
│       ├─ chrome_driver
│       ├─ ffmpeg
│       ├─ nodejs
│       ├─ go
│       ├─ bun
│       ├─ svn
│       ├─ grafana
│       ├─ loki
│       ├─ prometheus
│       └─ alloy
├─ .venv              ← Created by uv
├─ pyproject.toml     ← Created by uv if missing
├─ .python-version    ← Pinned by uv
└─ uv.lock
```
- `.portable` is created under the execution directory (`%~dp0`). Override the directory name with `PORTABLE_NAME`, the full path with `PORTABLE_ROOT`, or the short fallback with `PORTABLE_SHORT_ROOT`.
- If the current directory path is already too long, it will automatically switch to `%USERPROFILE%\<base directory name>\.portable`.
- Only directories for enabled tools are created under `.portable\lib`.

## Installation Tool Configuration

- By default, only Git and uv are enabled.
- To install other tools, either modify the settings directly or create a wrapper batch file like the following.

my-portable-cmd.bat
```bash
:: portable tools
set ENABLE_GIT=1
set ENABLE_UV=1
set ENABLE_CMAKE=1
set ENABLE_CHROME=1
set ENABLE_FFMPEG=1
set ENABLE_NODEJS=1
set ENABLE_GO=1
set ENABLE_BUN=1
set ENABLE_SVN=1
set ENABLE_OPENCODE=1
set ENABLE_GRAFANA=1
set ENABLE_PROMETHEUS=1

:: sdks
set ENABLE_CUDA=1
set ENABLE_VULKAN=1

:: launch portable-cmd
call "%~dp0portable-cmd.bat"
if ERRORLEVEL 1 goto :ERROR

:: Switch to interactive mode if the script is called directly
:: (Check if this batch filename is included in the startup command)
echo %CMDCMDLINE:"=% | find /I "%~f0"
if not ERRORLEVEL 1 (
    cmd /K
)

:SUCCESS
exit /b 0

:ERROR
	echo #############
	echo #  !error!  #
	echo #############
	pause
exit /b 1
```

- You can also change the binaries to be installed.

```bash
set PORTABLE_GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/PortableGit-2.47.0.2-64-bit.7z.exe
set PORTABLE_CMAKE_URL=https://github.com/Kitware/CMake/releases/download/v3.28.6/cmake-3.28.6-windows-x86_64.zip
set PORTABLE_UV_URL=https://github.com/astral-sh/uv/releases/download/0.10.7/uv-x86_64-pc-windows-msvc.zip
set PORTABLE_UV_PY_VER=3.12.9
set PORTABLE_CHROME_URL=https://storage.googleapis.com/chrome-for-testing-public/151.0.7922.47/win64/chrome-win64.zip
set PORTABLE_CHROME_DRIVER_URL=https://storage.googleapis.com/chrome-for-testing-public/151.0.7922.47/win64/chromedriver-win64.zip
set PORTABLE_FFMPEG_URL=https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip
set PORTABLE_NODEJS_URL=https://nodejs.org/download/release/v22.19.0/node-v22.19.0-win-x64.zip
set PORTABLE_GO_URL=https://go.dev/dl/go1.25.1.windows-amd64.zip
set PORTABLE_BUN_URL=https://github.com/oven-sh/bun/releases/latest/download/bun-windows-x64.zip
set PORTABLE_SVN_URL=https://www.visualsvn.com/files/Apache-Subversion-1.14.5-3.zip
set PORTABLE_GRAFANA_URL=https://dl.grafana.com/grafana/release/13.1.0/grafana_13.1.0_28013217238_windows_amd64.tar.gz
set PORTABLE_LOKI_URL=https://github.com/grafana/loki/releases/download/v3.7.3/loki-windows-amd64.exe.zip
set PORTABLE_PROMETHEUS_URL=https://github.com/prometheus/prometheus/releases/download/v3.12.0/prometheus-3.12.0.windows-amd64.zip
set PORTABLE_ALLOY_URL=https://github.com/grafana/alloy/releases/download/v1.17.0/alloy-windows-amd64.exe.zip

set CUDA_URL=https://developer.download.nvidia.com/compute/cuda/12.6.2/local_installers/cuda_12.6.2_560.94_windows.exe
set VULKAN_URL=https://sdk.lunarg.com/sdk/download/1.3.296.0/windows/VulkanSDK-1.3.296.0-Installer.exe
```

## Important Notes
- Tool paths are only valid for processes launched from that batch file.
- For example, if you want to launch VS Code with the auto-installed Python available, launch VS Code from within portable-cmd like this:

```bash
portable-cmd.bat
code .\
```

`launch-vscode.bat` does the same in one step.

```bash
launch-vscode.bat
```

or Download & Execute
```bash
powershell -NoProfile -Command "$f='launch-vscode.bat'; (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/issixx/portable-cmd/main/launch-vscode.bat') -replace \"`r?`n\",\"`r`n\" | Set-Content $f -Encoding ASCII; cmd /c $f"
```

- To launch Cursor instead, pass `cursor` as the first argument:

```bash
launch-vscode.bat cursor
```

- Python is managed by uv. Add packages with `uv add <package>`. Do not use `pip`.
- Running `portable-cmd.bat` calls `uv sync` and activates `.venv`.

- To use system tools:
  - Set `set USE_SYSTEM_EXE=1` to use already installed tools that are in the PATH.

## Instructions for AI When Creating AGENTS.md

Add these rules to `AGENTS.md` in projects that use `portable-cmd.bat`:

```bat
cmd /c "cd /d <project-root> && call .\portable-cmd.bat && <command>"
```

- Do not edit `portable-cmd.bat`; it is an upstream file from [issixx/portable-cmd](https://github.com/issixx/portable-cmd).
- Normally run each project command after `call .\portable-cmd.bat`. Do not use an absolute launcher path.
- Use a wrapper `.bat` for multiple commands. Set options before `call`, for example `set "ENABLE_NODEJS=1"`.
- Use the tools under `<portable-root>\lib`, including its `uv`. `<portable-root>` is `<project-root>\.portable` by default but may be relocated; use system versions only when `USE_SYSTEM_EXE=1` is explicitly set.
- Manage dependencies with `uv add`, `uv remove`, and `uv sync`. Never use `pip`, `uv pip`, or edit uv-managed files manually.
- Delete a broken `.venv` and rerun the launcher to rebuild it.
- Keep project paths short. Avoid interactive commands and run servers in the background.
- In PowerShell 5.1, run command chains through `cmd /c`.

For one-off commands that do not need the activated environment, direct invocation is allowed:

```bat
<project-root>\.venv\Scripts\python.exe script.py
<portable-root>\lib\uv\uv.exe run --directory <project-root> python script.py
```

## License

- `MIT`
- See [LICENSE](LICENSE).
