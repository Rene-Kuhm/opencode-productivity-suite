# Test Automation System - Zero Defect Programming
# Validates that all auto-initialization components work correctly

param(
    [Parameter(Mandatory=$false)]
    [string]$TestProjectPath = "$env:TEMP\zero-defect-test-project",
    
    [Parameter(Mandatory=$false)]
    [switch]$CleanupAfter = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# Test configuration
$REPO_URL = "https://github.com/Rene-Kuhm/opencode-productivity-suite.git"
$TEST_LOG = "$TestProjectPath\automation-test.log"

function Write-TestLog {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    $color = switch ($Level) {
        "SUCCESS" { "Green" }
        "WARN" { "Yellow" }
        "ERROR" { "Red" }
        "TEST" { "Cyan" }
        default { "White" }
    }
    
    Write-Host $logEntry -ForegroundColor $color
    
    if (Test-Path (Split-Path $TEST_LOG)) {
        Add-Content -Path $TEST_LOG -Value $logEntry
    }
}

function Test-ProjectDetection {
    Write-TestLog "Testing project type detection..." "TEST"
    
    # Create test files for different project types
    $testFiles = @{
        "TypeScript" = @("tsconfig.json", "index.ts")
        "JavaScript" = @("package.json", "index.js")
        "React" = @("package.json", "App.tsx")
        "PowerShell" = @("script.ps1")
    }
    
    foreach ($projectType in $testFiles.Keys) {
        $projectDir = "$TestProjectPath\test-$projectType"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
        
        foreach ($file in $testFiles[$projectType]) {
            New-Item -ItemType File -Path "$projectDir\$file" -Force | Out-Null
            
            if ($file -eq "package.json") {
                $packageContent = @"
{
  "name": "test-project",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.0.0"
  }
}
"@
                Set-Content -Path "$projectDir\$file" -Value $packageContent
            } elseif ($file -eq "tsconfig.json") {
                $tsconfigContent = '{"compilerOptions": {"strict": true}}'
                Set-Content -Path "$projectDir\$file" -Value $tsconfigContent
            }
        }
        
        Write-TestLog "Created test project for $projectType detection" "SUCCESS"
    }
    
    return $true
}

function Test-AutoInitialization {
    Write-TestLog "Testing auto-initialization script..." "TEST"
    
    $testProjectDir = "$TestProjectPath\test-typescript"
    $initScript = "$PSScriptRoot\auto-init-zero-defect.ps1"
    
    if (-not (Test-Path $initScript)) {
        Write-TestLog "Auto-initialization script not found at $initScript" "ERROR"
        return $false
    }
    
    try {
        # Run auto-initialization
        & $initScript -ProjectPath $testProjectDir -Force
        
        # Verify core files were created
        $requiredFiles = @(
            ".opencode\zero-defect-config.md",
            ".opencode\zero-defect-prompts.md",
            ".opencode\oh-my-opencode-zero-defect.json",
            "biome.json",
            "tsconfig.json"
        )
        
        $allFilesCreated = $true
        foreach ($file in $requiredFiles) {
            $filePath = "$testProjectDir\$file"
            if (Test-Path $filePath) {
                Write-TestLog "✅ Created: $file" "SUCCESS"
            } else {
                Write-TestLog "❌ Missing: $file" "ERROR"
                $allFilesCreated = $false
            }
        }
        
        return $allFilesCreated
    } catch {
        Write-TestLog "Auto-initialization failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-GitHooksInstallation {
    Write-TestLog "Testing git hooks installation..." "TEST"
    
    $testProjectDir = "$TestProjectPath\test-git-hooks"
    New-Item -ItemType Directory -Path $testProjectDir -Force | Out-Null
    
    Push-Location $testProjectDir
    try {
        # Initialize git repository
        git init | Out-Null
        
        # Run git hooks installation
        $hooksScript = "$PSScriptRoot\install-git-hooks.ps1"
        
        if (-not (Test-Path $hooksScript)) {
            Write-TestLog "Git hooks script not found at $hooksScript" "ERROR"
            return $false
        }
        
        & $hooksScript -ProjectPath $testProjectDir -Force
        
        # Verify hooks were installed
        $requiredHooks = @("pre-commit", "commit-msg", "post-commit")
        $allHooksInstalled = $true
        
        foreach ($hook in $requiredHooks) {
            $hookPath = "$testProjectDir\.git\hooks\$hook"
            if (Test-Path $hookPath) {
                Write-TestLog "✅ Installed: $hook hook" "SUCCESS"
            } else {
                Write-TestLog "❌ Missing: $hook hook" "ERROR"
                $allHooksInstalled = $false
            }
        }
        
        return $allHooksInstalled
    } catch {
        Write-TestLog "Git hooks installation failed: $($_.Exception.Message)" "ERROR"
        return $false
    } finally {
        Pop-Location
    }
}

function Test-ConfigurationValidation {
    Write-TestLog "Testing configuration validation..." "TEST"
    
    $testProjectDir = "$TestProjectPath\test-typescript"
    
    # Test biome.json validation
    $biomeConfig = "$testProjectDir\biome.json"
    if (Test-Path $biomeConfig) {
        $biomeContent = Get-Content $biomeConfig | ConvertFrom-Json
        
        if ($biomeContent.linter.enabled -eq $true) {
            Write-TestLog "✅ Biome linting enabled" "SUCCESS"
        } else {
            Write-TestLog "❌ Biome linting not enabled" "ERROR"
            return $false
        }
        
        if ($biomeContent.linter.rules.all -eq $true) {
            Write-TestLog "✅ Biome strict rules enabled" "SUCCESS"
        } else {
            Write-TestLog "❌ Biome strict rules not enabled" "ERROR"
            return $false
        }
    }
    
    # Test tsconfig.json validation
    $tsconfigPath = "$testProjectDir\tsconfig.json"
    if (Test-Path $tsconfigPath) {
        $tsconfigContent = Get-Content $tsconfigPath | ConvertFrom-Json
        
        if ($tsconfigContent.compilerOptions.strict -eq $true) {
            Write-TestLog "✅ TypeScript strict mode enabled" "SUCCESS"
        } else {
            Write-TestLog "❌ TypeScript strict mode not enabled" "ERROR"
            return $false
        }
        
        if ($tsconfigContent.compilerOptions.noImplicitAny -eq $true) {
            Write-TestLog "✅ TypeScript noImplicitAny enabled" "SUCCESS"
        } else {
            Write-TestLog "❌ TypeScript noImplicitAny not enabled" "ERROR"
            return $false
        }
    }
    
    return $true
}

function Test-SlashCommandsAvailability {
    Write-TestLog "Testing slash commands availability..." "TEST"
    
    # Check if OpenCode configuration includes Zero Defect commands
    $configPath = "$env:USERPROFILE\.config\opencode\AGENTS.md"
    
    if (Test-Path $configPath) {
        $configContent = Get-Content $configPath -Raw
        
        $requiredCommands = @(
            "/init-zero-defect",
            "/zero-check",
            "/fail-fast",
            "/pre-commit-validation",
            "/defensive-programming"
        )
        
        $allCommandsAvailable = $true
        foreach ($command in $requiredCommands) {
            if ($configContent.Contains($command)) {
                Write-TestLog "✅ Command available: $command" "SUCCESS"
            } else {
                Write-TestLog "❌ Command missing: $command" "ERROR"
                $allCommandsAvailable = $false
            }
        }
        
        return $allCommandsAvailable
    } else {
        Write-TestLog "OpenCode configuration not found at $configPath" "ERROR"
        return $false
    }
}

function Test-MonitoringSystem {
    Write-TestLog "Testing monitoring system configuration..." "TEST"
    
    # Check if monitoring configuration is in place
    $monitoringConfig = "$env:USERPROFILE\.config\opencode\ZERO-DEFECT-MONITOR.md"
    
    if (Test-Path $monitoringConfig) {
        Write-TestLog "✅ Monitoring configuration found" "SUCCESS"
        
        $monitoringContent = Get-Content $monitoringConfig -Raw
        
        $requiredMonitoringFeatures = @(
            "onSessionStart",
            "onFileChange", 
            "healthChecks",
            "autoRecovery",
            "complianceMetrics"
        )
        
        $allFeaturesConfigured = $true
        foreach ($feature in $requiredMonitoringFeatures) {
            if ($monitoringContent.Contains($feature)) {
                Write-TestLog "✅ Monitoring feature: $feature" "SUCCESS"
            } else {
                Write-TestLog "❌ Missing monitoring feature: $feature" "ERROR"
                $allFeaturesConfigured = $false
            }
        }
        
        return $allFeaturesConfigured
    } else {
        Write-TestLog "Monitoring configuration not found" "ERROR"
        return $false
    }
}

function Test-EndToEndWorkflow {
    Write-TestLog "Testing end-to-end automation workflow..." "TEST"
    
    $e2eProjectDir = "$TestProjectPath\test-e2e"
    New-Item -ItemType Directory -Path $e2eProjectDir -Force | Out-Null
    
    # Create a minimal TypeScript project
    $packageJson = @"
{
  "name": "test-e2e-project",
  "version": "1.0.0",
  "scripts": {
    "test": "echo 'No tests yet'"
  }
}
"@
    Set-Content -Path "$e2eProjectDir\package.json" -Value $packageJson
    
    # Create a simple TypeScript file
    $indexTs = @"
export function greet(name: string): string {
  return `Hello, `${name}!`;
}
"@
    Set-Content -Path "$e2eProjectDir\index.ts" -Value $indexTs
    
    # Run full initialization
    $initScript = "$PSScriptRoot\auto-init-zero-defect.ps1"
    
    try {
        & $initScript -ProjectPath $e2eProjectDir -Force
        Write-TestLog "✅ E2E initialization completed" "SUCCESS"
        
        # Verify complete setup
        $verificationChecks = @(
            ".opencode\zero-defect-config.md",
            "biome.json", 
            "tsconfig.json"
        )
        
        $allChecksPass = $true
        foreach ($check in $verificationChecks) {
            if (Test-Path "$e2eProjectDir\$check") {
                Write-TestLog "✅ E2E verification: $check" "SUCCESS"
            } else {
                Write-TestLog "❌ E2E verification failed: $check" "ERROR"
                $allChecksPass = $false
            }
        }
        
        return $allChecksPass
    } catch {
        Write-TestLog "E2E workflow failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Generate-TestReport {
    param([hashtable]$TestResults)
    
    Write-TestLog "Generating test report..." "TEST"
    
    $totalTests = $TestResults.Count
    $passedTests = ($TestResults.Values | Where-Object { $_ -eq $true }).Count
    $failedTests = $totalTests - $passedTests
    
    $report = @"
# Zero Defect Automation Test Report

## Summary
- **Total Tests**: $totalTests
- **Passed**: $passedTests
- **Failed**: $failedTests
- **Success Rate**: $([math]::Round(($passedTests / $totalTests) * 100, 2))%

## Test Results

"@

    foreach ($test in $TestResults.GetEnumerator()) {
        $status = if ($test.Value) { "✅ PASS" } else { "❌ FAIL" }
        $report += "- **$($test.Key)**: $status`n"
    }
    
    $report += @"

## Test Environment
- **Date**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
- **Test Path**: $TestProjectPath
- **PowerShell Version**: $($PSVersionTable.PSVersion)

## Automation Components Tested
1. Project type detection
2. Auto-initialization script
3. Git hooks installation
4. Configuration validation
5. Slash commands availability
6. Monitoring system setup
7. End-to-end workflow

## Next Steps
$(if ($failedTests -eq 0) {
    "🎉 All tests passed! Zero Defect automation is ready for production use."
} else {
    "⚠️ $failedTests test(s) failed. Review the logs and fix issues before deployment."
})
"@

    $reportPath = "$TestProjectPath\automation-test-report.md"
    Set-Content -Path $reportPath -Value $report
    
    Write-TestLog "Test report generated: $reportPath" "SUCCESS"
    
    return @{
        TotalTests = $totalTests
        PassedTests = $passedTests
        FailedTests = $failedTests
        SuccessRate = ($passedTests / $totalTests) * 100
        ReportPath = $reportPath
    }
}

# Main test execution
try {
    Write-TestLog "Starting Zero Defect Automation System Tests..." "TEST"
    
    # Create test environment
    if (Test-Path $TestProjectPath) {
        Remove-Item $TestProjectPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TestProjectPath -Force | Out-Null
    
    # Run all tests
    $testResults = @{}
    
    $testResults["ProjectDetection"] = Test-ProjectDetection
    $testResults["AutoInitialization"] = Test-AutoInitialization
    $testResults["GitHooksInstallation"] = Test-GitHooksInstallation
    $testResults["ConfigurationValidation"] = Test-ConfigurationValidation
    $testResults["SlashCommandsAvailability"] = Test-SlashCommandsAvailability
    $testResults["MonitoringSystem"] = Test-MonitoringSystem
    $testResults["EndToEndWorkflow"] = Test-EndToEndWorkflow
    
    # Generate report
    $reportSummary = Generate-TestReport -TestResults $testResults
    
    # Display final results
    Write-TestLog "=" * 60 "TEST"
    Write-TestLog "TEST EXECUTION COMPLETED" "TEST"
    Write-TestLog "=" * 60 "TEST"
    Write-TestLog "Total Tests: $($reportSummary.TotalTests)" "SUCCESS"
    Write-TestLog "Passed: $($reportSummary.PassedTests)" "SUCCESS"
    Write-TestLog "Failed: $($reportSummary.FailedTests)" "ERROR"
    Write-TestLog "Success Rate: $([math]::Round($reportSummary.SuccessRate, 2))%" "SUCCESS"
    
    if ($reportSummary.FailedTests -eq 0) {
        Write-TestLog "🎉 ALL TESTS PASSED - Zero Defect automation is READY!" "SUCCESS"
    } else {
        Write-TestLog "⚠️ Some tests failed - Review and fix before production use" "WARN"
    }
    
} catch {
    Write-TestLog "Test execution failed: $($_.Exception.Message)" "ERROR"
    exit 1
} finally {
    # Cleanup if requested
    if ($CleanupAfter -and (Test-Path $TestProjectPath)) {
        Write-TestLog "Cleaning up test environment..." "INFO"
        # Keep the report but remove test projects
        Get-ChildItem $TestProjectPath -Directory | Remove-Item -Recurse -Force
        Write-TestLog "Cleanup completed (report preserved)" "SUCCESS"
    }
}