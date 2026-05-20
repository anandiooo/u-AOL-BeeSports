$baseDir = 'c:\@dio\01_BINUS\04_Semester_4\01_Software_Engineering\02_Work\AOL\beesport_code'
Set-Location $baseDir

function Remove-DartComments {
    param([string]$content)
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?s)/\*.*?\*/', '')
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '//.*?(?=\r?\n|$)', '')
    return $content
}

function Remove-SqlComments {
    param([string]$content)
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?s)/\*.*?\*/', '')
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '--.*?(?=\r?\n|$)', '')
    return $content
}

function Remove-YamlComments {
    param([string]$content)
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, "(?<!['`"])#.*?(?=\r?\n|`$)", '')
    return $content
}

function Normalize-Whitespace {
    param([string]$content)
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?s)(\r?\n\s*)+\r?\n', "`r`n`r`n")
    $lines = $content -split '(?:\r?\n)'
    $lines = $lines | ForEach-Object { $_.TrimEnd() }
    $lines = @($lines)
    $start = 0
    while ($start -lt $lines.Count -and [string]::IsNullOrWhiteSpace($lines[$start])) {
        $start++
    }
    $end = $lines.Count - 1
    while ($end -ge $start -and [string]::IsNullOrWhiteSpace($lines[$end])) {
        $end--
    }
    if ($start -le $end) {
        $lines = $lines[$start..$end]
    } else {
        $lines = @('')
    }
    return ($lines -join "`r`n")
}

$count = 0

Write-Host "Processing lib folder..." -ForegroundColor Green
$libFiles = Get-ChildItem -Path 'lib' -Recurse -Filter '*.dart' -ErrorAction SilentlyContinue
foreach ($file in $libFiles) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        $content = Remove-DartComments -content $content
        $content = Normalize-Whitespace -content $content
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "[OK] $($file.FullName)"
        $count++
    } catch {
        Write-Host "[ERROR] $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Processing database folder..." -ForegroundColor Green
$sqlFiles = Get-ChildItem -Path 'database' -Recurse -Filter '*.sql' -ErrorAction SilentlyContinue
foreach ($file in $sqlFiles) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        $content = Remove-SqlComments -content $content
        $content = Normalize-Whitespace -content $content
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "[OK] $($file.FullName)"
        $count++
    } catch {
        Write-Host "[ERROR] $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Processing root folder..." -ForegroundColor Green
$yamlFiles = Get-ChildItem -Path '.' -Filter '*.yaml' -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $false }
foreach ($file in $yamlFiles) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        $content = Remove-YamlComments -content $content
        $content = Normalize-Whitespace -content $content
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "[OK] $($file.FullName)"
        $count++
    } catch {
        Write-Host "[ERROR] $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done! Processed $count files." -ForegroundColor Cyan
