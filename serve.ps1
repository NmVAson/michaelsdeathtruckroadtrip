#!/usr/bin/env pwsh
# Usage:
#   .\serve.ps1            # serve site at http://127.0.0.1:4000 with live reload
#   .\serve.ps1 build      # one-shot build into _site/
#
# Why this exists: on some Windows + Ruby 3.3 setups, the `bundle exec` shim
# can fail with "ruby.exe is not recognized". Loading the gem entry point via
# `ruby -rbundler/setup` sidesteps the broken shim.

param([string]$cmd = "serve")

# Refresh PATH from the registry so a brand-new shell can find Ruby right
# after install (winget adds Ruby to the Machine PATH, but existing shells
# only see whatever PATH they were launched with).
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") +
            ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# If Ruby still isn't on PATH, fall back to the default RubyInstaller location.
if (-not (Get-Command ruby -ErrorAction SilentlyContinue)) {
    $candidates = @(
        "C:\Ruby34-x64\bin",
        "C:\Ruby33-x64\bin",
        "C:\Ruby32-x64\bin",
        "C:\Ruby31-x64\bin"
    ) | Where-Object { Test-Path "$_\ruby.exe" }
    if ($candidates.Count -gt 0) {
        $env:Path = "$($candidates[0]);$env:Path"
    } else {
        Write-Error "Ruby not found. Install with: winget install RubyInstallerTeam.RubyWithDevKit.3.3"
        exit 1
    }
}

$env:BUNDLE_GEMFILE = "$PSScriptRoot\Gemfile"

$jekyllArgs = @($cmd, "--trace")
if ($cmd -eq "serve") {
    $jekyllArgs += @("--livereload", "--force_polling")
}

& ruby -rbundler/setup -e "load Gem.bin_path('jekyll','jekyll')" -- @jekyllArgs
