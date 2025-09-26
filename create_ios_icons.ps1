# PowerShell script to generate iOS app icons from a 1024x1024 source image
# Requires ImageMagick to be installed

param(
    [string]$SourceIcon = "assets\icons\icon_1024.png",
    [string]$OutputDir = "ios\Runner\Assets.xcassets\AppIcon.appiconset"
)

# Check if ImageMagick is available
try {
    $magick = Get-Command magick -ErrorAction Stop
    Write-Host "ImageMagick found at: $($magick.Source)"
} catch {
    Write-Host "ImageMagick not found. Please install ImageMagick first."
    Write-Host "Download from: https://imagemagick.org/script/download.php#windows"
    exit 1
}

# Check if source file exists
if (-not (Test-Path $SourceIcon)) {
    Write-Host "Source icon file not found: $SourceIcon"
    exit 1
}

Write-Host "Generating iOS app icons from: $SourceIcon"
Write-Host "Output directory: $OutputDir"

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force
}

# iOS icon sizes and their corresponding filenames
$iconSizes = @(
    @{Size="20x20"; File="Icon-App-20x20@1x.png"},
    @{Size="40x40"; File="Icon-App-20x20@2x.png"},
    @{Size="60x60"; File="Icon-App-20x20@3x.png"},
    @{Size="29x29"; File="Icon-App-29x29@1x.png"},
    @{Size="58x58"; File="Icon-App-29x29@2x.png"},
    @{Size="87x87"; File="Icon-App-29x29@3x.png"},
    @{Size="40x40"; File="Icon-App-40x40@1x.png"},
    @{Size="80x80"; File="Icon-App-40x40@2x.png"},
    @{Size="120x120"; File="Icon-App-40x40@3x.png"},
    @{Size="60x60"; File="Icon-App-60x60@2x.png"},
    @{Size="180x180"; File="Icon-App-60x60@3x.png"},
    @{Size="76x76"; File="Icon-App-76x76@1x.png"},
    @{Size="152x152"; File="Icon-App-76x76@2x.png"},
    @{Size="167x167"; File="Icon-App-83.5x83.5@2x.png"},
    @{Size="1024x1024"; File="Icon-App-1024x1024@1x.png"}
)

# Generate each icon size
foreach ($icon in $iconSizes) {
    $outputPath = Join-Path $OutputDir $icon.File
    Write-Host "Generating $($icon.Size) -> $($icon.File)"
    
    try {
        & magick $SourceIcon -resize $icon.Size $outputPath
        Write-Host "✓ Generated: $($icon.File)"
    } catch {
        Write-Host "✗ Failed to generate: $($icon.File) - $($_.Exception.Message)"
    }
}

Write-Host "`nIcon generation complete!"
Write-Host "Generated icons are in: $OutputDir"
Write-Host "`nNext steps:"
Write-Host "1. Open Xcode"
Write-Host "2. Open ios/Runner.xcworkspace"
Write-Host "3. Select Runner project"
Write-Host "4. Go to Build Phases -> Copy Bundle Resources"
Write-Host "5. Verify all icons are included"