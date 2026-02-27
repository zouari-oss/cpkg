#!/usr/bin/env bash
# =========================================
# .FILE
#   opencv4j2.sh
#
# .SYNOPSIS
#   Java OpenCV Build & Run Automater
#
# .DESCRIPTION
#   Automates cloning, building, installing OpenCV with Java bindings.
#   Supports contrib modules, Java JAR packaging, and multi-threaded build.
#
# .NOTES
#   Version       : 1.0.0
#   Author        : @ZouariOmar (zouariomar20@gmail.com)
#   Created       : 27/02/2026
#   Updated       : 27/02/2026
#   License       : GPL3.0
# =========================================

set -e

# -----------------------------
# CONFIGURATION
# -----------------------------
OPENCV_VERSION="4.13.0"
INSTALL_PREFIX="/usr/local"
BUILD_TYPE="Release"
NUM_JOBS=$(nproc)
SCRIPT_DIR=$(pwd)
OPENCV_DIR="$SCRIPT_DIR/opencv"
CONTRIB_DIR="$SCRIPT_DIR/opencv_contrib"
BUILD_DIR="$OPENCV_DIR/build"
JAVA_OPENCV_DIR="$INSTALL_PREFIX/share/java/opencv4"

# -----------------------------
# HELPER FUNCTIONS
# -----------------------------
check_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: $1 is not installed. Please install it first."
    exit 1
  }
}

clone_opencv() {
  echo "=== Cloning OpenCV $OPENCV_VERSION..."
  if [ ! -d "$OPENCV_DIR" ]; then
    git clone https://github.com/opencv/opencv.git "$OPENCV_DIR"
  fi
  cd "$OPENCV_DIR"
  git fetch --all
  git checkout "$OPENCV_VERSION"
}

clone_contrib() {
  echo "=== Cloning OpenCV Contrib $OPENCV_VERSION..."
  if [ ! -d "$CONTRIB_DIR" ]; then
    git clone https://github.com/opencv/opencv_contrib.git "$CONTRIB_DIR"
  fi
  cd "$CONTRIB_DIR"
  git fetch --all
  git checkout "$OPENCV_VERSION"
}

build_opencv() {
  echo "=== Building OpenCV..."
  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"
  cmake -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D CMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -D OPENCV_EXTRA_MODULES_PATH="$CONTRIB_DIR/modules" \
    -D BUILD_opencv_java=ON \
    -D BUILD_JAVA=ON \
    ..
  make -j"$NUM_JOBS"
}

install_opencv() {
  echo "=== Installing OpenCV..."
  sudo make install
  echo "OpenCV Java JAR and shared library installed in $JAVA_OPENCV_DIR"
}

clean_build() {
  echo "=== Cleaning build directory..."
  rm -rf "$BUILD_DIR"
}

show_usage() {
  echo "Usage: $0 [--clone | --build | --install | --clean | --all]"
  echo "  --clone    Clone OpenCV and contrib repos"
  echo "  --build    Build OpenCV (requires cmake & make)"
  echo "  --install  Install OpenCV system-wide"
  echo "  --clean    Remove build directory"
  echo "  --all      Clone, build, and install OpenCV"
  exit 1
}

# -----------------------------
# CHECK PREREQUISITES
# -----------------------------
check_command git
check_command cmake
check_command make
check_command java
check_command javac

# -----------------------------
# PARSE ARGUMENTS
# -----------------------------
if [ $# -eq 0 ]; then
  show_usage
fi

for arg in "$@"; do
  case $arg in
  --clone)
    clone_opencv
    clone_contrib
    ;;
  --build)
    build_opencv
    ;;
  --install)
    install_opencv
    ;;
  --clean)
    clean_build
    ;;
  --all)
    clone_opencv
    clone_contrib
    clean_build
    build_opencv
    install_opencv
    ;;
  *)
    show_usage
    ;;
  esac
done

echo "=== Done!"
