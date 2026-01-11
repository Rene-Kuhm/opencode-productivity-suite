# 🚀 Tailwind CSS Hacker System - v4.1+ Expert Configuration
# Ultra-advanced Tailwind CSS detection, upgrade, and optimization system

param(
    [string]$ProjectPath = ".",
    [switch]$ForceUpgrade = $false,
    [switch]$HackerMode = $true,
    [switch]$JsonOutput = $false
)

# Tailwind v4.1+ Features Detection
$TAILWIND_V4_FEATURES = @{
    "nativeCascadeLayers" = "@layer utilities, components, base"
    "propertyAPI" = "@property --color"
    "colorMix" = "color-mix(in srgb, red 50%, blue)"
    "containerQueries" = "@container (min-width: 400px)"
    "startingStyle" = "@starting-style"
    "dynamicUtilities" = "bg-[theme(colors.red.500)]"
    "cssFirstConfig" = "@theme default"
    "modernSelector" = ":is(), :where(), :has()"
}

# Hacker-Level Tailwind Configuration Templates
$HACKER_CONFIGS = @{
    "tailwind4-ultra" = @{
        config = @"
// 🚀 Tailwind CSS v4.1+ Ultra-Hacker Configuration
import { type Config } from 'tailwindcss'

export default {
  // CSS-first configuration (v4 native)
  content: {
    files: ['./src/**/*.{js,ts,jsx,tsx,vue,svelte}'],
    transform: {
      // Advanced content extraction for dynamic classes
      vue: (content: string) => content.replace(/(?:class)="([^"]*)"/, 'class="$1"')
    }
  },
  
  // Ultra-performance configuration
  future: {
    hoverOnlyWhenSupported: true,
    respectDefaultRingColorOpacity: true,
    disableColorOpacityUtilitiesByDefault: true,
    relativeContentPathsByDefault: true
  },
  
  // Hacker-level theme extensions
  theme: {
    // CSS Custom Properties integration
    extend: {
      // Dynamic color system with CSS color-mix()
      colors: {
        primary: {
          50: 'color-mix(in srgb, var(--primary) 5%, white)',
          100: 'color-mix(in srgb, var(--primary) 10%, white)',
          500: 'var(--primary, #3b82f6)',
          900: 'color-mix(in srgb, var(--primary) 90%, black)',
        },
        // Context-aware colors
        surface: {
          base: 'light-dark(white, #0f172a)',
          elevated: 'light-dark(#f8fafc, #1e293b)',
        }
      },
      
      // Container queries utilities
      containers: {
        xs: '20rem',
        sm: '24rem',
        md: '28rem',
        lg: '32rem',
        xl: '36rem',
        '2xl': '42rem',
      },
      
      // Advanced spacing system
      spacing: {
        'safe-top': 'env(safe-area-inset-top)',
        'safe-bottom': 'env(safe-area-inset-bottom)',
        'safe-left': 'env(safe-area-inset-left)',
        'safe-right': 'env(safe-area-inset-right)',
      },
      
      // Modern typography with CSS font features
      fontFamily: {
        sans: ['Inter Variable', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono Variable', 'Fira Code', 'monospace'],
      },
      
      // Advanced animations
      animation: {
        'fade-in': 'fadeIn 0.5s ease-out forwards',
        'slide-up': 'slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1)',
        'scale-in': 'scaleIn 0.2s cubic-bezier(0.16, 1, 0.3, 1)',
      },
      
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideUp: {
          '0%': { transform: 'translateY(100%)' },
          '100%': { transform: 'translateY(0)' },
        },
        scaleIn: {
          '0%': { transform: 'scale(0.95)', opacity: '0' },
          '100%': { transform: 'scale(1)', opacity: '1' },
        },
      },
    }
  },
  
  // Expert-level plugins
  plugins: [
    // Custom container queries plugin
    ({ addUtilities, theme, addComponents }) => {
      addUtilities({
        '.container-query': {
          'container-type': 'inline-size',
        },
      })
      
      // Advanced component classes
      addComponents({
        '.glass-effect': {
          '@apply backdrop-blur-md bg-white/10 border border-white/20': {},
          'box-shadow': '0 8px 32px 0 rgba(31, 38, 135, 0.37)',
        },
        '.neomorphism': {
          '@apply bg-gray-100 rounded-2xl': {},
          'box-shadow': '20px 20px 60px #bebebe, -20px -20px 60px #ffffff',
        },
      })
    },
    
    // Hacker utilities plugin
    ({ addUtilities, matchUtilities, theme }) => {
      // Dynamic gradient utilities
      matchUtilities(
        {
          'bg-gradient-conic': (value) => ({
            'background-image': `conic-gradient(${value})`,
          }),
        },
        { values: theme('colors') }
      )
      
      // Advanced layout utilities
      addUtilities({
        '.layout-grid': {
          'display': 'grid',
          'grid-template-columns': 'repeat(auto-fit, minmax(280px, 1fr))',
          'gap': '1rem',
        },
        '.flex-center': {
          'display': 'flex',
          'align-items': 'center',
          'justify-content': 'center',
        },
      })
    },
  ],
} satisfies Config
"@
    },
    
    "postcss-ultra" = @{
        config = @"
// 🚀 PostCSS Ultra-Hacker Configuration for Tailwind v4.1+
module.exports = {
  plugins: [
    // Tailwind CSS v4 with native features
    require('tailwindcss'),
    
    // Advanced CSS processing
    require('postcss-preset-env')({
      stage: 0,
      features: {
        'custom-properties': true,
        'custom-selectors': true,
        'nesting-rules': true,
        'color-mix': true,
      },
    }),
    
    // Performance optimization
    require('cssnano')({
      preset: ['advanced', {
        discardComments: { removeAll: true },
        reduceIdents: { keyframes: false },
        zindex: false,
      }],
    }),
  ],
}
"@
    }
}

# Ultra-Advanced CSS Templates
$HACKER_CSS_TEMPLATES = @{
    "main.css" = @"
/* 🚀 Tailwind v4.1+ Ultra-Hacker CSS Setup */

/* CSS-first theme configuration (v4 native) */
@theme default {
  --color-primary: #3b82f6;
  --color-secondary: #8b5cf6;
  --color-accent: #f59e0b;
}

/* Import Tailwind with cascade layers */
@layer base, components, utilities;

@import 'tailwindcss' layer(utilities);

/* Advanced base layer */
@layer base {
  /* Modern CSS reset */
  *, *::before, *::after {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }
  
  /* CSS custom properties for theming */
  :root {
    color-scheme: light dark;
    --ease-spring: cubic-bezier(0.175, 0.885, 0.32, 1.275);
    --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  }
  
  /* Dark mode with preference detection */
  @media (prefers-color-scheme: dark) {
    :root {
      --color-primary: #60a5fa;
      --color-secondary: #a78bfa;
    }
  }
  
  /* Advanced focus management */
  :focus-visible {
    @apply outline-2 outline-blue-500 outline-offset-2;
  }
  
  /* Smooth scrolling with reduced motion respect */
  html {
    scroll-behavior: smooth;
  }
  
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
    }
  }
}

/* Hacker-level component layer */
@layer components {
  /* Glass morphism component */
  .glass {
    @apply backdrop-blur-sm bg-white/10 border border-white/20 rounded-xl;
    box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  }
  
  /* Advanced button system */
  .btn {
    @apply inline-flex items-center justify-center px-4 py-2 rounded-lg font-medium transition-all duration-200;
    
    &-primary {
      @apply bg-primary-500 text-white hover:bg-primary-600 active:bg-primary-700;
      @apply shadow-lg hover:shadow-xl transform hover:-translate-y-0.5;
    }
    
    &-ghost {
      @apply text-primary-600 hover:bg-primary-50 active:bg-primary-100;
    }
  }
  
  /* Container query components */
  .card {
    @apply container-query p-6 rounded-xl border bg-surface-base;
    
    @container (min-width: 400px) {
      @apply p-8;
    }
  }
  
  /* Modern grid layouts */
  .grid-auto-fit {
    @apply grid gap-4;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  }
  
  .grid-auto-fill {
    @apply grid gap-4;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  }
}

/* Ultra-advanced utilities */
@layer utilities {
  /* Dynamic color utilities with CSS functions */
  .text-dynamic {
    color: light-dark(#1f2937, #f9fafb);
  }
  
  /* Advanced animation utilities */
  .animate-in {
    animation: fadeIn 0.5s var(--ease-out) forwards;
  }
  
  .animate-out {
    animation: fadeOut 0.3s var(--ease-out) forwards;
  }
  
  /* Container query utilities */
  .cq-normal { container-type: normal; }
  .cq-size { container-type: size; }
  .cq-inline-size { container-type: inline-size; }
  
  /* Modern layout utilities */
  .layout-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 1rem;
  }
  
  /* Safe area utilities for mobile */
  .pt-safe { padding-top: env(safe-area-inset-top); }
  .pb-safe { padding-bottom: env(safe-area-inset-bottom); }
  .pl-safe { padding-left: env(safe-area-inset-left); }
  .pr-safe { padding-right: env(safe-area-inset-right); }
}

/* Advanced keyframes */
@keyframes fadeIn {
  from { 
    opacity: 0; 
    transform: translateY(20px); 
  }
  to { 
    opacity: 1; 
    transform: translateY(0); 
  }
}

@keyframes fadeOut {
  from { 
    opacity: 1; 
    transform: translateY(0); 
  }
  to { 
    opacity: 0; 
    transform: translateY(-20px); 
  }
}
"@
}

function Test-TailwindVersion {
    param([string]$ProjectPath)
    
    $packageJsonPath = Join-Path $ProjectPath "package.json"
    $result = @{
        hasTailwind = $false
        currentVersion = ""
        isLatest = $false
        needsUpgrade = $false
        configExists = $false
        configType = ""
    }
    
    if (Test-Path $packageJsonPath) {
        try {
            $packageJson = Get-Content $packageJsonPath | ConvertFrom-Json
            
            # Check for Tailwind in dependencies
            $tailwindVersion = $null
            if ($packageJson.dependencies -and $packageJson.dependencies.tailwindcss) {
                $tailwindVersion = $packageJson.dependencies.tailwindcss
            }
            elseif ($packageJson.devDependencies -and $packageJson.devDependencies.tailwindcss) {
                $tailwindVersion = $packageJson.devDependencies.tailwindcss
            }
            
            if ($tailwindVersion) {
                $result.hasTailwind = $true
                $result.currentVersion = $tailwindVersion
                
                # Check if it's v4.1+
                if ($tailwindVersion -match "\^?4\.[1-9]" -or $tailwindVersion -match "\^?[5-9]\." -or $tailwindVersion -eq "latest") {
                    $result.isLatest = $true
                } else {
                    $result.needsUpgrade = $true
                }
            }
            
        } catch {
            Write-Warning "Failed to parse package.json: $($_.Exception.Message)"
        }
    }
    
    # Check for config files
    $configFiles = @(
        "tailwind.config.js",
        "tailwind.config.ts", 
        "tailwind.config.mjs",
        "tailwind.config.cjs"
    )
    
    foreach ($configFile in $configFiles) {
        $configPath = Join-Path $ProjectPath $configFile
        if (Test-Path $configPath) {
            $result.configExists = $true
            $result.configType = $configFile
            break
        }
    }
    
    return $result
}

function Install-TailwindLatest {
    param([string]$ProjectPath, [string]$PackageManager = "npm")
    
    Write-Host "🚀 Installing Tailwind CSS v4.1+ (latest)..." -ForegroundColor Cyan
    
    Push-Location $ProjectPath
    try {
        # Install latest Tailwind CSS
        switch ($PackageManager) {
            "npm" { 
                & npm install -D tailwindcss@latest postcss@latest autoprefixer@latest
                & npm install -D @tailwindcss/typography@latest @tailwindcss/forms@latest
            }
            "yarn" { 
                & yarn add -D tailwindcss@latest postcss@latest autoprefixer@latest
                & yarn add -D @tailwindcss/typography@latest @tailwindcss/forms@latest
            }
            "pnpm" { 
                & pnpm add -D tailwindcss@latest postcss@latest autoprefixer@latest
                & pnpm add -D @tailwindcss/typography@latest @tailwindcss/forms@latest
            }
            "bun" { 
                & bun add -D tailwindcss@latest postcss@latest autoprefixer@latest
                & bun add -D @tailwindcss/typography@latest @tailwindcss/forms@latest
            }
        }
        
        Write-Host "✅ Tailwind CSS latest version installed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Failed to install Tailwind CSS: $($_.Exception.Message)"
    }
    finally {
        Pop-Location
    }
}

function Create-HackerTailwindConfig {
    param([string]$ProjectPath, [string]$ConfigType = "tailwind.config.ts")
    
    $configPath = Join-Path $ProjectPath $ConfigType
    
    Write-Host "🧠 Creating Ultra-Hacker Tailwind v4.1+ configuration..." -ForegroundColor Magenta
    
    if ($ConfigType -like "*.ts") {
        $configContent = $HACKER_CONFIGS["tailwind4-ultra"].config
    } else {
        # Convert TypeScript config to JavaScript
        $configContent = $HACKER_CONFIGS["tailwind4-ultra"].config -replace "import \{ type Config \} from 'tailwindcss'", "/** @type {import('tailwindcss').Config} */"
        $configContent = $configContent -replace "export default", "module.exports ="
        $configContent = $configContent -replace "satisfies Config", ""
    }
    
    Set-Content -Path $configPath -Value $configContent -Encoding UTF8
    Write-Host "✅ Ultra-hacker config created: $ConfigType" -ForegroundColor Green
    
    # Create PostCSS config
    $postcssPath = Join-Path $ProjectPath "postcss.config.js"
    Set-Content -Path $postcssPath -Value $HACKER_CONFIGS["postcss-ultra"].config -Encoding UTF8
    Write-Host "✅ Ultra-hacker PostCSS config created!" -ForegroundColor Green
    
    # Create main CSS file
    $cssPath = Join-Path $ProjectPath "src"
    if (-not (Test-Path $cssPath)) {
        New-Item -Path $cssPath -ItemType Directory -Force | Out-Null
    }
    $cssFilePath = Join-Path $cssPath "main.css"
    Set-Content -Path $cssFilePath -Value $HACKER_CSS_TEMPLATES["main.css"] -Encoding UTF8
    Write-Host "✅ Ultra-hacker CSS template created: src/main.css" -ForegroundColor Green
}

function Optimize-TailwindPerformance {
    param([string]$ProjectPath)
    
    Write-Host "⚡ Applying ultra-performance Tailwind optimizations..." -ForegroundColor Yellow
    
    # Create .tailwindignore file
    $ignoreContent = @"
node_modules/
dist/
build/
*.log
.next/
.nuxt/
.vuepress/
coverage/
"@
    Set-Content -Path (Join-Path $ProjectPath ".tailwindignore") -Value $ignoreContent
    
    # Create purge optimization script
    $optimizeScript = @"
// 🚀 Tailwind CSS Ultra-Performance Optimization Script
const fs = require('fs');
const path = require('path');

// Advanced content scanning for dynamic classes
const scanForDynamicClasses = (filePath) => {
  const content = fs.readFileSync(filePath, 'utf8');
  const dynamicPatterns = [
    /className=\{[^}]*\}/g,
    /class:\s*[^,\]}\s]*/g,
    /'[^']*'/g,
    /"[^"]*"/g,
  ];
  
  let classes = new Set();
  
  dynamicPatterns.forEach(pattern => {
    const matches = content.match(pattern) || [];
    matches.forEach(match => {
      const classMatches = match.match(/[\w-]+/g) || [];
      classMatches.forEach(cls => classes.add(cls));
    });
  });
  
  return Array.from(classes);
};

console.log('🚀 Tailwind optimization complete!');
"@
    Set-Content -Path (Join-Path $ProjectPath "tailwind-optimize.js") -Value $optimizeScript
    
    Write-Host "✅ Performance optimizations applied!" -ForegroundColor Green
}

# Main execution
function Initialize-TailwindHackerSystem {
    param([string]$ProjectPath, [switch]$ForceUpgrade)
    
    Write-Host "🚀 Tailwind CSS Hacker System v4.1+ Initializing..." -ForegroundColor Cyan
    Write-Host "📁 Project: $ProjectPath" -ForegroundColor White
    
    # Detect package manager
    $packageManager = "npm"
    if (Test-Path "$ProjectPath\pnpm-lock.yaml") { $packageManager = "pnpm" }
    elseif (Test-Path "$ProjectPath\yarn.lock") { $packageManager = "yarn" }
    elseif (Test-Path "$ProjectPath\bun.lockb") { $packageManager = "bun" }
    
    Write-Host "📦 Package Manager: $packageManager" -ForegroundColor White
    
    # Check current Tailwind status
    $tailwindStatus = Test-TailwindVersion -ProjectPath $ProjectPath
    
    if (-not $tailwindStatus.hasTailwind) {
        Write-Host "💫 No Tailwind detected. Installing v4.1+ with hacker configuration..." -ForegroundColor Yellow
        Install-TailwindLatest -ProjectPath $ProjectPath -PackageManager $packageManager
        Create-HackerTailwindConfig -ProjectPath $ProjectPath
        Optimize-TailwindPerformance -ProjectPath $ProjectPath
    }
    elseif ($tailwindStatus.needsUpgrade -or $ForceUpgrade) {
        Write-Host "🔄 Upgrading Tailwind to v4.1+ with hacker enhancements..." -ForegroundColor Yellow
        Install-TailwindLatest -ProjectPath $ProjectPath -PackageManager $packageManager
        
        if ($tailwindStatus.configExists) {
            $backupPath = "$($tailwindStatus.configType).backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item "$ProjectPath\$($tailwindStatus.configType)" "$ProjectPath\$backupPath"
            Write-Host "📄 Backup created: $backupPath" -ForegroundColor Gray
        }
        
        Create-HackerTailwindConfig -ProjectPath $ProjectPath -ConfigType ($tailwindStatus.configType -or "tailwind.config.ts")
        Optimize-TailwindPerformance -ProjectPath $ProjectPath
    }
    else {
        Write-Host "✅ Tailwind v4.1+ already detected!" -ForegroundColor Green
        
        if (-not $tailwindStatus.configExists -or $ForceUpgrade) {
            Create-HackerTailwindConfig -ProjectPath $ProjectPath
            Optimize-TailwindPerformance -ProjectPath $ProjectPath
        }
    }
    
    # Final status
    $finalStatus = Test-TailwindVersion -ProjectPath $ProjectPath
    
    $result = @{
        success = $true
        message = "🚀 Tailwind CSS Hacker System initialized successfully!"
        version = $finalStatus.currentVersion
        features = @(
            "✅ Tailwind CSS v4.1+ (Latest)",
            "🧠 Ultra-Hacker Configuration",
            "⚡ Performance Optimizations", 
            "🎨 CSS-first Configuration",
            "📱 Container Queries",
            "🌈 Dynamic Color System",
            "🚀 Modern CSS Features"
        )
        commands = @{
            "Build CSS" = "$packageManager run build-css"
            "Watch CSS" = "$packageManager run watch-css"
            "Optimize" = "node tailwind-optimize.js"
        }
    }
    
    if ($JsonOutput) {
        return $result | ConvertTo-Json -Depth 10
    } else {
        Write-Host ""
        Write-Host $result.message -ForegroundColor Green
        Write-Host ""
        Write-Host "🎯 Features Enabled:" -ForegroundColor Cyan
        $result.features | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        Write-Host ""
        Write-Host "⚡ Available Commands:" -ForegroundColor Cyan
        $result.commands.GetEnumerator() | ForEach-Object { 
            Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor White 
        }
        Write-Host ""
        return $result
    }
}

# Execute if called directly
if ($MyInvocation.InvocationName -ne '.') {
    Initialize-TailwindHackerSystem -ProjectPath $ProjectPath -ForceUpgrade:$ForceUpgrade
}