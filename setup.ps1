$root = Get-Location

$vault   = Join-Path $root "Vault"
$areas   = Join-Path $vault "Areas"
$projects= Join-Path $vault "Projects"
$domains = Join-Path $vault "Domains"

New-Item -ItemType Directory -Force -Path $areas, $projects, $domains | Out-Null

Set-Content -Path (Join-Path $vault "Core.md") -Value @"
test

[Ir a YourArea](./Areas/YourArea.md)
"@ -Encoding UTF8

Set-Content -Path (Join-Path $areas "YourArea.md") -Value @"
test

[Ir a YourDomain](../Domains/YourDomain.md)
"@ -Encoding UTF8

Set-Content -Path (Join-Path $domains "YourDomain.md") -Value @"
test

[Ir a YourProject](../Projects/YourProject.md)
"@ -Encoding UTF8

$yourProject = Join-Path $projects "YourProject.md"
if (-not (Test-Path $yourProject)) { New-Item -ItemType File -Path $yourProject | Out-Null } else { Clear-Content -Path $yourProject }

Write-Host "Estructura creada en: $vault"
