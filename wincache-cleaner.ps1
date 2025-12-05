<#
WinCache Cleaner (Windows) - PowerShell utility to clear common development and creative-tool caches.
Targets: Android Studio/Gradle, Flutter (projects + global), Node (npm/yarn/pnpm), Python (pip),
.NET/NuGet, IDEs (VS, VSCode, JetBrains), browsers, Adobe apps (Premiere/AE/PS/Media Encoder),
Unity, Docker Desktop, system temp/Recycle Bin. Designed to be cautious: only cache/log/temp paths,
no project sources or user docs.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
# Continue on errors so a missing tool/cache does not halt the script
$ErrorActionPreference = "Continue"

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "=== $Title ===" -ForegroundColor Cyan
}

function Remove-Paths {
    param(
        [string]$Label,
        [string[]]$Paths,
        [switch]$Recurse
    )
    Write-Host "-> $Label" -ForegroundColor Green
    foreach ($p in $Paths | Where-Object { $_ -and (Test-Path $_) }) {
        try {
            Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue -Recurse:$Recurse
        } catch {
            Write-Host "   Skipped: $p ($_)" -ForegroundColor Yellow
        }
    }
}

function Clean-AndroidGradle {
    Write-Section "Android Studio / Gradle"
    $paths = @(
        "$env:USERPROFILE\.gradle\caches",
        "$env:USERPROFILE\.gradle\daemon",
        "$env:USERPROFILE\.android\cache",
        "$env:LOCALAPPDATA\Google\AndroidStudio*\system\caches",
        "$env:LOCALAPPDATA\Google\AndroidStudio*\system\log",
        "$env:LOCALAPPDATA\Google\AndroidStudio*\system\compile-server",
        "$env:LOCALAPPDATA\Google\AndroidStudio*\system\tasks",
        "$env:LOCALAPPDATA\JetBrains\Toolbox\apps\AndroidStudio\*\system\caches"
    )
    Remove-Paths -Label "Gradle/Android Studio caches" -Paths $paths -Recurse
}

function Clean-Flutter {
    Write-Section "Flutter projects + global cache"
    $projects = Get-ChildItem -Path . -Recurse -Filter pubspec.yaml -ErrorAction SilentlyContinue
    foreach ($file in $projects) {
        $dir = $file.Directory.FullName
        Write-Host "Cleaning Flutter project: $dir" -ForegroundColor Green
        $projectPaths = @(
            "$dir\build",
            "$dir\.dart_tool",
            "$dir\.packages",
            "$dir\pubspec.lock",
            "$dir\android\.gradle",
            "$dir\android\build",
            "$dir\android\app\build",
            "$dir\ios\Pods"
        )
        Remove-Paths -Label "Project cache" -Paths $projectPaths -Recurse
    }
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        Write-Host "Running: flutter cache clean" -ForegroundColor Green
        try { flutter cache clean | Out-Null } catch { Write-Host "flutter cache clean failed: $_" -ForegroundColor Yellow }
    }
    $globalPaths = @(
        "$env:LOCALAPPDATA\Pub\Cache",
        "$env:USERPROFILE\.pub-cache",
        "$env:USERPROFILE\fvm"
    )
    Remove-Paths -Label "Flutter global caches (Pub/FVM)" -Paths $globalPaths -Recurse
}

function Clean-Node {
    Write-Section "Node package managers"
    if (Get-Command npm -ErrorAction SilentlyContinue) { try { npm cache clean --force | Out-Null } catch { Write-Host "npm cache clean failed: $_" -ForegroundColor Yellow } }
    if (Get-Command yarn -ErrorAction SilentlyContinue) { try { yarn cache clean | Out-Null } catch { Write-Host "yarn cache clean failed: $_" -ForegroundColor Yellow } }
    if (Get-Command pnpm -ErrorAction SilentlyContinue) { try { pnpm store prune | Out-Null } catch { Write-Host "pnpm store prune failed: $_" -ForegroundColor Yellow } }
}

function Clean-Python {
    Write-Section "Python (pip)"
    $paths = @(
        "$env:LOCALAPPDATA\pip\Cache",
        "$env:USERPROFILE\.cache\pip"
    )
    Remove-Paths -Label "pip cache" -Paths $paths -Recurse
}

function Clean-DotNetNuGet {
    Write-Section ".NET / NuGet"
    if (Get-Command dotnet -ErrorAction SilentlyContinue) { try { dotnet nuget locals all --clear | Out-Null } catch { Write-Host "dotnet nuget locals failed: $_" -ForegroundColor Yellow } }
    if (Get-Command nuget -ErrorAction SilentlyContinue) { try { nuget locals all -clear | Out-Null } catch { Write-Host "nuget locals failed: $_" -ForegroundColor Yellow } }
    $paths = @("$env:USERPROFILE\.nuget\packages")
    Remove-Paths -Label "NuGet packages cache" -Paths $paths -Recurse
}

function Clean-IDEs {
    Write-Section "IDEs (VS, VS Code, JetBrains)"
    $paths = @(
        "$env:APPDATA\Code\Cache",
        "$env:APPDATA\Code\CachedData",
        "$env:APPDATA\Code\User\workspaceStorage",
        "$env:APPDATA\Code\User\History",
        "$env:LOCALAPPDATA\Microsoft\VisualStudio\*\ComponentModelCache",
        "$env:LOCALAPPDATA\Microsoft\VisualStudio\*\Cache",
        "$env:LOCALAPPDATA\Microsoft\VSCommon\*\Cache",
        "$env:LOCALAPPDATA\JetBrains\*\caches",
        "$env:LOCALAPPDATA\JetBrains\*\log",
        "$env:LOCALAPPDATA\JetBrains\Toolbox\apps\*\*\system\caches",
        "$env:LOCALAPPDATA\JetBrains\Toolbox\apps\*\*\system\log"
    )
    Remove-Paths -Label "IDE caches" -Paths $paths -Recurse
}

function Clean-Browsers {
    Write-Section "Browsers"
    $paths = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Profile*\Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Profile*\Cache",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Profile*\Cache",
        "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2",
        "$env:APPDATA\Opera Software\Opera Stable\Cache",
        "$env:APPDATA\Opera Software\Opera GX Stable\Cache",
        "$env:LOCALAPPDATA\Vivaldi\User Data\Default\Cache"
    )
    Remove-Paths -Label "Browser caches" -Paths $paths -Recurse
}

function Clean-Adobe {
    Write-Section "Adobe (Premiere, After Effects, Photoshop, Media Encoder, Lightroom)"
    $paths = @(
        "$env:APPDATA\Adobe\Common\Media Cache",
        "$env:APPDATA\Adobe\Common\Media Cache Files",
        "$env:APPDATA\Adobe\Common\Media Cache Peaks",
        "$env:APPDATA\Adobe\After Effects\*\Disk Cache",
        "$env:APPDATA\Adobe\After Effects\*\Media Cache",
        "$env:APPDATA\Adobe\After Effects\*\Media Cache Files",
        "$env:APPDATA\Adobe\Premiere Pro\*\Profile-*\Media Cache",
        "$env:APPDATA\Adobe\Premiere Pro\*\Profile-*\Media Cache Files",
        "$env:APPDATA\Adobe\Premiere Pro\*\Profile-*\Peak Files",
        "$env:APPDATA\Adobe\Adobe Photoshop *\CT Font Cache.dat",
        "$env:LOCALAPPDATA\Adobe\Lightroom\Caches",
        "$env:APPDATA\Adobe\CameraRaw\Cache",
        "$env:TEMP\Adobe"
    )
    Remove-Paths -Label "Adobe caches" -Paths $paths -Recurse
}

function Clean-Unity {
    Write-Section "Unity / Unity Hub"
    $paths = @(
        "$env:APPDATA\Unity\Asset Store-5.x",
        "$env:APPDATA\Unity\Cache",
        "$env:LOCALAPPDATA\Unity\cache",
        "$env:LOCALAPPDATA\Unity\Editor",
        "$env:APPDATA\UnityHub\logs"
    )
    Remove-Paths -Label "Unity caches" -Paths $paths -Recurse
}

function Clean-Docker {
    Write-Section "Docker Desktop"
    $paths = @(
        "$env:LOCALAPPDATA\Docker\log.txt",
        "$env:LOCALAPPDATA\Docker\logs",
        "$env:LOCALAPPDATA\Docker\cache"
    )
    Remove-Paths -Label "Docker Desktop logs/cache" -Paths $paths -Recurse
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        $answer = Read-Host "Run docker system prune -a --volumes (frees images/containers; destructive)? y/N"
        if ($answer -match '^(y|Y)$') {
            try { docker system prune -a -f --volumes } catch { Write-Host "docker system prune failed: $_" -ForegroundColor Yellow }
        }
    }
}

function Clean-System {
    Write-Section "System temp / Recycle Bin"
    $paths = @(
        "$env:TEMP\*",
        "$env:WINDIR\Temp\*"
    )
    Remove-Paths -Label "Temp folders" -Paths $paths -Recurse
    if (Get-Command Clear-RecycleBin -ErrorAction SilentlyContinue) {
        try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch {}
    }
}

function Clean-All {
    Clean-AndroidGradle
    Clean-Flutter
    Clean-Node
    Clean-Python
    Clean-DotNetNuGet
    Clean-IDEs
    Clean-Browsers
    Clean-Adobe
    Clean-Unity
    Clean-Docker
    Clean-System
}

function Show-Menu {
    Write-Host ""
    Write-Host "WinCache Cleaner" -ForegroundColor Yellow
    Write-Host "Select an option:"
    Write-Host " 0) Exit"
    Write-Host " 1) Run ALL"
    Write-Host " 2) Android Studio / Gradle"
    Write-Host " 3) Flutter (projects + global)"
    Write-Host " 4) Node (npm/yarn/pnpm)"
    Write-Host " 5) Python (pip)"
    Write-Host " 6) .NET / NuGet"
    Write-Host " 7) IDEs (VS, VS Code, JetBrains)"
    Write-Host " 8) Browsers"
    Write-Host " 9) Adobe Suite caches"
    Write-Host "10) Unity / Unity Hub"
    Write-Host "11) Docker Desktop"
    Write-Host "12) System temp + Recycle Bin"
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Enter choice"
    switch ($choice) {
        "0" { break }
        "1" { Clean-All }
        "2" { Clean-AndroidGradle }
        "3" { Clean-Flutter }
        "4" { Clean-Node }
        "5" { Clean-Python }
        "6" { Clean-DotNetNuGet }
        "7" { Clean-IDEs }
        "8" { Clean-Browsers }
        "9" { Clean-Adobe }
        "10" { Clean-Unity }
        "11" { Clean-Docker }
        "12" { Clean-System }
        Default { Write-Host "Invalid choice, try again." -ForegroundColor Red }
    }
}

Write-Host "Done."
