# Build Drive Time BETA APK (release, signed)
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

Write-Host "A compilar APK release..."
& $flutter build apk --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$pubspec = Get-Content "pubspec.yaml" -Raw
if ($pubspec -match 'version:\s*([\d.]+)\+(\d+)') {
    $ver = $Matches[1]
    $build = $Matches[2]
} else {
    $ver = "1.0.0"
    $build = "4"
}

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$dest = Join-Path $dist "DriveTime-BETA-$ver-build$build.apk"
Copy-Item -Force "build\app\outputs\flutter-apk\app-release.apk" $dest
Write-Host "APK: $dest"
