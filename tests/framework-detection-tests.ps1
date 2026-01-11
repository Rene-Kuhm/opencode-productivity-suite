# ==========================================
# Framework Detection Tests
# Automated tests for advanced framework detection
# ==========================================

param(
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# Test configuration
$TEMP_TEST_DIR = "$env:TEMP\framework-detection-tests"
$TEST_RESULTS = @()
$TOTAL_TESTS = 0
$PASSED_TESTS = 0
$FAILED_TESTS = 0

function Write-TestLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Level) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "INFO" { "Cyan" }
        "WARN" { "Yellow" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function New-TestProject {
    param(
        [string]$ProjectName,
        [hashtable]$Files,
        [string]$Description
    )
    
    $projectPath = "$TEMP_TEST_DIR\$ProjectName"
    
    if (Test-Path $projectPath) {
        Remove-Item $projectPath -Recurse -Force
    }
    
    New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
    
    foreach ($file in $Files.Keys) {
        $filePath = "$projectPath\$file"
        $fileDir = Split-Path $filePath -Parent
        
        if ($fileDir -and $fileDir -ne $projectPath) {
            New-Item -ItemType Directory -Path $fileDir -Force | Out-Null
        }
        
        Set-Content -Path $filePath -Value $Files[$file]
    }
    
    return $projectPath
}

function Test-FrameworkDetection {
    param(
        [string]$ProjectPath,
        [string]$ExpectedFramework,
        [string]$TestName,
        [int]$MinConfidence = 70
    )
    
    global:$TOTAL_TESTS++
    
    Write-TestLog "Running test: $TestName" "INFO"
    
    try {
        # Run framework detection
        $detectionScript = "$PSScriptRoot\..\automation\advanced-framework-detection.ps1"
        $result = & $detectionScript -ProjectPath $ProjectPath -JsonOutput | ConvertFrom-Json
        
        if ($result -and $result.Count -gt 0) {
            $primaryFramework = $result | Where-Object { $_.Confidence -ge $MinConfidence } | Select-Object -First 1
            
            if ($primaryFramework) {
                if ($primaryFramework.Name -eq $ExpectedFramework) {
                    Write-TestLog "✅ PASSED: $TestName - Detected $($primaryFramework.Name) (Confidence: $($primaryFramework.Confidence)%)" "PASS"
                    global:$PASSED_TESTS++
                    
                    global:$TEST_RESULTS += [PSCustomObject]@{
                        Test = $TestName
                        Expected = $ExpectedFramework
                        Detected = $primaryFramework.Name
                        Confidence = $primaryFramework.Confidence
                        Result = "PASS"
                        Details = "Framework correctly detected"
                    }
                } else {
                    Write-TestLog "❌ FAILED: $TestName - Expected $ExpectedFramework, got $($primaryFramework.Name)" "FAIL"
                    global:$FAILED_TESTS++
                    
                    global:$TEST_RESULTS += [PSCustomObject]@{
                        Test = $TestName
                        Expected = $ExpectedFramework
                        Detected = $primaryFramework.Name
                        Confidence = $primaryFramework.Confidence
                        Result = "FAIL"
                        Details = "Wrong framework detected"
                    }
                }
            } else {
                Write-TestLog "❌ FAILED: $TestName - No high-confidence detection (best: $($result[0].Name) at $($result[0].Confidence)%)" "FAIL"
                global:$FAILED_TESTS++
                
                global:$TEST_RESULTS += [PSCustomObject]@{
                    Test = $TestName
                    Expected = $ExpectedFramework
                    Detected = if ($result[0]) { $result[0].Name } else { "None" }
                    Confidence = if ($result[0]) { $result[0].Confidence } else { 0 }
                    Result = "FAIL"
                    Details = "Low confidence detection"
                }
            }
        } else {
            Write-TestLog "❌ FAILED: $TestName - No framework detected" "FAIL"
            global:$FAILED_TESTS++
            
            global:$TEST_RESULTS += [PSCustomObject]@{
                Test = $TestName
                Expected = $ExpectedFramework
                Detected = "None"
                Confidence = 0
                Result = "FAIL"
                Details = "No framework detected"
            }
        }
    } catch {
        Write-TestLog "❌ FAILED: $TestName - Error during detection: $($_.Exception.Message)" "FAIL"
        global:$FAILED_TESTS++
        
        global:$TEST_RESULTS += [PSCustomObject]@{
            Test = $TestName
            Expected = $ExpectedFramework
            Detected = "Error"
            Confidence = 0
            Result = "FAIL"
            Details = "Detection script error"
        }
    }
}

# Test cases for different frameworks
function Run-AllTests {
    Write-TestLog "🚀 Starting Framework Detection Tests..." "INFO"
    
    # Cleanup test directory
    if (Test-Path $TEMP_TEST_DIR) {
        Remove-Item $TEMP_TEST_DIR -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TEMP_TEST_DIR -Force | Out-Null
    
    # Test 1: Next.js project
    Write-TestLog "📦 Test 1: Next.js Detection" "INFO"
    $nextProject = New-TestProject -ProjectName "nextjs-test" -Files @{
        "next.config.js" = "module.exports = {}"
        "package.json" = '{"dependencies": {"next": "^15.0.0", "react": "^18.0.0"}}'
        "app\layout.tsx" = 'import React from "react"; export default function Layout() { return <div></div>; }'
    } -Description "Next.js project with App Router"
    
    Test-FrameworkDetection -ProjectPath $nextProject -ExpectedFramework "Next.js" -TestName "Next.js App Router Project"
    
    # Test 2: React project
    Write-TestLog "📦 Test 2: React Detection" "INFO"
    $reactProject = New-TestProject -ProjectName "react-test" -Files @{
        "package.json" = '{"dependencies": {"react": "^18.0.0", "react-dom": "^18.0.0"}}'
        "src\App.tsx" = 'import React from "react"; export default function App() { return <div>Hello</div>; }'
        "src\index.tsx" = 'import React from "react"; import ReactDOM from "react-dom"'
    } -Description "Standard React project"
    
    Test-FrameworkDetection -ProjectPath $reactProject -ExpectedFramework "React" -TestName "Standard React Project"
    
    # Test 3: Vue.js project
    Write-TestLog "📦 Test 3: Vue.js Detection" "INFO"
    $vueProject = New-TestProject -ProjectName "vue-test" -Files @{
        "package.json" = '{"dependencies": {"vue": "^3.3.0"}}'
        "vue.config.js" = "module.exports = {}"
        "src\App.vue" = "<template><div>Hello Vue</div></template>"
        "src\main.ts" = 'import { createApp } from "vue"'
    } -Description "Vue.js 3 project"
    
    Test-FrameworkDetection -ProjectPath $vueProject -ExpectedFramework "Vue.js" -TestName "Vue.js 3 Project"
    
    # Test 4: Angular project
    Write-TestLog "📦 Test 4: Angular Detection" "INFO"
    $angularProject = New-TestProject -ProjectName "angular-test" -Files @{
        "angular.json" = '{"version": 1, "projects": {}}'
        "package.json" = '{"dependencies": {"@angular/core": "^17.0.0", "@angular/common": "^17.0.0"}}'
        "src\app\app.component.ts" = 'import { Component } from "@angular/core"'
    } -Description "Angular 17 project"
    
    Test-FrameworkDetection -ProjectPath $angularProject -ExpectedFramework "Angular" -TestName "Angular 17 Project"
    
    # Test 5: Express.js project
    Write-TestLog "📦 Test 5: Express.js Detection" "INFO"
    $expressProject = New-TestProject -ProjectName "express-test" -Files @{
        "package.json" = '{"dependencies": {"express": "^4.18.0"}}'
        "src\index.ts" = 'import express from "express"; const app = express();'
        "src\routes\users.ts" = 'import { Router } from "express"'
    } -Description "Express.js backend project"
    
    Test-FrameworkDetection -ProjectPath $expressProject -ExpectedFramework "Express.js" -TestName "Express.js Backend"
    
    # Test 6: Flutter project
    Write-TestLog "📦 Test 6: Flutter Detection" "INFO"
    $flutterProject = New-TestProject -ProjectName "flutter-test" -Files @{
        "pubspec.yaml" = "name: flutter_app`nflutter:`n  sdk: flutter`n  cupertino_icons: ^1.0.0"
        "lib\main.dart" = 'import "package:flutter/material.dart";'
        "android\app\build.gradle" = "android {"
    } -Description "Flutter mobile project"
    
    Test-FrameworkDetection -ProjectPath $flutterProject -ExpectedFramework "Flutter" -TestName "Flutter Mobile App"
    
    # Test 7: Svelte project
    Write-TestLog "📦 Test 7: Svelte Detection" "INFO"
    $svelteProject = New-TestProject -ProjectName "svelte-test" -Files @{
        "package.json" = '{"dependencies": {"svelte": "^4.0.0"}}'
        "svelte.config.js" = "export default {};"
        "src\App.svelte" = "<script>let name = 'world';</script>"
    } -Description "Svelte project"
    
    Test-FrameworkDetection -ProjectPath $svelteProject -ExpectedFramework "Svelte" -TestName "Svelte Project"
    
    # Test 8: Astro project
    Write-TestLog "📦 Test 8: Astro Detection" "INFO"
    $astroProject = New-TestProject -ProjectName "astro-test" -Files @{
        "package.json" = '{"dependencies": {"astro": "^4.0.0"}}'
        "astro.config.mjs" = "export default {};"
        "src\pages\index.astro" = "---`ntitle: Hello Astro`n---"
    } -Description "Astro project"
    
    Test-FrameworkDetection -ProjectPath $astroProject -ExpectedFramework "Astro" -TestName "Astro Static Site"
    
    # Test 9: Qwik project
    Write-TestLog "📦 Test 9: Qwik Detection" "INFO"
    $qwikProject = New-TestProject -ProjectName "qwik-test" -Files @{
        "package.json" = '{"dependencies": {"@builder.io/qwik": "^1.0.0"}}'
        "vite.config.ts" = 'import { qwikVite } from "@builder.io/qwik/optimizer"'
        "src\routes\layout.tsx" = 'import { component$ } from "@builder.io/qwik"'
    } -Description "Qwik project"
    
    Test-FrameworkDetection -ProjectPath $qwikProject -ExpectedFramework "Qwik" -TestName "Qwik Resumable App"
    
    # Test 10: SolidJS project
    Write-TestLog "📦 Test 10: SolidJS Detection" "INFO"
    $solidProject = New-TestProject -ProjectName "solid-test" -Files @{
        "package.json" = '{"dependencies": {"solid-js": "^1.8.0"}}'
        "vite.config.ts" = 'import { defineConfig } from "vite"; import solid from "vite-plugin-solid"'
        "src\App.tsx" = 'import { createSignal } from "solid-js"'
    } -Description "SolidJS project"
    
    Test-FrameworkDetection -ProjectPath $solidProject -ExpectedFramework "SolidJS" -TestName "SolidJS Reactive App"
    
    # Test 11: Django project
    Write-TestLog "📦 Test 11: Django Detection" "INFO"
    $djangoProject = New-TestProject -ProjectName "django-test" -Files @{
        "manage.py" = "import django"
        "settings.py" = "DJANGO_SETTINGS_MODULE = 'myproject.settings'"
        "requirements.txt" = "Django==4.2.0"
    } -Description "Django backend project"
    
    Test-FrameworkDetection -ProjectPath $djangoProject -ExpectedFramework "Django" -TestName "Django Backend"
    
    # Test 12: FastAPI project
    Write-TestLog "📦 Test 12: FastAPI Detection" "INFO"
    $fastapiProject = New-TestProject -ProjectName "fastapi-test" -Files @{
        "main.py" = 'from fastapi import FastAPI; app = FastAPI()'
        "requirements.txt" = "fastapi==0.104.0`nuvicorn==0.24.0"
    } -Description "FastAPI backend project"
    
    Test-FrameworkDetection -ProjectPath $fastapiProject -ExpectedFramework "FastAPI" -TestName "FastAPI Backend"
    
    # Test 13: React Native project
    Write-TestLog "📦 Test 13: React Native Detection" "INFO"
    $reactNativeProject = New-TestProject -ProjectName "react-native-test" -Files @{
        "package.json" = '{"dependencies": {"react-native": "^0.72.0", "react": "^18.0.0"}}'
        "metro.config.js" = "module.exports = {};"
        "App.tsx" = 'import React from "react"; import { View } from "react-native"'
    } -Description "React Native mobile project"
    
    Test-FrameworkDetection -ProjectPath $reactNativeProject -ExpectedFramework "React Native" -TestName "React Native Mobile"
    
    # Test 14: Multi-framework project (should detect primary)
    Write-TestLog "📦 Test 14: Multi-Framework Detection" "INFO"
    $multiProject = New-TestProject -ProjectName "multi-test" -Files @{
        "package.json" = '{"dependencies": {"next": "^15.0.0", "react": "^18.0.0", "express": "^4.18.0"}}'
        "next.config.js" = "module.exports = {}"
        "server.js" = 'const express = require("express")'
        "app\layout.tsx" = 'import React from "react"'
    } -Description "Multi-framework project"
    
    Test-FrameworkDetection -ProjectPath $multiProject -ExpectedFramework "Next.js" -TestName "Multi-Framework (Next.js Primary)"
    
    Write-TestLog "🏁 All tests completed!" "INFO"
}

function Show-TestResults {
    Write-TestLog "" "INFO"
    Write-TestLog "📊 TEST RESULTS SUMMARY" "INFO"
    Write-TestLog "========================" "INFO"
    Write-TestLog "Total Tests: $TOTAL_TESTS" "INFO"
    Write-TestLog "Passed: $PASSED_TESTS" "PASS"
    Write-TestLog "Failed: $FAILED_TESTS" $(if ($FAILED_TESTS -eq 0) { "PASS" } else { "FAIL" })
    Write-TestLog "Success Rate: $(if ($TOTAL_TESTS -gt 0) { [math]::Round(($PASSED_TESTS / $TOTAL_TESTS) * 100, 2) } else { 0 })%" "INFO"
    
    if ($Verbose -or $FAILED_TESTS -gt 0) {
        Write-TestLog "" "INFO"
        Write-TestLog "📋 DETAILED RESULTS" "INFO"
        Write-TestLog "====================" "INFO"
        
        foreach ($result in $TEST_RESULTS) {
            $status = if ($result.Result -eq "PASS") { "✅" } else { "❌" }
            Write-TestLog "$status $($result.Test)" $(if ($result.Result -eq "PASS") { "PASS" } else { "FAIL" })
            Write-TestLog "    Expected: $($result.Expected)" "INFO"
            Write-TestLog "    Detected: $($result.Detected)" "INFO"
            Write-TestLog "    Confidence: $($result.Confidence)%" "INFO"
            Write-TestLog "    Details: $($result.Details)" "INFO"
            Write-TestLog "" "INFO"
        }
    }
    
    if ($FAILED_TESTS -eq 0) {
        Write-TestLog "🎉 ALL TESTS PASSED! Framework detection is working perfectly." "PASS"
    } else {
        Write-TestLog "⚠️ Some tests failed. Review the detection logic." "WARN"
    }
}

# Main execution
try {
    Write-TestLog "🧪 Framework Detection Test Suite" "INFO"
    Write-TestLog "===================================" "INFO"
    
    # Check if detection script exists
    $detectionScript = "$PSScriptRoot\..\automation\advanced-framework-detection.ps1"
    if (-not (Test-Path $detectionScript)) {
        Write-TestLog "❌ Detection script not found: $detectionScript" "FAIL"
        exit 1
    }
    
    Run-AllTests
    Show-TestResults
    
    # Cleanup
    if (Test-Path $TEMP_TEST_DIR) {
        Remove-Item $TEMP_TEST_DIR -Recurse -Force
    }
    
    # Exit with appropriate code
    exit $(if ($FAILED_TESTS -eq 0) { 0 } else { 1 })
    
} catch {
    Write-TestLog "❌ Test suite failed: $($_.Exception.Message)" "FAIL"
    if ($Verbose) {
        Write-TestLog "Stack trace: $($_.ScriptStackTrace)" "FAIL"
    }
    exit 1
}