$ErrorActionPreference = 'Stop'
$obsidianExe = Join-Path $env:LOCALAPPDATA 'Programs\Obsidian\Obsidian.exe'
if (-not (Test-Path -LiteralPath $obsidianExe)) {
    throw "Obsidian was not found at: $obsidianExe"
}
Start-Process -FilePath $obsidianExe -ArgumentList 'obsidian://open?vault=JavaNotes'
