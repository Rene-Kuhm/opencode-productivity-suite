# 🚀 Smart Framework Tailwind Detection System
# Automatically determines if a framework needs Tailwind CSS

param(
    [string]$ProjectPath = ".",
    [switch]$JsonOutput = $false
)

# Framework UI Classification
$UI_FRAMEWORKS = @{
    # Frontend Frameworks (Always need Tailwind)
    "Next.js" = @{
        requiresTailwind = $true
        reason = "Full-stack React framework with heavy UI focus"
        confidence = 100
    }
    "React" = @{
        requiresTailwind = $true  
        reason = "UI component library, perfect for utility-first CSS"
        confidence = 95
    }
    "Vue.js" = @{
        requiresTailwind = $true
        reason = "Progressive UI framework, excellent Tailwind integration"
        confidence = 95
    }
    "Angular" = @{
        requiresTailwind = $true
        reason = "Component-based UI framework, benefits from Tailwind"
        confidence = 90
    }
    "Svelte" = @{
        requiresTailwind = $true
        reason = "Modern UI framework with great Tailwind support"
        confidence = 95
    }
    "Astro" = @{
        requiresTailwind = $true
        reason = "Static site generator focused on performance and UI"
        confidence = 90
    }
    "Qwik" = @{
        requiresTailwind = $true
        reason = "Performance-focused UI framework"
        confidence = 85
    }
    "SolidJS" = @{
        requiresTailwind = $true
        reason = "Reactive UI framework"
        confidence = 85
    }
    "Nuxt" = @{
        requiresTailwind = $true
        reason = "Vue.js framework with UI focus"
        confidence = 90
    }
    "SvelteKit" = @{
        requiresTailwind = $true
        reason = "Full-stack Svelte framework"
        confidence = 90
    }
    
    # Mobile/Desktop UI Frameworks
    "React Native" = @{
        requiresTailwind = $false  # Uses different styling system
        reason = "Mobile framework with native styling"
        confidence = 100
    }
    "Expo" = @{
        requiresTailwind = $false  # Uses React Native styling
        reason = "React Native framework with native components"  
        confidence = 100
    }
    "Flutter" = @{
        requiresTailwind = $false  # Uses Dart and Material/Cupertino
        reason = "Uses Dart with Material/Cupertino design systems"
        confidence = 100
    }
    "Electron" = @{
        requiresTailwind = $true   # Web-based desktop apps
        reason = "Web-based desktop apps benefit from CSS frameworks"
        confidence = 80
    }
    "Tauri" = @{
        requiresTailwind = $true   # Web-based desktop apps
        reason = "Rust desktop apps with web frontend"
        confidence = 80
    }
    
    # Backend Frameworks (No Tailwind needed)
    "Express.js" = @{
        requiresTailwind = $false
        reason = "Backend API framework, no UI components"
        confidence = 100
    }
    "NestJS" = @{
        requiresTailwind = $false
        reason = "Backend service framework"
        confidence = 100
    }
    "FastAPI" = @{
        requiresTailwind = $false
        reason = "Python backend API framework"
        confidence = 100
    }
    "Django" = @{
        requiresTailwind = $false  # Unless specifically frontend-focused
        reason = "Backend framework (unless template-heavy)"
        confidence = 85
    }
    "Spring Boot" = @{
        requiresTailwind = $false
        reason = "Java backend framework"
        confidence = 100
    }
    "Laravel" = @{
        requiresTailwind = $false  # Unless specifically frontend-focused
        reason = "PHP backend framework (unless Blade/Inertia heavy)"
        confidence = 85
    }
}

function Test-FrameworkTailwindNeed {
    param([string]$ProjectPath)
    
    # Import framework detection
    $detectionScript = Join-Path (Split-Path $PSScriptRoot -Parent) "automation\advanced-framework-detection.ps1"
    if (Test-Path $detectionScript) {
        . $detectionScript
        $frameworks = Get-ProjectFrameworks -ProjectPath $ProjectPath
        
        if ($frameworks.Count -eq 0) {
            return @{
                needsTailwind = $false
                reason = "No framework detected"
                confidence = 0
                frameworks = @()
            }
        }
        
        $primaryFramework = $frameworks | Sort-Object Confidence -Descending | Select-Object -First 1
        $frameworkName = $primaryFramework.Name
        
        if ($UI_FRAMEWORKS.ContainsKey($frameworkName)) {
            $uiInfo = $UI_FRAMEWORKS[$frameworkName]
            
            return @{
                needsTailwind = $uiInfo.requiresTailwind
                reason = $uiInfo.reason
                confidence = $uiInfo.confidence
                framework = $frameworkName
                category = $primaryFramework.Category
                allFrameworks = $frameworks
                tailwindRecommendation = if ($uiInfo.requiresTailwind) { 
                    "Auto-install Tailwind CSS v4.1+ with hacker configuration" 
                } else { 
                    "Tailwind CSS not recommended for this framework type" 
                }
            }
        } else {
            # Unknown framework - make smart guess based on category
            $needsTailwind = $primaryFramework.Category -eq "Frontend"
            
            return @{
                needsTailwind = $needsTailwind
                reason = "Unknown framework - decision based on category: $($primaryFramework.Category)"
                confidence = 60
                framework = $frameworkName
                category = $primaryFramework.Category  
                allFrameworks = $frameworks
                tailwindRecommendation = if ($needsTailwind) {
                    "Consider Tailwind CSS for UI development"
                } else {
                    "Tailwind CSS probably not needed"
                }
            }
        }
    } else {
        Write-Error "Framework detection script not found: $detectionScript"
        return $null
    }
}

function Get-TailwindRecommendations {
    param([object]$Analysis)
    
    if (-not $Analysis.needsTailwind) {
        return @{
            install = $false
            message = "✅ Tailwind CSS not needed for $($Analysis.framework)"
            alternative = "Focus on backend/API development tools instead"
        }
    }
    
    $recommendations = @{
        install = $true
        message = "🚀 Auto-installing Tailwind CSS v4.1+ for $($Analysis.framework)"
        features = @(
            "CSS-first configuration (v4 native)",
            "Container queries for responsive design", 
            "color-mix() functions for dynamic colors",
            "Glass morphism & neomorphism utilities",
            "Ultra-performance optimizations",
            "Modern CSS cascade layers"
        )
        commands = @{
            "Manual Install" = "tailwind-hacker --Action install"
            "Analyze Project" = "tailwind-hacker --Action analyze"  
            "Generate Examples" = "tailwind-hacker --Action examples"
        }
    }
    
    # Framework-specific recommendations
    switch ($Analysis.framework) {
        "Next.js" { 
            $recommendations.specificTips = @(
                "Perfect integration with App Router",
                "shadcn/ui components auto-configured",
                "SSR-optimized CSS generation"
            )
        }
        "React" {
            $recommendations.specificTips = @(
                "Material-UI (MUI) + Tailwind combination",
                "Component library integration",
                "Vite optimization included"
            )
        }
        "Vue.js" {
            $recommendations.specificTips = @(
                "Vuetify + Tailwind compatibility",
                "Composition API reactive styling",
                "Nuxt.js ready configuration"
            )
        }
        "Angular" {
            $recommendations.specificTips = @(
                "Angular Material + Tailwind setup",
                "Component scoping optimization",
                "CLI integration ready"
            )
        }
    }
    
    return $recommendations
}

# Main execution
$analysis = Test-FrameworkTailwindNeed -ProjectPath $ProjectPath

if (-not $analysis) {
    Write-Error "❌ Failed to analyze project for Tailwind compatibility"
    exit 1
}

$recommendations = Get-TailwindRecommendations -Analysis $analysis

if ($JsonOutput) {
    @{
        analysis = $analysis
        recommendations = $recommendations
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    } | ConvertTo-Json -Depth 10
} else {
    Write-Host ""
    Write-Host "🔍 Smart Framework Tailwind Detection" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Gray
    Write-Host "📁 Project: $ProjectPath" -ForegroundColor White
    Write-Host "🎯 Framework: $($analysis.framework)" -ForegroundColor White
    Write-Host "📂 Category: $($analysis.category)" -ForegroundColor White
    Write-Host "🎨 Needs Tailwind: $(if ($analysis.needsTailwind) { '✅ YES' } else { '❌ NO' })" -ForegroundColor $(if ($analysis.needsTailwind) { 'Green' } else { 'Red' })
    Write-Host "💭 Reason: $($analysis.reason)" -ForegroundColor Gray
    Write-Host "📊 Confidence: $($analysis.confidence)%" -ForegroundColor White
    
    Write-Host ""
    Write-Host "💡 Recommendation:" -ForegroundColor Yellow
    Write-Host "  $($recommendations.message)" -ForegroundColor White
    
    if ($recommendations.install) {
        Write-Host ""
        Write-Host "🚀 Features Included:" -ForegroundColor Cyan
        $recommendations.features | ForEach-Object { Write-Host "  • $_" -ForegroundColor White }
        
        if ($recommendations.specificTips) {
            Write-Host ""
            Write-Host "🎯 $($analysis.framework) Specific:" -ForegroundColor Magenta
            $recommendations.specificTips | ForEach-Object { Write-Host "  • $_" -ForegroundColor White }
        }
        
        Write-Host ""
        Write-Host "⚡ Available Commands:" -ForegroundColor Cyan
        $recommendations.commands.GetEnumerator() | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor White
        }
    } else {
        Write-Host "  💡 $($recommendations.alternative)" -ForegroundColor Gray
    }
    
    Write-Host ""
}

return $analysis