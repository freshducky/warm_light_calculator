# Script to run Flutter app on Pixel Tablet
# Make sure Pixel Tablet is running in Android Studio first!

Write-Host "Checking for Pixel Tablet emulator..."
flutter devices

Write-Host "`nLooking for tablet device..."
$output = flutter devices
$tabletFound = $false

$output | ForEach-Object {
    if ($_ -match "tablet|Tablet" -or $_ -match "Pixel") {
        if ($_ -match "• ([a-zA-Z0-9\-]+) •") {
            $deviceId = $matches[1]
            Write-Host "Found tablet device: $deviceId"
            Write-Host "Running app on tablet...`n"
            flutter run -d $deviceId
            $tabletFound = $true
        }
    }
}

if (-not $tabletFound) {
    Write-Host "`n❌ No tablet detected!"
    Write-Host "Please:"
    Write-Host "1. Open Android Studio"
    Write-Host "2. Tools → Device Manager"
    Write-Host "3. Start Pixel Tablet emulator"
    Write-Host "4. Wait for it to fully boot"
    Write-Host "5. Run this script again"
}

