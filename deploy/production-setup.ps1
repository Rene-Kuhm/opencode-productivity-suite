# ==========================================
# OpenCode Productivity Suite - Production Deploy Script
# One-command setup for immediate use in production
# ==========================================

param(
    [string]$InstallPath = "$env:USERPROFILE\.opencode-suite",
    [switch]$GlobalInstall = $false,
    [switch]$TeamSetup = $false,
    [string]$GitHubToken = "",
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# Production Configuration
$PROD_CONFIG = @{
    repoUrl = "https://github.com/Rene-Kuhm/opencode-productivity-suite.git"
    version = "2.0.0"
    requiredTools = @("git", "powershell")
    optionalTools = @("gh", "docker")
    configPath = "$env:USERPROFILE\.config\opencode"
}

function Write-SetupLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Level) {
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        "INFO" { "Cyan" }
        "PROGRESS" { "Magenta" }
        default { "White" }
    }
    
    if ($Verbose -or $Level -ne "DEBUG") {
        Write-Host "[$timestamp] $Message" -ForegroundColor $color
    }
}

function Test-Prerequisites {
    Write-SetupLog "🔍 Checking system prerequisites..." "INFO"
    
    $missing = @()
    
    # Check Git
    try {
        $gitVersion = git --version
        Write-SetupLog "✅ Git: $gitVersion" "SUCCESS"
    } catch {
        $missing += "Git"
    }
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -lt 5) {
        $missing += "PowerShell 5.0+"
    } else {
        Write-SetupLog "✅ PowerShell: $($psVersion.ToString())" "SUCCESS"
    }
    
    # Check optional tools
    try {
        $ghVersion = gh --version
        Write-SetupLog "✅ GitHub CLI: Available" "SUCCESS"
    } catch {
        Write-SetupLog "⚠️ GitHub CLI: Not available (optional)" "WARNING"
    }
    
    if ($missing.Count -gt 0) {
        Write-SetupLog "❌ Missing required tools: $($missing -join ', ')" "ERROR"
        Write-SetupLog "Please install the missing tools and try again." "ERROR"
        exit 1
    }
    
    Write-SetupLog "✅ All prerequisites met!" "SUCCESS"
}

function Install-OpenCodeSuite {
    param([string]$Path)
    
    Write-SetupLog "📦 Installing OpenCode Productivity Suite..." "PROGRESS"
    
    # Create installation directory
    if (Test-Path $Path) {
        Write-SetupLog "⚠️ Installation directory exists. Updating..." "WARNING"
        Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    
    # Clone repository
    Write-SetupLog "⬇️ Downloading latest version..." "INFO"
    git clone --depth 1 $PROD_CONFIG.repoUrl $Path
    
    if (-not $?) {
        Write-SetupLog "❌ Failed to clone repository" "ERROR"
        exit 1
    }
    
    Write-SetupLog "✅ OpenCode Suite downloaded successfully" "SUCCESS"
}

function Setup-GlobalConfiguration {
    Write-SetupLog "⚙️ Setting up global configuration..." "PROGRESS"
    
    $configPath = $PROD_CONFIG.configPath
    
    # Create config directory
    if (-not (Test-Path $configPath)) {
        New-Item -ItemType Directory -Path $configPath -Force | Out-Null
    }
    
    # Copy configuration files
    $sourceConfig = "$InstallPath\global-config"
    if (Test-Path $sourceConfig) {
        Copy-Item "$sourceConfig\*" $configPath -Recurse -Force
        Write-SetupLog "✅ Global configuration applied" "SUCCESS"
    }
    
    # Update AGENTS.md with new commands
    $agentsPath = "$configPath\AGENTS.md"
    if (Test-Path $agentsPath) {
        $newCommands = @"

## 🚀 Enhanced Zero Defect Commands (v2.0)

### Intelligent Analysis Commands
```bash
/analyze-codebase              # Comprehensive project analysis
/suggest-patterns              # Framework-specific pattern suggestions
/optimize-performance          # AI-powered performance optimization
/security-audit               # OWASP Top 10 security analysis
```

### Team Management Commands  
```bash
/team-dashboard               # Real-time team metrics and rankings
/team-dashboard --live        # Live updating dashboard
/team-report --format=html    # Generate team performance reports
```

### Advanced Setup Commands
```bash
/init-zero-defect             # Enhanced auto-initialization with framework detection
/detect-framework             # Advanced framework detection (38+ supported)
/validate-setup               # Comprehensive setup validation
```

### Framework-Specific Commands (Auto-detected)
- **Next.js**: Server Component optimization, App Router best practices
- **React**: Hook optimization, memoization patterns
- **Vue.js**: Composition API patterns, reactivity optimization  
- **Angular**: OnPush strategy, lazy loading optimization
- **Express.js**: Security middleware, API optimization
- **Flutter**: Widget optimization, performance patterns

### Usage Examples
```bash
# Complete project setup with framework detection
/init-zero-defect

# Analyze specific framework patterns
/suggest-patterns --framework=react --focus=performance

# Generate team performance report
/team-dashboard --format=html --output=./reports/

# Security audit with auto-fix
/security-audit --deep --autofix

# Performance optimization with impact metrics
/optimize-performance --autofix --focus=bundle
```

## 📊 New Metrics & Analytics

- **Zero Defect Score**: Real-time code quality scoring
- **Team Rankings**: Live productivity leaderboards  
- **Framework Optimization**: Performance metrics by framework
- **Security Compliance**: OWASP Top 10 monitoring
- **Productivity Tracking**: Commits, tests, optimizations

"@
        
        Add-Content -Path $agentsPath -Value $newCommands
        Write-SetupLog "✅ Enhanced commands added to AGENTS.md" "SUCCESS"
    }
}

function Setup-TeamEnvironment {
    Write-SetupLog "👥 Setting up team environment..." "PROGRESS"
    
    # Create team configuration
    $teamConfigPath = "$InstallPath\team-config"
    New-Item -ItemType Directory -Path $teamConfigPath -Force | Out-Null
    
    # Create team dashboard shortcut
    $dashboardScript = @"
# Team Dashboard Shortcut
param(
    [string]`$Period = "week",
    [switch]`$Live = `$false,
    [string]`$Format = "console",
    [string]`$Output = ""
)

& "$InstallPath\dashboard\team-dashboard.ps1" -TeamName "$($(Get-Item $PWD).Name) Team" -Period `$Period -Live:`$Live -OutputFormat `$Format -ReportPath `$Output
"@
    
    Set-Content -Path "$teamConfigPath\team-dashboard.ps1" -Value $dashboardScript
    
    # Create analysis shortcut
    $analysisScript = @"
# Quick Analysis Shortcut
param(
    [switch]`$Deep = `$false,
    [switch]`$Security = `$false,
    [switch]`$Performance = `$false
)

Write-Host "🎯 Running comprehensive project analysis..." -ForegroundColor Cyan

& "$InstallPath\commands\analyze-codebase.ps1" -Deep:`$Deep -Security:`$Security -Performance:`$Performance
"@
    
    Set-Content -Path "$teamConfigPath\analyze-project.ps1" -Value $analysisScript
    
    Write-SetupLog "✅ Team environment configured" "SUCCESS"
}

function Install-PowerShellModules {
    Write-SetupLog "📦 Installing required PowerShell modules..." "INFO"
    
    $requiredModules = @("PowerShellGet")
    
    foreach ($module in $requiredModules) {
        try {
            if (-not (Get-Module -ListAvailable -Name $module)) {
                Install-Module -Name $module -Force -Scope CurrentUser
                Write-SetupLog "✅ Installed module: $module" "SUCCESS"
            } else {
                Write-SetupLog "✅ Module already installed: $module" "SUCCESS"
            }
        } catch {
            Write-SetupLog "⚠️ Failed to install module: $module" "WARNING"
        }
    }
}

function Create-DesktopShortcuts {
    Write-SetupLog "🖥️ Creating desktop shortcuts..." "INFO"
    
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    
    # Team Dashboard shortcut
    $dashboardShortcut = @"
@echo off
powershell -ExecutionPolicy Bypass -File "$InstallPath\dashboard\team-dashboard.ps1" --live
pause
"@
    
    Set-Content -Path "$desktopPath\Zero Defects Team Dashboard.bat" -Value $dashboardShortcut
    
    # Quick Analysis shortcut
    $analysisShortcut = @"
@echo off
cd /d "%CD%"
powershell -ExecutionPolicy Bypass -File "$InstallPath\commands\analyze-codebase.ps1" -Deep
pause
"@
    
    Set-Content -Path "$desktopPath\Zero Defects Analysis.bat" -Value $analysisShortcut
    
    Write-SetupLog "✅ Desktop shortcuts created" "SUCCESS"
}

function Setup-GitHubIntegration {
    param([string]$Token)
    
    if ($Token) {
        Write-SetupLog "🔗 Setting up GitHub integration..." "INFO"
        
        # Configure GitHub CLI
        try {
            $env:GH_TOKEN = $Token
            gh auth login --with-token <<< $Token 2>$null
            Write-SetupLog "✅ GitHub CLI configured" "SUCCESS"
        } catch {
            Write-SetupLog "⚠️ GitHub CLI configuration failed" "WARNING"
        }
    }
}

function Validate-Installation {
    Write-SetupLog "🔍 Validating installation..." "PROGRESS"
    
    $validationResults = @()
    
    # Check installation directory
    if (Test-Path $InstallPath) {
        $validationResults += "✅ Installation directory exists"
    } else {
        $validationResults += "❌ Installation directory missing"
        return $false
    }
    
    # Check core commands
    $coreCommands = @(
        "commands\analyze-codebase.ps1",
        "commands\suggest-patterns.ps1", 
        "commands\optimize-performance.ps1",
        "commands\security-audit.ps1",
        "dashboard\team-dashboard.ps1"
    )
    
    foreach ($command in $coreCommands) {
        if (Test-Path "$InstallPath\$command") {
            $validationResults += "✅ $command available"
        } else {
            $validationResults += "❌ $command missing"
        }
    }
    
    # Check global configuration
    if (Test-Path $PROD_CONFIG.configPath) {
        $validationResults += "✅ Global configuration applied"
    } else {
        $validationResults += "⚠️ Global configuration not applied"
    }
    
    foreach ($result in $validationResults) {
        Write-SetupLog $result $(if ($result -match "✅") { "SUCCESS" } elseif ($result -match "⚠️") { "WARNING" } else { "ERROR" })
    }
    
    $errors = $validationResults | Where-Object { $_ -match "❌" }
    return $errors.Count -eq 0
}

function Show-CompletionMessage {
    Write-Host ""
    Write-Host "🎉 OPENCODE PRODUCTIVITY SUITE INSTALLED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "=======================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📍 Installation Location: $InstallPath" -ForegroundColor Cyan
    Write-Host "⚙️ Configuration: $($PROD_CONFIG.configPath)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🚀 AVAILABLE COMMANDS:" -ForegroundColor Yellow
    Write-Host "  📊 /analyze-codebase          - Comprehensive project analysis" -ForegroundColor White
    Write-Host "  🎯 /suggest-patterns          - Framework-specific patterns" -ForegroundColor White  
    Write-Host "  ⚡ /optimize-performance       - AI-powered optimization" -ForegroundColor White
    Write-Host "  🛡️ /security-audit            - OWASP security analysis" -ForegroundColor White
    Write-Host "  👥 /team-dashboard            - Real-time team metrics" -ForegroundColor White
    Write-Host "  🔧 /init-zero-defect          - Enhanced project setup" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 QUICK START:" -ForegroundColor Yellow
    Write-Host "  1. Navigate to any project directory" -ForegroundColor Gray
    Write-Host "  2. Run: /init-zero-defect" -ForegroundColor Gray
    Write-Host "  3. Zero Defect Programming activated automatically!" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📊 TEAM FEATURES:" -ForegroundColor Yellow
    Write-Host "  • Live team dashboard with rankings" -ForegroundColor Gray
    Write-Host "  • Real-time Zero Defect scoring" -ForegroundColor Gray
    Write-Host "  • Productivity metrics and insights" -ForegroundColor Gray
    Write-Host "  • Framework-optimized workflows" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🖥️ DESKTOP SHORTCUTS:" -ForegroundColor Yellow
    Write-Host "  • Zero Defects Team Dashboard (Live)" -ForegroundColor Gray
    Write-Host "  • Zero Defects Analysis (Deep)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📚 FRAMEWORK SUPPORT:" -ForegroundColor Yellow
    Write-Host "  Frontend: Next.js, React, Vue, Angular, Svelte, Astro, Qwik, SolidJS" -ForegroundColor Gray
    Write-Host "  Backend: Express, NestJS, FastAPI, Django, Spring Boot, Rails" -ForegroundColor Gray  
    Write-Host "  Mobile: React Native, Flutter, Expo, Ionic" -ForegroundColor Gray
    Write-Host "  Total: 38+ frameworks automatically detected and optimized!" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔗 LINKS:" -ForegroundColor Yellow
    Write-Host "  Repository: https://github.com/Rene-Kuhm/opencode-productivity-suite" -ForegroundColor Gray
    Write-Host "  Documentation: Available in installation directory" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🎉 Ready to revolutionize your development workflow!" -ForegroundColor Green
    Write-Host "🚀 Start with: cd your-project && /init-zero-defect" -ForegroundColor Magenta
}

# Main execution
try {
    Write-Host ""
    Write-Host "🚀 OPENCODE PRODUCTIVITY SUITE INSTALLER" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "Version: $($PROD_CONFIG.version)" -ForegroundColor Gray
    Write-Host ""
    
    # Step 1: Prerequisites
    Test-Prerequisites
    
    # Step 2: Install PowerShell modules
    Install-PowerShellModules
    
    # Step 3: Download and install
    Install-OpenCodeSuite -Path $InstallPath
    
    # Step 4: Global configuration
    Setup-GlobalConfiguration
    
    # Step 5: Team setup (if requested)
    if ($TeamSetup) {
        Setup-TeamEnvironment
    }
    
    # Step 6: Desktop shortcuts
    Create-DesktopShortcuts
    
    # Step 7: GitHub integration (if token provided)
    if ($GitHubToken) {
        Setup-GitHubIntegration -Token $GitHubToken
    }
    
    # Step 8: Validation
    $success = Validate-Installation
    
    if ($success) {
        Show-CompletionMessage
        
        # Open team dashboard as demo
        if ($TeamSetup) {
            Write-Host "🎭 Opening team dashboard demo..." -ForegroundColor Cyan
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$InstallPath\dashboard\team-dashboard.ps1`" -TeamName `"Demo Team`""
        }
        
        exit 0
    } else {
        Write-SetupLog "❌ Installation validation failed" "ERROR"
        exit 1
    }
    
} catch {
    Write-SetupLog "❌ Installation failed: $($_.Exception.Message)" "ERROR"
    if ($Verbose) {
        Write-SetupLog "Stack trace: $($_.ScriptStackTrace)" "ERROR" 
    }
    exit 1
}