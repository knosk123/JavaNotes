$ErrorActionPreference = 'Stop'
$obsidianExe = 'C:\Users\zhanglei\AppData\Local\Programs\Obsidian\Obsidian.exe'
Start-Process -FilePath $obsidianExe -ArgumentList 'obsidian://open?vault=JavaNotes'