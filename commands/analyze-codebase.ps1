# ==========================================
# /analyze-codebase - Intelligent Codebase Analysis
# AI-powered project analysis with actionable insights
# ==========================================

param(
    [string]$ProjectPath = ".",
    [switch]$Deep = $false,
    [switch]$Security = $false,
    [switch]$Performance = $false,
    [string]$Focus = "",
    [switch]$JsonOutput = $false
)

$ErrorActionPreference = "Stop"

# Analysis Configuration
$ANALYSIS_RESULTS = @{
    framework = ""
    codeQuality = @{}
    architecture = @{}
    security = @{}
    performance = @{}
    suggestions = @()
    issues = @()
    metrics = @{}
}

function Write-AnalysisLog {
    param([string]$Message, [string]$Level = "INFO")
    if (-not $JsonOutput) {
        $color = switch ($Level) {
            "SUCCESS" { "Green" }
            "WARNING" { "Yellow" }
            "ERROR" { "Red" }
            "INSIGHT" { "Cyan" }
            default { "White" }
        }
        Write-Host $Message -ForegroundColor $color
    }
}

function Get-ProjectFramework {
    param([string]$Path)
    
    # Quick framework detection
    if (Test-Path "$Path\next.config.js") { return "Next.js" }
    if (Test-Path "$Path\angular.json") { return "Angular" }
    if (Test-Path "$Path\vue.config.js") { return "Vue.js" }
    if (Test-Path "$Path\svelte.config.js") { return "Svelte" }
    if (Test-Path "$Path\astro.config.mjs") { return "Astro" }
    if (Test-Path "$Path\pubspec.yaml") { return "Flutter" }
    
    # Check package.json for framework hints
    if (Test-Path "$Path\package.json") {
        $packageContent = Get-Content "$Path\package.json" | ConvertFrom-Json
        if ($packageContent.dependencies) {
            if ($packageContent.dependencies."react") { return "React" }
            if ($packageContent.dependencies."express") { return "Express.js" }
            if ($packageContent.dependencies."@nestjs/core") { return "NestJS" }
        }
    }
    
    return "Generic"
}

function Analyze-CodeQuality {
    param([string]$Path, [string]$Framework)
    
    Write-AnalysisLog "🔍 Analyzing code quality patterns..." "INFO"
    
    $quality = @{
        lintingSetup = $false
        typescriptUsage = $false
        testCoverage = 0
        codeSmells = @()
        strengths = @()
    }
    
    # Check for linting setup
    if ((Test-Path "$Path\biome.json") -or (Test-Path "$Path\.eslintrc*") -or (Test-Path "$Path\eslint.config.js")) {
        $quality.lintingSetup = $true
        $quality.strengths += "Linting configured properly"
    } else {
        $quality.codeSmells += "No linting configuration found"
    }
    
    # Check TypeScript usage
    if (Test-Path "$Path\tsconfig.json") {
        $quality.typescriptUsage = $true
        $quality.strengths += "TypeScript configured"
        
        # Analyze TypeScript configuration
        try {
            $tsconfig = Get-Content "$Path\tsconfig.json" | ConvertFrom-Json
            if ($tsconfig.compilerOptions.strict) {
                $quality.strengths += "Strict TypeScript mode enabled"
            } else {
                $quality.codeSmells += "TypeScript strict mode is disabled"
            }
        } catch {
            $quality.codeSmells += "Invalid tsconfig.json structure"
        }
    } else {
        $quality.codeSmells += "No TypeScript configuration found"
    }
    
    # Check for testing setup
    if (Test-Path "$Path\package.json") {
        $packageContent = Get-Content "$Path\package.json" | ConvertFrom-Json
        $testFrameworks = @("vitest", "jest", "mocha", "cypress", "playwright")
        $hasTests = $false
        
        foreach ($framework in $testFrameworks) {
            if ($packageContent.devDependencies.$framework -or $packageContent.dependencies.$framework) {
                $hasTests = $true
                $quality.strengths += "Testing framework configured: $framework"
                break
            }
        }
        
        if (-not $hasTests) {
            $quality.codeSmells += "No testing framework detected"
        }
    }
    
    # Scan for common code smells
    $codeFiles = Get-ChildItem -Path $Path -Recurse -Include "*.ts", "*.tsx", "*.js", "*.jsx" -ErrorAction SilentlyContinue | Select-Object -First 20
    
    foreach ($file in $codeFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            # Check for console.log
            if ($content -match "console\.log") {
                $quality.codeSmells += "console.log found in $($file.Name) - should be removed for production"
            }
            
            # Check for any type usage
            if ($content -match ": any\b" -or $content -match "as any\b") {
                $quality.codeSmells += "TypeScript 'any' type usage in $($file.Name) - reduces type safety"
            }
            
            # Check for TODO comments
            if ($content -match "TODO|FIXME|HACK") {
                $quality.codeSmells += "TODO/FIXME comments in $($file.Name) - technical debt indicators"
            }
            
            # Check for long functions (approximation)
            $lines = $content -split "`n"
            if ($lines.Count -gt 200) {
                $quality.codeSmells += "$($file.Name) is very long ($($lines.Count) lines) - consider refactoring"
            }
        }
    }
    
    return $quality
}

function Analyze-Architecture {
    param([string]$Path, [string]$Framework)
    
    Write-AnalysisLog "🏗️ Analyzing project architecture..." "INFO"
    
    $architecture = @{
        structure = @{}
        patterns = @()
        antiPatterns = @()
        suggestions = @()
    }
    
    # Analyze folder structure
    $directories = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue
    $architecture.structure = @{
        hasSource = (Test-Path "$Path\src")
        hasComponents = (Test-Path "$Path\src\components") -or (Test-Path "$Path\components")
        hasUtils = (Test-Path "$Path\src\utils") -or (Test-Path "$Path\utils") -or (Test-Path "$Path\lib")
        hasTypes = (Test-Path "$Path\src\types") -or (Test-Path "$Path\types")
        hasTests = (Test-Path "$Path\src\__tests__") -or (Test-Path "$Path\tests") -or (Test-Path "$Path\__tests__")
        hasConfig = (Test-Path "$Path\config")
    }
    
    # Framework-specific analysis
    switch ($Framework) {
        "Next.js" {
            if (Test-Path "$Path\app") {
                $architecture.patterns += "Using Next.js App Router (recommended)"
            } elseif (Test-Path "$Path\pages") {
                $architecture.antiPatterns += "Using Pages Router - consider migrating to App Router"
            }
            
            if (Test-Path "$Path\public") {
                $architecture.patterns += "Static assets properly organized in public folder"
            }
        }
        
        "React" {
            if ($architecture.structure.hasComponents) {
                $architecture.patterns += "Components properly organized in dedicated folder"
            } else {
                $architecture.suggestions += "Consider creating a components folder for better organization"
            }
        }
        
        "Express.js" {
            if (Test-Path "$Path\src\routes") {
                $architecture.patterns += "Routes properly organized"
            } else {
                $architecture.suggestions += "Consider organizing routes in a dedicated folder"
            }
            
            if (Test-Path "$Path\src\middleware") {
                $architecture.patterns += "Middleware properly organized"
            }
        }
    }
    
    # General architecture analysis
    if (-not $architecture.structure.hasSource) {
        $architecture.antiPatterns += "No src folder - consider organizing source code in src/ directory"
    }
    
    if (-not $architecture.structure.hasTests) {
        $architecture.antiPatterns += "No test directory structure found"
    }
    
    if ($architecture.structure.hasTypes) {
        $architecture.patterns += "Type definitions properly organized"
    }
    
    return $architecture
}

function Analyze-Security {
    param([string]$Path)
    
    Write-AnalysisLog "🛡️ Analyzing security patterns..." "INFO"
    
    $security = @{
        issues = @()
        strengths = @()
        recommendations = @()
    }
    
    # Check for environment variables handling
    if (Test-Path "$Path\.env") {
        $envContent = Get-Content "$Path\.env" -ErrorAction SilentlyContinue
        foreach ($line in $envContent) {
            if ($line -match "(password|secret|key|token).*=.*[^#]" -and $line -notmatch "^#") {
                $security.issues += "Potential sensitive data in .env file: $line"
            }
        }
    }
    
    if (Test-Path "$Path\.env.example") {
        $security.strengths += ".env.example file provides good template"
    } else {
        $security.recommendations += "Create .env.example file for environment variable documentation"
    }
    
    # Check package.json for security-related packages
    if (Test-Path "$Path\package.json") {
        $packageContent = Get-Content "$Path\package.json" | ConvertFrom-Json
        
        $securityPackages = @("helmet", "cors", "express-rate-limit", "bcrypt", "jsonwebtoken")
        foreach ($package in $securityPackages) {
            if ($packageContent.dependencies.$package) {
                $security.strengths += "Security package detected: $package"
            }
        }
        
        # Check for outdated dependencies (basic check)
        if ($packageContent.dependencies -and $packageContent.dependencies.Count -gt 10) {
            $security.recommendations += "Consider running 'npm audit' to check for vulnerable dependencies"
        }
    }
    
    # Scan for common security anti-patterns
    $codeFiles = Get-ChildItem -Path $Path -Recurse -Include "*.ts", "*.tsx", "*.js", "*.jsx" -ErrorAction SilentlyContinue | Select-Object -First 15
    
    foreach ($file in $codeFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            # Check for dangerous patterns
            if ($content -match "eval\(") {
                $security.issues += "eval() usage detected in $($file.Name) - potential XSS risk"
            }
            
            if ($content -match "innerHTML\s*=") {
                $security.issues += "innerHTML usage in $($file.Name) - consider using textContent or proper React patterns"
            }
            
            if ($content -match "dangerouslySetInnerHTML") {
                $security.issues += "dangerouslySetInnerHTML usage in $($file.Name) - ensure input is sanitized"
            }
            
            # Check for hardcoded secrets (basic patterns)
            if ($content -match "(api_key|apikey|secret|password|token)\s*[:=]\s*['\"][^'\"\s]{10,}['\"]") {
                $security.issues += "Potential hardcoded secret in $($file.Name)"
            }
        }
    }
    
    return $security
}

function Analyze-Performance {
    param([string]$Path, [string]$Framework)
    
    Write-AnalysisLog "⚡ Analyzing performance patterns..." "INFO"
    
    $performance = @{
        optimizations = @()
        bottlenecks = @()
        recommendations = @()
        metrics = @{}
    }
    
    # Analyze bundle and build configuration
    if (Test-Path "$Path\package.json") {
        $packageContent = Get-Content "$Path\package.json" | ConvertFrom-Json
        
        # Check for performance-related packages
        $perfPackages = @("react-memo", "usememo", "web-vitals", "@tanstack/react-query")
        foreach ($package in $perfPackages) {
            if ($packageContent.dependencies.$package) {
                $performance.optimizations += "Performance package detected: $package"
            }
        }
    }
    
    # Framework-specific performance analysis
    switch ($Framework) {
        "Next.js" {
            if (Test-Path "$Path\next.config.js") {
                $nextConfig = Get-Content "$Path\next.config.js" -Raw
                if ($nextConfig -match "experimental.*appDir") {
                    $performance.optimizations += "Using App Router for better performance"
                }
                if ($nextConfig -match "images.*domains") {
                    $performance.optimizations += "Image optimization configured"
                }
            }
            
            # Check for proper image usage
            $jsxFiles = Get-ChildItem -Path $Path -Recurse -Include "*.tsx", "*.jsx" -ErrorAction SilentlyContinue | Select-Object -First 10
            foreach ($file in $jsxFiles) {
                $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
                if ($content -match "<img\s" -and $content -notmatch "next/image") {
                    $performance.bottlenecks += "Using <img> instead of Next.js Image component in $($file.Name)"
                }
            }
        }
        
        "React" {
            $reactFiles = Get-ChildItem -Path $Path -Recurse -Include "*.tsx", "*.jsx" -ErrorAction SilentlyContinue | Select-Object -First 10
            foreach ($file in $reactFiles) {
                $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
                if ($content) {
                    # Check for potential performance issues
                    if ($content -match "useEffect\(\s*\(\)\s*=>\s*{[^}]*}\s*,\s*\[\s*\]\s*\)") {
                        $performance.bottlenecks += "Empty dependency array in useEffect in $($file.Name) - consider if this is intentional"
                    }
                    
                    # Check for React.memo usage
                    if ($content -match "React\.memo\(|memo\(") {
                        $performance.optimizations += "React.memo optimization found in $($file.Name)"
                    }
                    
                    # Check for useMemo/useCallback
                    if ($content -match "useMemo\(|useCallback\(") {
                        $performance.optimizations += "Performance hooks (useMemo/useCallback) found in $($file.Name)"
                    }
                }
            }
        }
    }
    
    # Check bundle size indicators
    if (Test-Path "$Path\node_modules") {
        $nodeModulesSize = (Get-ChildItem -Path "$Path\node_modules" -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if ($nodeModulesSize -gt 500MB) {
            $performance.bottlenecks += "Large node_modules folder ($(Math]::Round($nodeModulesSize / 1MB, 2))MB) - consider dependency cleanup"
        }
    }
    
    return $performance
}

function Generate-Suggestions {
    param($Analysis)
    
    $suggestions = @()
    
    # Code quality suggestions
    if ($Analysis.codeQuality.codeSmells.Count -gt 0) {
        $suggestions += @{
            type = "Code Quality"
            priority = "High"
            action = "Fix code smells: $($Analysis.codeQuality.codeSmells -join '; ')"
        }
    }
    
    if (-not $Analysis.codeQuality.lintingSetup) {
        $suggestions += @{
            type = "Tooling"
            priority = "High"
            action = "Setup Biome or ESLint for code quality enforcement"
        }
    }
    
    # Security suggestions
    if ($Analysis.security.issues.Count -gt 0) {
        $suggestions += @{
            type = "Security"
            priority = "Critical"
            action = "Address security issues: $($Analysis.security.issues -join '; ')"
        }
    }
    
    # Performance suggestions
    if ($Analysis.performance.bottlenecks.Count -gt 0) {
        $suggestions += @{
            type = "Performance"
            priority = "Medium"
            action = "Optimize performance bottlenecks: $($Analysis.performance.bottlenecks -join '; ')"
        }
    }
    
    # Architecture suggestions
    if ($Analysis.architecture.antiPatterns.Count -gt 0) {
        $suggestions += @{
            type = "Architecture"
            priority = "Medium"
            action = "Improve architecture: $($Analysis.architecture.antiPatterns -join '; ')"
        }
    }
    
    return $suggestions
}

function Show-AnalysisResults {
    param($Analysis)
    
    if ($JsonOutput) {
        $Analysis | ConvertTo-Json -Depth 10
        return
    }
    
    Write-AnalysisLog "`n🎯 CODEBASE ANALYSIS RESULTS" "INSIGHT"
    Write-AnalysisLog "================================" "INSIGHT"
    
    Write-AnalysisLog "`n📊 PROJECT OVERVIEW" "INFO"
    Write-AnalysisLog "Framework: $($Analysis.framework)" "INFO"
    
    # Code Quality Results
    Write-AnalysisLog "`n🔧 CODE QUALITY" "INFO"
    if ($Analysis.codeQuality.strengths.Count -gt 0) {
        foreach ($strength in $Analysis.codeQuality.strengths) {
            Write-AnalysisLog "  ✅ $strength" "SUCCESS"
        }
    }
    
    if ($Analysis.codeQuality.codeSmells.Count -gt 0) {
        foreach ($smell in $Analysis.codeQuality.codeSmells) {
            Write-AnalysisLog "  ⚠️ $smell" "WARNING"
        }
    }
    
    # Architecture Results
    Write-AnalysisLog "`n🏗️ ARCHITECTURE" "INFO"
    if ($Analysis.architecture.patterns.Count -gt 0) {
        foreach ($pattern in $Analysis.architecture.patterns) {
            Write-AnalysisLog "  ✅ $pattern" "SUCCESS"
        }
    }
    
    if ($Analysis.architecture.antiPatterns.Count -gt 0) {
        foreach ($antiPattern in $Analysis.architecture.antiPatterns) {
            Write-AnalysisLog "  ❌ $antiPattern" "WARNING"
        }
    }
    
    # Security Results
    Write-AnalysisLog "`n🛡️ SECURITY" "INFO"
    if ($Analysis.security.strengths.Count -gt 0) {
        foreach ($strength in $Analysis.security.strengths) {
            Write-AnalysisLog "  ✅ $strength" "SUCCESS"
        }
    }
    
    if ($Analysis.security.issues.Count -gt 0) {
        foreach ($issue in $Analysis.security.issues) {
            Write-AnalysisLog "  🚨 $issue" "ERROR"
        }
    }
    
    # Performance Results
    Write-AnalysisLog "`n⚡ PERFORMANCE" "INFO"
    if ($Analysis.performance.optimizations.Count -gt 0) {
        foreach ($optimization in $Analysis.performance.optimizations) {
            Write-AnalysisLog "  ✅ $optimization" "SUCCESS"
        }
    }
    
    if ($Analysis.performance.bottlenecks.Count -gt 0) {
        foreach ($bottleneck in $Analysis.performance.bottlenecks) {
            Write-AnalysisLog "  🐌 $bottleneck" "WARNING"
        }
    }
    
    # Suggestions
    Write-AnalysisLog "`n💡 ACTIONABLE SUGGESTIONS" "INSIGHT"
    if ($Analysis.suggestions.Count -gt 0) {
        foreach ($suggestion in $Analysis.suggestions) {
            $priorityIcon = switch ($suggestion.priority) {
                "Critical" { "🚨" }
                "High" { "⚠️" }
                "Medium" { "💡" }
                "Low" { "📝" }
            }
            Write-AnalysisLog "  $priorityIcon [$($suggestion.type)] $($suggestion.action)" "INSIGHT"
        }
    } else {
        Write-AnalysisLog "  🎉 No critical issues found! Your codebase is in great shape." "SUCCESS"
    }
    
    Write-AnalysisLog "`n🎯 NEXT STEPS" "INSIGHT"
    Write-AnalysisLog "  1. Address critical and high priority issues first" "INFO"
    Write-AnalysisLog "  2. Run /optimize-performance for specific performance improvements" "INFO"
    Write-AnalysisLog "  3. Run /security-audit for deeper security analysis" "INFO"
    Write-AnalysisLog "  4. Use /suggest-patterns for framework-specific best practices" "INFO"
}

# Main execution
try {
    Write-AnalysisLog "🚀 Starting intelligent codebase analysis..." "INFO"
    
    $framework = Get-ProjectFramework -Path $ProjectPath
    $ANALYSIS_RESULTS.framework = $framework
    
    Write-AnalysisLog "Framework detected: $framework" "INFO"
    
    # Run different analysis based on focus or run all
    if ($Focus) {
        switch ($Focus.ToLower()) {
            "quality" { 
                $ANALYSIS_RESULTS.codeQuality = Analyze-CodeQuality -Path $ProjectPath -Framework $framework
            }
            "architecture" { 
                $ANALYSIS_RESULTS.architecture = Analyze-Architecture -Path $ProjectPath -Framework $framework
            }
            "security" { 
                $ANALYSIS_RESULTS.security = Analyze-Security -Path $ProjectPath
            }
            "performance" { 
                $ANALYSIS_RESULTS.performance = Analyze-Performance -Path $ProjectPath -Framework $framework
            }
        }
    } else {
        # Run comprehensive analysis
        $ANALYSIS_RESULTS.codeQuality = Analyze-CodeQuality -Path $ProjectPath -Framework $framework
        $ANALYSIS_RESULTS.architecture = Analyze-Architecture -Path $ProjectPath -Framework $framework
        
        if ($Security -or $Deep) {
            $ANALYSIS_RESULTS.security = Analyze-Security -Path $ProjectPath
        }
        
        if ($Performance -or $Deep) {
            $ANALYSIS_RESULTS.performance = Analyze-Performance -Path $ProjectPath -Framework $framework
        }
    }
    
    # Generate actionable suggestions
    $ANALYSIS_RESULTS.suggestions = Generate-Suggestions -Analysis $ANALYSIS_RESULTS
    
    # Show results
    Show-AnalysisResults -Analysis $ANALYSIS_RESULTS
    
    Write-AnalysisLog "`n✅ Analysis completed successfully!" "SUCCESS"
    
} catch {
    Write-AnalysisLog "❌ Analysis failed: $($_.Exception.Message)" "ERROR"
    exit 1
}