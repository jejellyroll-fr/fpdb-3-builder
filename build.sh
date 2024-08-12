#!/bin/bash

# Fonction pour détecter l'OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "MacOS";;
        CYGWIN*|MINGW32*|MSYS*|MINGW*) echo "Windows";;
        *)          echo "Unknown OS"
    esac
}

OS=$(detect_os)
echo "Detected OS: $OS"

# Build pypoker-eval
echo "Building pypoker-eval..."
cd fpdb-3/pypoker-eval
./build.sh
cp pokereval.py ../fpdb-3/pokereval.py
cd ../..

# Build fpdb-3
echo "Building fpdb-3..."

case $OS in
    "Windows")
        ./build_fpdb.sh
        ;;
    "Linux")
        ./build_fpdb-linux.sh
        ;;
    "MacOS")
        ./build_fpdb-osx.sh
        ;;
    *)
        echo "Unsupported OS for local build"
        exit 1
        ;;
esac
cd ..

echo "Build completed successfully"