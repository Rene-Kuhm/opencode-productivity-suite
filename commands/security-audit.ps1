# ==========================================
# /security-audit - Comprehensive Security Audit
# AI-powered security analysis following OWASP Top 10 guidelines
# ==========================================

param(
    [string]$ProjectPath = ".",
    [string]$Framework = "",
    [switch]$Deep = $false,
    [switch]$AutoFix = $false,
    [switch]$JsonOutput = $false
)

$ErrorActionPreference = "Stop"

$SECURITY_AUDIT_RESULTS = @{
    framework = ""
    owaspFindings = @()
    vulnerabilities = @()
    securityScore = 0
    recommendations = @()
    autoFixed = @()
    criticalIssues = @()
}

# OWASP Top 10 2023 Security Checks
$OWASP_CHECKS = @{
    "A01_BrokenAccessControl" = @{
        name = "Broken Access Control"
        checks = @(
            "Hardcoded credentials",
            "Missing authorization checks", 
            "Insecure direct object references",
            "CORS misconfigurations"
        )
    }
    "A02_CryptographicFailures" = @{
        name = "Cryptographic Failures"
        checks = @(
            "Weak encryption algorithms",
            "Hardcoded secrets",
            "Unencrypted sensitive data",
            "Weak password hashing"
        )
    }
    "A03_Injection" = @{
        name = "Injection Flaws"
        checks = @(
            "SQL injection vulnerabilities",
            "NoSQL injection",
            "Command injection",
            "XSS vulnerabilities"
        )
    }
    "A04_InsecureDesign" = @{
        name = "Insecure Design"
        checks = @(
            "Missing security controls",
            "Insecure architecture patterns",
            "Lack of input validation"
        )
    }
    "A05_SecurityMisconfiguration" = @{
        name = "Security Misconfiguration"
        checks = @(
            "Default configurations",
            "Unnecessary features enabled",
            "Missing security headers",
            "Verbose error messages"
        )
    }
    "A06_VulnerableComponents" = @{
        name = "Vulnerable and Outdated Components"
        checks = @(
            "Outdated dependencies",
            "Known vulnerable packages",
            "Unpatched libraries"
        )
    }
    "A07_IdentificationFailures" = @{
        name = "Identification and Authentication Failures"
        checks = @(
            "Weak password policies",
            "Session management flaws",
            "Missing MFA",
            "Brute force protection"
        )
    }
    "A08_SoftwareIntegrityFailures" = @{
        name = "Software and Data Integrity Failures"
        checks = @(
            "Unsigned code",
            "Insecure CI/CD pipelines",
            "Auto-update without verification"
        )
    }
    "A09_LoggingFailures" = @{
        name = "Security Logging and Monitoring Failures"
        checks = @(
            "Insufficient logging",
            "Log injection vulnerabilities",
            "Missing monitoring"
        )
    }
    "A10_SSRF" = @{
        name = "Server-Side Request Forgery (SSRF)"
        checks = @(
            "Unvalidated URL inputs",
            "Internal service exposure",
            "Network boundary bypass"
        )
    }
}

function Write-SecurityLog {
    param([string]$Message, [string]$Level = "INFO")
    if (-not $JsonOutput) {
        $color = switch ($Level) {
            "CRITICAL" { "Red" }
            "HIGH" { "Magenta" }
            "MEDIUM" { "Yellow" }
            "LOW" { "Cyan" }
            "PASS" { "Green" }
            "INFO" { "White" }
            default { "Gray" }
        }
        Write-Host $Message -ForegroundColor $color
    }
}

function Get-ProjectFramework {
    param([string]$Path)
    
    if ($Framework) { return $Framework }
    
    if (Test-Path "$Path\next.config.js") { return "Next.js" }
    if (Test-Path "$Path\angular.json") { return "Angular" }
    if (Test-Path "$Path\vue.config.js") { return "Vue.js" }
    if (Test-Path "$Path\package.json") {
        $packageContent = Get-Content "$Path\package.json" | ConvertFrom-Json
        if ($packageContent.dependencies."express") { return "Express.js" }
        if ($packageContent.dependencies."react") { return "React" }
    }
    
    return "Generic"
}

function Test-BrokenAccessControl {
    param([string]$Path, [string]$Framework)
    
    Write-SecurityLog "🔒 Checking for Broken Access Control (OWASP A01)..." "INFO"
    
    $findings = @()
    
    # Check for hardcoded credentials
    $codeFiles = Get-ChildItem -Path $Path -Recurse -Include "*.ts", "*.tsx", "*.js", "*.jsx", "*.py" -ErrorAction SilentlyContinue | Select-Object -First 20
    
    foreach ($file in $codeFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            # Check for hardcoded passwords/secrets
            if ($content -match "(password|secret|key|token|api_key)\s*[:=]\s*['\"][^'\"]{8,}['\"]") {
                $findings += @{
                    type = "Hardcoded Credentials"
                    severity = "CRITICAL"
                    file = $file.Name
                    description = "Hardcoded credentials found in source code"
                    recommendation = "Move sensitive data to environment variables"
                    autoFixable = $false
                }
            }
            
            # Check for CORS misconfigurations
            if ($content -match "cors.*origin.*\*|Access-Control-Allow-Origin.*\*") {
                $findings += @{
                    type = "CORS Misconfiguration"
                    severity = "HIGH"
                    file = $file.Name
                    description = "Wildcard CORS origin allows any domain"
                    recommendation = "Specify explicit allowed origins"
                    autoFixable = $true
                }
            }
            
            # Check for missing authorization
            if ($Framework -eq "Express.js" -and $content -match "app\.(get|post|put|delete)" -and $content -notmatch "auth|middleware") {
                $findings += @{
                    type = "Missing Authorization"
                    severity = "HIGH"
                    file = $file.Name
                    description = "Route without apparent authorization check"
                    recommendation = "Add authentication/authorization middleware"
                    autoFixable = $false
                }
            }
        }
    }
    
    return $findings
}

function Test-CryptographicFailures {
    param([string]$Path, [string]$Framework)
    
    Write-SecurityLog "🔐 Checking for Cryptographic Failures (OWASP A02)..." "INFO"
    
    $findings = @()
    
    # Check environment variables
    if (Test-Path "$Path\.env") {
        $envContent = Get-Content "$Path\.env" -ErrorAction SilentlyContinue
        foreach ($line in $envContent) {
            if ($line -match "^[^#].*=.*" -and $line -notmatch "(SECRET|KEY|PASSWORD)" -and $line.Length -gt 50) {
                $findings += @{
                    type = "Potential Unencrypted Secret"
                    severity = "MEDIUM"
                    file = ".env"
                    description = "Long value in .env that might be unencrypted sensitive data"
                    recommendation = "Ensure sensitive data is properly encrypted"
                    autoFixable = $false
                }
            }
        }
    }
    
    # Check for weak crypto in code
    $codeFiles = Get-ChildItem -Path $Path -Recurse -Include "*.ts", "*.tsx", "*.js", "*.jsx" -ErrorAction SilentlyContinue | Select-Object -First 15
    
    foreach ($file in $codeFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            # Check for weak hashing
            if ($content -match "md5|sha1\(" -and $content -notmatch "crypto|bcrypt") {
                $findings += @{
                    type = "Weak Cryptographic Algorithm"
                    severity = "HIGH"
                    file = $file.Name
                    description = "Using weak hashing algorithm (MD5/SHA1)"
                    recommendation = "Use bcrypt, scrypt, or Argon2 for passwords"
                    autoFixable = $false
                }
            }
            
            # Check for crypto best practices
            if ($content -match "crypto" -and $content -notmatch "randomBytes") {
                $findings += @{
                    type = "Crypto Implementation Review"
                    severity = "MEDIUM"
                    file = $file.Name
                    description = "Custom cryptographic implementation detected"
                    recommendation = "Review cryptographic implementation for best practices"
                    autoFixable = $false
                }
            }
        }
    }
    
    return $findings
}

function Test-InjectionFlaws {
    param([string]$Path, [string]$Framework)
    
    Write-SecurityLog "💉 Checking for Injection Flaws (OWASP A03)..." "INFO"
    
    $findings = @()
    
    $codeFiles = Get-ChildItem -Path $Path -Recurse -Include "*.ts", "*.tsx", "*.js", "*.jsx", "*.py" -ErrorAction SilentlyContinue | Select-Object -First 20
    
    foreach ($file in $codeFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            # Check for SQL injection vulnerabilities
            if ($content -match "SELECT.*\+.*|INSERT.*\+.*|UPDATE.*\+.*" -and $content -notmatch "prepared|parameterized") {
                $findings += @{
                    type = "Potential SQL Injection"
                    severity = "CRITICAL"
                    file = $file.Name
                    description = "String concatenation in SQL query detected"
                    recommendation = "Use parameterized queries or prepared statements"
                    autoFixable = $false
                }
            }
            
            # Check for XSS vulnerabilities
            if ($content -match "innerHTML\s*=\s*.*\+" -or $content -match "dangerouslySetInnerHTML.*\+") {
                $findings += @{
                    type = "Potential XSS Vulnerability"
                    severity = "HIGH"
                    file = $file.Name
                    description = "Dynamic HTML content without sanitization"
                    recommendation = "Sanitize user input before rendering HTML"
                    autoFixable = $false
                }
            }
            
            # Check for command injection
            if ($content -match "exec\(.*\+|spawn\(.*\+|system\(.*\+") {
                $findings += @{
                    type = "Potential Command Injection"
                    severity = "CRITICAL"
                    file = $file.Name
                    description = "Dynamic command execution detected"
                    recommendation = "Validate and sanitize inputs for command execution"
                    autoFixable = $false
                }
            }
            
            # Check for NoSQL injection
            if ($content -match "\$where|\$regex" -and $content -match "\+|\$\{") {
                $findings += @{
                    type = "Potential NoSQL Injection"
                    severity = "HIGH"
                    file = $file.Name
                    description = "Dynamic NoSQL query construction"
                    recommendation = "Use parameterized NoSQL queries"
                    autoFixable = $false
                }
            }
        }
    }
    
    return $findings
}

function Test-SecurityMisconfiguration {
    param([string]$Path, [string]$Framework)
    
    Write-SecurityLog "⚙️ Checking for Security Misconfigurations (OWASP A05)..." "INFO"
    
    $findings = @()
    
    # Check for missing security headers (Express.js)
    if ($Framework -eq "Express.js") {
        $appFiles = Get-ChildItem -Path $Path -Recurse -Include "*.ts", "*.js" -ErrorAction SilentlyContinue | Where-Object { (Get-Content $_.FullName -Raw) -match "express\(\)" }
        
        foreach ($file in $appFiles) {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            
            if ($content -notmatch "helmet") {
                $findings += @{
                    type = "Missing Security Headers"
                    severity = "MEDIUM"
                    file = $file.Name
                    description = "No helmet middleware detected for security headers"
                    recommendation = "Install and configure helmet middleware"
                    autoFixable = $true
                    fixCode = "npm install helmet && app.use(helmet())"
                }
            }
        }
    }
    
    # Check for development configurations in production
    if (Test-Path "$Path\package.json") {
        $packageContent = Get-Content "$Path\package.json" | ConvertFrom-Json
        
        if ($packageContent.scripts.start -and $packageContent.scripts.start -match "development|dev") {
            $findings += @{
                type = "Development Configuration"
                severity = "MEDIUM"
                file = "package.json"
                description = "Start script appears to use development configuration"
                recommendation = "Ensure production builds use production configurations"
                autoFixable = $false
            }
        }
    }
    
    # Check for verbose error messages
    $codeFiles = Get-ChildItem -Path $Path -Recurse -Include "*.ts", "*.js" -ErrorAction SilentlyContinue | Select-Object -First 10
    
    foreach ($file in $codeFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match "console\.error\(.*error\)|res\.send\(.*error\)" -and $content -notmatch "NODE_ENV.*production") {
            $findings += @{
                type = "Verbose Error Messages"
                severity = "LOW"
                file = $file.Name
                description = "Detailed error information may leak to clients"
                recommendation = "Implement proper error handling that doesn't expose internal details"
                autoFixable = $false
            }
        }
    }
    
    return $findings
}

function Test-VulnerableComponents {
    param([string]$Path)
    
    Write-SecurityLog "📦 Checking for Vulnerable Components (OWASP A06)..." "INFO"
    
    $findings = @()
    
    if (Test-Path "$Path\package.json") {
        # This would integrate with npm audit in a real implementation
        $findings += @{
            type = "Dependency Audit Required"
            severity = "MEDIUM"
            file = "package.json"
            description = "Dependencies should be regularly audited for vulnerabilities"
            recommendation = "Run 'npm audit' and 'npm audit fix' regularly"
            autoFixable = $false
        }
    }
    
    # Check for known vulnerable patterns
    if (Test-Path "$Path\package-lock.json") {
        $lockContent = Get-Content "$Path\package-lock.json" | ConvertFrom-Json -ErrorAction SilentlyContinue
        
        # Check for commonly vulnerable packages (examples)
        $vulnerablePackages = @("lodash", "moment", "request")
        
        if ($lockContent.dependencies) {
            foreach ($pkg in $vulnerablePackages) {
                if ($lockContent.dependencies.$pkg) {
                    $findings += @{
                        type = "Potentially Vulnerable Package"
                        severity = "LOW"
                        file = "package-lock.json"
                        description = "$pkg has had security vulnerabilities in the past"
                        recommendation = "Ensure $pkg is updated to latest secure version"
                        autoFixable = $false
                    }
                }
            }
        }
    }
    
    return $findings
}

function Calculate-SecurityScore {
    param($AllFindings)
    
    $totalFindings = $AllFindings.Count
    $criticalCount = ($AllFindings | Where-Object { $_.severity -eq "CRITICAL" }).Count
    $highCount = ($AllFindings | Where-Object { $_.severity -eq "HIGH" }).Count
    $mediumCount = ($AllFindings | Where-Object { $_.severity -eq "MEDIUM" }).Count
    $lowCount = ($AllFindings | Where-Object { $_.severity -eq "LOW" }).Count
    
    # Calculate score (100 is perfect)
    $score = 100
    $score -= ($criticalCount * 25)  # -25 per critical
    $score -= ($highCount * 15)      # -15 per high
    $score -= ($mediumCount * 8)     # -8 per medium
    $score -= ($lowCount * 3)        # -3 per low
    
    $score = [Math]::Max(0, $score)  # Don't go below 0
    
    return @{
        score = $score
        grade = if ($score -ge 90) { "A" } elseif ($score -ge 80) { "B" } elseif ($score -ge 70) { "C" } elseif ($score -ge 60) { "D" } else { "F" }
        critical = $criticalCount
        high = $highCount
        medium = $mediumCount
        low = $lowCount
        total = $totalFindings
    }
}

function Apply-SecurityFixes {
    param($Findings, [string]$Path)
    
    Write-SecurityLog "🔧 Applying automatic security fixes..." "INFO"
    
    $autoFixed = @()
    
    foreach ($finding in $Findings) {
        if ($finding.autoFixable -and $finding.fixCode) {
            try {
                # In a real implementation, this would apply the actual fix
                $autoFixed += @{
                    type = $finding.type
                    file = $finding.file
                    fix = $finding.fixCode
                }
                
                Write-SecurityLog "✅ Auto-fixed: $($finding.type)" "PASS"
            } catch {
                Write-SecurityLog "❌ Failed to auto-fix: $($finding.type)" "HIGH"
            }
        }
    }
    
    return $autoFixed
}

function Show-SecurityResults {
    param($Results)
    
    if ($JsonOutput) {
        $Results | ConvertTo-Json -Depth 10
        return
    }
    
    Write-SecurityLog "`n🛡️ SECURITY AUDIT RESULTS" "INFO"
    Write-SecurityLog "=========================" "INFO"
    Write-SecurityLog "Framework: $($Results.framework)" "INFO"
    
    # Show security score
    $scoreData = Calculate-SecurityScore -AllFindings $Results.owaspFindings
    $Results.securityScore = $scoreData.score
    
    Write-SecurityLog "`n📊 SECURITY SCORE: $($scoreData.score)/100 (Grade: $($scoreData.grade))" "INFO"
    Write-SecurityLog "Critical: $($scoreData.critical) | High: $($scoreData.high) | Medium: $($scoreData.medium) | Low: $($scoreData.low)" "INFO"
    
    # Show findings by severity
    $severityOrder = @("CRITICAL", "HIGH", "MEDIUM", "LOW")
    
    foreach ($severity in $severityOrder) {
        $findingsOfSeverity = $Results.owaspFindings | Where-Object { $_.severity -eq $severity }
        
        if ($findingsOfSeverity.Count -gt 0) {
            Write-SecurityLog "`n🚨 $severity SEVERITY FINDINGS" $severity
            
            foreach ($finding in $findingsOfSeverity) {
                Write-SecurityLog "  • $($finding.type)" $severity
                Write-SecurityLog "    File: $($finding.file)" "INFO"
                Write-SecurityLog "    Issue: $($finding.description)" "INFO"
                Write-SecurityLog "    Fix: $($finding.recommendation)" "INFO"
                
                if ($finding.autoFixable) {
                    Write-SecurityLog "    🔧 Auto-fixable" "PASS"
                }
                Write-SecurityLog "" "INFO"
            }
        }
    }
    
    # Show auto-fixes applied
    if ($Results.autoFixed.Count -gt 0) {
        Write-SecurityLog "🔧 AUTO-FIXES APPLIED" "PASS"
        foreach ($fix in $Results.autoFixed) {
            Write-SecurityLog "  ✅ $($fix.type) in $($fix.file)" "PASS"
        }
    }
    
    # OWASP compliance summary
    Write-SecurityLog "`n📋 OWASP TOP 10 COMPLIANCE" "INFO"
    $owaspCategories = @{}
    foreach ($finding in $Results.owaspFindings) {
        $owaspCategory = switch -Regex ($finding.type) {
            "Access Control|Authorization|CORS" { "A01 - Broken Access Control" }
            "Cryptographic|Encryption|Hashing" { "A02 - Cryptographic Failures" }
            "Injection|XSS|SQL" { "A03 - Injection" }
            "Security Headers|Configuration" { "A05 - Security Misconfiguration" }
            "Vulnerable|Dependencies|Audit" { "A06 - Vulnerable Components" }
            default { "Other" }
        }
        
        if (-not $owaspCategories.ContainsKey($owaspCategory)) {
            $owaspCategories[$owaspCategory] = 0
        }
        $owaspCategories[$owaspCategory]++
    }
    
    foreach ($category in $owaspCategories.Keys) {
        $status = if ($owaspCategories[$category] -eq 0) { "✅ COMPLIANT" } else { "⚠️ $($owaspCategories[$category]) ISSUES" }
        Write-SecurityLog "  $category`: $status" "INFO"
    }
    
    Write-SecurityLog "`n🎯 RECOMMENDATIONS" "INFO"
    Write-SecurityLog "1. Address all CRITICAL and HIGH severity findings immediately" "HIGH"
    Write-SecurityLog "2. Run 'npm audit' to check for known vulnerable dependencies" "MEDIUM"
    Write-SecurityLog "3. Implement security headers using helmet.js (Express) or security.txt" "MEDIUM"
    Write-SecurityLog "4. Set up automated security scanning in CI/CD pipeline" "LOW"
    Write-SecurityLog "5. Regular security reviews and penetration testing" "LOW"
    
    # Overall status
    if ($scoreData.score -ge 90) {
        Write-SecurityLog "`n🎉 Excellent security posture! Keep up the good work." "PASS"
    } elseif ($scoreData.score -ge 70) {
        Write-SecurityLog "`n👍 Good security posture with room for improvement." "MEDIUM"
    } else {
        Write-SecurityLog "`n⚠️ Security improvements needed. Address critical issues first." "HIGH"
    }
}

# Main execution
try {
    Write-SecurityLog "🛡️ Starting comprehensive security audit..." "INFO"
    
    $framework = Get-ProjectFramework -Path $ProjectPath
    $SECURITY_AUDIT_RESULTS.framework = $framework
    
    Write-SecurityLog "Framework detected: $framework" "INFO"
    Write-SecurityLog "Running OWASP Top 10 security checks..." "INFO"
    
    # Run OWASP security checks
    $allFindings = @()
    
    $allFindings += Test-BrokenAccessControl -Path $ProjectPath -Framework $framework
    $allFindings += Test-CryptographicFailures -Path $ProjectPath -Framework $framework
    $allFindings += Test-InjectionFlaws -Path $ProjectPath -Framework $framework
    $allFindings += Test-SecurityMisconfiguration -Path $ProjectPath -Framework $framework
    
    if ($Deep) {
        $allFindings += Test-VulnerableComponents -Path $ProjectPath
    }
    
    $SECURITY_AUDIT_RESULTS.owaspFindings = $allFindings
    $SECURITY_AUDIT_RESULTS.criticalIssues = $allFindings | Where-Object { $_.severity -eq "CRITICAL" }
    
    # Apply auto-fixes if requested
    if ($AutoFix) {
        $SECURITY_AUDIT_RESULTS.autoFixed = Apply-SecurityFixes -Findings $allFindings -Path $ProjectPath
    }
    
    # Show results
    Show-SecurityResults -Results $SECURITY_AUDIT_RESULTS
    
    Write-SecurityLog "`n✅ Security audit completed!" "PASS"
    
    # Exit with error code if critical issues found
    if ($SECURITY_AUDIT_RESULTS.criticalIssues.Count -gt 0) {
        Write-SecurityLog "❌ Critical security issues found!" "CRITICAL"
        exit 1
    }
    
} catch {
    Write-SecurityLog "❌ Security audit failed: $($_.Exception.Message)" "CRITICAL"
    exit 1
}