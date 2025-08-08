#!/bin/bash

# ==========================================
# AUTO-COMMIT SCRIPT FOR GITHUB CONTRIBUTIONS
# Supports: Pop!_OS (Ubuntu-based) & Fedora
# Modified version with:
# - Repo directory: ~/.auto-commit
# - HTTP API endpoints
# - Quotes organized by alphabet
# - Standardized commit messages
# ==========================================

# Configuration
REPO_DIR="$HOME/www/.auto-commit"    # Auto-commit repository location
QUOTES_REPO_DIR="$HOME/www/.quotes"  # Quotes repository location
GIT_USER="Sugeng Sulistiyawan"
GIT_EMAIL="sugeng.sulistiyawan@gmail.com"
MAX_FILENAME_LENGTH=64

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =====================
# DEPENDENCY MANAGEMENT
# =====================

check_dependencies() {
    local missing=()
    
    # Check required tools
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi
    
    # Install missing dependencies if any
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}[WARNING] Missing dependencies:${NC} ${missing[*]}"
        install_dependencies "${missing[@]}"
    fi
}

install_dependencies() {
    # Detect Linux distribution
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
                echo -e "${RED}[ERROR] Unsupported Linux distribution${NC}"
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
# EMOJI & QUOTE FUNCTIONS
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
    
    # Fallback quotes if APIs are unavailable
    if [ -z "$quote" ]; then
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
# QUOTE MANAGEMENT
# =====================

get_alphabet_section() {
    local quote="$1"
    local first_char="${quote:0:1}"
    
    # Convert to uppercase for consistency
    first_char=$(echo "$first_char" | tr '[:lower:]' '[:upper:]')
    
    # Return the first character or # for non-alphabetic characters
    if [[ "$first_char" =~ [A-Z] ]]; then
        echo "$first_char"
    else
        echo "#"
    fi
}

append_quote_to_readme() {
    local quote="$1"
    local emoji="$2"
    local quotes_readme="$QUOTES_REPO_DIR/README.md"
    
    # Get alphabet section (no language grouping)
    local alphabet=$(get_alphabet_section "$quote")
    local quote_line="- $emoji $quote"
    
    # Check if quote text already exists to avoid duplicates
    local quote_text_only=$(echo "$quote_line" | sed 's/^- [^ ]* //')
    if grep -q "$quote_text_only" "$quotes_readme"; then
        echo -e "${YELLOW}[INFO] Quote already exists, skipping: $quote${NC}"
        return
    fi
    
    # Create backup of README.md
    cp "$quotes_readme" "$quotes_readme.bak"
    
    # Use AWK to properly handle the insertion by alphabet
    awk -v alph="$alphabet" -v quote_line="$quote_line" '
    BEGIN { 
        in_alph = 0
        alph_found = 0
        inserted = 0
    }
    
    # Check for alphabet section headers
    /^## / {
        if ($0 == "## " alph) {
            in_alph = 1
            alph_found = 1
            print $0
        } else {
            if (!alph_found && !inserted && $0 > "## " alph) {
                # Insert new alphabet section before this subsection
                print "## " alph
                print ""
                print quote_line
                print ""
                inserted = 1
            }
            in_alph = 0
            print $0
        }
        next
    }
    
    # Handle quote lines within alphabet section
    /^- / {
        if (in_alph && !inserted) {
            if ($0 > quote_line) {
                print quote_line
                inserted = 1
            }
        }
        print $0
        next
    }
    
    # Handle empty lines and other content
    {
        if (in_alph && /^$/ && !inserted) {
            print quote_line
            inserted = 1
        }
        print $0
    }
    
    END {
        if (!alph_found && !inserted) {
            # Add new alphabet section at the end
            print ""
            print "## " alph
            print ""
            print quote_line
        } else if (alph_found && !inserted) {
            # Add quote at the end of existing alphabet section
            print quote_line
        }
    }
    ' "$quotes_readme" > "$quotes_readme.tmp"
    
    mv "$quotes_readme.tmp" "$quotes_readme"
    echo -e "${GREEN}[INFO] Quote added to alphabet section: $alphabet${NC}"
}

generate_commit_message() {
    local emoji="$1"
    local quote="$2"
    
    # Standard commit message format: [emoji] [first 10 words of quote...]
    local short_quote=$(echo "$quote" | cut -d ' ' -f 1-10)
    
    # Add ellipsis if quote is longer than 10 words
    if [ $(echo "$quote" | wc -w) -gt 10 ]; then
        short_quote="${short_quote}..."
    fi
    
    echo "${emoji} ${short_quote}"
}

# =====================
# AESTHETIC PATTERN GENERATOR
# =====================

get_commits_for_aesthetic_pattern() {
    local day_of_week=$(date +%u)    # 1=Monday, 7=Sunday
    local week_of_month=$(( (10#$(date +%d) - 1) / 7 + 1 ))
    
    # Only create commits on weekdays (Monday-Friday)
    if [ $day_of_week -gt 5 ]; then
        echo 0
        return
    fi
    
    # Create aesthetic patterns based on day and week
    case $week_of_month in
        1)  # First week - ascending pattern
            case $day_of_week in
                1) echo 2 ;;   # Monday - light green
                2) echo 4 ;;   # Tuesday - medium green
                3) echo 7 ;;   # Wednesday - dark green
                4) echo 10 ;;  # Thursday - darkest green
                5) echo 7 ;;   # Friday - dark green
            esac
            ;;
        2)  # Second week - wave pattern
            case $day_of_week in
                1) echo 5 ;;   # Monday - medium green
                2) echo 8 ;;   # Tuesday - dark green
                3) echo 3 ;;   # Wednesday - light green
                4) echo 8 ;;   # Thursday - dark green
                5) echo 5 ;;   # Friday - medium green
            esac
            ;;
        3)  # Third week - mountain pattern
            case $day_of_week in
                1) echo 3 ;;   # Monday - light green
                2) echo 6 ;;   # Tuesday - medium green
                3) echo 12 ;;  # Wednesday - darkest green
                4) echo 6 ;;   # Thursday - medium green
                5) echo 3 ;;   # Friday - light green
            esac
            ;;
        4|5)  # Fourth/Fifth week - descending pattern
            case $day_of_week in
                1) echo 9 ;;   # Monday - dark green
                2) echo 6 ;;   # Tuesday - medium green
                3) echo 4 ;;   # Wednesday - medium green
                4) echo 2 ;;   # Thursday - light green
                5) echo 1 ;;   # Friday - light green
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
    
    echo -e "${GREEN}[INFO] Checking existing commits for user: $username${NC}" >&2
    
    # Get GitHub events for today (public API)
    local events_url="https://api.github.com/users/$username/events"
    local existing_commits=0
    
    # Check for push events today with timeout and error handling
    local api_response=$(curl -s --max-time 10 "$events_url" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$api_response" ]; then
        echo -e "${YELLOW}[WARNING] Cannot connect to GitHub API. Proceeding without existing commit check.${NC}" >&2
        echo "0"
        return
    fi
    
    # Check for push events today
    local push_events=$(echo "$api_response" | jq -r --arg today "$today" '
        [.[] | select(.type == "PushEvent" and (.created_at | startswith($today)))] | length
    ' 2>/dev/null)
    
    if [[ "$push_events" =~ ^[0-9]+$ ]] && [ "$push_events" -gt 0 ]; then
        existing_commits=$push_events
        echo -e "${YELLOW}[INFO] Found $existing_commits commits already made today${NC}" >&2
    else
        echo -e "${GREEN}[INFO] No commits found today, starting fresh${NC}" >&2
        existing_commits=0
    fi
    
    echo "$existing_commits"
}

calculate_remaining_commits() {
    local target_commits="$1"
    local existing_commits="$2"
    
    # Validate input parameters are numeric
    if ! [[ "$target_commits" =~ ^[0-9]+$ ]]; then
        echo -e "${YELLOW}[WARNING] Invalid target_commits value: $target_commits, defaulting to 0${NC}" >&2
        target_commits=0
    fi
    
    if ! [[ "$existing_commits" =~ ^[0-9]+$ ]]; then
        echo -e "${YELLOW}[WARNING] Invalid existing_commits value: $existing_commits, defaulting to 0${NC}" >&2
        existing_commits=0
    fi
    
    local remaining=$((target_commits - existing_commits))
    
    # Ensure non-negative result
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
    
    # Initialize auto-commit repository if it doesn't exist
    if [ ! -d "$REPO_DIR" ]; then
        echo -e "${GREEN}[INFO] Creating auto-commit repository directory...${NC}"
        mkdir -p "$REPO_DIR"
        cd "$REPO_DIR" || exit
        git init
        git config user.name "$GIT_USER"
        git config user.email "$GIT_EMAIL"
        git config commit.gpgsign false
        git config tag.gpgsign false
        git branch -M main
        echo "# Auto-Commit Repository" > README.md
        git add README.md
        git commit -m "🎉"
    else
        cd "$REPO_DIR" || exit
        # Ensure GPG signing is disabled for existing repo
        git config commit.gpgsign false
        git config tag.gpgsign false
    fi
    
    # Initialize quotes repository if it doesn't exist
    if [ ! -d "$QUOTES_REPO_DIR" ]; then
        echo -e "${GREEN}[INFO] Creating quotes repository directory...${NC}"
        mkdir -p "$QUOTES_REPO_DIR"
        cd "$QUOTES_REPO_DIR" || exit
        git init
        git config user.name "$GIT_USER"
        git config user.email "$GIT_EMAIL"
        git config commit.gpgsign false
        git config tag.gpgsign false
        git branch -M main
        echo "# Quotes" > README.md
        echo "" >> README.md
        git add README.md
        git commit -m "🎉 Initialize quotes repository"
    else
        # Ensure GPG signing is disabled for existing quotes repo
        cd "$QUOTES_REPO_DIR" || exit
        git config commit.gpgsign false
        git config tag.gpgsign false
    fi
    
    # Return to auto-commit repo for the rest of the script
    cd "$REPO_DIR" || exit
    
    # Generate commits based on aesthetic pattern for weekdays
    TARGET_COMMITS=$(get_commits_for_aesthetic_pattern)
    
    # Check existing commits on GitHub
    EXISTING_COMMITS=$(check_github_commits_today)
    
    # Ensure EXISTING_COMMITS is a valid number
    if ! [[ "$EXISTING_COMMITS" =~ ^[0-9]+$ ]]; then
        echo -e "${YELLOW}[WARNING] Invalid commit count received, defaulting to 0${NC}" >&2
        EXISTING_COMMITS=0
    fi
    
    # Calculate how many more commits we need
    COMMITS_COUNT=$(calculate_remaining_commits "$TARGET_COMMITS" "$EXISTING_COMMITS")
    
    # Ensure COMMITS_COUNT is a valid number
    if ! [[ "$COMMITS_COUNT" =~ ^[0-9]+$ ]]; then
        echo -e "${YELLOW}[WARNING] Invalid commits count calculated, defaulting to 0${NC}" >&2
        COMMITS_COUNT=0
    fi
    
    # Get pattern description for display
    local day_name=$(date +%A)
    local week_of_month=$(( (10#$(date +%d) - 1) / 7 + 1 ))
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
    
    # Exit if target already achieved
    if [ $COMMITS_COUNT -eq 0 ]; then
        echo -e "${YELLOW}[SUCCESS] Target already achieved! No additional commits needed.${NC}"
        exit 0
    fi
    
    # Create commits loop
    for (( i=1; i<=COMMITS_COUNT; i++ )); do
        EMOJI=$(get_random_emoji)
        QUOTE=$(get_inspirational_quote)
        COMMIT_MSG=$(generate_commit_message "$EMOJI" "$QUOTE")
        
        # Add quote to quotes repository README.md
        append_quote_to_readme "$QUOTE" "$EMOJI"
        
        # Commit to quotes repository
        cd "$QUOTES_REPO_DIR" || exit
        git add README.md
        git commit -m "$COMMIT_MSG"
        
        # Create dummy commit in auto-commit repository
        cd "$REPO_DIR" || exit
        echo "$(date): $COMMIT_MSG" >> auto-commit.log
        git add auto-commit.log
        git commit -m "$COMMIT_MSG"
        
        echo -e "${YELLOW}Committed: ${NC}${COMMIT_MSG}"
        echo -e "   Quote added to .quotes repository"
    done
    
    # Push to remote repositories
    echo -e "${GREEN}[INFO] Pushing commits to GitHub...${NC}"
    
    # Push auto-commit repository
    if ! git remote show origin >/dev/null 2>&1; then
        echo -e "${YELLOW}[WARNING] No remote origin set for auto-commit repository.${NC}"
        echo -e "Create a GitHub repository and run:"
        echo -e "git remote add origin git@github.com:wanforge/.auto-commit.git"
        echo -e "or:"
        echo -e "git remote add origin https://github.com/wanforge/.auto-commit.git"
    else
        if git push origin main; then
            echo -e "${GREEN}[SUCCESS] Pushed auto-commit repository to GitHub!${NC}"
        else
            echo -e "${RED}[ERROR] Failed to push auto-commit repository to GitHub.${NC}"
        fi
    fi
    
    # Push quotes repository
    cd "$QUOTES_REPO_DIR" || exit
    if ! git remote show origin >/dev/null 2>&1; then
        echo -e "${YELLOW}[WARNING] No remote origin set for quotes repository.${NC}"
        echo -e "Create a GitHub repository and run:"
        echo -e "cd $QUOTES_REPO_DIR"
        echo -e "git remote add origin git@github.com:wanforge/.quotes.git"
        echo -e "or:"
        echo -e "git remote add origin https://github.com/wanforge/.quotes.git"
    else
        if git push origin main; then
            echo -e "${GREEN}[SUCCESS] Pushed quotes repository to GitHub!${NC}"
            
            # Final status report
            local final_count=$((EXISTING_COMMITS + COMMITS_COUNT))
            echo -e "${GREEN}[PATTERN STATUS] Total commits today: $final_count/$TARGET_COMMITS${NC}"
            
            if [ $final_count -ge $TARGET_COMMITS ]; then
                echo -e "${GREEN}[SUCCESS] ✅ Pattern goal achieved for today!${NC}"
            else
                echo -e "${YELLOW}[INFO] ⏳ Pattern partially completed. Run again if needed.${NC}"
            fi
        else
            echo -e "${RED}[ERROR] Failed to push quotes repository to GitHub.${NC}"
        fi
    fi
}

# Execute main function
main
