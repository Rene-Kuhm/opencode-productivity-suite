# Zero Defect Auto-Initialization Script
# Automatically configures any project for Zero Defect Programming

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = $PWD,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# Configuration
$REPO_URL = "https://github.com/Rene-Kuhm/opencode-productivity-suite.git"
$TEMP_DIR = "$env:TEMP\zero-defect-setup"
$LOG_FILE = "$ProjectPath\zero-defect-setup.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LOG_FILE -Value $logEntry
}

function Test-ProjectType {
    param([string]$Path)
    
    $indicators = @{
        "TypeScript" = @("tsconfig.json", "*.ts", "*.tsx")
        "JavaScript" = @("package.json", "*.js", "*.jsx")
        "React" = @("react", "next.js", "@types/react")
        "Node.js" = @("package.json", "node_modules")
        "Bun" = @("bunfig.toml", "bun.lockb")
        "PowerShell" = @("*.ps1", "*.psm1", "*.psd1")
        "Python" = @("requirements.txt", "*.py", "pyproject.toml")
    }
    
    $detectedTypes = @()
    
    foreach ($type in $indicators.Keys) {
        foreach ($pattern in $indicators[$type]) {
            if (Test-Path "$Path\$pattern") {
                $detectedTypes += $type
                break
            }
        }
    }
    
    return $detectedTypes
}

function Install-ZeroDefectConfig {
    param([string]$ProjectPath, [array]$ProjectTypes)
    
    Write-Log "Installing Zero Defect configuration for project types: $($ProjectTypes -join ', ')"
    
    # Create .opencode directory
    $opencodeDir = "$ProjectPath\.opencode"
    if (-not (Test-Path $opencodeDir)) {
        New-Item -ItemType Directory -Path $opencodeDir -Force | Out-Null
        Write-Log "Created .opencode directory"
    }
    
    # Download and extract templates
    if (Test-Path $TEMP_DIR) {
        Remove-Item $TEMP_DIR -Recurse -Force
    }
    
    Write-Log "Downloading Zero Defect templates..."
    git clone --depth 1 $REPO_URL $TEMP_DIR 2>$null
    
    # Copy core configuration files
    $templateDir = "$TEMP_DIR\project-templates"
    
    $coreFiles = @(
        "zero-defect-config.md",
        "zero-defect-prompts.md", 
        "pre-commit-gates.yaml",
        "oh-my-opencode-zero-defect.json",
        "zero-defect-cicd.yml"
    )
    
    foreach ($file in $coreFiles) {
        $source = "$templateDir\$file"
        $destination = "$opencodeDir\$file"
        
        if (Test-Path $source) {
            Copy-Item $source $destination -Force
            Write-Log "Copied $file"
        }
    }
    
    # Configure based on project type
    if ($ProjectTypes -contains "TypeScript" -or $ProjectTypes -contains "JavaScript") {
        # TypeScript/JavaScript configuration
        Copy-Item "$templateDir\tsconfig-zero-defect.json" "$ProjectPath\tsconfig.json" -Force
        Copy-Item "$templateDir\biome-zero-defect.json" "$ProjectPath\biome.json" -Force
        Write-Log "Configured TypeScript/JavaScript Zero Defect settings"
    }
    
    if ($ProjectTypes -contains "React" -or $ProjectTypes -contains "Next.js") {
        # React/Next.js specific configuration
        $nextConfig = @"
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    strictMode: true,
    typedRoutes: true,
  },
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production',
  },
  typescript: {
    tsconfigPath: './tsconfig.json',
  },
  eslint: {
    ignoreDuringBuilds: false,
  },
};

module.exports = nextConfig;
"@
        Set-Content -Path "$ProjectPath\next.config.js" -Value $nextConfig
        Write-Log "Configured Next.js Zero Defect settings"
    }
    
    if ($ProjectTypes -contains "PowerShell") {
        # PowerShell specific configuration
        $psAnalyzerSettings = @"
@{
    Severity = @('Error', 'Warning', 'Information')
    IncludeDefaultRules = $true
    ExcludeRules = @()
    Rules = @{
        PSAvoidUsingCmdletAliases = @{
            'allowlist' = @()
        }
        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            IndentationSize = 4
        }
        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckSeparator = $true
        }
    }
}
"@
        Set-Content -Path "$ProjectPath\PSScriptAnalyzerSettings.psd1" -Value $psAnalyzerSettings
        Write-Log "Configured PowerShell Zero Defect settings"
    }
    
    # Copy examples based on project type
    $examplesDir = "$TEMP_DIR\examples"
    $projectExamplesDir = "$opencodeDir\examples"
    
    if (-not (Test-Path $projectExamplesDir)) {
        New-Item -ItemType Directory -Path $projectExamplesDir -Force | Out-Null
    }
    
    if (Test-Path "$examplesDir\zero-defect-patterns.ts") {
        Copy-Item "$examplesDir\zero-defect-patterns.ts" "$projectExamplesDir\" -Force
        Write-Log "Copied Zero Defect patterns examples"
    }
}

function Install-GitHooks {
    param([string]$ProjectPath)
    
    $hooksDir = "$ProjectPath\.git\hooks"
    
    if (-not (Test-Path $hooksDir)) {
        Write-Log "No git repository found, skipping git hooks installation" "WARN"
        return
    }
    
    # Pre-commit hook
    $preCommitHook = @"
#!/bin/sh
# Zero Defect Pre-commit Hook

echo "🛡️ Running Zero Defect validation..."

# Run zero defect validation
if command -v opencode >/dev/null 2>&1; then
    opencode /pre-commit-validation
    if [ `$? -ne 0 ]; then
        echo "❌ COMMIT BLOCKED: Zero Defect validation failed"
        echo "Fix all errors before committing. NO EXCEPTIONS."
        exit 1
    fi
    echo "✅ Zero Defect validation passed"
else
    echo "⚠️  OpenCode not found, skipping validation"
fi

# Run Biome if available
if [ -f "biome.json" ] && command -v biome >/dev/null 2>&1; then
    biome check --apply=off
    if [ `$? -ne 0 ]; then
        echo "❌ COMMIT BLOCKED: Code quality issues detected"
        exit 1
    fi
fi

# Run TypeScript check if available
if [ -f "tsconfig.json" ] && command -v tsc >/dev/null 2>&1; then
    tsc --noEmit --strict
    if [ `$? -ne 0 ]; then
        echo "❌ COMMIT BLOCKED: TypeScript errors detected"
        exit 1
    fi
fi

echo "✅ All pre-commit checks passed"
"@
    
    Set-Content -Path "$hooksDir\pre-commit" -Value $preCommitHook
    Write-Log "Installed pre-commit git hook"
    
    # Make executable (on Unix systems)
    if ($IsLinux -or $IsMacOS) {
        chmod +x "$hooksDir/pre-commit"
    }
}

function Install-Dependencies {
    param([string]$ProjectPath, [array]$ProjectTypes)
    
    if ($ProjectTypes -contains "TypeScript" -or $ProjectTypes -contains "JavaScript") {
        if (Test-Path "$ProjectPath\package.json") {
            Write-Log "Installing Zero Defect dependencies..."
            
            Push-Location $ProjectPath
            try {
                # Detect package manager
                $packageManager = "npm"
                if (Test-Path "pnpm-lock.yaml") { $packageManager = "pnpm" }
                elseif (Test-Path "yarn.lock") { $packageManager = "yarn" }
                elseif (Test-Path "bun.lockb") { $packageManager = "bun" }
                
                Write-Log "Using package manager: $packageManager"
                
                # Install Zero Defect dependencies
                $dependencies = @(
                    "zod",           # Input validation
                    "@biomejs/biome" # Linting and formatting
                )
                
                $devDependencies = @(
                    "typescript",
                    "@types/node"
                )
                
                foreach ($dep in $dependencies) {
                    & $packageManager add $dep
                }
                
                foreach ($devDep in $devDependencies) {
                    & $packageManager add -D $devDep
                }
                
                Write-Log "Dependencies installed successfully"
            }
            catch {
                Write-Log "Failed to install dependencies: $($_.Exception.Message)" "ERROR"
            }
            finally {
                Pop-Location
            }
        }
    }
}

function Update-PackageJson {
    param([string]$ProjectPath)
    
    $packageJsonPath = "$ProjectPath\package.json"
    
    if (Test-Path $packageJsonPath) {
        Write-Log "Updating package.json with Zero Defect scripts..."
        
        $packageJson = Get-Content $packageJsonPath | ConvertFrom-Json
        
        # Add Zero Defect scripts
        if (-not $packageJson.scripts) {
            $packageJson | Add-Member -Name "scripts" -Value @{} -MemberType NoteProperty
        }
        
        $zeroDefectScripts = @{
            "zero-check" = "opencode /zero-check"
            "pre-commit" = "opencode /pre-commit-validation"
            "lint" = "biome check --apply=off"
            "lint:fix" = "biome check --apply=unsafe"
            "type-check" = "tsc --noEmit --strict"
            "validate" = "npm run type-check && npm run lint && npm run zero-check"
        }
        
        foreach ($script in $zeroDefectScripts.GetEnumerator()) {
            $packageJson.scripts | Add-Member -Name $script.Key -Value $script.Value -MemberType NoteProperty -Force
        }
        
        # Save updated package.json
        $packageJson | ConvertTo-Json -Depth 10 | Set-Content $packageJsonPath
        Write-Log "Updated package.json with Zero Defect scripts"
    }
}

function Test-ZeroDefectInstallation {
    param([string]$ProjectPath)
    
    Write-Log "Testing Zero Defect installation..."
    
    $requiredFiles = @(
        ".opencode\zero-defect-config.md",
        ".opencode\zero-defect-prompts.md",
        ".opencode\oh-my-opencode-zero-defect.json"
    )
    
    $allFilesExist = $true
    
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path "$ProjectPath\$file")) {
            Write-Log "Missing required file: $file" "ERROR"
            $allFilesExist = $false
        }
    }
    
    if ($allFilesExist) {
        Write-Log "✅ Zero Defect installation completed successfully!"
        return $true
    } else {
        Write-Log "❌ Zero Defect installation incomplete" "ERROR"
        return $false
    }
}

# Main execution
try {
    Write-Log "Starting Zero Defect Auto-Initialization for $ProjectPath"
    
    # Detect project type
    $projectTypes = Test-ProjectType -Path $ProjectPath
    
    if ($projectTypes.Count -eq 0) {
        Write-Log "No recognized project type detected. Proceeding with generic configuration." "WARN"
        $projectTypes = @("Generic")
    } else {
        Write-Log "Detected project types: $($projectTypes -join ', ')"
    }
    
    # Check if already configured
    if ((Test-Path "$ProjectPath\.opencode\zero-defect-config.md") -and -not $Force) {
        Write-Log "Zero Defect configuration already exists. Use -Force to overwrite." "WARN"
        exit 0
    }
    
    # Install Zero Defect configuration
    Install-ZeroDefectConfig -ProjectPath $ProjectPath -ProjectTypes $projectTypes
    
    # Install Git hooks if git repo exists
    Install-GitHooks -ProjectPath $ProjectPath
    
    # Install dependencies for supported project types
    Install-Dependencies -ProjectPath $ProjectPath -ProjectTypes $projectTypes
    
    # Update package.json if it exists
    Update-PackageJson -ProjectPath $ProjectPath
    
    # Test installation
    $success = Test-ZeroDefectInstallation -ProjectPath $ProjectPath
    
    if ($success) {
        Write-Log "🎉 Zero Defect Programming is now ACTIVE for this project!"
        Write-Log "Available commands:"
        Write-Log "  /zero-check              - Comprehensive validation"
        Write-Log "  /fail-fast               - Immediate failure detection"
        Write-Log "  /real-time-validation    - Continuous validation"
        Write-Log "  /pre-commit-validation   - Pre-commit gates"
        Write-Log "  /defensive-programming   - Defensive patterns"
        Write-Log ""
        Write-Log "Next steps:"
        Write-Log "1. Run: /zero-check"
        Write-Log "2. Start coding with zero-defect patterns"
        Write-Log "3. Commit will automatically validate"
    }
    
} catch {
    Write-Log "Auto-initialization failed: $($_.Exception.Message)" "ERROR"
    exit 1
} finally {
    # Cleanup
    if (Test-Path $TEMP_DIR) {
        Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    }
}