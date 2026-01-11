# ==========================================
# OpenCode Advanced Framework Detection
# Detects ALL modern frameworks (2026)
# ==========================================

param(
    [string]$ProjectPath = ".",
    [switch]$Verbose = $false,
    [switch]$JsonOutput = $false
)

# Framework Detection Database - Updated 2026
$FrameworkDatabase = @{
    # Frontend Frameworks - Established
    "React" = @{
        Files = @("package.json")
        Patterns = @('"react":', '"@types/react":')
        Priority = 90
        Category = "Frontend"
        ConfigFile = "react-zero-defect.json"
        Commands = @("npm run dev", "npm run build", "npm test")
        Description = "React library for building user interfaces"
    }
    
    "Next.js" = @{
        Files = @("next.config.js", "next.config.ts", "next.config.mjs")
        Patterns = @('"next":', 'from "next/')
        Priority = 95
        Category = "Frontend"
        ConfigFile = "nextjs-zero-defect.json"
        Commands = @("npm run dev", "npm run build", "npm start")
        Description = "React framework for production"
    }
    
    "Vue.js" = @{
        Files = @("vue.config.js", "vite.config.js", "package.json")
        Patterns = @('"vue":', '"@vue/', '.vue')
        Priority = 85
        Category = "Frontend"
        ConfigFile = "vue-zero-defect.json"
        Commands = @("npm run serve", "npm run build")
        Description = "Progressive JavaScript framework"
    }
    
    "Nuxt.js" = @{
        Files = @("nuxt.config.js", "nuxt.config.ts")
        Patterns = @('"nuxt":', '"@nuxt/')
        Priority = 88
        Category = "Frontend"
        ConfigFile = "nuxt-zero-defect.json"
        Commands = @("npm run dev", "npm run build", "npm run generate")
        Description = "Vue.js framework for server-side rendering"
    }
    
    "Angular" = @{
        Files = @("angular.json", ".angular-cli.json")
        Patterns = @('"@angular/', '"ng ')
        Priority = 85
        Category = "Frontend"
        ConfigFile = "angular-zero-defect.json"
        Commands = @("ng serve", "ng build", "ng test")
        Description = "Platform for building mobile and desktop web applications"
    }
    
    "Svelte" = @{
        Files = @("svelte.config.js", "package.json")
        Patterns = @('"svelte":', '.svelte')
        Priority = 80
        Category = "Frontend"
        ConfigFile = "svelte-zero-defect.json"
        Commands = @("npm run dev", "npm run build")
        Description = "Cybernetically enhanced web apps"
    }
    
    "SvelteKit" = @{
        Files = @("svelte.config.js", "package.json")
        Patterns = @('"@sveltejs/kit":', '"@sveltejs/adapter-')
        Priority = 83
        Category = "Frontend"
        ConfigFile = "sveltekit-zero-defect.json"
        Commands = @("npm run dev", "npm run build", "npm run preview")
        Description = "The fastest way to build Svelte apps"
    }

    # Frontend Frameworks - Modern/Emerging
    "Qwik" = @{
        Files = @("vite.config.ts", "package.json")
        Patterns = @('"@builder.io/qwik":', 'from "@builder.io/qwik"')
        Priority = 75
        Category = "Frontend"
        ConfigFile = "qwik-zero-defect.json"
        Commands = @("npm run dev", "npm run build")
        Description = "The HTML-first framework. Resumable"
    }
    
    "SolidJS" = @{
        Files = @("vite.config.ts", "package.json")
        Patterns = @('"solid-js":', 'from "solid-js"')
        Priority = 70
        Category = "Frontend"
        ConfigFile = "solid-zero-defect.json"
        Commands = @("npm run dev", "npm run build")
        Description = "Simple and performant reactivity for building user interfaces"
    }
    
    "Fresh" = @{
        Files = @("fresh.gen.ts", "deno.json", "deno.jsonc")
        Patterns = @('from "https://deno.land/x/fresh"', '"$fresh/')
        Priority = 65
        Category = "Frontend"
        ConfigFile = "fresh-zero-defect.json"
        Commands = @("deno task start", "deno task build")
        Description = "The next-gen web framework for Deno"
    }
    
    "Astro" = @{
        Files = @("astro.config.mjs", "astro.config.js", "astro.config.ts")
        Patterns = @('"astro":', '.astro')
        Priority = 78
        Category = "Frontend"
        ConfigFile = "astro-zero-defect.json"
        Commands = @("npm run dev", "npm run build", "npm run preview")
        Description = "The web framework for content-driven websites"
    }
    
    "Remix" = @{
        Files = @("remix.config.js", "package.json")
        Patterns = @('"@remix-run/', 'from "@remix-run/')
        Priority = 72
        Category = "Frontend"
        ConfigFile = "remix-zero-defect.json"
        Commands = @("npm run dev", "npm run build", "npm start")
        Description = "Focused on web standards and modern web app UX"
    }

    # Backend Frameworks - Node.js
    "Express.js" = @{
        Files = @("package.json")
        Patterns = @('"express":', 'require("express")', 'from "express"')
        Priority = 85
        Category = "Backend"
        ConfigFile = "express-zero-defect.json"
        Commands = @("npm start", "npm run dev")
        Description = "Fast, unopinionated, minimalist web framework for Node.js"
    }
    
    "Fastify" = @{
        Files = @("package.json")
        Patterns = @('"fastify":', 'require("fastify")', 'from "fastify"')
        Priority = 80
        Category = "Backend"
        ConfigFile = "fastify-zero-defect.json"
        Commands = @("npm start", "npm run dev")
        Description = "Fast and low overhead web framework, for Node.js"
    }
    
    "Koa.js" = @{
        Files = @("package.json")
        Patterns = @('"koa":', 'require("koa")', 'from "koa"')
        Priority = 75
        Category = "Backend"
        ConfigFile = "koa-zero-defect.json"
        Commands = @("npm start")
        Description = "Next generation web framework for Node.js"
    }
    
    "NestJS" = @{
        Files = @("nest-cli.json", "package.json")
        Patterns = @('"@nestjs/', 'from "@nestjs/')
        Priority = 88
        Category = "Backend"
        ConfigFile = "nestjs-zero-defect.json"
        Commands = @("npm run start:dev", "npm run build", "npm run start:prod")
        Description = "A progressive Node.js framework for building efficient server-side applications"
    }

    # Backend Frameworks - Python
    "Django" = @{
        Files = @("manage.py", "settings.py", "requirements.txt")
        Patterns = @("django", "Django", "DJANGO_SETTINGS_MODULE")
        Priority = 90
        Category = "Backend"
        ConfigFile = "django-zero-defect.json"
        Commands = @("python manage.py runserver", "python manage.py migrate")
        Description = "The Web framework for perfectionists with deadlines"
    }
    
    "FastAPI" = @{
        Files = @("main.py", "requirements.txt", "pyproject.toml")
        Patterns = @("from fastapi", "import fastapi", "FastAPI()")
        Priority = 85
        Category = "Backend"
        ConfigFile = "fastapi-zero-defect.json"
        Commands = @("uvicorn main:app --reload", "python -m uvicorn main:app")
        Description = "Modern, fast web framework for building APIs with Python"
    }
    
    "Flask" = @{
        Files = @("app.py", "requirements.txt")
        Patterns = @("from flask", "import Flask", "Flask(__name__)")
        Priority = 80
        Category = "Backend"
        ConfigFile = "flask-zero-defect.json"
        Commands = @("python app.py", "flask run")
        Description = "Lightweight WSGI web application framework"
    }

    # Mobile Frameworks
    "React Native" = @{
        Files = @("metro.config.js", "react-native.config.js", "package.json")
        Patterns = @('"react-native":', 'from "react-native"')
        Priority = 90
        Category = "Mobile"
        ConfigFile = "react-native-zero-defect.json"
        Commands = @("npx react-native run-android", "npx react-native run-ios")
        Description = "Framework for building native mobile apps using React"
    }
    
    "Expo" = @{
        Files = @("app.config.js", "app.config.ts", "app.json", "expo.json")
        Patterns = @('"expo":', '"@expo/', 'from "expo"')
        Priority = 88
        Category = "Mobile"
        ConfigFile = "expo-zero-defect.json"
        Commands = @("expo start", "expo build:android", "expo build:ios")
        Description = "Platform for universal React applications"
    }
    
    "Flutter" = @{
        Files = @("pubspec.yaml", "pubspec.yml")
        Patterns = @("flutter:", "cupertino_icons:")
        Priority = 92
        Category = "Mobile"
        ConfigFile = "flutter-zero-defect.yaml"
        Commands = @("flutter run", "flutter build apk", "flutter build ios")
        Description = "Google's UI toolkit for building natively compiled applications"
    }
    
    "Ionic" = @{
        Files = @("ionic.config.json", "capacitor.config.ts")
        Patterns = @('"@ionic/', '"@capacitor/')
        Priority = 85
        Category = "Mobile"
        ConfigFile = "ionic-zero-defect.json"
        Commands = @("ionic serve", "ionic build", "ionic capacitor run android")
        Description = "Cross-platform mobile app development framework"
    }

    # Desktop Frameworks
    "Electron" = @{
        Files = @("package.json")
        Patterns = @('"electron":', 'require("electron")', 'from "electron"')
        Priority = 85
        Category = "Desktop"
        ConfigFile = "electron-zero-defect.json"
        Commands = @("npm run electron-dev", "npm run electron-pack")
        Description = "Build cross-platform desktop apps with JavaScript"
    }
    
    "Tauri" = @{
        Files = @("src-tauri/Cargo.toml", "src-tauri/tauri.conf.json")
        Patterns = @("tauri", "@tauri-apps/")
        Priority = 80
        Category = "Desktop"
        ConfigFile = "tauri-zero-defect.json"
        Commands = @("npm run tauri dev", "npm run tauri build")
        Description = "Build smaller, faster, and more secure desktop applications"
    }

    # Game Development
    "Unity" = @{
        Files = @("ProjectSettings/ProjectVersion.txt", "Assets/")
        Patterns = @("m_EditorVersion:", "UnityEngine")
        Priority = 85
        Category = "Game"
        ConfigFile = "unity-zero-defect.json"
        Commands = @("Unity.exe", "Unity")
        Description = "Cross-platform game engine"
    }
    
    "Godot" = @{
        Files = @("project.godot", "*.gd")
        Patterns = @("engine_version", "extends ")
        Priority = 80
        Category = "Game"
        ConfigFile = "godot-zero-defect.json"
        Commands = @("godot", "godot --export")
        Description = "Open source game engine"
    }

    # Backend Languages/Runtimes
    "Spring Boot" = @{
        Files = @("pom.xml", "build.gradle", "application.properties")
        Patterns = @("spring-boot-starter", "@SpringBootApplication")
        Priority = 90
        Category = "Backend"
        ConfigFile = "spring-boot-zero-defect.json"
        Commands = @("./mvnw spring-boot:run", "./gradlew bootRun")
        Description = "Java-based framework for creating stand-alone applications"
    }
    
    "Laravel" = @{
        Files = @("artisan", "composer.json")
        Patterns = @('"laravel/', '"illuminate/')
        Priority = 88
        Category = "Backend"
        ConfigFile = "laravel-zero-defect.json"
        Commands = @("php artisan serve", "php artisan migrate")
        Description = "PHP web application framework with elegant syntax"
    }
    
    "Ruby on Rails" = @{
        Files = @("Gemfile", "config/application.rb", "config/routes.rb")
        Patterns = @("gem 'rails'", "Rails.application")
        Priority = 85
        Category = "Backend"
        ConfigFile = "rails-zero-defect.json"
        Commands = @("rails server", "rails generate", "rails db:migrate")
        Description = "Web application framework written in Ruby"
    }
    
    "ASP.NET Core" = @{
        Files = @("*.csproj", "Program.cs", "Startup.cs")
        Patterns = @("Microsoft.AspNetCore", "WebApplication.CreateBuilder")
        Priority = 88
        Category = "Backend"
        ConfigFile = "aspnetcore-zero-defect.json"
        Commands = @("dotnet run", "dotnet build", "dotnet publish")
        Description = "Cross-platform framework for building modern cloud-based web applications"
    }
    
    "Go Gin" = @{
        Files = @("go.mod", "main.go")
        Patterns = @('github.com/gin-gonic/gin', 'gin.Default()')
        Priority = 80
        Category = "Backend"
        ConfigFile = "gin-zero-defect.json"
        Commands = @("go run main.go", "go build")
        Description = "HTTP web framework written in Go"
    }
    
    "Rust Actix" = @{
        Files = @("Cargo.toml")
        Patterns = @('actix-web', 'use actix_web')
        Priority = 75
        Category = "Backend"
        ConfigFile = "actix-zero-defect.toml"
        Commands = @("cargo run", "cargo build --release")
        Description = "Powerful, pragmatic, and extremely fast web framework for Rust"
    }

    # Emerging/Experimental Frameworks 2026
    "Bun" = @{
        Files = @("bun.lockb", "bunfig.toml")
        Patterns = @('"bun":', 'Bun.serve')
        Priority = 70
        Category = "Runtime"
        ConfigFile = "bun-zero-defect.json"
        Commands = @("bun run dev", "bun run build")
        Description = "Fast all-in-one JavaScript runtime"
    }
    
    "Deno Fresh" = @{
        Files = @("deno.json", "fresh.gen.ts")
        Patterns = @('"$fresh/', 'https://deno.land/x/fresh')
        Priority = 68
        Category = "Frontend"
        ConfigFile = "deno-fresh-zero-defect.json"
        Commands = @("deno task start", "deno task build")
        Description = "The next-gen web framework for Deno"
    }
    
    "Vite" = @{
        Files = @("vite.config.js", "vite.config.ts")
        Patterns = @('from "vite"', '"vite":')
        Priority = 85
        Category = "Build Tool"
        ConfigFile = "vite-zero-defect.json"
        Commands = @("npm run dev", "npm run build", "npm run preview")
        Description = "Next generation frontend tooling"
    }
    
    "Parcel" = @{
        Files = @("package.json")
        Patterns = @('"parcel":', '"@parcel/')
        Priority = 75
        Category = "Build Tool"
        ConfigFile = "parcel-zero-defect.json"
        Commands = @("parcel serve", "parcel build")
        Description = "Zero configuration build tool"
    }

    # AI/ML Frameworks
    "TensorFlow.js" = @{
        Files = @("package.json")
        Patterns = @('"@tensorflow/tfjs":', 'from "@tensorflow/tfjs"')
        Priority = 80
        Category = "AI/ML"
        ConfigFile = "tensorflow-zero-defect.json"
        Commands = @("npm start")
        Description = "Machine learning for JavaScript"
    }
    
    "PyTorch" = @{
        Files = @("requirements.txt", "setup.py")
        Patterns = @("torch", "pytorch", "import torch")
        Priority = 85
        Category = "AI/ML"
        ConfigFile = "pytorch-zero-defect.json"
        Commands = @("python main.py", "python train.py")
        Description = "Deep learning framework for Python"
    }

    # Blockchain/Web3
    "Hardhat" = @{
        Files = @("hardhat.config.js", "hardhat.config.ts")
        Patterns = @('"hardhat":', '@nomiclabs/hardhat')
        Priority = 75
        Category = "Web3"
        ConfigFile = "hardhat-zero-defect.json"
        Commands = @("npx hardhat compile", "npx hardhat test")
        Description = "Ethereum development environment"
    }
    
    "Truffle" = @{
        Files = @("truffle-config.js", "truffle.js")
        Patterns = @('"truffle":', 'module.exports')
        Priority = 70
        Category = "Web3"
        ConfigFile = "truffle-zero-defect.json"
        Commands = @("truffle compile", "truffle migrate")
        Description = "Development framework for Ethereum"
    }

    # Testing Frameworks
    "Vitest" = @{
        Files = @("vitest.config.js", "vitest.config.ts", "package.json")
        Patterns = @('"vitest":', 'from "vitest"')
        Priority = 85
        Category = "Testing"
        ConfigFile = "vitest-zero-defect.json"
        Commands = @("npm run test", "vitest run")
        Description = "Blazing fast unit test framework powered by Vite"
    }
    
    "Playwright" = @{
        Files = @("playwright.config.js", "playwright.config.ts")
        Patterns = @('"@playwright/', 'from "@playwright/')
        Priority = 80
        Category = "Testing"
        ConfigFile = "playwright-zero-defect.json"
        Commands = @("npx playwright test", "npx playwright codegen")
        Description = "Cross-browser automation library"
    }
}

function Detect-Framework {
    param (
        [string]$Path
    )
    
    $results = @()
    $Path = Resolve-Path $Path -ErrorAction SilentlyContinue
    
    if (-not $Path) {
        Write-Warning "Invalid path provided"
        return $results
    }

    foreach ($frameworkName in $FrameworkDatabase.Keys) {
        $framework = $FrameworkDatabase[$frameworkName]
        $score = 0
        $evidence = @()

        # Check for specific files
        foreach ($file in $framework.Files) {
            $filePath = Join-Path $Path $file
            if (Test-Path $filePath) {
                $score += 30
                $evidence += "File: $file"
                
                # Check for patterns within files
                if ($framework.Patterns) {
                    try {
                        $content = Get-Content $filePath -Raw -ErrorAction SilentlyContinue
                        if ($content) {
                            foreach ($pattern in $framework.Patterns) {
                                if ($content -match [regex]::Escape($pattern)) {
                                    $score += 20
                                    $evidence += "Pattern: $pattern in $file"
                                }
                            }
                        }
                    } catch {
                        # Ignore errors reading files
                    }
                }
            }
        }

        # Check for patterns in all relevant files if no specific files matched
        if ($score -eq 0 -and $framework.Patterns) {
            $searchFiles = @()
            
            # Common file extensions to search
            $extensions = @("*.js", "*.ts", "*.jsx", "*.tsx", "*.json", "*.py", "*.go", "*.rs", "*.cs", "*.java", "*.php", "*.rb")
            
            foreach ($ext in $extensions) {
                $searchFiles += Get-ChildItem -Path $Path -Filter $ext -Recurse -ErrorAction SilentlyContinue | Select-Object -First 10
            }

            foreach ($file in $searchFiles) {
                try {
                    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
                    if ($content) {
                        foreach ($pattern in $framework.Patterns) {
                            if ($content -match [regex]::Escape($pattern)) {
                                $score += 15
                                $evidence += "Pattern: $pattern in $($file.Name)"
                                break
                            }
                        }
                    }
                } catch {
                    # Ignore errors
                }
            }
        }

        # Add framework to results if score is significant
        if ($score -gt 0) {
            $confidence = [Math]::Min(100, $score)
            $results += [PSCustomObject]@{
                Name = $frameworkName
                Category = $framework.Category
                Confidence = $confidence
                Priority = $framework.Priority
                ConfigFile = $framework.ConfigFile
                Commands = $framework.Commands
                Description = $framework.Description
                Evidence = $evidence
                Score = $score
            }
        }
    }

    # Sort by priority and confidence
    $results = $results | Sort-Object Priority -Descending | Sort-Object Confidence -Descending
    
    return $results
}

function Show-DetectionResults {
    param (
        [array]$Results,
        [bool]$JsonOutput = $false
    )
    
    if ($JsonOutput) {
        $Results | ConvertTo-Json -Depth 10
        return
    }

    if ($Results.Count -eq 0) {
        Write-Host "❌ No frameworks detected in this project" -ForegroundColor Red
        return
    }

    Write-Host "`n🎯 Framework Detection Results" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    
    $primaryFramework = $Results | Where-Object { $_.Confidence -ge 70 } | Select-Object -First 1
    
    if ($primaryFramework) {
        Write-Host "`n🏆 PRIMARY FRAMEWORK DETECTED:" -ForegroundColor Green
        Write-Host "   Name: $($primaryFramework.Name)" -ForegroundColor White
        Write-Host "   Category: $($primaryFramework.Category)" -ForegroundColor Gray
        Write-Host "   Confidence: $($primaryFramework.Confidence)%" -ForegroundColor Yellow
        Write-Host "   Config: $($primaryFramework.ConfigFile)" -ForegroundColor Magenta
        Write-Host "   Description: $($primaryFramework.Description)" -ForegroundColor Gray
        
        if ($primaryFramework.Commands.Count -gt 0) {
            Write-Host "   Commands:" -ForegroundColor Cyan
            foreach ($cmd in $primaryFramework.Commands) {
                Write-Host "     • $cmd" -ForegroundColor White
            }
        }
    }
    
    $secondaryFrameworks = $Results | Where-Object { $_.Confidence -ge 30 -and $_.Name -ne $primaryFramework.Name }
    
    if ($secondaryFrameworks.Count -gt 0) {
        Write-Host "`n📋 ADDITIONAL FRAMEWORKS/TOOLS:" -ForegroundColor Blue
        foreach ($framework in $secondaryFrameworks) {
            Write-Host "   • $($framework.Name)" -ForegroundColor White -NoNewline
            Write-Host " ($($framework.Category), $($framework.Confidence)%)" -ForegroundColor Gray
        }
    }
    
    if ($Verbose) {
        Write-Host "`n🔍 DETAILED EVIDENCE:" -ForegroundColor Yellow
        foreach ($result in $Results) {
            Write-Host "`n  [$($result.Name)]" -ForegroundColor Cyan
            foreach ($evidence in $result.Evidence) {
                Write-Host "    ✓ $evidence" -ForegroundColor Green
            }
        }
    }
    
    Write-Host "`n💡 NEXT STEPS:" -ForegroundColor Magenta
    if ($primaryFramework) {
        Write-Host "   1. Run: /init-zero-defect --framework=$($primaryFramework.Name.ToLower())" -ForegroundColor White
        Write-Host "   2. Zero Defect config will be automatically applied" -ForegroundColor Gray
        Write-Host "   3. Project will be configured for optimal development" -ForegroundColor Gray
    } else {
        Write-Host "   1. Run: /init-zero-defect --framework=generic" -ForegroundColor White
        Write-Host "   2. Generic Zero Defect configuration will be applied" -ForegroundColor Gray
    }
}

# Main execution
try {
    Write-Host "🔍 Scanning project for frameworks..." -ForegroundColor Cyan
    
    $detectionResults = Detect-Framework -Path $ProjectPath
    
    Show-DetectionResults -Results $detectionResults -JsonOutput $JsonOutput
    
    if ($detectionResults.Count -gt 0) {
        $primaryFramework = $detectionResults | Where-Object { $_.Confidence -ge 70 } | Select-Object -First 1
        if ($primaryFramework) {
            Write-Host "`n✅ Primary framework detected: $($primaryFramework.Name)" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "`n⚠️  Frameworks detected but confidence is low" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "`n❌ No frameworks detected" -ForegroundColor Red
        exit 2
    }
} catch {
    Write-Error "Error during framework detection: $_"
    exit 3
}