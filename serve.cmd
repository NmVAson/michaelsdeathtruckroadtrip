@echo off
rem Usage:
rem   serve            -> serve site at http://127.0.0.1:4000 with live reload
rem   serve build      -> one-shot build into _site\
rem
rem Why this exists: on some Windows + Ruby 3.3 setups, `bundle exec jekyll ...`
rem fails with "ruby.exe is not recognized" because of a broken bundler binstub.
rem This wrapper invokes Jekyll directly via Ruby instead, sidestepping the
rem shim. Using a .cmd file also avoids PowerShell's script execution policy.

setlocal

rem --- find ruby ---
where ruby >nul 2>nul
if errorlevel 1 (
    for %%D in ("C:\Ruby34-x64\bin" "C:\Ruby33-x64\bin" "C:\Ruby32-x64\bin" "C:\Ruby31-x64\bin") do (
        if exist "%%~D\ruby.exe" (
            set "PATH=%%~D;%PATH%"
            goto :have_ruby
        )
    )
    echo Ruby not found. Install with:
    echo   winget install RubyInstallerTeam.RubyWithDevKit.3.3
    exit /b 1
)
:have_ruby

set "BUNDLE_GEMFILE=%~dp0Gemfile"

set "CMD=%1"
if "%CMD%"=="" set "CMD=serve"
shift

rem Collect any remaining args to forward to Jekyll (e.g. --watch, --port 5000)
set "EXTRA="
:gather
if "%~1"=="" goto :run
set "EXTRA=%EXTRA% %1"
shift
goto :gather

:run
if /i "%CMD%"=="serve" (
    ruby -rbundler/setup -e "load Gem.bin_path('jekyll','jekyll')" -- serve --trace --livereload --force_polling%EXTRA%
) else (
    ruby -rbundler/setup -e "load Gem.bin_path('jekyll','jekyll')" -- %CMD% --trace%EXTRA%
)

endlocal
