# 📦 Installation Guide

## Prerequisites

- **OpenCode CLI** installed and configured
- **GitHub CLI** (optional, for repository operations)
- **Git** version 2.20+

## Quick Installation

### 1. Clone Repository
```bash
git clone https://github.com/Rene-Kuhm/opencode-productivity-suite.git
cd opencode-productivity-suite
```

### 2. Install Global Configuration
```bash
# Windows
copy global-config\AGENTS.md %USERPROFILE%\.config\opencode\

# macOS/Linux
cp global-config/AGENTS.md ~/.config/opencode/
```

### 3. Setup Project Templates
```bash
# Copy to your project directory
cp -r project-templates/.opencode ./
```

## Verification

Test installation with:
```bash
# Should show available commands
/ps-review --help

# Test token optimization
/opt --test
```

## Customization

Edit `.opencode/oh-my-opencode.json` to customize:
- Preferred agents
- Automation rules
- Project-specific settings