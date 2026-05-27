# Gera upload-keystore.jks na pasta android/ e copia key.properties.example -> key.properties
# Altera as passwords antes de usar em producao.

$ErrorActionPreference = "Stop"
$androidDir = Join-Path $PSScriptRoot "..\android"
$keystore = Join-Path $androidDir "upload-keystore.jks"
$keytool = "keytool"
if (-not (Get-Command $keytool -ErrorAction SilentlyContinue)) {
    $asKeytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
    if (Test-Path $asKeytool) {
        $keytool = $asKeytool
    } else {
        Write-Error "keytool nao encontrado. Instala o JDK ou Android Studio."
    }
}

if (Test-Path $keystore) {
    Write-Host "Keystore ja existe: $keystore"
} else {
    & $keytool -genkey -v `
        -keystore $keystore `
        -alias upload `
        -keyalg RSA `
        -keysize 2048 `
        -validity 10000 `
        -storepass drivetime2026 `
        -keypass drivetime2026 `
        -dname "CN=Drive Time, OU=Mobile, O=Drive Time, L=Lisboa, ST=Lisboa, C=PT"
    Write-Host "Keystore criado: $keystore"
}

$propsExample = Join-Path $androidDir "key.properties.example"
$props = Join-Path $androidDir "key.properties"
if (-not (Test-Path $props)) {
    Copy-Item $propsExample $props
    (Get-Content $props) `
        -replace 'CHANGE_ME', 'drivetime2026' `
        -replace 'storeFile=upload-keystore.jks', 'storeFile=../upload-keystore.jks' |
        Set-Content $props
    Write-Host "key.properties criado. Edita passwords antes de publicar na Play Store."
}

Write-Host "Depois: flutter build apk --release"
