# 🚀 Tailwind CSS Hacker Command - Ultra-Advanced Tailwind Management
# Command: /tailwind-hacker

param(
    [string]$ProjectPath = ".",
    [string]$Action = "analyze",
    [switch]$Upgrade = $false,
    [switch]$Force = $false,
    [switch]$JsonOutput = $false
)

# Import the Tailwind Hacker System
$tailwindSystemPath = Join-Path (Split-Path $PSScriptRoot -Parent) "automation\tailwind-hacker-system.ps1"

if (-not (Test-Path $tailwindSystemPath)) {
    Write-Error "❌ Tailwind Hacker System not found: $tailwindSystemPath"
    exit 1
}

. $tailwindSystemPath

# Hacker-level Tailwind Analysis
function Analyze-TailwindProject {
    param([string]$ProjectPath)
    
    Write-Host "🔍 Analyzing Tailwind CSS setup with hacker-level insights..." -ForegroundColor Cyan
    
    $status = Test-TailwindVersion -ProjectPath $ProjectPath
    $analysis = @{
        status = $status
        recommendations = @()
        hackerFeatures = @()
        performance = @{}
        modernFeatures = @{}
    }
    
    # Performance Analysis
    if ($status.hasTailwind) {
        $cssFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "*.css" | Where-Object { $_.Length -gt 100KB }
        $analysis.performance = @{
            largeCSSFiles = $cssFiles.Count
            totalCSSSize = ($cssFiles | Measure-Object -Property Length -Sum).Sum
            needsOptimization = $cssFiles.Count -gt 2
        }
        
        # Check for modern CSS features
        $configPath = if ($status.configExists) { Join-Path $ProjectPath $status.configType } else { $null }
        if ($configPath -and (Test-Path $configPath)) {
            $configContent = Get-Content $configPath -Raw
            
            $analysis.modernFeatures = @{
                hasContainerQueries = $configContent -match "container"
                hasColorMix = $configContent -match "color-mix"
                hasCascadeLayers = $configContent -match "@layer"
                hasPropertyAPI = $configContent -match "@property"
                hasStartingStyle = $configContent -match "@starting-style"
                isDynamicUtilities = $configContent -match "theme\("
            }
        }
        
        # Generate recommendations
        if (-not $status.isLatest) {
            $analysis.recommendations += "🚀 Upgrade to Tailwind CSS v4.1+ for 5x faster builds and modern CSS features"
        }
        
        if (-not $analysis.modernFeatures.hasContainerQueries) {
            $analysis.recommendations += "📱 Add container queries for responsive component design"
        }
        
        if (-not $analysis.modernFeatures.hasColorMix) {
            $analysis.recommendations += "🌈 Implement color-mix() functions for dynamic color systems"
        }
        
        if ($analysis.performance.needsOptimization) {
            $analysis.recommendations += "⚡ CSS optimization needed - $(($analysis.performance.totalCSSSize / 1MB).ToString('F1'))MB total"
        }
        
        # Hacker features available
        $analysis.hackerFeatures = @(
            "🔮 Glass Morphism Utilities",
            "💎 Neomorphism Components", 
            "🌈 Dynamic Gradient System",
            "📱 Container Query Utilities",
            "🛡️ Safe Area Mobile Support",
            "⚡ Advanced Animation System",
            "🎨 CSS-first Configuration",
            "🚀 Ultra-Performance Optimization"
        )
    } else {
        $analysis.recommendations += "📦 Install Tailwind CSS v4.1+ with hacker configuration"
        $analysis.recommendations += "🎯 Enable all modern CSS features and optimizations"
    }
    
    return $analysis
}

# Main command execution
switch ($Action.ToLower()) {
    "analyze" {
        $analysis = Analyze-TailwindProject -ProjectPath $ProjectPath
        
        if ($JsonOutput) {
            $analysis | ConvertTo-Json -Depth 10
        } else {
            Write-Host ""
            Write-Host "🚀 Tailwind CSS Hacker Analysis Report" -ForegroundColor Cyan
            Write-Host "=" * 50 -ForegroundColor Gray
            
            if ($analysis.status.hasTailwind) {
                Write-Host "📦 Current Version: $($analysis.status.currentVersion)" -ForegroundColor White
                Write-Host "✅ Configuration: $($analysis.status.configType)" -ForegroundColor Green
                
                if ($analysis.status.isLatest) {
                    Write-Host "🎯 Status: Up to date (v4.1+)" -ForegroundColor Green
                } else {
                    Write-Host "⚠️  Status: Needs upgrade" -ForegroundColor Yellow
                }
            } else {
                Write-Host "❌ Tailwind CSS not detected" -ForegroundColor Red
            }
            
            Write-Host ""
            Write-Host "🔍 Modern CSS Features:" -ForegroundColor Cyan
            $analysis.modernFeatures.GetEnumerator() | ForEach-Object {
                $icon = if ($_.Value) { "✅" } else { "❌" }
                Write-Host "  $icon $($_.Key)" -ForegroundColor White
            }
            
            Write-Host ""
            Write-Host "⚡ Performance Analysis:" -ForegroundColor Cyan
            Write-Host "  📁 Large CSS Files: $($analysis.performance.largeCSSFiles)" -ForegroundColor White
            if ($analysis.performance.totalCSSSize -gt 0) {
                Write-Host "  📊 Total CSS Size: $(($analysis.performance.totalCSSSize / 1MB).ToString('F1'))MB" -ForegroundColor White
            }
            
            if ($analysis.recommendations.Count -gt 0) {
                Write-Host ""
                Write-Host "💡 Recommendations:" -ForegroundColor Yellow
                $analysis.recommendations | ForEach-Object { Write-Host "  • $_" -ForegroundColor White }
            }
            
            Write-Host ""
            Write-Host "🧠 Hacker Features Available:" -ForegroundColor Magenta
            $analysis.hackerFeatures | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            
            Write-Host ""
            Write-Host "⚡ Available Actions:" -ForegroundColor Cyan
            Write-Host "  tailwind-hacker --Action install    # Install/upgrade with hacker config" -ForegroundColor White
            Write-Host "  tailwind-hacker --Action optimize   # Ultra-performance optimization" -ForegroundColor White
            Write-Host "  tailwind-hacker --Action examples   # Generate hacker usage examples" -ForegroundColor White
        }
    }
    
    "install" {
        Initialize-TailwindHackerSystem -ProjectPath $ProjectPath -ForceUpgrade:($Upgrade -or $Force)
    }
    
    "optimize" {
        Write-Host "⚡ Running ultra-performance Tailwind optimizations..." -ForegroundColor Yellow
        Optimize-TailwindPerformance -ProjectPath $ProjectPath
        
        # Additional hacker optimizations
        $optimizeScript = @"
# 🚀 Ultra-Hacker Tailwind Build Commands
npm run build-css:prod -- --minify --optimize
npx tailwindcss -i ./src/main.css -o ./dist/output.css --watch --minify
pnpm dlx @tailwindcss/cli build -c tailwind.config.ts --minify
"@
        Set-Content -Path "$ProjectPath\tailwind-build-optimized.sh" -Value $optimizeScript
        Write-Host "✅ Optimization scripts created!" -ForegroundColor Green
    }
    
    "examples" {
        Write-Host "🎨 Generating hacker-level Tailwind examples..." -ForegroundColor Cyan
        
        $examplesDir = Join-Path $ProjectPath "tailwind-hacker-examples"
        if (-not (Test-Path $examplesDir)) {
            New-Item -Path $examplesDir -ItemType Directory -Force | Out-Null
        }
        
        # Glass morphism example
        $glassExample = @"
<!-- 🔮 Glass Morphism Card -->
<div class="glass p-8 m-4 max-w-md">
  <h3 class="text-xl font-bold text-white mb-4">Glass Effect</h3>
  <p class="text-white/80">Ultra-modern glass morphism with backdrop blur</p>
  <button class="btn btn-primary mt-4">Action</button>
</div>

<!-- 🌈 Dynamic Gradient -->
<div class="bg-gradient-conic from-purple-500 via-pink-500 to-blue-500 p-8 rounded-xl">
  <h3 class="text-white text-xl font-bold">Conic Gradient</h3>
</div>

<!-- 📱 Container Query Example -->
<div class="card container-query">
  <h3 class="text-lg @lg:text-xl font-bold">Responsive Container</h3>
  <p class="text-sm @md:text-base">Adapts based on container size, not viewport</p>
</div>

<!-- 🚀 Advanced Animation -->
<div class="animate-in hover:scale-105 transition-all duration-300 ease-spring">
  <div class="neomorphism p-6">
    <h3 class="font-bold">Neomorphism Design</h3>
    <p>Soft, tactile 3D effect</p>
  </div>
</div>

<!-- 🛡️ Safe Area Mobile -->
<div class="pt-safe pb-safe pl-safe pr-safe bg-blue-500">
  <p class="text-white">Respects device safe areas</p>
</div>
"@
        Set-Content -Path "$examplesDir\glass-morphism.html" -Value $glassExample
        
        # Advanced utilities example
        $advancedUtils = @"
/* 🧠 Advanced Tailwind Hacker Utilities */

/* Dynamic color with CSS functions */
.text-dynamic { color: light-dark(#1f2937, #f9fafb); }

/* Container queries */
@container (min-width: 400px) {
  .card-responsive { @apply p-8 text-lg; }
}

/* Modern gradients */
.bg-gradient-radial {
  background: radial-gradient(circle at center, var(--tw-gradient-stops));
}

/* Glass effect utility */
.glass-ultra {
  @apply backdrop-blur-xl bg-white/5 border border-white/10;
  box-shadow: 
    0 8px 32px 0 rgba(31, 38, 135, 0.37),
    inset 0 1px 0 0 rgba(255, 255, 255, 0.1);
}

/* Neomorphism utility */
.neo-pressed {
  box-shadow: 
    inset 8px 8px 16px #bebebe,
    inset -8px -8px 16px #ffffff;
}

/* Advanced animation utilities */
.animate-float {
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}
"@
        Set-Content -Path "$examplesDir\advanced-utilities.css" -Value $advancedUtils
        
        Write-Host "✅ Hacker examples generated in: $examplesDir" -ForegroundColor Green
    }
    
    default {
        Write-Host "❌ Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available actions: analyze, install, optimize, examples" -ForegroundColor Yellow
        exit 1
    }
}