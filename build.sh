#!/bin/bash

# Arrête le script si une commande échoue
set -e

# Fonction pour détecter l'OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "MacOS";;
        CYGWIN*|MINGW32*|MSYS*|MINGW*) echo "Windows";;
        *)          echo "unknown"
    esac
}

OS=$(detect_os)
echo "Detected OS: $OS"



WORK_DIR=$(pwd)
echo "Working directory: $WORK_DIR"

BASE_PATH="$WORK_DIR/fpdb-3"
echo "Base path: $BASE_PATH"

# Créer explicitement le répertoire de sortie
DIST_DIR="$WORK_DIR/dist"
mkdir -p "$DIST_DIR"
echo "Created dist directory: $DIST_DIR"

# path to base for Windows
if [ "$OS" = "Windows" ]; then
    BASE_PATH2=$(cygpath -w "$BASE_PATH")
else
    BASE_PATH2="$BASE_PATH"
fi

echo "Adjusted BASE_PATH2 for OS: $BASE_PATH2"

# Build poker-eval
echo "Building poker-eval..."
cd "${BASE_PATH}/pypoker-eval/poker-eval"
mkdir -p build
cd build
if [[ "$OS" == "Windows" ]]; then
    echo "Running CMake for poker-eval..."
    cmake .. -G "Visual Studio 17 2022" -A x64
    cmake --build . --config Release
elif [[ "$OS" == "Linux" || "$OS" == "MacOS" ]]; then
    cmake .. -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_CXX_FLAGS="-fPIC"
    make
fi
cd "${BASE_PATH}"

# Build pypoker-eval
echo "Building pypoker-eval..."
cd "${BASE_PATH}/pypoker-eval"
mkdir -p build
cd build
if [[ "$OS" == "Windows" ]]; then
    echo "Running CMake for pypoker-eval..."
    cmake .. -G "Visual Studio 17 2022" -A x64
    cmake --build . --config Release
elif [[ "$OS" == "Linux" || "$OS" == "MacOS" ]]; then
    cmake .. -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_CXX_FLAGS="-fPIC"
    make
fi
cd "${BASE_PATH}"

# Copier et renommer pokereval
if [[ "$OS" == "Windows" ]]; then
    echo "Renaming and moving pypokereval.dll..."
    mv "${BASE_PATH}/pypoker-eval/build/Release/pypokereval.dll" "${BASE_PATH}/_pokereval_3_11.pyd"
elif [[ "$OS" == "Linux" || "$OS" == "MacOS" ]]; then
    echo "Renaming and moving pypokereval.so..."
    mv "${BASE_PATH}/pypoker-eval/build/pypokereval.so" "${BASE_PATH}/_pokereval_3_11.so"
fi

# Copier pokereval.py vers le dossier fpdb-3
echo "Copying pokereval.py to fpdb-3 directory..."
cp "${BASE_PATH}/pypoker-eval/pokereval.py" "${BASE_PATH}/"

# name of the main script
MAIN_SCRIPT="fpdb.pyw"
SECOND_SCRIPT="HUD_main.pyw"

# Options of pyinstaller
PYINSTALLER_OPTIONS="--noconfirm --onedir --windowed --log-level=DEBUG"

# List of all files
FILES=(
    "Anonymise.py"
    "api.py"
    "app.py"
    "Archive.py"
    "Aux_Base.py"
    "Aux_Classic_Hud.py"
    "Aux_Hud.py"
    "base_model.py"
    "BetfairToFpdb.py"
    "BetOnlineToFpdb.py"
    "BovadaSummary.py"
    "BovadaToFpdb.py"
    "bug-1823.py"
    "CakeToFpdb.py"
    "Card.py"
    "Cardold.py"
    "card_path.py"
    "Charset.py"
    "Configuration.py"
    "contributors.txt"
    "Database.py"
    "Databaseold.py"
    "db_sqlite3.md"
    "decimal_wrapper.py"
    "Deck.py"
    "dependencies.txt"
    "DerivedStats.py"
    "DerivedStats_old.py"
    "DetectInstalledSites.py"
    "Exceptions.py"
    "files.qrc"
    "files_rc.py"
    "Filters.py"
    "fpdb.pyw"
    "fpdb.toml"
    "fpdb_prerun.py"
    "GGPokerToFpdb.py"
    "GuiAutoImport.py"
    "GuiBulkImport.py"
    "GuiDatabase.py"
    "GuiGraphViewer.py"
    "GuiHandViewer.py"
    "GuiLogView.py"
    "GuiOddsCalc.py"
    "GuiPositionalStats.py"
    "GuiPrefs.py"
    "GuiReplayer.py"
    "GuiRingPlayerStats.py"
    "GuiSessionViewer.py"
    "GuiStove.py"
    "GuiTourneyGraphViewer.py"
    "GuiTourneyImport.py"
    "GuiTourneyPlayerStats.py"
    "GuiTourneyViewer.py"
    "Hand.py"
    "HandHistory.py"
    "HandHistoryConverter.py"
    "Hello.py"
    "Hud.py"
    "HUD_config.test.xml"
    "HUD_config.xml"
    "HUD_config.xml.example"
    "HUD_config.xml.exemple"
    "HUD_main.pyw"
    "HUD_run_me.py"
    "IdentifySite.py"
    "Importer-old.py"
    "Importer.py"
    "ImporterLight.py"
    "interlocks.py"
    "iPokerSummary.py"
    "iPokerToFpdb.py"
    "KingsClubToFpdb.py"
    "L10n.py"
    "LICENSE"
    "linux_table_detect.py"
    "logging.conf"
    "Makefile"
    "MergeStructures.py"
    "MergeSummary.py"
    "MergeToFpdb.py"
    "montecarlo.py"
    "Mucked.py"
    "OddsCalc.py"
    "OddsCalcnew.py"
    "OddsCalcNew2.py"
    "OddsCalcPQL.py"
    "Options.py"
    "OSXTables.py"
    "P5sResultsParser.py"
    "PacificPokerSummary.py"
    "PacificPokerToFpdb.py"
    "PartyPokerToFpdb.py"
    "Pokenum_api_call.py"
    "pokenum_example.py"
    "pokereval.py"
    "PokerStarsStructures.py"
    "PokerStarsSummary.py"
    "PokerStarsToFpdb.py"
    "PokerTrackerSummary.py"
    "PokerTrackerToFpdb.py"
    "Popup.py"
    "ppt.py"
    "ps.ico"
    "RazzStartHandGenerator.py"
    "run_fpdb.py"
    "RushNotesAux.py"
    "RushNotesMerge.py"
    "ScriptAddStatToRegression.py"
    "ScriptFetchMergeResults.py"
    "ScriptFetchWinamaxResults.py"
    "ScriptGenerateWikiPage.py"
    "SealsWithClubsToFpdb.py"
    "settings.json"
    "setup.py"
    "sim.py"
    "sim2.py"
    "simulation.py"
    "SitenameSummary.py"
    "SplitHandHistory.py"
    "SQL.py"
    "sql_request.py"
    "start_fpdb_web.py"
    "Stats.py"
    "Stove.py"
    "Summaries.py"
    "TableWindow.py"
    "TestDetectInstalledSites.py"
    "TestHandsPlayers.py"
    "testodd.py"
    "TournamentTracker.py"
    "TourneySummary.py"
    "TreeViewTooltips.py"
    "UnibetToFpdb.py"
    "UnibetToFpdb_old.py"
    "upd_indexes.sql"
    "wina.ico"
    "WinamaxSummary.py"
    "WinamaxToFpdb.py"
    "windows_make_bats.py"
    "WinningSummary.py"
    "WinningToFpdb.py"
    "WinTables.py"
    "win_table_detect.py"
    "xlib_tester.py"
    "XTables.py"
)

FOLDERS=(
    "gfx"
    "icons"
    "fonts"
    "locale"
    "ppt"
    "static"
    "templates"
    "utils"
)

# Function to add pokereval file
add_pokereval_file() {
    local command=$1
    if [ "$OS" = "Windows" ]; then
        command+=" --add-data \"$BASE_PATH2\_pokereval_3_11.pyd;.\""
    else
        command+=" --add-data \"$BASE_PATH2/_pokereval_3_11.so:.\""
    fi
    echo "$command"
}

# Function to generate the pyinstaller command
generate_pyinstaller_command() {
    local script_path=$1
    local command="pyinstaller $PYINSTALLER_OPTIONS --distpath=\"$DIST_DIR\""

    # process files
    for file in "${FILES[@]}"; do
        if [ "$OS" = "Windows" ]; then
            command+=" --add-data \"$BASE_PATH2\\$file;.\""
        else
            command+=" --add-data \"$BASE_PATH2/$file:.\""
        fi
    done

    # Add pokereval file
    command=$(add_pokereval_file "$command")

    # process folders
    for folder in "${FOLDERS[@]}"; do
        if [ "$OS" = "Windows" ]; then
            command+=" --add-data \"$BASE_PATH2\\$folder;$folder\""
        else
            command+=" --add-data \"$BASE_PATH2/$folder:$folder\""
        fi
    done

    if [ "$OS" = "MacOS" ]; then
        command+=" --icon=\"$BASE_PATH2/gfx/tribal.icns\""
    fi

    if [ "$OS" = "Windows" ]; then
        command+=" \"$BASE_PATH2\\$script_path\""
    else
        command+=" \"$BASE_PATH2/$script_path\""
    fi
    echo "$command"
}

# Function to move files
move_files() {
    local source_dir=$1
    local target_dir=$2

    for file in "${FILES[@]}"; do
        local source_path="$source_dir/$file"
        local target_path="$target_dir/$file"

        if [ -e "$source_path" ]; then
            if [ ! -e "$target_path" ]; then
                echo "Déplacement de $file de $source_path à $target_path"
                mv "$source_path" "$target_path"
            fi
        fi
    done
}

# Function to copy folders
copy_and_remove_folders() {
    local source_dir=$1
    local target_dir=$2

    for folder in "${FOLDERS[@]}"; do
        local source_path="$source_dir/$folder"
        local target_path="$target_dir/$folder"

        if [ -e "$source_path" ]; then
            echo "Déplacement de $folder de $source_path à $target_path"
            cp -r "$source_path" "$target_path"
            rm -r "$source_path"
        fi
    done
}

# Function to copy the HUD_main.exe
copy_hudmain() {
    local source_dir=$1
    local target_dir=$2

    local hud_main_exe="$source_dir/HUD_main"
    if [ "$OS" = "Windows" ]; then
        hud_main_exe="$source_dir/HUD_main.exe"
    fi
    local target_exe="$target_dir/HUD_main"
    if [ "$OS" = "Windows" ]; then
        target_exe="$target_dir/HUD_main.exe"
    fi

    if [ ! -e "$target_exe" ]; then
        echo "Copie de HUD_main de $hud_main_exe à $target_exe"
        cp "$hud_main_exe" "$target_exe"
    fi

    local source_internal="$source_dir/_internal"
    local target_internal="$target_dir/_internal"

    if [ -e "$source_internal" ]; then
        find "$source_internal" -type f | while read -r file; do
            local destination_path="$target_internal/${file#$source_internal/}"
            if [ ! -e "$destination_path" ]; then
                echo "Copie de $file à $destination_path"
                mkdir -p "$(dirname "$destination_path")"
                cp "$file" "$destination_path"
            fi
        done
    fi
}

# Build fpdb-3
echo "Building fpdb-3..."
cd "${BASE_PATH}"

echo "PyInstaller will output to: $DIST_DIR"
pyinstaller --version

if [[ "$OS" == "Windows" ]]; then
    echo "Starting Windows build process..."

    # Ensure we're in the correct directory
    cd "${BASE_PATH}"

    # Build poker-eval
    echo "Building poker-eval..."
    cd "${BASE_PATH}/pypoker-eval/poker-eval"
    mkdir -p build
    cd build
    echo "Running CMake for poker-eval..."
    cmake .. -G "Visual Studio 17 2022" -A x64
    echo "Building poker-eval with CMake..."
    cmake --build . --config Release
    if [ $? -ne 0 ]; then
        echo "Failed to build poker-eval"
        exit 1
    fi
    cd "${BASE_PATH}"

    # Build pypoker-eval
    echo "Building pypoker-eval..."
    cd "${BASE_PATH}/pypoker-eval"
    mkdir -p build
    cd build
    echo "Running CMake for pypoker-eval..."
    cmake .. -G "Visual Studio 17 2022" -A x64
    echo "Building pypoker-eval with CMake..."
    cmake --build . --config Release
    if [ $? -ne 0 ]; then
        echo "Failed to build pypoker-eval"
        exit 1
    fi
    cd "${BASE_PATH}"

    # Copy and rename pokereval
    echo "Copying and renaming pypokereval.dll..."
    cp "${BASE_PATH}/pypoker-eval/build/Release/pypokereval.dll" "${BASE_PATH}/_pokereval_3_11.pyd"
    if [ $? -ne 0 ]; then
        echo "Failed to copy pypokereval.dll"
        exit 1
    fi

    # Generate the pyinstaller command for main script
    echo "Building main script with PyInstaller..."
    command=$(generate_pyinstaller_command "$MAIN_SCRIPT")
    echo "Executing: $command"
    eval "$command"
    if [ $? -ne 0 ]; then
        echo "Failed to build main script"
        exit 1
    fi

    # Generate the pyinstaller command for HUD script
    echo "Building HUD script with PyInstaller..."
    command=$(generate_pyinstaller_command "$SECOND_SCRIPT")
    echo "Executing: $command"
    eval "$command"
    if [ $? -ne 0 ]; then
        echo "Failed to build HUD script"
        exit 1
    fi

    echo "PyInstaller build completed."

    # Setup output directories
    fpdb_output_dir="$DIST_DIR/fpdb"
    hud_output_dir="$DIST_DIR/HUD_main"

    echo "Contents of $DIST_DIR:"
    ls -R "$DIST_DIR"

    if [ ! -d "$hud_output_dir" ]; then
        echo "ERROR: $hud_output_dir does not exist. Please check the build logs."
        exit 1
    fi

    # Move and copy files
    fpdb_internal_dir="$fpdb_output_dir/_internal"
    hud_internal_dir="$hud_output_dir/_internal"

    echo "Moving files..."
    move_files "$fpdb_internal_dir" "$fpdb_output_dir"

    echo "Copying folders..."
    copy_and_remove_folders "$fpdb_internal_dir" "$fpdb_output_dir"

    echo "Copying HUD main..."
    copy_hudmain "$hud_output_dir" "$fpdb_output_dir"

    echo "Windows build process completed successfully."
fi

elif [[ "$OS" == "Linux" ]]; then
    # Vérification de l'existence des fichiers
    if [ ! -f "$BASE_PATH/$SECOND_SCRIPT" ]; then
        echo "Erreur : $SECOND_SCRIPT n'existe pas dans $BASE_PATH"
        exit 1
    fi
    if [ ! -f "$BASE_PATH/$MAIN_SCRIPT" ]; then
        echo "Erreur : $MAIN_SCRIPT n'existe pas dans $BASE_PATH"
        exit 1
    fi

    # Install FUSE if not present
    if ! dpkg -s libfuse2 >/dev/null 2>&1; then
        echo "Installing FUSE..."
        sudo apt-get update
        sudo apt-get install -y libfuse2
    fi

    # Téléchargement de appimagetool
    if [ ! -f ./appimagetool-x86_64.AppImage ]; then
        wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
        chmod +x appimagetool-x86_64.AppImage
    fi

    # Convertir tribal.jpg en fpdb.png si nécessaire
    if [ ! -f "$BASE_PATH/gfx/fpdb.png" ]; then
        if [ -f "$BASE_PATH/gfx/tribal.jpg" ]; then
            echo "Converting tribal.jpg to fpdb.png..."
            convert "$BASE_PATH/gfx/tribal.jpg" "$BASE_PATH/gfx/fpdb.png"
        else
            echo "Erreur : tribal.jpg non trouvé dans $BASE_PATH/gfx/"
            exit 1
        fi
    fi

    # Build HUD_main
    echo "Building HUD_main..."
    command=$(generate_pyinstaller_command "$SECOND_SCRIPT")
    echo "Exécution : $command"
    eval "$command"

    # Build fpdb
    echo "Building fpdb..."
    command=$(generate_pyinstaller_command "$MAIN_SCRIPT")
    echo "Exécution : $command"
    eval "$command"

    # Création de l'AppImage
    echo "Creating AppImage structure..."
    APP_DIR="$BASE_PATH/AppDir"
    mkdir -p "$APP_DIR/usr/bin"
    mkdir -p "$APP_DIR/usr/share/icons/hicolor/256x256/apps"

    echo "Copying files to AppDir..."
    cp -r "$DIST_DIR/fpdb/"* "$APP_DIR/usr/bin/"

    # Copier l'icône en fpdb.png
    cp "$BASE_PATH/gfx/fpdb.png" "$APP_DIR/usr/share/icons/hicolor/256x256/apps/fpdb.png"
    cp "$BASE_PATH/gfx/fpdb.png" "$APP_DIR/fpdb.png"

    # Créer un fichier desktop
    echo "Creating .desktop file..."
    cat <<EOF > "$APP_DIR/fpdb.desktop"
[Desktop Entry]
Name=fpdb
Exec=fpdb
Icon=fpdb
Type=Application
Categories=Utility;
EOF

    # Création du fichier AppRun
    echo "Creating AppRun file..."
    cat <<'EOF' > "$APP_DIR/AppRun"
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
export PYTHONPATH="$HERE/usr/bin"
exec "$HERE/usr/bin/fpdb"
EOF

    chmod +x "$APP_DIR/AppRun"

    # Créer l'AppImage avec un nom personnalisé en spécifiant l'architecture
    echo "Creating AppImage..."
    ARCH=x86_64 ./appimagetool-x86_64.AppImage --appimage-extract-and-run "$APP_DIR" fpdb-x86_64.AppImage

    # Si la création de l'AppImage échoue, essayez l'extraction manuelle
    if [ $? -ne 0 ]; then
        echo "AppImage creation failed. Trying manual extraction..."
        ./appimagetool-x86_64.AppImage --appimage-extract
        ARCH=x86_64 ./squashfs-root/AppRun "$APP_DIR" fpdb-x86_64.AppImage
    fi

    if [ -f fpdb-x86_64.AppImage ]; then
        echo "AppImage created successfully: fpdb-x86_64.AppImage"
        # Déplacer l'AppImage dans le dossier dist
        mv fpdb-x86_64.AppImage "$DIST_DIR/"
        echo "AppImage moved to $DIST_DIR/fpdb-x86_64.AppImage"
    else
        echo "Failed to create AppImage"
        exit 1
    fi

    # Nettoyage
    echo "Cleaning up..."
    rm -rf "$APP_DIR"
    rm -rf squashfs-root

    echo "Linux build process completed successfully."

elif [[ "$OS" == "MacOS" ]]; then
    # Vérification de l'existence des fichiers
    if [ ! -f "$BASE_PATH/$SECOND_SCRIPT" ]; then
        echo "Erreur : $SECOND_SCRIPT n'existe pas dans $BASE_PATH"
        exit 1
    fi
    if [ ! -f "$BASE_PATH/$MAIN_SCRIPT" ]; then
        echo "Erreur : $MAIN_SCRIPT n'existe pas dans $BASE_PATH"
        exit 1
    fi

    # Build HUD_main
    command=$(generate_pyinstaller_command "$SECOND_SCRIPT")
    echo "Exécution : $command"
    eval "$command"

    # Build fpdb
    command=$(generate_pyinstaller_command "$MAIN_SCRIPT")
    echo "Exécution : $command"
    eval "$command"

    APP_NAME="fpdb3"
    APP_DIR="$DIST_DIR/$APP_NAME.app/Contents/MacOS"
    RES_DIR="$DIST_DIR/$APP_NAME.app/Contents/Resources"

    # Create AppDir structure
    mkdir -p "$APP_DIR"
    mkdir -p "$RES_DIR"

    # Copy built files to AppDir, including the first _internal
    cp -R "$DIST_DIR/fpdb/"* "$RES_DIR/"

    # Create the nested _internal structure
    mkdir -p "$RES_DIR/_internal/_internal"

    # Copy the content of the original _internal to the nested _internal
    cp -R "$DIST_DIR/fpdb/_internal/"* "$RES_DIR/_internal/_internal/"

    # Create launcher script
    cat <<EOF >"$APP_DIR/$APP_NAME"
#!/bin/bash
BASE_DIR="\$(cd "\$(dirname "\$0")/../Resources" && pwd)"
export DYLD_LIBRARY_PATH="\$BASE_DIR:\$BASE_DIR/_internal:\$DYLD_LIBRARY_PATH"
export PYTHONHOME="\$BASE_DIR/_internal"
export PYTHONPATH="\$BASE_DIR:\$BASE_DIR/_internal:\$PYTHONPATH"
"\$BASE_DIR/fpdb"
EOF

    chmod +x "$APP_DIR/$APP_NAME"

    # Create Info.plist
    cat <<EOF >"$DIST_DIR/$APP_NAME.app/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>tribal.icns</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.$APP_NAME</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.9</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

    # Copy the existing tribal.icns file
    if [ -f "$BASE_PATH2/gfx/tribal.icns" ]; then
        cp "$BASE_PATH2/gfx/tribal.icns" "$RES_DIR/tribal.icns"
    else
        echo "Warning: tribal.icns not found in gfx folder. Icon will be missing."
    fi

    # Ensure all files are executable
    chmod -R 755 "$APP_DIR"
    chmod -R 755 "$RES_DIR"

    # Remove quarantine attribute
    xattr -cr "$DIST_DIR/$APP_NAME.app"

    echo "App bundle created successfully."
    echo "You can now test the app by running:"
    echo "open \"$DIST_DIR/$APP_NAME.app\""

    # Check dependencies of HUD_main
    echo "Checking dependencies of HUD_main:"
    otool -L "$DIST_DIR/$APP_NAME.app/Contents/Resources/_internal/_internal/HUD_main"

    # For ARM build, you might need to use a different Python and PyInstaller version
    # or use tools like 'arch' to run the build process under Rosetta 2
    if [[ $(uname -m) == 'arm64' ]]; then
        echo "Building for ARM64 architecture"
        # Add any ARM-specific build steps here
    fi
fi

# Clean up build files
echo "Cleaning up build files..."
rm -rf "$BASE_PATH/build"
rm -rf "$DIST_DIR/HUD_main"

echo "All projects built successfully."