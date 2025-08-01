#!/bin/bash

# ==========================================
# AUTO-COMMIT SCRIPT FOR GITHUB CONTRIBUTIONS
# Supports: Pop!_OS (Ubuntu-based) & Fedora
# Modified version with:
# - Repo directory: ~/www/.auto-commit
# - HTTP API endpoints
# - Normalized file names (32 chars max)
# - Standardized commit messages
# ==========================================

# Config
REPO_DIR="$HOME/www/.auto-commit"  # Custom repo location
GIT_USER="wanforge"
GIT_EMAIL="sugeng.sulistiyawan@gmail.com"
MAX_FILENAME_LENGTH=64

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =====================
# DEPENDENCY CHECK
# =====================
check_dependencies() {
    local missing=()
    
    # Check git
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    # Check curl
    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi
    
    # Check jq
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}[WARNING] Missing dependencies:${NC} ${missing[*]}"
        install_dependencies "${missing[@]}"
    fi
}

install_dependencies() {
    # Detect distro
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            pop|ubuntu|debian)
                INSTALL_CMD="sudo apt install -y"
                ;;
            fedora|rhel|centos)
                INSTALL_CMD="sudo dnf install -y"
                ;;
            *)
                echo -e "${RED}[ERROR] Unsupported Linux distro${NC}"
                exit 1
                ;;
        esac
    else
        echo -e "${RED}[ERROR] Cannot detect Linux distribution${NC}"
        exit 1
    fi

    echo -e "${GREEN}[INFO] Installing dependencies...${NC}"
    for pkg in "$@"; do
        $INSTALL_CMD "$pkg"
    done
}

# =====================
# EMOJI & QUOTE FUNCTIONS (HTTP version)
# =====================
get_random_emoji() {
    local emojis=(
        "💡" "✨" "🌱" "🚀" "🎯" "🔖" "📚" "🌿" "🦋" "🍀" 
        "🌸" "🌼" "🌻" "🌞" "🌝" "🌛" "🌟" "🌠" "☀️" "⭐"
        "🔥" "💧" "🌊" "🍃" "🍂" "🍁" "🍄" "🌰" "🎁" "🎈"
        "🧩" "🎨" "🖌️" "📝" "📌" "📍" "🎉" "🎊" "🏆" "🏅"
        "🥇" "🥈" "🥉" "⚡" "🌈" "🌏" "🧠" "🦾" "🦿" "🧬"
        "🔭" "🧪" "🔬" "💎" "🧿" "🕹️" "📱" "💻" "🖥️" "⌨️"
        "🖱️" "📡" "🔋" "🛠️" "🧰" "🧲" "🔮" "🧨" "🎆" "🧧"
        "🪔" "🎎" "🏮" "📜" "🎵" "🎶" "🎼" "🎤" "🎧" "🎷"
        "🎸" "🎹" "📯" "🎺" "🪕" "🥁" "🪘" "📢" "🔔" "🎙️"
    )
    echo "${emojis[$RANDOM % ${#emojis[@]}]}"
}

get_inspirational_quote() {
    local quote
    # Try multiple quote APIs (HTTP only)
    quote=$(curl -s "http://api.quotable.io/random" | jq -r '.content' 2>/dev/null)
    
    if [ -z "$quote" ]; then
        quote=$(curl -s "http://zenquotes.io/api/random" | jq -r '.[0].q' 2>/dev/null)
    fi
    
    if [ -z "$quote" ]; then
        # Fallback quotes
        local fallback_quotes=(
            "Perjalanan ribuan mil dimulai dengan satu langkah"
            "Belajar adalah harta karun yang akan mengikuti pemiliknya ke mana pun"
            "Kesempatan tidak datang dua kali, raih saat ini juga"
            "Kegagalan adalah guru terbaik"
            "Kebahagiaan datang ketika kita berhenti mengeluh"
            "Mimpi tidak akan terwujud dengan sendirinya"
            "Kesederhanaan adalah kecanggihan tertinggi"
            "Bumi ini cukup untuk tujuh generasi, tetapi tidak untuk tujuh orang serakah"
        )
        quote="${fallback_quotes[$RANDOM % ${#fallback_quotes[@]}]}"
    fi
    
    echo "$quote"
}

# =====================
# STRING UTILITIES
# =====================
normalize_string() {
    local str="$1"
    local max_length="$2"
    
    # Convert to lowercase
    str=$(echo "$str" | tr '[:upper:]' '[:lower:]')
    
    # Replace spaces with dashes
    str=$(echo "$str" | tr ' ' '-')
    
    # Remove special characters
    str=$(echo "$str" | sed -e 's/[^a-zA-Z0-9-]//g')
    
    # Trim to max length
    str=${str:0:$max_length}
    
    # Remove trailing dash if exists
    str=$(echo "$str" | sed 's/-$//')
    
    echo "$str"
}

generate_filename() {
    local quote="$1"
    local timestamp=$(date +%s)
    
    # Normalize the quote for filename
    local normalized=$(normalize_string "$quote" "$MAX_FILENAME_LENGTH")
    
    # If normalization removed everything, use timestamp
    if [ -z "$normalized" ]; then
        normalized="$timestamp"
    fi
    
    echo "${normalized}.txt"
}

generate_commit_message() {
    local emoji="$1"
    local quote="$2"
    
    # Standard commit message format: [emoji] [first 10 words of quote...]
    local short_quote=$(echo "$quote" | cut -d ' ' -f 1-10)
    
    # If quote is longer than 10 words, add ellipsis
    if [ $(echo "$quote" | wc -w) -gt 10 ]; then
        short_quote="${short_quote}..."
    fi
    
    echo "${emoji} ${short_quote}"
}

# =====================
# MAIN SCRIPT
# =====================
main() {
    # Check dependencies
    check_dependencies
    
    # Initialize repo if doesn't exist
    if [ ! -d "$REPO_DIR" ]; then
        echo -e "${GREEN}[INFO] Creating repository directory...${NC}"
        mkdir -p "$REPO_DIR"
        cd "$REPO_DIR" || exit
        git init
        git config user.name "$GIT_USER"
        git config user.email "$GIT_EMAIL"
        git branch -M main
        echo "# Auto-Commit Repository" > README.md
        git add README.md
        git commit -m "🎉"
    else
        cd "$REPO_DIR" || exit
    fi
    
    # Generate random number of commits (1-5)
    RANDOM_COMMITS=$(( (RANDOM % 5) + 1 ))
    echo -e "${GREEN}[INFO] Generating $RANDOM_COMMITS commits...${NC}"
    
    for (( i=1; i<=RANDOM_COMMITS; i++ ))
    do
        EMOJI=$(get_random_emoji)
        QUOTE=$(get_inspirational_quote)
        FILENAME=$(generate_filename "$QUOTE")
        COMMIT_MSG=$(generate_commit_message "$EMOJI" "$QUOTE")
        
        echo "$QUOTE" > "$FILENAME"
        git add "$FILENAME"
        git commit -m "$COMMIT_MSG"
        
        echo -e "${YELLOW}Committed: ${NC}${COMMIT_MSG}"
        echo -e "   File: ${FILENAME}"
    done
    
    # Push to remote
    if ! git remote | grep -q "origin"; then
        echo -e "${YELLOW}[WARNING] No remote origin set.${NC}"
        echo -e "Create a GitHub repository and run:"
        echo -e "git remote add origin git@github.com:wanforge/.auto-commit.git"
        echo -e "or:"
        echo -e "git remote add origin https://github.com/wanforge/.auto-commit.git"
    else
        git push origin main
        echo -e "${GREEN}[SUCCESS] Pushed commits to GitHub!${NC}"
    fi
}

main
