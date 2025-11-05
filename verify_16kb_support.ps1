# PowerShell script to verify 16 KB page size support configuration
Write-Host "Checking 16 KB page size support configuration..." -ForegroundColor Yellow

# Check if necessary files exist
if (-not (Test-Path "android\app\build.gradle.kts")) {
    Write-Host "❌ build.gradle.kts not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "android\app\src\main\cpp\CMakeLists.txt")) {
    Write-Host "❌ CMakeLists.txt not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "android\app\src\main\cpp\native-lib.cpp")) {
    Write-Host "❌ native-lib.cpp not found" -ForegroundColor Red
    exit 1
}

# Check build.gradle.kts for required configurations
Write-Host "Checking build.gradle.kts configuration..." -ForegroundColor Yellow
$buildGradleContent = Get-Content "android\app\build.gradle.kts" -Raw

if ($buildGradleContent -like "*abiFilters*") {
    Write-Host "✅ NDK ABI filters configured" -ForegroundColor Green
} else {
    Write-Host "❌ NDK ABI filters not configured" -ForegroundColor Red
}

if ($buildGradleContent -like "*prefab = true*") {
    Write-Host "✅ Prefab support enabled" -ForegroundColor Green
} else {
    Write-Host "❌ Prefab support not enabled" -ForegroundColor Red
}

if ($buildGradleContent -like "*cmake*") {
    Write-Host "✅ CMake configuration found" -ForegroundColor Green
} else {
    Write-Host "❌ CMake configuration not found" -ForegroundColor Red
}

# Check AndroidManifest.xml for required configurations
$manifestContent = Get-Content "android\app\src\main\AndroidManifest.xml" -Raw

if ($manifestContent -like "*largeHeap*") {
    Write-Host "✅ Large heap enabled" -ForegroundColor Green
} else {
    Write-Host "❌ Large heap not enabled" -ForegroundColor Red
}

if ($manifestContent -like "*vmSafeMode*") {
    Write-Host "✅ VM safe mode enabled" -ForegroundColor Green
} else {
    Write-Host "❌ VM safe mode not enabled" -ForegroundColor Red
}

Write-Host "Configuration check complete!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run 'flutter clean' to clean the build cache" -ForegroundColor White
Write-Host "2. Run 'flutter pub get' to get dependencies" -ForegroundColor White
Write-Host "3. Run 'flutter build appbundle --release' to build the app" -ForegroundColor White
Write-Host "4. Test the app on a device with Android 15+ to verify 16 KB page support" -ForegroundColor White
