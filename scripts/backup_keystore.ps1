# Backup seguro da chave de assinatura Drive Time (NAO vai para o GitHub)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$android = Join-Path $root "android"
$keystore = Join-Path $android "upload-keystore.jks"
$props = Join-Path $android "key.properties"

if (-not (Test-Path $keystore)) {
    Write-Error "Falta $keystore - gera primeiro com tools\generate_release_keystore.ps1"
}
if (-not (Test-Path $props)) {
    Write-Error "Falta $props"
}

$stamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$backupRoot = Join-Path $env:USERPROFILE "Documents\DriveTime-Signing-Backup"
$dest = Join-Path $backupRoot $stamp
New-Item -ItemType Directory -Force -Path $dest | Out-Null

Copy-Item -Force $keystore (Join-Path $dest "upload-keystore.jks")
Copy-Item -Force $props (Join-Path $dest "key.properties")

$readme = @"
Drive Time - backup da chave de assinatura Android
Data: $stamp

Ficheiros nesta pasta:
  - upload-keystore.jks  (chave de assinatura)
  - key.properties       (passwords e alias)

IMPORTANTE:
  1. Guarda esta pasta em 2-3 sitios (ex.: pen USB + nuvem privada).
  2. Regista as passwords tambem num gestor de passwords (1Password, Bitwarden, etc.).
  3. NUNCA envies isto para GitHub, email ou WhatsApp.
  4. Sem estes ficheiros nao podes publicar atualizacoes na Play Store.

Para restaurar noutro PC:
  Copia upload-keystore.jks e key.properties para a pasta android\ do projeto.

Package Android: pt.drivetime.app
Alias da chave: upload
"@

Set-Content -Path (Join-Path $dest "LEIA-ME.txt") -Value $readme -Encoding UTF8

Write-Host ""
Write-Host "Backup criado em:"
Write-Host "  $dest"
Write-Host ""
Write-Host "Proximo passo: copia esta pasta para pen USB ou nuvem privada."
Write-Host "Abre LEIA-ME.txt dentro da pasta para instrucoes."
