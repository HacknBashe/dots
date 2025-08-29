#!/run/current-system/sw/bin/bash

# toggle_parental_apps - Toggle parental control apps for kids user
# Copies apps from dotfiles repo to ~/.local/share/applications or removes them

set -euo pipefail

# Configuration
REPO_DIR="/home/nick/.config/dots"
SOURCE_DIR="$REPO_DIR/files/local/share/applications"
TARGET_DIR="/home/kids/.local/share/applications"
STATE_FILE="/home/kids/.local/share/parental_apps_installed"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Check if apps are currently installed
if [[ -f "$STATE_FILE" ]]; then
    # Apps are installed, remove them
    log_info "Removing parental apps..."
    
    removed_count=0
    while IFS= read -r app_file; do
        target_file="$TARGET_DIR/$app_file"
        if [[ -f "$target_file" ]]; then
            rm "$target_file"
            log_info "Removed: $app_file"
            ((removed_count++))
        else
            log_warn "File not found (already removed?): $app_file"
        fi
    done < "$STATE_FILE"
    
    # Remove state file
    rm "$STATE_FILE"
    
    if [[ $removed_count -gt 0 ]]; then
        log_info "Successfully removed $removed_count parental apps"
    else
        log_warn "No apps were removed"
    fi
    
else
    # Apps are not installed, install them
    log_info "Installing parental apps..."
    
    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_error "Source directory not found: $SOURCE_DIR"
        exit 1
    fi
    
    installed_count=0
    > "$STATE_FILE"  # Create empty state file
    
    for source_file in "$SOURCE_DIR"/*.desktop; do
        if [[ -f "$source_file" ]]; then
            app_name=$(basename "$source_file")
            target_file="$TARGET_DIR/$app_name"
            
            # Copy the file
            cp "$source_file" "$target_file"
            
            # Record in state file
            echo "$app_name" >> "$STATE_FILE"
            
            log_info "Installed: $app_name"
            ((installed_count++))
        fi
    done
    
    if [[ $installed_count -gt 0 ]]; then
        log_info "Successfully installed $installed_count parental apps"
    else
        log_warn "No .desktop files found in $SOURCE_DIR"
        rm -f "$STATE_FILE"  # Clean up empty state file
    fi
fi
