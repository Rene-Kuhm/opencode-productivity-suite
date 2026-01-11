# Git Hooks Auto-Installation Script
# Automatically installs Zero Defect git hooks in any repository

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = $PWD,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Global = $false
)

$ErrorActionPreference = "Stop"

function Write-Status {
    param([string]$Message, [string]$Type = "INFO")
    
    $color = switch ($Type) {
        "SUCCESS" { "Green" }
        "WARN" { "Yellow" }
        "ERROR" { "Red" }
        default { "White" }
    }
    
    Write-Host "[$Type] $Message" -ForegroundColor $color
}

function Test-GitRepository {
    param([string]$Path)
    
    return Test-Path "$Path\.git"
}

function Install-PreCommitHook {
    param([string]$ProjectPath)
    
    $hooksDir = "$ProjectPath\.git\hooks"
    $preCommitPath = "$hooksDir\pre-commit"
    
    if ((Test-Path $preCommitPath) -and -not $Force) {
        Write-Status "Pre-commit hook already exists. Use -Force to overwrite." "WARN"
        return $false
    }
    
    # Zero Defect Pre-commit Hook
    $preCommitScript = @'
#!/bin/sh
# Zero Defect Programming Pre-commit Hook
# This hook enforces zero-tolerance validation before any commit

set -e

echo "🛡️  Running Zero Defect validation..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ZERO_DEFECT_CONFIG=".opencode/zero-defect-config.md"
BIOME_CONFIG="biome.json"
TSCONFIG="tsconfig.json"

# Check if Zero Defect is configured
if [ ! -f "$ZERO_DEFECT_CONFIG" ]; then
    echo "${YELLOW}⚠️  Zero Defect Programming not configured.${NC}"
    echo "Run: /init-zero-defect to set up"
    echo "Proceeding with basic validation..."
fi

# Function to run command with error handling
run_validation() {
    local name="$1"
    local cmd="$2"
    local blocking="$3"
    
    echo "🔍 Running $name..."
    
    if eval "$cmd"; then
        echo "${GREEN}✅ $name passed${NC}"
        return 0
    else
        if [ "$blocking" = "true" ]; then
            echo "${RED}❌ COMMIT BLOCKED: $name failed${NC}"
            return 1
        else
            echo "${YELLOW}⚠️  $name failed (non-blocking)${NC}"
            return 0
        fi
    fi
}

# Validation gates
validation_failed=false

# 1. TypeScript validation (if available)
if [ -f "$TSCONFIG" ] && command -v tsc >/dev/null 2>&1; then
    if ! run_validation "TypeScript strict check" "tsc --noEmit --strict" "true"; then
        validation_failed=true
    fi
elif command -v npx >/dev/null 2>&1 && [ -f "$TSCONFIG" ]; then
    if ! run_validation "TypeScript strict check" "npx tsc --noEmit --strict" "true"; then
        validation_failed=true
    fi
fi

# 2. Biome validation (if available)
if [ -f "$BIOME_CONFIG" ] && command -v biome >/dev/null 2>&1; then
    if ! run_validation "Biome code quality check" "biome check --apply=off" "true"; then
        validation_failed=true
    fi
elif command -v npx >/dev/null 2>&1 && [ -f "$BIOME_CONFIG" ]; then
    if ! run_validation "Biome code quality check" "npx biome check --apply=off" "true"; then
        validation_failed=true
    fi
fi

# 3. OpenCode Zero Defect validation (if available)
if command -v opencode >/dev/null 2>&1; then
    if ! run_validation "OpenCode Zero Defect validation" "opencode /pre-commit-validation" "true"; then
        validation_failed=true
    fi
fi

# 4. Security scan for common issues
echo "🔍 Running security scan..."
if git diff --cached --name-only | xargs grep -l "password\s*=\s*[\"']" 2>/dev/null; then
    echo "${RED}❌ COMMIT BLOCKED: Hardcoded passwords detected${NC}"
    validation_failed=true
fi

if git diff --cached --name-only | xargs grep -l "secret\s*=\s*[\"']" 2>/dev/null; then
    echo "${RED}❌ COMMIT BLOCKED: Hardcoded secrets detected${NC}"
    validation_failed=true
fi

if git diff --cached --name-only | xargs grep -l "api[_-]key\s*=\s*[\"']" 2>/dev/null; then
    echo "${RED}❌ COMMIT BLOCKED: Hardcoded API keys detected${NC}"
    validation_failed=true
fi

# 5. Prevent commits to main/master without PR
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
    echo "${YELLOW}⚠️  Direct commit to $current_branch detected${NC}"
    echo "Consider using a feature branch and PR workflow."
fi

# 6. Check for TODO/FIXME in staged files
staged_files=$(git diff --cached --name-only)
if echo "$staged_files" | xargs grep -l "TODO\|FIXME" 2>/dev/null; then
    echo "${YELLOW}⚠️  TODO/FIXME comments found in staged files${NC}"
    echo "Consider resolving or documenting these before commit."
fi

# Final validation result
if [ "$validation_failed" = true ]; then
    echo ""
    echo "${RED}❌ COMMIT REJECTED: One or more validation gates failed${NC}"
    echo ""
    echo "Zero Defect Programming - NO ERRORS TOLERATED"
    echo ""
    echo "Fix all issues and try again:"
    echo "  - Run: /zero-check for comprehensive validation"
    echo "  - Run: /fail-fast for immediate issue detection"
    echo "  - Run: npm run validate (if available)"
    echo ""
    exit 1
fi

echo ""
echo "${GREEN}🎉 All validation gates passed!${NC}"
echo "${GREEN}✅ Zero Defect validation successful${NC}"
echo ""
echo "Commit authorized - proceeding..."
'@

    # Create hooks directory if it doesn't exist
    if (-not (Test-Path $hooksDir)) {
        New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
    }
    
    # Write the hook script
    Set-Content -Path $preCommitPath -Value $preCommitScript -Encoding UTF8
    
    # Make executable on Unix systems
    if ($IsLinux -or $IsMacOS) {
        chmod +x $preCommitPath
    }
    
    Write-Status "Zero Defect pre-commit hook installed successfully" "SUCCESS"
    return $true
}

function Install-CommitMsgHook {
    param([string]$ProjectPath)
    
    $hooksDir = "$ProjectPath\.git\hooks"
    $commitMsgPath = "$hooksDir\commit-msg"
    
    if ((Test-Path $commitMsgPath) -and -not $Force) {
        Write-Status "Commit-msg hook already exists. Use -Force to overwrite." "WARN"
        return $false
    }
    
    # Conventional Commits validation hook
    $commitMsgScript = @'
#!/bin/sh
# Conventional Commits validation hook

commit_regex='^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "❌ Invalid commit message format!"
    echo ""
    echo "Commit message must follow Conventional Commits format:"
    echo "  <type>[optional scope]: <description>"
    echo ""
    echo "Examples:"
    echo "  feat: add user authentication"
    echo "  fix(auth): resolve login validation issue"
    echo "  docs: update API documentation"
    echo "  refactor(components): simplify button component"
    echo ""
    echo "Valid types: feat, fix, docs, style, refactor, perf, test, chore, build, ci, revert"
    exit 1
fi
'@

    Set-Content -Path $commitMsgPath -Value $commitMsgScript -Encoding UTF8
    
    # Make executable on Unix systems
    if ($IsLinux -or $IsMacOS) {
        chmod +x $commitMsgPath
    }
    
    Write-Status "Conventional Commits hook installed successfully" "SUCCESS"
    return $true
}

function Install-PostCommitHook {
    param([string]$ProjectPath)
    
    $hooksDir = "$ProjectPath\.git\hooks"
    $postCommitPath = "$hooksDir\post-commit"
    
    if ((Test-Path $postCommitPath) -and -not $Force) {
        Write-Status "Post-commit hook already exists. Use -Force to overwrite." "WARN"
        return $false
    }
    
    # Post-commit hook for logging and metrics
    $postCommitScript = @'
#!/bin/sh
# Zero Defect Post-commit Hook
# Logs successful commits and updates metrics

echo "✅ Commit successful - Zero Defect validation passed"

# Log commit for metrics (if logging is configured)
if [ -f ".opencode/zero-defect-config.md" ]; then
    commit_hash=$(git rev-parse HEAD)
    commit_msg=$(git log -1 --pretty=%s)
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Create metrics log if it doesn't exist
    if [ ! -f ".opencode/commit-metrics.log" ]; then
        echo "timestamp,commit_hash,message,validation_status" > .opencode/commit-metrics.log
    fi
    
    # Log successful commit
    echo "$timestamp,$commit_hash,$commit_msg,passed" >> .opencode/commit-metrics.log
fi

# Optional: Run post-commit analysis
if command -v opencode >/dev/null 2>&1; then
    opencode /post-commit-analysis >/dev/null 2>&1 &
fi
'@

    Set-Content -Path $postCommitPath -Value $postCommitScript -Encoding UTF8
    
    # Make executable on Unix systems  
    if ($IsLinux -or $IsMacOS) {
        chmod +x $postCommitPath
    }
    
    Write-Status "Post-commit hook installed successfully" "SUCCESS"
    return $true
}

function Install-GlobalGitHooks {
    # Set up global git hooks directory
    $globalHooksDir = "$env:USERPROFILE\.config\git\hooks"
    
    if (-not (Test-Path $globalHooksDir)) {
        New-Item -ItemType Directory -Path $globalHooksDir -Force | Out-Null
    }
    
    # Configure git to use global hooks directory
    git config --global core.hooksPath $globalHooksDir
    
    Write-Status "Configured global git hooks directory: $globalHooksDir" "SUCCESS"
    
    # Install hooks in global directory
    Install-PreCommitHook -ProjectPath $globalHooksDir.Replace("\.git\hooks", "")
    Install-CommitMsgHook -ProjectPath $globalHooksDir.Replace("\.git\hooks", "")
    Install-PostCommitHook -ProjectPath $globalHooksDir.Replace("\.git\hooks", "")
}

function Test-HooksInstallation {
    param([string]$ProjectPath)
    
    $hooksDir = "$ProjectPath\.git\hooks"
    
    $hooks = @("pre-commit", "commit-msg", "post-commit")
    $allInstalled = $true
    
    foreach ($hook in $hooks) {
        $hookPath = "$hooksDir\$hook"
        if (Test-Path $hookPath) {
            Write-Status "✅ $hook hook installed" "SUCCESS"
        } else {
            Write-Status "❌ $hook hook missing" "ERROR"
            $allInstalled = $false
        }
    }
    
    return $allInstalled
}

# Main execution
try {
    Write-Status "Starting Zero Defect Git Hooks installation..."
    
    if ($Global) {
        Write-Status "Installing global git hooks for all repositories..."
        Install-GlobalGitHooks
        Write-Status "Global git hooks installation completed" "SUCCESS"
        return
    }
    
    # Check if we're in a git repository
    if (-not (Test-GitRepository -Path $ProjectPath)) {
        Write-Status "Not a git repository. Initialize git first with 'git init'" "ERROR"
        exit 1
    }
    
    Write-Status "Installing Zero Defect git hooks in: $ProjectPath"
    
    # Install individual hooks
    $preCommitSuccess = Install-PreCommitHook -ProjectPath $ProjectPath
    $commitMsgSuccess = Install-CommitMsgHook -ProjectPath $ProjectPath  
    $postCommitSuccess = Install-PostCommitHook -ProjectPath $ProjectPath
    
    # Test installation
    $success = Test-HooksInstallation -ProjectPath $ProjectPath
    
    if ($success) {
        Write-Status "🎉 Zero Defect git hooks installation completed successfully!" "SUCCESS"
        Write-Status ""
        Write-Status "Hooks installed:"
        Write-Status "  • pre-commit: Zero Defect validation (BLOCKING)"
        Write-Status "  • commit-msg: Conventional Commits format validation"
        Write-Status "  • post-commit: Success logging and metrics"
        Write-Status ""
        Write-Status "Your commits will now be automatically validated for:"
        Write-Status "  • TypeScript strict compliance"
        Write-Status "  • Code quality (Biome rules)"
        Write-Status "  • Security issues (secrets detection)"
        Write-Status "  • Zero Defect standards compliance"
        Write-Status ""
        Write-Status "NO COMMITS WILL BE ALLOWED without passing ALL validations."
    } else {
        Write-Status "Git hooks installation incomplete" "ERROR"
        exit 1
    }
    
} catch {
    Write-Status "Git hooks installation failed: $($_.Exception.Message)" "ERROR"
    exit 1
}