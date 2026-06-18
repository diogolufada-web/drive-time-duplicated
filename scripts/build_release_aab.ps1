# Build Drive Time AAB (release, signed) for Google Play
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$flutter = "C:\src\flutter\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) {
    $flutter = "flutter"
}

if (-not (Test-Path "android\key.properties")) {
    Write-Error "Falta android/key.properties - copia de key.properties.example e preenche o keystore."
}

Write-Host "A obter dependencias..."
& $flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "A compilar App Bundle (AAB) release..."
& $flutter build appbundle --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$pubspec = Get-Content "pubspec.yaml" -Raw
if ($pubspec -match 'version:\s*([\d.]+)\+(\d+)') {
    $ver = $Matches[1]
    $build = $Matches[2]
} else {
    $ver = "1.0.0"
    $build = "1"
}

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$dest = Join-Path $dist "DriveTime-$ver-build$build.aab"
Copy-Item -Force "build\app\outputs\bundle\release\app-release.aab" $dest
Write-Host "AAB: $dest"
