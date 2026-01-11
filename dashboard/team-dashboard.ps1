# ==========================================
# Team Zero Defects Dashboard
# Real-time team metrics and productivity tracking
# ==========================================

param(
    [string]$TeamName = "Development Team",
    [string]$Period = "week",
    [switch]$Live = $false,
    [string]$OutputFormat = "console",
    [string]$ReportPath = ""
)

$ErrorActionPreference = "Stop"

# Dashboard Configuration
$DASHBOARD_CONFIG = @{
    refreshInterval = 5  # seconds for live mode
    dataRetention = 30   # days
    thresholds = @{
        excellent = 95
        good = 85
        needsImprovement = 70
    }
}

# Sample team data (in production this would come from git/CI logs)
$TEAM_DATA = @{
    members = @(
        @{
            name = "Juan Pérez"
            email = "juan@company.com"
            avatar = "👨‍💻"
            stats = @{
                zeroDefectScore = 97
                commitsThisWeek = 45
                cleanCommits = 43
                errorsFixed = 2
                linesOfCode = 2850
                testsWritten = 28
                securityIssuesFound = 0
                performanceOptimizations = 3
            }
            languages = @("TypeScript", "React", "Node.js")
            lastActivity = "2 hours ago"
        },
        @{
            name = "María García"
            email = "maria@company.com"
            avatar = "👩‍💻"
            stats = @{
                zeroDefectScore = 94
                commitsThisWeek = 38
                cleanCommits = 36
                errorsFixed = 2
                linesOfCode = 2240
                testsWritten = 22
                securityIssuesFound = 1
                performanceOptimizations = 5
            }
            languages = @("TypeScript", "Vue.js", "Python")
            lastActivity = "30 minutes ago"
        },
        @{
            name = "Pedro Martínez"
            email = "pedro@company.com"
            avatar = "🧑‍💻"
            stats = @{
                zeroDefectScore = 89
                commitsThisWeek = 28
                cleanCommits = 25
                errorsFixed = 3
                linesOfCode = 1890
                testsWritten = 15
                securityIssuesFound = 2
                performanceOptimizations = 1
            }
            languages = @("JavaScript", "React", "Express.js")
            lastActivity = "1 hour ago"
        },
        @{
            name = "Ana López"
            email = "ana@company.com"
            avatar = "👩‍💼"
            stats = @{
                zeroDefectScore = 85
                commitsThisWeek = 22
                cleanCommits = 19
                errorsFixed = 3
                linesOfCode = 1650
                testsWritten = 18
                securityIssuesFound = 1
                performanceOptimizations = 2
            }
            languages = @("TypeScript", "Angular", "C#")
            lastActivity = "3 hours ago"
        },
        @{
            name = "Carlos Ruiz"
            email = "carlos@company.com"
            avatar = "👨‍🔧"
            stats = @{
                zeroDefectScore = 92
                commitsThisWeek = 35
                cleanCommits = 32
                errorsFixed = 3
                linesOfCode = 2100
                testsWritten = 25
                securityIssuesFound = 0
                performanceOptimizations = 4
            }
            languages = @("TypeScript", "Next.js", "PostgreSQL")
            lastActivity = "45 minutes ago"
        }
    )
    
    teamMetrics = @{
        totalCommits = 168
        totalLinesOfCode = 10730
        averageZeroDefectScore = 91.4
        totalTestsWritten = 108
        totalSecurityIssues = 4
        totalPerformanceOpts = 15
        codeQualityTrend = @(88, 89, 91, 92, 91, 93, 91)  # Last 7 days
    }
    
    projectMetrics = @{
        activeProjects = 3
        deploymentsThisWeek = 12
        successfulDeployments = 11
        averageBuildTime = "3m 24s"
        testCoverage = 87
        securityScore = 94
    }
}

function Get-ScoreColor {
    param([int]$Score)
    
    if ($Score -ge $DASHBOARD_CONFIG.thresholds.excellent) { return "Green" }
    elseif ($Score -ge $DASHBOARD_CONFIG.thresholds.good) { return "Yellow" }
    elseif ($Score -ge $DASHBOARD_CONFIG.thresholds.needsImprovement) { return "DarkYellow" }
    else { return "Red" }
}

function Get-ScoreEmoji {
    param([int]$Score)
    
    if ($Score -ge $DASHBOARD_CONFIG.thresholds.excellent) { return "🏆" }
    elseif ($Score -ge $DASHBOARD_CONFIG.thresholds.good) { return "⭐" }
    elseif ($Score -ge $DASHBOARD_CONFIG.thresholds.needsImprovement) { return "📈" }
    else { return "⚠️" }
}

function Show-TeamHeader {
    Write-Host ""
    Write-Host "🎯 ZERO DEFECTS TEAM DASHBOARD" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "Team: $TeamName" -ForegroundColor White
    Write-Host "Period: Last $Period" -ForegroundColor Gray
    Write-Host "Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""
}

function Show-TeamSummary {
    $metrics = $TEAM_DATA.teamMetrics
    
    Write-Host "📊 TEAM PERFORMANCE SUMMARY" -ForegroundColor Magenta
    Write-Host "=============================" -ForegroundColor Magenta
    
    # Team averages
    $avgScore = [math]::Round($metrics.averageZeroDefectScore, 1)
    $scoreColor = Get-ScoreColor -Score $avgScore
    $scoreEmoji = Get-ScoreEmoji -Score $avgScore
    
    Write-Host "🏆 Average Zero Defect Score: " -NoNewline
    Write-Host "$scoreEmoji $avgScore%" -ForegroundColor $scoreColor
    
    Write-Host "📝 Total Commits: $($metrics.totalCommits)" -ForegroundColor White
    Write-Host "📏 Lines of Code: $($metrics.totalLinesOfCode)" -ForegroundColor White
    Write-Host "🧪 Tests Written: $($metrics.totalTestsWritten)" -ForegroundColor White
    Write-Host "🛡️ Security Issues: $($metrics.totalSecurityIssues)" -ForegroundColor $(if ($metrics.totalSecurityIssues -eq 0) { "Green" } else { "Yellow" })
    Write-Host "⚡ Performance Opts: $($metrics.totalPerformanceOpts)" -ForegroundColor Green
    
    # Quality trend
    $trend = $metrics.codeQualityTrend
    $trendDirection = if ($trend[-1] -gt $trend[0]) { "📈 Improving" } elseif ($trend[-1] -lt $trend[0]) { "📉 Declining" } else { "➡️ Stable" }
    Write-Host "📈 Quality Trend: $trendDirection" -ForegroundColor $(if ($trend[-1] -gt $trend[0]) { "Green" } else { "Yellow" })
    
    Write-Host ""
}

function Show-IndividualRankings {
    Write-Host "🏆 INDIVIDUAL RANKINGS - THIS WEEK" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    
    # Sort by Zero Defect Score
    $sortedMembers = $TEAM_DATA.members | Sort-Object { $_.stats.zeroDefectScore } -Descending
    
    $position = 1
    foreach ($member in $sortedMembers) {
        $stats = $member.stats
        $scoreColor = Get-ScoreColor -Score $stats.zeroDefectScore
        $scoreEmoji = Get-ScoreEmoji -Score $stats.zeroDefectScore
        
        # Position emoji
        $positionEmoji = switch ($position) {
            1 { "🥇" }
            2 { "🥈" }
            3 { "🥉" }
            default { "🏅" }
        }
        
        Write-Host ""
        Write-Host "$positionEmoji #$position - $($member.avatar) $($member.name)" -ForegroundColor White
        Write-Host "    Zero Defect Score: $scoreEmoji $($stats.zeroDefectScore)%" -ForegroundColor $scoreColor
        Write-Host "    Commits: $($stats.cleanCommits)/$($stats.commitsThisWeek) clean" -ForegroundColor Gray
        Write-Host "    Tests: $($stats.testsWritten) | Performance: $($stats.performanceOptimizations)" -ForegroundColor Gray
        Write-Host "    Languages: $($member.languages -join ', ')" -ForegroundColor DarkGray
        Write-Host "    Last activity: $($member.lastActivity)" -ForegroundColor DarkGray
        
        $position++
    }
    
    Write-Host ""
}

function Show-DetailedMetrics {
    Write-Host "📈 DETAILED METRICS" -ForegroundColor Blue
    Write-Host "===================" -ForegroundColor Blue
    
    # Create metrics table
    Write-Host ""
    Write-Host "Developer          Score  Commits  Clean  Tests  Security  Performance" -ForegroundColor Cyan
    Write-Host "─────────────────  ─────  ───────  ─────  ─────  ────────  ───────────" -ForegroundColor DarkGray
    
    foreach ($member in $TEAM_DATA.members) {
        $stats = $member.stats
        $name = $member.name.PadRight(17)
        $score = "$($stats.zeroDefectScore)%".PadLeft(5)
        $commits = "$($stats.commitsThisWeek)".PadLeft(7)
        $clean = "$($stats.cleanCommits)".PadLeft(5)
        $tests = "$($stats.testsWritten)".PadLeft(5)
        $security = "$($stats.securityIssuesFound)".PadLeft(8)
        $performance = "$($stats.performanceOptimizations)".PadLeft(11)
        
        $scoreColor = Get-ScoreColor -Score $stats.zeroDefectScore
        
        Write-Host "$name " -NoNewline
        Write-Host "$score " -NoNewline -ForegroundColor $scoreColor
        Write-Host "$commits $clean $tests $security $performance" -ForegroundColor White
    }
    
    Write-Host ""
}

function Show-ProjectHealth {
    $metrics = $TEAM_DATA.projectMetrics
    
    Write-Host "🚀 PROJECT HEALTH" -ForegroundColor Green
    Write-Host "==================" -ForegroundColor Green
    
    Write-Host "📁 Active Projects: $($metrics.activeProjects)" -ForegroundColor White
    Write-Host "🚀 Deployments: $($metrics.successfulDeployments)/$($metrics.deploymentsThisWeek) successful" -ForegroundColor $(if ($metrics.successfulDeployments -eq $metrics.deploymentsThisWeek) { "Green" } else { "Yellow" })
    Write-Host "⏱️ Average Build Time: $($metrics.averageBuildTime)" -ForegroundColor White
    Write-Host "🧪 Test Coverage: $($metrics.testCoverage)%" -ForegroundColor $(if ($metrics.testCoverage -ge 80) { "Green" } else { "Yellow" })
    Write-Host "🛡️ Security Score: $($metrics.securityScore)%" -ForegroundColor $(if ($metrics.securityScore -ge 90) { "Green" } else { "Yellow" })
    
    Write-Host ""
}

function Show-Achievements {
    Write-Host "🏅 WEEKLY ACHIEVEMENTS" -ForegroundColor Magenta
    Write-Host "======================" -ForegroundColor Magenta
    
    # Generate achievements based on data
    $achievements = @()
    
    # Top performer
    $topPerformer = $TEAM_DATA.members | Sort-Object { $_.stats.zeroDefectScore } -Descending | Select-Object -First 1
    $achievements += "🥇 **Zero Defect Champion**: $($topPerformer.name) with $($topPerformer.stats.zeroDefectScore)% score!"
    
    # Most commits
    $mostCommits = $TEAM_DATA.members | Sort-Object { $_.stats.commitsThisWeek } -Descending | Select-Object -First 1
    $achievements += "📝 **Commit Hero**: $($mostCommits.name) with $($mostCommits.stats.commitsThisWeek) commits!"
    
    # Most tests
    $mostTests = $TEAM_DATA.members | Sort-Object { $_.stats.testsWritten } -Descending | Select-Object -First 1
    $achievements += "🧪 **Testing Master**: $($mostTests.name) wrote $($mostTests.stats.testsWritten) tests!"
    
    # Security champion
    $securityChamp = $TEAM_DATA.members | Sort-Object { $_.stats.securityIssuesFound } | Select-Object -First 1
    if ($securityChamp.stats.securityIssuesFound -eq 0) {
        $achievements += "🛡️ **Security Guardian**: $($securityChamp.name) - Zero security issues!"
    }
    
    # Performance optimizer
    $perfOptimizer = $TEAM_DATA.members | Sort-Object { $_.stats.performanceOptimizations } -Descending | Select-Object -First 1
    $achievements += "⚡ **Performance Pro**: $($perfOptimizer.name) made $($perfOptimizer.stats.performanceOptimizations) optimizations!"
    
    foreach ($achievement in $achievements) {
        Write-Host "  $achievement" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

function Show-Recommendations {
    Write-Host "💡 TEAM RECOMMENDATIONS" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    
    $recommendations = @()
    
    # Analyze team performance and generate recommendations
    $avgScore = $TEAM_DATA.teamMetrics.averageZeroDefectScore
    $lowPerformers = $TEAM_DATA.members | Where-Object { $_.stats.zeroDefectScore -lt 90 }
    $securityIssues = ($TEAM_DATA.members | Measure-Object -Property { $_.stats.securityIssuesFound } -Sum).Sum
    
    if ($avgScore -lt 90) {
        $recommendations += "📈 Focus on code quality - team average is below 90%"
    }
    
    if ($lowPerformers.Count -gt 0) {
        $names = $lowPerformers.name -join ", "
        $recommendations += "🎯 Provide additional support for: $names"
    }
    
    if ($securityIssues -gt 3) {
        $recommendations += "🛡️ Schedule security training - $securityIssues issues found this week"
    }
    
    $testCoverage = $TEAM_DATA.projectMetrics.testCoverage
    if ($testCoverage -lt 80) {
        $recommendations += "🧪 Increase test coverage - currently at $testCoverage%"
    }
    
    if ($recommendations.Count -eq 0) {
        $recommendations += "🎉 Excellent team performance! Keep up the great work!"
    }
    
    foreach ($recommendation in $recommendations) {
        Write-Host "  • $recommendation" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

function Export-DashboardReport {
    param([string]$Path, [string]$Format = "html")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $fileName = "$Path\team-dashboard-report-$timestamp.$Format"
    
    switch ($Format.ToLower()) {
        "html" {
            $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Zero Defects Team Dashboard - $TeamName</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; }
        .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }
        .metric-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .score-excellent { color: #28a745; }
        .score-good { color: #ffc107; }
        .score-needs-improvement { color: #fd7e14; }
        .score-poor { color: #dc3545; }
        .ranking { background: white; padding: 20px; border-radius: 8px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎯 Zero Defects Team Dashboard</h1>
        <p><strong>Team:</strong> $TeamName | <strong>Period:</strong> Last $Period</p>
        <p><strong>Generated:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    </div>
    
    <div class="metrics">
        <div class="metric-card">
            <h3>📊 Team Average</h3>
            <div class="score-excellent">$([math]::Round($TEAM_DATA.teamMetrics.averageZeroDefectScore, 1))%</div>
        </div>
        <div class="metric-card">
            <h3>📝 Total Commits</h3>
            <div>$($TEAM_DATA.teamMetrics.totalCommits)</div>
        </div>
        <div class="metric-card">
            <h3>🧪 Tests Written</h3>
            <div>$($TEAM_DATA.teamMetrics.totalTestsWritten)</div>
        </div>
        <div class="metric-card">
            <h3>⚡ Performance Opts</h3>
            <div>$($TEAM_DATA.teamMetrics.totalPerformanceOpts)</div>
        </div>
    </div>
    
    <div class="ranking">
        <h2>🏆 Team Rankings</h2>
        <table width="100%" border="1" style="border-collapse: collapse;">
            <tr style="background: #f8f9fa;">
                <th>Rank</th><th>Developer</th><th>Score</th><th>Commits</th><th>Tests</th>
            </tr>
"@
            
            $sortedMembers = $TEAM_DATA.members | Sort-Object { $_.stats.zeroDefectScore } -Descending
            $rank = 1
            foreach ($member in $sortedMembers) {
                $scoreClass = "score-excellent"
                if ($member.stats.zeroDefectScore -lt 95) { $scoreClass = "score-good" }
                if ($member.stats.zeroDefectScore -lt 85) { $scoreClass = "score-needs-improvement" }
                if ($member.stats.zeroDefectScore -lt 70) { $scoreClass = "score-poor" }
                
                $htmlContent += @"
            <tr>
                <td>$rank</td>
                <td>$($member.name)</td>
                <td class="$scoreClass">$($member.stats.zeroDefectScore)%</td>
                <td>$($member.stats.commitsThisWeek)</td>
                <td>$($member.stats.testsWritten)</td>
            </tr>
"@
                $rank++
            }
            
            $htmlContent += @"
        </table>
    </div>
</body>
</html>
"@
            
            Set-Content -Path $fileName -Value $htmlContent -Encoding UTF8
        }
        
        "json" {
            $TEAM_DATA | ConvertTo-Json -Depth 10 | Set-Content -Path $fileName
        }
        
        "csv" {
            $csvData = $TEAM_DATA.members | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.name
                    Email = $_.email
                    ZeroDefectScore = $_.stats.zeroDefectScore
                    Commits = $_.stats.commitsThisWeek
                    CleanCommits = $_.stats.cleanCommits
                    TestsWritten = $_.stats.testsWritten
                    SecurityIssues = $_.stats.securityIssuesFound
                    PerformanceOpts = $_.stats.performanceOptimizations
                    Languages = $_.languages -join '; '
                }
            }
            $csvData | Export-Csv -Path $fileName -NoTypeInformation
        }
    }
    
    Write-Host "📄 Report exported: $fileName" -ForegroundColor Green
}

function Start-LiveDashboard {
    while ($true) {
        Clear-Host
        Show-TeamDashboard
        
        Write-Host "🔄 Live mode - Refreshing in $($DASHBOARD_CONFIG.refreshInterval) seconds..." -ForegroundColor DarkGray
        Write-Host "Press Ctrl+C to exit" -ForegroundColor DarkGray
        
        Start-Sleep -Seconds $DASHBOARD_CONFIG.refreshInterval
        
        # In a real implementation, this would fetch fresh data
        # Update timestamp for demo
        $TEAM_DATA.lastUpdate = Get-Date
    }
}

function Show-TeamDashboard {
    Show-TeamHeader
    Show-TeamSummary
    Show-IndividualRankings
    Show-DetailedMetrics
    Show-ProjectHealth
    Show-Achievements
    Show-Recommendations
}

# Main execution
try {
    switch ($OutputFormat.ToLower()) {
        "console" {
            if ($Live) {
                Start-LiveDashboard
            } else {
                Show-TeamDashboard
            }
        }
        "html" {
            if ($ReportPath) {
                Export-DashboardReport -Path $ReportPath -Format "html"
            } else {
                Write-Host "❌ ReportPath required for HTML output" -ForegroundColor Red
                exit 1
            }
        }
        "json" {
            if ($ReportPath) {
                Export-DashboardReport -Path $ReportPath -Format "json"  
            } else {
                $TEAM_DATA | ConvertTo-Json -Depth 10
            }
        }
        "csv" {
            if ($ReportPath) {
                Export-DashboardReport -Path $ReportPath -Format "csv"
            } else {
                Write-Host "❌ ReportPath required for CSV output" -ForegroundColor Red
                exit 1
            }
        }
        default {
            Write-Host "❌ Unsupported output format: $OutputFormat" -ForegroundColor Red
            Write-Host "Supported formats: console, html, json, csv" -ForegroundColor Yellow
            exit 1
        }
    }
    
} catch {
    Write-Host "❌ Dashboard failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}