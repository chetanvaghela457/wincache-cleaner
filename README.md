# WinCache Cleaner (Windows)

[![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen)](https://github.com/chetanvaghela457/wincache-cleaner)
[![GitHub stars](https://img.shields.io/github/stars/chetanvaghela457/wincache-cleaner)](https://github.com/chetanvaghela457/wincache-cleaner/stargazers)

PowerShell utility that removes heavy caches for common Windows dev/creative tools. Missing software is skipped automatically; only cache/log/temp paths are touched.

## What it cleans
- Android Studio / Gradle caches
- Flutter projects + global cache (Pub/FVM)
- Node package managers (npm/yarn/pnpm)
- Python pip cache
- .NET / NuGet cache
- IDE caches: Visual Studio, VS Code, JetBrains (including Toolbox)
- Browsers: Chrome, Edge, Brave, Firefox, Opera/Opera GX, Vivaldi
- Adobe: Premiere, After Effects, Photoshop, Media Encoder, Lightroom caches
- Unity / Unity Hub caches
- Docker Desktop logs/cache (optional prune prompt)
- System temp and Recycle Bin

## Quick start (one-liner)
```powershell
iwr https://raw.githubusercontent.com/chetanvaghela457/wincache-cleaner/main/wincache-cleaner.ps1 -OutFile wincache-cleaner.ps1; powershell -ExecutionPolicy Bypass -File .\wincache-cleaner.ps1
```

## From a clone
```powershell
git clone https://github.com/chetanvaghela457/wincache-cleaner.git
cd wincache-cleaner
powershell -ExecutionPolicy Bypass -File .\wincache-cleaner.ps1
```

Choose a menu option (0–12). The script continues even if certain tools aren’t installed.

## Safety
- Targets only caches/logs/temp; does not touch source files or documents.
- Docker prune is opt-in and clearly prompted.
- Errors are non-fatal so the menu run won’t hang on missing tools.

## Contributing
PRs and issues welcome.

<a href="https://github.com/chetanvaghela457/wincache-cleaner/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=chetanvaghela457/wincache-cleaner&preview=false&max=&columns=" />
</a>
