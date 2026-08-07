$dRoot = "D:\Package\浏览器"
$um = Join-Path $dRoot "user_mods"
Write-Host "D drive root: $dRoot"
Write-Host "user_mods exists: $(Test-Path $um)"
if (Test-Path $um) {
    Get-ChildItem $um | ForEach-Object { Write-Host "  $($_.Name)" }
    $sf = Join-Path $um ".volante.json"
    if (Test-Path $sf) {
        $j = Get-Content -Raw $sf | ConvertFrom-Json
        Write-Host "CSS: $($j.css_mods -join ', ')"
        Write-Host "JS count: $($j.js_mods.Count)"
    }
    $legacy = Join-Path $um ".awesome-vivaldi.json"
    if (Test-Path $legacy) {
        Write-Host "Found .awesome-vivaldi.json"
    }
    $baInstalled = Join-Path $um "css\BetterAnimation.css"
    $baSource = Join-Path $PSScriptRoot "Vivaldi8.0Stable\CSS\BetterAnimation.css"
    Write-Host "BA installed: $(Test-Path $baInstalled)"
    if ((Test-Path $baInstalled) -and (Test-Path $baSource)) {
        $sh = (Get-FileHash $baSource -Algorithm MD5).Hash
        $dh = (Get-FileHash $baInstalled -Algorithm MD5).Hash
        Write-Host "Src: $sh"
        Write-Host "Dst: $dh"
        Write-Host "Same: $($sh -eq $dh)"
    }
} else {
    Write-Host "No user_mods on D drive"
    Write-Host "Listing D root:"
    Get-ChildItem $dRoot -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  $($_.Name)" }
}

# Also check AppData local
$localViv = "$env:LOCALAPPDATA\Vivaldi"
$um2 = Join-Path $localViv "user_mods"
Write-Host ""
Write-Host "LocalAppData: $localViv"
Write-Host "user_mods exists: $(Test-Path $um2)"
if (Test-Path $um2) {
    Get-ChildItem $um2 | ForEach-Object { Write-Host "  $($_.Name)" }
}
