<#
.FILE
    opencv4j2.ps1

.SYNOPSIS
    PowerShell OpenCV Java Build & Install Script

.DESCRIPTION
    Automates cloning, building, and installing OpenCV with Java bindings.
    Supports OpenCV contrib modules, multi-threaded builds, and generates
    Java library paths for immediate use.

.NOTES
    Version       : 1.0.0
    Author        : @ZouariOmar (zouariomar20@gmail.com)
    Created       : 02/27/2026
    Updated       : 27/02/2026
    License       : GPL3.0
#>

# -----------------------------
# CONFIGURATION
# -----------------------------
param (
    [switch]$Clone,
    [switch]$Build,
    [switch]$Install,
    [switch]$Clean,
    [switch]$All,
    [string]$OpenCVVersion = "4.13.0",
    [string]$InstallPrefix = "C:\opencv"
)

# -----------------------------
# HELPER FUNCTIONS
# -----------------------------
function Check-Command($cmd) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "Command '$cmd' not found. Please install it first."
        exit 1
    }
}

function Clone-OpenCV {
    Write-Host "=== Cloning OpenCV $OpenCVVersion..."
    if (-not (Test-Path "opencv")) {
        git clone https://github.com/opencv/opencv.git
    }
    Push-Location "opencv"
    git fetch --all
    git checkout $OpenCVVersion
    Pop-Location
}

function Clone-Contrib {
    Write-Host "=== Cloning OpenCV Contrib $OpenCVVersion..."
    if (-not (Test-Path "opencv_contrib")) {
        git clone https://github.com/opencv/opencv_contrib.git
    }
    Push-Location "opencv_contrib"
    git fetch --all
    git checkout $OpenCVVersion
    Pop-Location
}

function Build-OpenCV {
    Write-Host "=== Building OpenCV..."
    $buildDir = "opencv\build"
    if (-not (Test-Path $buildDir)) { New-Item -ItemType Directory -Path $buildDir | Out-Null }
    Push-Location $buildDir

    cmake .. `
        -D CMAKE_BUILD_TYPE=Release `
        -D CMAKE_INSTALL_PREFIX=$InstallPrefix `
        -D OPENCV_EXTRA_MODULES_PATH="../opencv_contrib/modules" `
        -D BUILD_opencv_java=ON `
        -D BUILD_JAVA=ON

    $nJobs = [Environment]::ProcessorCount
    cmake --build . --config Release -- /m:$nJobs

    Pop-Location
}

function Install-OpenCV {
    Write-Host "=== Installing OpenCV..."
    Push-Location "opencv\build"
    cmake --install . --config Release
    Pop-Location
    Write-Host "OpenCV Java JAR and DLL/SO installed in $InstallPrefix"
}

function Clean-Build {
    Write-Host "=== Cleaning build directory..."
    Remove-Item -Recurse -Force "opencv\build"
}

# -----------------------------
# CHECK PRE-REQUISITES
# -----------------------------
Check-Command git
Check-Command cmake
Check-Command javac
Check-Command java

# -----------------------------
# EXECUTE SELECTED ACTIONS
# -----------------------------
if ($All) {
    Clone-OpenCV
    Clone-Contrib
    Clean-Build
    Build-OpenCV
    Install-OpenCV
    exit
}

if ($Clone) { Clone-OpenCV; Clone-Contrib }
if ($Build) { Build-OpenCV }
if ($Install) { Install-OpenCV }
if ($Clean) { Clean-Build }

Write-Host "=== Done!"
