# GitHub Auto-Commit Scri## ✨ Features

- 🎨 **Aesthetic GitHub Contribution Patterns** - Creates beautiful weekly patterns on your contribution graph
- 📅 **Smart Weekday-Only Commits** - Only runs Monday-Friday for professional patterns
- 🔍 **GitHub Integration Check** - Verifies existing commits to avoid over-committing
- 💬 **Inspirational Quotes** - Uses API or built-in Indonesian quotes collection
- 📁 **Organized File Structure** - Saves quotes in dedicated `quotes/` folder
- 🎯 **Pattern-Based Commits** - 4 different weekly patterns (Ascending, Wave, Mountain, Descending)
- 📝 **Preserved Filenames** - Keeps original case and spaces in quote filenames
- 🔄 **Automatic Dependency Installation** - Auto-installs git, curl, jq
- 🐧 **Multi-Distro Support** - Ubuntu/Pop!_OS and Fedora compatibility
- ⏲️ **Intelligent Scheduling** - Smart cron integration with pattern awareness
- 🌈 **Color-Coded Contribution Levels** - Light to dark green based on commit frequency
- 🔄 **API Fallback System** - Multiple quote sources with offline fallbackScript](<https://img.shields.io/badge/Shell_Script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white>)
![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)
![Automation](https://img.shields.io/badge/Automation-%23FF6F00.svg?style=for-the-badge&logo=windows-terminal&logoColor=white)

Automated Git commit script that creates aesthetic contribution patterns on GitHub with intelligent commit management and beautiful weekly patterns.

## 📋 Table of Contents

- [GitHub Auto-Commit Scri## ✨ Features](#github-auto-commit-scri--features)
  - [📋 Table of Contents](#-table-of-contents)
  - [✨ Features](#-features)
  - [📥 Installation](#-installation)
  - [⚙️ Configuration](#️-configuration)
  - [🚀 Usage](#-usage)
  - [⏰ Cron Job Setup](#-cron-job-setup)
  - [📂 File Structure](#-file-structure)
  - [💾 Commit Behavior](#-commit-behavior)
    - [🎨 Aesthetic Patterns (Monday-Friday)](#-aesthetic-patterns-monday-friday)
    - [📝 Commit Format](#-commit-format)
    - [🔍 Smart Detection](#-smart-detection)
  - [📊 Example Output](#-example-output)
  - [❓ FAQ](#-faq)
    - [How do I connect to GitHub?](#how-do-i-connect-to-github)
    - [How to customize quotes?](#how-to-customize-quotes)
    - [How to change commit patterns?](#how-to-change-commit-patterns)
    - [How does GitHub API integration work?](#how-does-github-api-integration-work)
    - [What happens on weekends?](#what-happens-on-weekends)
    - [How to stop automated commits?](#how-to-stop-automated-commits)
  - [📜 License](#-license)

## ✨ Features

- � **Aesthetic GitHub Contribution Patterns** - Creates beautiful weekly patterns on your contribution graph
- 📅 **Smart Weekday-Only Commits** - Only runs Monday-Friday for professional patterns
- � **GitHub Integration Check** - Verifies existing commits to avoid over-committing
- 💬 **Inspirational Quotes** - Uses API or built-in Indonesian quotes collection
- 📁 **Organized File Structure** - Saves quotes in dedicated `quotes/` folder
- 🎯 **Pattern-Based Commits** - 4 different weekly patterns (Ascending, Wave, Mountain, Descending)
- 📝 **Preserved Filenames** - Keeps original case and spaces in quote filenames
- 🔄 **Automatic Dependency Installation** - Auto-installs git, curl, jq
- 🐧 **Multi-Distro Support** - Ubuntu/Pop!_OS and Fedora compatibility
- ⏲️ **Intelligent Scheduling** - Smart cron integration with pattern awareness

## 📥 Installation

1. Clone or download the script:

```bash
git clone https://github.com/wanforge/.auto-commit.git
cd .auto-commit
```

2. Make the script executable:

```bash
chmod +x auto-commit.sh
```

## ⚙️ Configuration

Edit these variables at the top of `auto-commit.sh`:

```bash
REPO_DIR="$HOME/.auto-commit"  # Repository storage location
GIT_USER="Sugeng Sulistiyawan" # Your display name
GIT_EMAIL="sugeng.sulistiyawan@gmail.com" # Your email
MAX_FILENAME_LENGTH=64         # Maximum filename length
```

## 🚀 Usage

Run manually:

```bash
./auto-commit.sh
```

## ⏰ Cron Job Setup

For automated weekday commits (Monday-Friday at 6:00 AM):

1. Open crontab:

```bash
crontab -e
```

2. Add this line:

```bash
0 6 * * 1-5 /home/wanforge/www/.auto-commit/auto-commit.sh >> /home/wanforge/www/.auto-commit/auto-commit.log 2>&1
```

Alternative schedules:

- Daily at 9 AM: `0 9 * * *`
- Every weekday at 9 AM and 6 PM: `0 9,18 * * 1-5`
- Every 30 minutes: `*/30 * * * *`

## 📂 File Structure

```
/home/sugengsulistiyawan/.auto-commit/
├── auto-commit.sh      # Main script
├── auto-commit.log     # Execution logs (created by cron)
├── LICENSE.md          # MIT License
├── README.md           # This documentation
└── quotes/             # Directory for quote files
    ├── Perjalanan ribuan mil dimulai dengan satu langkah.txt
    ├── Belajar adalah harta karun yang akan mengikuti pemiliknya ke mana pun.txt
    └── ...             # Additional quote files
```

## 💾 Commit Behavior

### 🎨 Aesthetic Patterns (Monday-Friday)

**Week 1 - Ascending Pattern:**

- Monday: 2 commits (Light green)
- Tuesday: 4 commits (Medium green)
- Wednesday: 7 commits (Dark green)
- Thursday: 10 commits (Darkest green)
- Friday: 7 commits (Dark green)

**Week 2 - Wave Pattern:**

- Monday: 5 commits (Medium green)
- Tuesday: 8 commits (Dark green)
- Wednesday: 3 commits (Light green)
- Thursday: 8 commits (Dark green)
- Friday: 5 commits (Medium green)

**Week 3 - Mountain Pattern:**

- Monday: 3 commits (Light green)
- Tuesday: 6 commits (Medium green)
- Wednesday: 12 commits (Darkest green)
- Thursday: 6 commits (Medium green)
- Friday: 3 commits (Light green)

**Week 4/5 - Descending Pattern:**

- Monday: 9 commits (Dark green)
- Tuesday: 6 commits (Medium green)
- Wednesday: 4 commits (Medium green)
- Thursday: 2 commits (Light green)
- Friday: 1 commit (Light green)

### 📝 Commit Format

- Commit message: `[emoji] [first 10 words of quote...]`
  Example: `🚀 Kesempatan tidak datang dua kali, raih saat...`
- Filename format: `[original-quote-with-spaces].txt`
  Example: `Perjalanan ribuan mil dimulai dengan satu langkah.txt`

### 🔍 Smart Detection

- Checks existing GitHub commits before creating new ones
- Only creates additional commits needed to reach pattern target
- Skips execution on weekends with friendly message

## 📊 Example Output

When running the script, you'll see informative output like this:

```bash
[INFO] Today is Wednesday (Week 3)
[INFO] Checking existing commits for user: wanforge
[INFO] Found 2 commits already made today
[INFO] Target commits for Mountain Pattern: 12
[INFO] Existing commits today: 2
[INFO] Creating 10 additional commits...
Committed: 🚀 Kesempatan tidak datang dua kali, raih saat...
   File: quotes/Kesempatan tidak datang dua kali, raih saat ini juga.txt
[SUCCESS] Pushed commits to GitHub!
[PATTERN STATUS] Total commits today: 12/12
[SUCCESS] ✅ Pattern goal achieved for today!
```

Weekend message:

```bash
[INFO] It's weekend! No commits scheduled for aesthetic pattern.
[INFO] Come back on Monday-Friday for beautiful contribution patterns!
```

## ❓ FAQ

### How do I connect to GitHub?

Run these commands in your repository folder:

```bash
# SSH
git remote add origin git@github.com:wanforge/.auto-commit.git

# HTTPS
git remote add origin https://github.com/wanforge/.auto-commit.git
```

### How to customize quotes?

Edit the `fallback_quotes` array in the `get_inspirational_quote()` function, or the script will automatically fetch quotes from online APIs.

### How to change commit patterns?

Modify the `get_commits_for_aesthetic_pattern()` function to create your own weekly patterns.

### How does GitHub API integration work?

The script automatically checks the `wanforge` GitHub account for existing commits today using the public GitHub API. No authentication required - it uses publicly available data to ensure pattern accuracy.

### What happens on weekends?

The script automatically detects weekends and displays a friendly message without creating commits, maintaining the professional weekday-only pattern.

### How to stop automated commits?

1. Remove the cron job:

   ```bash
   crontab -e
   ```

2. Delete the repository:

   ```bash
   rm -rf ~/.auto-commit
   ```

## 📜 License

MIT License - Free to use and modify

---

*Maintained by [Sugeng Sulistiyawan](mailto:sugeng.sulistiyawan@gmail.com)*  
*"Perjalanan ribuan mil dimulai dengan satu langkah"*
