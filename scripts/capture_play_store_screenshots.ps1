# Capture Play Store screenshots via adb (phone + tablet)
param(
    [ValidateSet("phone", "tablet", "all")]
    [string]$Device = "all"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$adb = "C:\Android\Sdk\platform-tools\adb.exe"
$apk = Join-Path $root "dist\DriveTime-BETA-1.0.0-build10.apk"
$phoneOut = Join-Path $root "play-store\screenshots\phone"
$tabletOut = Join-Path $root "play-store\screenshots\tablet"

function Wait-EmulatorReady {
    param([string]$Serial)
    & $adb -s $Serial wait-for-device | Out-Null
    for ($i = 0; $i -lt 60; $i++) {
        $boot = (& $adb -s $Serial shell getprop sys.boot_completed 2>$null).Trim()
        if ($boot -eq "1") { return }
        Start-Sleep -Seconds 2
    }
    throw "Emulator $Serial did not finish booting."
}

function Ensure-Portrait {
    param([string]$Serial)
    & $adb -s $Serial shell settings put system accelerometer_rotation 0 | Out-Null
    & $adb -s $Serial shell settings put system user_rotation 0 | Out-Null
    & $adb -s $Serial shell input keyevent KEYCODE_WAKEUP 2>$null | Out-Null
}

function Launch-App {
    param([string]$Serial)
    & $adb -s $Serial shell am force-stop pt.drivetime.app | Out-Null
    & $adb -s $Serial shell am start -n pt.drivetime.app/.MainActivity | Out-Null
    Start-Sleep -Seconds 8
    $focus = (& $adb -s $Serial shell dumpsys window) -join "`n"
    if ($focus -notmatch "pt\.drivetime\.app") {
        throw "Drive Time is not in foreground after launch."
    }
}

function Install-And-Launch {
    param([string]$Serial)
    if (-not (Test-Path $apk)) { throw "Missing APK: $apk" }
    & $adb -s $Serial install -r $apk | Out-Null
    Launch-App -Serial $Serial
}

function Get-ScreenSize {
    param([string]$Serial)
    $out = (& $adb -s $Serial shell wm size).Trim()
    if ($out -match "Physical size:\s*(\d+)x(\d+)") {
        return [PSCustomObject]@{ Width = [int]$matches[1]; Height = [int]$matches[2] }
    }
    throw "Could not read screen size from: $out"
}

function Ensure-Landscape {
    param([string]$Serial)
    & $adb -s $Serial shell settings put system accelerometer_rotation 0 | Out-Null
    & $adb -s $Serial shell settings put system user_rotation 0 | Out-Null
    & $adb -s $Serial shell input keyevent KEYCODE_WAKEUP 2>$null | Out-Null
}

function Tap-NavTab {
    param(
        [string]$Serial,
        [int]$Width,
        [int]$Height,
        [ValidateSet("home", "history", "reports", "settings")]
        [string]$Tab,
        [ValidateSet("portrait", "landscape")]
        [string]$Orientation = "portrait"
    )
    if ($Orientation -eq "portrait") {
        Ensure-Portrait -Serial $Serial
    } else {
        Ensure-Landscape -Serial $Serial
    }
    Start-Sleep -Milliseconds 500
    $size = Get-ScreenSize -Serial $Serial
    if ($Orientation -eq "portrait" -and $size.Width -gt $size.Height) {
        throw "Emulator must be portrait before tapping ($($size.Width)x$($size.Height))."
    }
    if ($Orientation -eq "landscape" -and $size.Width -lt $size.Height) {
        throw "Emulator must be landscape before tapping ($($size.Width)x$($size.Height))."
    }
    $Width = $size.Width
    $Height = $size.Height
    $y = $Height - 82
    $slots = @{
        home     = 0.125
        history  = 0.375
        reports  = 0.625
        settings = 0.875
    }
    $x = [int]($Width * $slots[$Tab])
    & $adb -s $Serial shell input tap $x $y | Out-Null
    Start-Sleep -Seconds 3
}

function Capture-Screen {
    param(
        [string]$Serial,
        [string]$OutputPath,
        [ValidateSet("portrait", "landscape")]
        [string]$Orientation = "portrait"
    )
    if ($Orientation -eq "portrait") {
        Ensure-Portrait -Serial $Serial
    } else {
        Ensure-Landscape -Serial $Serial
    }
    Start-Sleep -Milliseconds 400
    $size = Get-ScreenSize -Serial $Serial
    if ($Orientation -eq "portrait" -and $size.Width -gt $size.Height) {
        throw "Emulator must be portrait before capture ($($size.Width)x$($size.Height))."
    }
    if ($Orientation -eq "landscape" -and $size.Width -lt $size.Height) {
        throw "Emulator must be landscape before capture ($($size.Width)x$($size.Height))."
    }
    $remote = "/sdcard/play_store_cap.png"
    & $adb -s $Serial shell screencap -p $remote | Out-Null
    & $adb -s $Serial pull $remote $OutputPath | Out-Null
    & $adb -s $Serial shell rm $remote 2>$null | Out-Null
    $size = (Get-Item $OutputPath).Length
    if ($size -lt 50000) {
        throw "Screenshot too small ($size bytes): $OutputPath"
    }
}

function Capture-PhoneSet {
    param([string]$Serial)
    New-Item -ItemType Directory -Force -Path $phoneOut | Out-Null
    Ensure-Portrait -Serial $Serial
    Install-And-Launch -Serial $Serial
    $size = Get-ScreenSize -Serial $Serial
    if ($size.Width -gt $size.Height) {
        throw "Phone emulator not in portrait ($($size.Width)x$($size.Height))."
    }
    Write-Host "Phone resolution: $($size.Width)x$($size.Height)"

    Capture-Screen -Serial $Serial -OutputPath (Join-Path $phoneOut "01-home.png")

    Tap-NavTab -Serial $Serial -Width $size.Width -Height $size.Height -Tab "history"
    Capture-Screen -Serial $Serial -OutputPath (Join-Path $phoneOut "02-history.png")

    Tap-NavTab -Serial $Serial -Width $size.Width -Height $size.Height -Tab "reports"
    Capture-Screen -Serial $Serial -OutputPath (Join-Path $phoneOut "03-reports.png")

    Tap-NavTab -Serial $Serial -Width $size.Width -Height $size.Height -Tab "settings"
    Capture-Screen -Serial $Serial -OutputPath (Join-Path $phoneOut "04-settings.png")
}

function Capture-TabletSet {
    param([string]$Serial)
    New-Item -ItemType Directory -Force -Path $tabletOut | Out-Null
    Ensure-Landscape -Serial $Serial
    Install-And-Launch -Serial $Serial
    $size = Get-ScreenSize -Serial $Serial
    if ($size.Width -lt $size.Height) {
        throw "Tablet emulator not in landscape ($($size.Width)x$($size.Height))."
    }
    Write-Host "Tablet resolution: $($size.Width)x$($size.Height)"

    Capture-Screen -Serial $Serial -OutputPath (Join-Path $tabletOut "01-home.png") -Orientation landscape

    Tap-NavTab -Serial $Serial -Width $size.Width -Height $size.Height -Tab "history" -Orientation landscape
    Capture-Screen -Serial $Serial -OutputPath (Join-Path $tabletOut "02-history.png") -Orientation landscape

    Tap-NavTab -Serial $Serial -Width $size.Width -Height $size.Height -Tab "reports" -Orientation landscape
    Capture-Screen -Serial $Serial -OutputPath (Join-Path $tabletOut "03-reports.png") -Orientation landscape

    Tap-NavTab -Serial $Serial -Width $size.Width -Height $size.Height -Tab "settings" -Orientation landscape
    Capture-Screen -Serial $Serial -OutputPath (Join-Path $tabletOut "04-settings.png") -Orientation landscape
}

function Get-OnlineEmulator {
    $lines = & $adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "device$" }
    foreach ($line in $lines) {
        if ($line -match "^(emulator-\d+)\s+device") {
            return $matches[1]
        }
    }
    return $null
}

if ($Device -eq "phone" -or $Device -eq "all") {
    $serial = Get-OnlineEmulator
    if (-not $serial) { throw "No emulator online for phone capture." }
    Capture-PhoneSet -Serial $serial
}

if ($Device -eq "tablet") {
    $serial = Get-OnlineEmulator
    if (-not $serial) { throw "No emulator online for tablet capture." }
    Capture-TabletSet -Serial $serial
}

Write-Host "Done."
