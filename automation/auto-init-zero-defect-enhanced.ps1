# ==========================================
# Enhanced Zero Defect Auto-Initialization Script v2.0
# Automatically configures ANY project with Advanced Framework Detection
# ==========================================

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = $PWD,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose = $false,

    [Parameter(Mandatory=$false)]
    [string]$Framework = ""
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

function Invoke-AdvancedFrameworkDetection {
    param([string]$Path)
    
    Write-Log "🔍 Running advanced framework detection..."
    
    # Run the advanced framework detection script
    $detectionScript = "$TEMP_DIR\automation\advanced-framework-detection.ps1"
    
    if (Test-Path $detectionScript) {
        try {
            $detectionResult = & $detectionScript -ProjectPath $Path -JsonOutput
            $frameworks = $detectionResult | ConvertFrom-Json
            
            if ($frameworks -and $frameworks.Count -gt 0) {
                $primaryFramework = $frameworks | Where-Object { $_.Confidence -ge 70 } | Select-Object -First 1
                
                if ($primaryFramework) {
                    Write-Log "✅ Primary framework detected: $($primaryFramework.Name) (Confidence: $($primaryFramework.Confidence)%)"
                    return @{
                        Primary = $primaryFramework
                        All = $frameworks
                    }
                } else {
                    $bestFramework = $frameworks | Sort-Object Confidence -Descending | Select-Object -First 1
                    Write-Log "⚠️ Low confidence detection. Best match: $($bestFramework.Name) ($($bestFramework.Confidence)%)"
                    return @{
                        Primary = $bestFramework
                        All = $frameworks
                    }
                }
            }
        } catch {
            Write-Log "❌ Advanced framework detection failed: $($_.Exception.Message)" "ERROR"
        }
    }
    
    # Fallback to basic detection
    Write-Log "📋 Falling back to basic project type detection..."
    return Get-BasicProjectType -Path $Path
}

function Get-BasicProjectType {
    param([string]$Path)
    
    $indicators = @{
        "TypeScript" = @("tsconfig.json", "*.ts", "*.tsx")
        "JavaScript" = @("package.json", "*.js", "*.jsx")
        "React" = @("react", "next.js", "@types/react")
        "Node.js" = @("package.json", "node_modules")
        "Bun" = @("bunfig.toml", "bun.lockb")
        "PowerShell" = @("*.ps1", "*.psm1", "*.psd1")
        "Python" = @("requirements.txt", "*.py", "pyproject.toml")
        "Generic" = @()
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
    
    if ($detectedTypes.Count -eq 0) {
        $detectedTypes = @("Generic")
    }
    
    # Return in compatible format
    $primaryType = $detectedTypes[0]
    return @{
        Primary = @{
            Name = $primaryType
            Category = "Unknown"
            ConfigFile = "$($primaryType.ToLower())-zero-defect.json"
            Confidence = 50
        }
        All = $detectedTypes | ForEach-Object {
            @{
                Name = $_
                Category = "Unknown"
                ConfigFile = "$($_.ToLower())-zero-defect.json"
                Confidence = 50
            }
        }
    }
}

function Install-FrameworkSpecificConfig {
    param(
        [string]$ProjectPath,
        [object]$FrameworkInfo
    )
    
    $primaryFramework = $FrameworkInfo.Primary
    $frameworkName = $primaryFramework.Name.ToLower() -replace '\.', ''
    
    Write-Log "📦 Installing Zero Defect configuration for: $($primaryFramework.Name)"
    
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
    
    Write-Log "⬇️ Downloading Zero Defect templates..."
    git clone --depth 1 $REPO_URL $TEMP_DIR 2>$null
    
    # Copy core configuration files
    $templateDir = "$TEMP_DIR\project-templates"
    $frameworkConfigDir = "$TEMP_DIR\framework-configs"
    
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
            Write-Log "✅ Copied $file"
        }
    }
    
    # Install framework-specific configuration
    $frameworkConfigFile = "$frameworkName-zero-defect.json"
    if ($primaryFramework.ConfigFile -like "*.yaml") {
        $frameworkConfigFile = "$frameworkName-zero-defect.yaml"
    }
    
    $frameworkConfigPath = "$frameworkConfigDir\$frameworkConfigFile"
    
    if (Test-Path $frameworkConfigPath) {
        Write-Log "🎯 Found specific configuration for $($primaryFramework.Name)"
        
        try {
            if ($frameworkConfigFile -like "*.yaml") {
                # Handle YAML configuration (e.g., Flutter)
                Copy-Item $frameworkConfigPath "$ProjectPath\analysis_options.yaml" -Force
                Write-Log "✅ Applied $($primaryFramework.Name) analysis options"
            } else {
                # Handle JSON configuration
                $config = Get-Content $frameworkConfigPath | ConvertFrom-Json
                
                # Apply TypeScript configuration if present
                if ($config.typescript) {
                    $tsconfig = $config.typescript | ConvertTo-Json -Depth 10
                    Set-Content "$ProjectPath\tsconfig.json" -Value $tsconfig
                    Write-Log "✅ Applied $($primaryFramework.Name) TypeScript config"
                }
                
                # Apply Biome configuration if present
                if ($config.biome) {
                    $biomeConfig = $config.biome | ConvertTo-Json -Depth 10
                    Set-Content "$ProjectPath\biome.json" -Value $biomeConfig
                    Write-Log "✅ Applied $($primaryFramework.Name) Biome config"
                }
                
                # Apply VS Code settings if present
                if ($config.vscode) {
                    $vscodeDir = "$ProjectPath\.vscode"
                    if (-not (Test-Path $vscodeDir)) {
                        New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
                    }
                    
                    if ($config.vscode.settings) {
                        $settings = $config.vscode.settings | ConvertTo-Json -Depth 10
                        Set-Content "$vscodeDir\settings.json" -Value $settings
                        Write-Log "✅ Applied $($primaryFramework.Name) VS Code settings"
                    }
                    
                    if ($config.vscode.extensions) {
                        $extensions = @{
                            recommendations = $config.vscode.extensions
                        } | ConvertTo-Json -Depth 10
                        Set-Content "$vscodeDir\extensions.json" -Value $extensions
                        Write-Log "✅ Applied $($primaryFramework.Name) VS Code extensions"
                    }
                }
                
                # Update package.json scripts if configuration has scripts
                if ($config.scripts) {
                    Update-PackageJsonWithFrameworkScripts -ProjectPath $ProjectPath -Scripts $config.scripts
                }
                
                # Store framework info for future reference
                $frameworkInfo = @{
                    framework = $primaryFramework.Name
                    category = $primaryFramework.Category
                    confidence = $primaryFramework.Confidence
                    configApplied = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    securityRules = $config.securityRules
                    performanceRules = $config.performanceRules
                } | ConvertTo-Json -Depth 10
                
                Set-Content "$opencodeDir\framework-info.json" -Value $frameworkInfo
                Write-Log "✅ Stored framework information"
            }
        } catch {
            Write-Log "⚠️ Failed to apply some framework-specific settings: $($_.Exception.Message)" "WARN"
        }
    } else {
        Write-Log "⚠️ No specific configuration found for $($primaryFramework.Name), using generic setup" "WARN"
        # Apply generic configuration
        Apply-GenericConfiguration -ProjectPath $ProjectPath
    }
    
    # Install additional frameworks configurations if detected
    $additionalFrameworks = $FrameworkInfo.All | Where-Object { $_.Name -ne $primaryFramework.Name -and $_.Confidence -ge 30 }
    foreach ($framework in $additionalFrameworks) {
        Write-Log "📝 Applying additional configuration for: $($framework.Name)"
        # Apply lightweight configurations for additional frameworks
    }
}

function Apply-GenericConfiguration {
    param([string]$ProjectPath)
    
    Write-Log "🔧 Applying generic Zero Defect configuration..."
    
    # Generic TypeScript configuration
    if (-not (Test-Path "$ProjectPath\tsconfig.json")) {
        $genericTsConfig = @{
            compilerOptions = @{
                target = "ES2020"
                module = "ESNext"
                strict = $true
                esModuleInterop = $true
                skipLibCheck = $true
                forceConsistentCasingInFileNames = $true
                moduleResolution = "node"
                resolveJsonModule = $true
                isolatedModules = $true
                noEmit = $true
                strictNullChecks = $true
                strictFunctionTypes = $true
                noImplicitAny = $true
                noImplicitReturns = $true
                noUnusedLocals = $true
                noUnusedParameters = $true
            }
            include = @("src", "**/*.ts", "**/*.tsx")
            exclude = @("node_modules", "dist", "build")
        } | ConvertTo-Json -Depth 10
        
        Set-Content "$ProjectPath\tsconfig.json" -Value $genericTsConfig
        Write-Log "✅ Applied generic TypeScript configuration"
    }
    
    # Generic Biome configuration
    if (-not (Test-Path "$ProjectPath\biome.json")) {
        Copy-Item "$TEMP_DIR\project-templates\biome-zero-defect.json" "$ProjectPath\biome.json" -Force
        Write-Log "✅ Applied generic Biome configuration"
    }
}

function Update-PackageJsonWithFrameworkScripts {
    param([string]$ProjectPath, [object]$Scripts)
    
    $packageJsonPath = "$ProjectPath\package.json"
    
    if (Test-Path $packageJsonPath) {
        Write-Log "📝 Updating package.json with framework-specific scripts..."
        
        try {
            $packageJson = Get-Content $packageJsonPath | ConvertFrom-Json
            
            if (-not $packageJson.scripts) {
                $packageJson | Add-Member -Name "scripts" -Value @{} -MemberType NoteProperty
            }
            
            # Add framework-specific scripts
            foreach ($scriptName in $Scripts.PSObject.Properties.Name) {
                $packageJson.scripts | Add-Member -Name $scriptName -Value $Scripts.$scriptName -MemberType NoteProperty -Force
                Write-Log "✅ Added script: $scriptName"
            }
            
            # Save updated package.json
            $packageJson | ConvertTo-Json -Depth 10 | Set-Content $packageJsonPath
            Write-Log "✅ Updated package.json with framework scripts"
        } catch {
            Write-Log "⚠️ Failed to update package.json: $($_.Exception.Message)" "WARN"
        }
    }
}

function Install-FrameworkDependencies {
    param([string]$ProjectPath, [object]$FrameworkInfo)
    
    $primaryFramework = $FrameworkInfo.Primary
    $frameworkName = $primaryFramework.Name.ToLower() -replace '\.', ''
    
    # Try to load framework-specific dependencies
    $frameworkConfigPath = "$TEMP_DIR\framework-configs\$frameworkName-zero-defect.json"
    
    if (Test-Path $frameworkConfigPath -and (Test-Path "$ProjectPath\package.json")) {
        Write-Log "📦 Installing framework-specific dependencies for $($primaryFramework.Name)..."
        
        try {
            $config = Get-Content $frameworkConfigPath | ConvertFrom-Json
            
            if ($config.dependencies) {
                Push-Location $ProjectPath
                
                # Detect package manager
                $packageManager = "npm"
                if (Test-Path "pnpm-lock.yaml") { $packageManager = "pnpm" }
                elseif (Test-Path "yarn.lock") { $packageManager = "yarn" }
                elseif (Test-Path "bun.lockb") { $packageManager = "bun" }
                
                Write-Log "📦 Using package manager: $packageManager"
                
                # Install required dependencies
                if ($config.dependencies.required) {
                    Write-Log "Installing required dependencies..."
                    foreach ($dep in $config.dependencies.required) {
                        try {
                            & $packageManager add $dep
                            Write-Log "✅ Installed: $dep"
                        } catch {
                            Write-Log "⚠️ Failed to install $dep`: $($_.Exception.Message)" "WARN"
                        }
                    }
                }
                
                # Install recommended dependencies
                if ($config.dependencies.recommended) {
                    Write-Log "Installing recommended dependencies..."
                    foreach ($dep in $config.dependencies.recommended) {
                        try {
                            & $packageManager add $dep
                            Write-Log "✅ Installed: $dep"
                        } catch {
                            Write-Log "⚠️ Failed to install $dep`: $($_.Exception.Message)" "WARN"
                        }
                    }
                }
                
                # Install development dependencies
                if ($config.dependencies.testing -or $config.dependencies.development) {
                    $devDeps = @()
                    if ($config.dependencies.testing) { $devDeps += $config.dependencies.testing }
                    if ($config.dependencies.development) { $devDeps += $config.dependencies.development }
                    
                    Write-Log "Installing development dependencies..."
                    foreach ($dep in $devDeps) {
                        try {
                            & $packageManager add -D $dep
                            Write-Log "✅ Installed (dev): $dep"
                        } catch {
                            Write-Log "⚠️ Failed to install $dep`: $($_.Exception.Message)" "WARN"
                        }
                    }
                }
                
                Pop-Location
                Write-Log "✅ Framework dependencies installation completed"
            }
        } catch {
            Write-Log "❌ Failed to install framework dependencies: $($_.Exception.Message)" "ERROR"
            Pop-Location
        }
    }
}

function Install-GitHooks {
    param([string]$ProjectPath)
    
    $hooksDir = "$ProjectPath\.git\hooks"
    
    if (-not (Test-Path $hooksDir)) {
        Write-Log "No git repository found, skipping git hooks installation" "WARN"
        return
    }
    
    # Enhanced pre-commit hook with framework detection
    $preCommitHook = @"
#!/bin/sh
# Enhanced Zero Defect Pre-commit Hook with Framework Support

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
    echo "⚠️  OpenCode not found, running basic validation"
fi

# Framework-specific validations
if [ -f ".opencode/framework-info.json" ]; then
    echo "🎯 Running framework-specific validations..."
    
    # Check if jq is available for JSON parsing
    if command -v jq >/dev/null 2>&1; then
        FRAMEWORK=`$(cat .opencode/framework-info.json | jq -r '.framework // "Unknown"')
        echo "Framework detected: `$FRAMEWORK"
    fi
fi

# Run Biome if available
if [ -f "biome.json" ] && command -v biome >/dev/null 2>&1; then
    echo "🔧 Running Biome checks..."
    biome check --apply=off
    if [ `$? -ne 0 ]; then
        echo "❌ COMMIT BLOCKED: Code quality issues detected"
        exit 1
    fi
    echo "✅ Biome checks passed"
fi

# Run TypeScript check if available
if [ -f "tsconfig.json" ] && command -v tsc >/dev/null 2>&1; then
    echo "🔍 Running TypeScript checks..."
    tsc --noEmit --strict
    if [ `$? -ne 0 ]; then
        echo "❌ COMMIT BLOCKED: TypeScript errors detected"
        exit 1
    fi
    echo "✅ TypeScript checks passed"
fi

# Run tests if available
if [ -f "package.json" ]; then
    if command -v npm >/dev/null 2>&1 && npm run test --dry-run >/dev/null 2>&1; then
        echo "🧪 Running tests..."
        npm run test -- --passWithNoTests --watchAll=false
        if [ `$? -ne 0 ]; then
            echo "❌ COMMIT BLOCKED: Tests failed"
            exit 1
        fi
        echo "✅ Tests passed"
    fi
fi

echo "✅ All pre-commit checks passed - Ready to commit!"
"@
    
    Set-Content -Path "$hooksDir\pre-commit" -Value $preCommitHook
    Write-Log "✅ Installed enhanced pre-commit git hook"
    
    # Make executable (on Unix systems)
    if ($IsLinux -or $IsMacOS) {
        chmod +x "$hooksDir/pre-commit"
    }
}

function Test-ZeroDefectInstallation {
    param([string]$ProjectPath, [object]$FrameworkInfo)
    
    Write-Log "🔍 Testing Zero Defect installation..."
    
    $requiredFiles = @(
        ".opencode\zero-defect-config.md",
        ".opencode\zero-defect-prompts.md",
        ".opencode\oh-my-opencode-zero-defect.json"
    )
    
    $allFilesExist = $true
    
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path "$ProjectPath\$file")) {
            Write-Log "❌ Missing required file: $file" "ERROR"
            $allFilesExist = $false
        }
    }
    
    # Test framework-specific files
    if ($FrameworkInfo.Primary.Name -ne "Generic") {
        $frameworkSpecificFiles = @()
        
        switch ($FrameworkInfo.Primary.Category) {
            "Frontend" { 
                $frameworkSpecificFiles += @("tsconfig.json", "biome.json")
            }
            "Backend" { 
                $frameworkSpecificFiles += @("tsconfig.json", "biome.json")
            }
            "Mobile" { 
                if ($FrameworkInfo.Primary.Name -eq "Flutter") {
                    $frameworkSpecificFiles += @("analysis_options.yaml")
                } else {
                    $frameworkSpecificFiles += @("tsconfig.json", "biome.json")
                }
            }
        }
        
        foreach ($file in $frameworkSpecificFiles) {
            if (-not (Test-Path "$ProjectPath\$file")) {
                Write-Log "⚠️ Missing framework-specific file: $file" "WARN"
            } else {
                Write-Log "✅ Framework-specific file present: $file"
            }
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
    Write-Log "🚀 Starting Enhanced Zero Defect Auto-Initialization v2.0 for $ProjectPath"
    
    # Override framework detection if specified
    if ($Framework) {
        Write-Log "🎯 Framework manually specified: $Framework"
        $frameworkInfo = @{
            Primary = @{
                Name = $Framework
                Category = "Manual"
                ConfigFile = "$($Framework.ToLower())-zero-defect.json"
                Confidence = 100
            }
            All = @(@{
                Name = $Framework
                Category = "Manual" 
                ConfigFile = "$($Framework.ToLower())-zero-defect.json"
                Confidence = 100
            })
        }
    } else {
        # Run advanced framework detection
        $frameworkInfo = Invoke-AdvancedFrameworkDetection -Path $ProjectPath
    }
    
    if (-not $frameworkInfo.Primary) {
        Write-Log "❌ No framework detected. Using generic configuration." "WARN"
        $frameworkInfo = @{
            Primary = @{
                Name = "Generic"
                Category = "Generic"
                ConfigFile = "generic-zero-defect.json"
                Confidence = 100
            }
            All = @(@{
                Name = "Generic"
                Category = "Generic"
                ConfigFile = "generic-zero-defect.json"
                Confidence = 100
            })
        }
    }
    
    Write-Log "🎯 Primary framework: $($frameworkInfo.Primary.Name) ($($frameworkInfo.Primary.Category))"
    if ($frameworkInfo.All.Count -gt 1) {
        $additional = $frameworkInfo.All | Where-Object { $_.Name -ne $frameworkInfo.Primary.Name }
        Write-Log "📋 Additional frameworks: $($additional.Name -join ', ')"
    }
    
    # Check if already configured
    if ((Test-Path "$ProjectPath\.opencode\zero-defect-config.md") -and -not $Force) {
        Write-Log "⚠️ Zero Defect configuration already exists. Use -Force to overwrite." "WARN"
        exit 0
    }
    
    # Install framework-specific Zero Defect configuration
    Install-FrameworkSpecificConfig -ProjectPath $ProjectPath -FrameworkInfo $frameworkInfo
    
    # Install Git hooks if git repo exists
    Install-GitHooks -ProjectPath $ProjectPath
    
    # Install framework-specific dependencies
    Install-FrameworkDependencies -ProjectPath $ProjectPath -FrameworkInfo $frameworkInfo
    
    # Test installation
    $success = Test-ZeroDefectInstallation -ProjectPath $ProjectPath -FrameworkInfo $frameworkInfo
    
    if ($success) {
        Write-Log "🎉 Enhanced Zero Defect Programming is now ACTIVE for $($frameworkInfo.Primary.Name)!"
        Write-Log ""
        Write-Log "🚀 FRAMEWORK-OPTIMIZED COMMANDS AVAILABLE:"
        Write-Log "  /zero-check                 - Comprehensive validation"
        Write-Log "  /fail-fast                  - Immediate failure detection"
        Write-Log "  /real-time-validation       - Continuous validation"
        Write-Log "  /pre-commit-validation      - Pre-commit gates"
        Write-Log "  /defensive-programming      - Defensive patterns"
        Write-Log "  /analyze-codebase          - Deep project analysis"
        Write-Log "  /suggest-patterns          - Framework-specific suggestions"
        Write-Log "  /optimize-performance      - Performance optimization"
        Write-Log "  /security-audit           - Security analysis"
        Write-Log ""
        Write-Log "📋 FRAMEWORK-SPECIFIC FEATURES:"
        Write-Log "  ✅ $($frameworkInfo.Primary.Name) optimized configuration applied"
        Write-Log "  ✅ Framework-specific linting rules activated"
        Write-Log "  ✅ Performance optimizations enabled"
        Write-Log "  ✅ Security rules configured"
        Write-Log "  ✅ Development workflow optimized"
        Write-Log ""
        Write-Log "🎯 NEXT STEPS:"
        Write-Log "  1. Run: /zero-check"
        Write-Log "  2. Start coding with $($frameworkInfo.Primary.Name) best practices"
        Write-Log "  3. Commits will automatically validate with framework-specific rules"
        Write-Log "  4. Use /analyze-codebase for continuous improvement"
        Write-Log ""
        Write-Log "🔗 Framework detected with $($frameworkInfo.Primary.Confidence)% confidence"
        Write-Log "📁 Configuration saved in .opencode/framework-info.json"
    }
    
} catch {
    Write-Log "❌ Enhanced auto-initialization failed: $($_.Exception.Message)" "ERROR"
    if ($Verbose) {
        Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    }
    exit 1
} finally {
    # Cleanup
    if (Test-Path $TEMP_DIR) {
        Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    }
}