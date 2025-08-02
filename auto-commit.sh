#!/bin/bash

# ==========================================
# AUTO-COMMIT SCRIPT FOR GITHUB CONTRIBUTIONS
# Supports: Pop!_OS (Ubuntu-based) & Fedora
# Modified version with:
# - Repo directory: ~/.auto-commit
# - HTTP API endpoints
# - Normalized file names (32 chars max)
# - Standardized commit messages
# ==========================================

# Config
REPO_DIR="$HOME/.auto-commit"  # Custom repo location
GIT_USER="Sugeng Sulistiyawan"
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
    
    # Keep original case and spaces
    # Only remove special characters that are problematic for filenames
    str=$(echo "$str" | sed -e 's/[\/\\:*?"<>|]//g')
    
    # Trim to max length
    str=${str:0:$max_length}
    
    # Remove leading/trailing whitespace
    str=$(echo "$str" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
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
# AESTHETIC PATTERN GENERATOR
# =====================
get_commits_for_aesthetic_pattern() {
    local day_of_week=$(date +%u)  # 1=Monday, 7=Sunday
    local week_of_month=$(( ($(date +%d) - 1) / 7 + 1 ))
    
    # Only create commits on weekdays (Monday-Friday)
    if [ $day_of_week -gt 5 ]; then
        echo 0
        return
    fi
    
    # Create aesthetic patterns based on day and week
    case $week_of_month in
        1)  # First week - ascending pattern
            case $day_of_week in
                1) echo 2 ;;  # Monday - light green
                2) echo 4 ;;  # Tuesday - medium green
                3) echo 7 ;;  # Wednesday - dark green
                4) echo 10 ;; # Thursday - darkest green
                5) echo 7 ;;  # Friday - dark green
            esac
            ;;
        2)  # Second week - wave pattern
            case $day_of_week in
                1) echo 5 ;;  # Monday - medium green
                2) echo 8 ;;  # Tuesday - dark green
                3) echo 3 ;;  # Wednesday - light green
                4) echo 8 ;;  # Thursday - dark green
                5) echo 5 ;;  # Friday - medium green
            esac
            ;;
        3)  # Third week - mountain pattern
            case $day_of_week in
                1) echo 3 ;;  # Monday - light green
                2) echo 6 ;;  # Tuesday - medium green
                3) echo 12 ;; # Wednesday - darkest green
                4) echo 6 ;;  # Thursday - medium green
                5) echo 3 ;;  # Friday - light green
            esac
            ;;
        4|5)  # Fourth/Fifth week - descending pattern
            case $day_of_week in
                1) echo 9 ;;  # Monday - dark green
                2) echo 6 ;;  # Tuesday - medium green
                3) echo 4 ;;  # Wednesday - medium green
                4) echo 2 ;;  # Thursday - light green
                5) echo 1 ;;  # Friday - light green
            esac
            ;;
        *)  # Fallback pattern
            echo $(( (RANDOM % 8) + 1 ))
            ;;
    esac
}

# =====================
# GITHUB CONTRIBUTION CHECK
# =====================
check_github_commits_today() {
    local username="wanforge"
    local today=$(date +%Y-%m-%d)
    
    echo -e "${GREEN}[INFO] Checking existing commits for user: $username${NC}"
    
    # Get GitHub events for today (public API)
    local events_url="https://api.github.com/users/$username/events"
    local existing_commits=0
    
    # Check for push events today with timeout and error handling
    local api_response=$(curl -s --max-time 10 "$events_url" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$api_response" ]; then
        echo -e "${YELLOW}[WARNING] Cannot connect to GitHub API. Proceeding without existing commit check.${NC}"
        echo "0"
        return
    fi
    
    # Check for push events today
    local push_events=$(echo "$api_response" | jq -r --arg today "$today" '
        [.[] | select(.type == "PushEvent" and (.created_at | startswith($today)))] | length
    ' 2>/dev/null)
    
    if [[ "$push_events" =~ ^[0-9]+$ ]] && [ "$push_events" -gt 0 ]; then
        existing_commits=$push_events
        echo -e "${YELLOW}[INFO] Found $existing_commits commits already made today${NC}"
    else
        echo -e "${GREEN}[INFO] No commits found today, starting fresh${NC}"
        existing_commits=0
    fi
    
    echo "$existing_commits"
}

calculate_remaining_commits() {
    local target_commits="$1"
    local existing_commits="$2"
    local remaining=$((target_commits - existing_commits))
    
    if [ $remaining -lt 0 ]; then
        remaining=0
    fi
    
    echo "$remaining"
}

# =====================
# MAIN SCRIPT
# =====================
main() {
    # Check if it's weekend (Saturday=6, Sunday=7)
    local day_of_week=$(date +%u)
    if [ $day_of_week -gt 5 ]; then
        echo -e "${YELLOW}[INFO] It's weekend! No commits scheduled for aesthetic pattern.${NC}"
        echo -e "${GREEN}[INFO] Come back on Monday-Friday for beautiful contribution patterns!${NC}"
        exit 0
    fi
    
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
    
    # Create quotes directory if doesn't exist
    if [ ! -d "quotes" ]; then
        echo -e "${GREEN}[INFO] Creating quotes directory...${NC}"
        mkdir -p quotes
    fi
    
    # Generate commits based on aesthetic pattern for weekdays
    TARGET_COMMITS=$(get_commits_for_aesthetic_pattern)
    
    # Check existing commits on GitHub
    EXISTING_COMMITS=$(check_github_commits_today)
    
    # Calculate how many more commits we need
    COMMITS_COUNT=$(calculate_remaining_commits "$TARGET_COMMITS" "$EXISTING_COMMITS")
    
    # Get pattern description
    local day_name=$(date +%A)
    local week_of_month=$(( ($(date +%d) - 1) / 7 + 1 ))
    local pattern_name=""
    
    case $week_of_month in
        1) pattern_name="Ascending Pattern" ;;
        2) pattern_name="Wave Pattern" ;;
        3) pattern_name="Mountain Pattern" ;;
        4|5) pattern_name="Descending Pattern" ;;
        *) pattern_name="Random Pattern" ;;
    esac
    
    echo -e "${GREEN}[INFO] Today is $day_name (Week $week_of_month)${NC}"
    echo -e "${GREEN}[INFO] Target commits for $pattern_name: $TARGET_COMMITS${NC}"
    echo -e "${GREEN}[INFO] Existing commits today: $EXISTING_COMMITS${NC}"
    echo -e "${GREEN}[INFO] Creating $COMMITS_COUNT additional commits...${NC}"
    
    if [ $COMMITS_COUNT -eq 0 ]; then
        echo -e "${YELLOW}[SUCCESS] Target already achieved! No additional commits needed.${NC}"
        exit 0
    fi
    
    for (( i=1; i<=COMMITS_COUNT; i++ ))
    do
        EMOJI=$(get_random_emoji)
        QUOTE=$(get_inspirational_quote)
        FILENAME=$(generate_filename "$QUOTE")
        COMMIT_MSG=$(generate_commit_message "$EMOJI" "$QUOTE")
        
        echo "$QUOTE" > "quotes/$FILENAME"
        git add "quotes/$FILENAME"
        git commit -m "$COMMIT_MSG"
        
        echo -e "${YELLOW}Committed: ${NC}${COMMIT_MSG}"
        echo -e "   File: quotes/${FILENAME}"
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
        
        # Final status
        local final_count=$((EXISTING_COMMITS + COMMITS_COUNT))
        echo -e "${GREEN}[PATTERN STATUS] Total commits today: $final_count/$TARGET_COMMITS${NC}"
        
        if [ $final_count -ge $TARGET_COMMITS ]; then
            echo -e "${GREEN}[SUCCESS] ✅ Pattern goal achieved for today!${NC}"
        else
            echo -e "${YELLOW}[INFO] ⏳ Pattern partially completed. Run again if needed.${NC}"
        fi
    fi
}

main
