# ==========================================
# /suggest-patterns - Framework-Specific Pattern Suggestions
# AI-powered pattern recommendations based on project context
# ==========================================

param(
    [string]$ProjectPath = ".",
    [string]$Component = "",
    [string]$Framework = "",
    [switch]$Security = $false,
    [switch]$Performance = $false,
    [switch]$Components = $false,
    [switch]$JsonOutput = $false
)

$ErrorActionPreference = "Stop"

# Pattern Database by Framework
$PATTERN_DATABASE = @{
    "Next.js" = @{
        components = @(
            @{
                name = "Server Component with Loading"
                pattern = "async-server-component"
                code = @"
// app/users/page.tsx
import { Suspense } from 'react'
import { UsersList } from './users-list'
import { UsersLoading } from './users-loading'

export default function UsersPage() {
  return (
    <div>
      <h1>Users</h1>
      <Suspense fallback={<UsersLoading />}>
        <UsersList />
      </Suspense>
    </div>
  )
}

// app/users/users-list.tsx  
import { getUsers } from '@/lib/api'

export async function UsersList() {
  const users = await getUsers()
  
  return (
    <div>
      {users.map((user) => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  )
}
"@
                description = "Server Component with proper loading states using Suspense"
                benefits = @("Better SEO", "Faster initial load", "Automatic loading states")
            },
            @{
                name = "Error Boundary with App Router"
                pattern = "error-boundary"
                code = @"
// app/error.tsx
'use client'
 
import { useEffect } from 'react'
 
export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error(error)
  }, [error])
 
  return (
    <div className="error-boundary">
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>
        Try again
      </button>
    </div>
  )
}
"@
                description = "Proper error handling with App Router error boundaries"
                benefits = @("Better UX", "Error recovery", "Automatic error isolation")
            }
        )
        api = @(
            @{
                name = "Route Handler with Validation"
                pattern = "route-handler-zod"
                code = @"
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

const CreateUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { name, email } = CreateUserSchema.parse(body)
    
    // Create user logic here
    const user = await createUser({ name, email })
    
    return NextResponse.json({ user }, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Invalid input', details: error.errors },
        { status: 400 }
      )
    }
    
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
"@
                description = "Route handler with Zod validation and proper error handling"
                benefits = @("Type safety", "Input validation", "Better error handling")
            }
        )
        performance = @(
            @{
                name = "Dynamic Imports with Loading"
                pattern = "dynamic-imports"
                code = @"
// components/heavy-component.tsx
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('./heavy-chart'), {
  loading: () => <p>Loading chart...</p>,
  ssr: false // Disable SSR if not needed
})

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <HeavyChart />
    </div>
  )
}
"@
                description = "Dynamic imports for heavy components with loading states"
                benefits = @("Reduced bundle size", "Faster initial load", "Better Core Web Vitals")
            }
        )
        security = @(
            @{
                name = "Environment Variable Validation"
                pattern = "env-validation"
                code = @"
// lib/env.ts
import { z } from 'zod'

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  NEXTAUTH_SECRET: z.string().min(32),
  NEXTAUTH_URL: z.string().url(),
  NODE_ENV: z.enum(['development', 'production', 'test']),
})

export const env = envSchema.parse(process.env)
"@
                description = "Runtime validation of environment variables"
                benefits = @("Early error detection", "Type safety", "Configuration validation")
            }
        )
    }
    
    "React" = @{
        components = @(
            @{
                name = "Custom Hook with Error Handling"
                pattern = "custom-hook-error"
                code = @"
// hooks/use-api-data.ts
import { useState, useEffect } from 'react'

interface UseApiDataResult<T> {
  data: T | null
  loading: boolean
  error: Error | null
  refetch: () => void
}

export function useApiData<T>(url: string): UseApiDataResult<T> {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchData = async () => {
    try {
      setLoading(true)
      setError(null)
      const response = await fetch(url)
      if (!response.ok) {
        throw new Error(`Failed to fetch: `${response.statusText}`)
      }
      const result = await response.json()
      setData(result)
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'))
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [url])

  return { data, loading, error, refetch: fetchData }
}
"@
                description = "Reusable hook with proper error handling and loading states"
                benefits = @("Reusability", "Error handling", "Loading states", "Type safety")
            },
            @{
                name = "Memoized Component with Props"
                pattern = "memo-component"
                code = @"
// components/user-card.tsx
import React, { memo } from 'react'

interface UserCardProps {
  id: string
  name: string
  email: string
  avatar?: string
  onClick?: (id: string) => void
}

const UserCard = memo<UserCardProps>(({ 
  id, 
  name, 
  email, 
  avatar, 
  onClick 
}) => {
  return (
    <div 
      className="user-card"
      onClick={() => onClick?.(id)}
    >
      {avatar && <img src={avatar} alt={name} />}
      <h3>{name}</h3>
      <p>{email}</p>
    </div>
  )
})

UserCard.displayName = 'UserCard'

export { UserCard }
"@
                description = "Memoized component to prevent unnecessary re-renders"
                benefits = @("Performance optimization", "Reduced re-renders", "Better UX")
            }
        )
        hooks = @(
            @{
                name = "useLocalStorage Hook"
                pattern = "use-local-storage"
                code = @"
// hooks/use-local-storage.ts
import { useState, useEffect } from 'react'

export function useLocalStorage<T>(
  key: string, 
  initialValue: T
): [T, (value: T | ((val: T) => T)) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === 'undefined') {
      return initialValue
    }
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch (error) {
      console.error(`Error reading localStorage key "`${key}":`, error)
      return initialValue
    }
  })

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value
      setStoredValue(valueToStore)
      
      if (typeof window !== 'undefined') {
        window.localStorage.setItem(key, JSON.stringify(valueToStore))
      }
    } catch (error) {
      console.error(`Error setting localStorage key "`${key}":`, error)
    }
  }

  return [storedValue, setValue]
}
"@
                description = "Hook for managing localStorage with SSR safety"
                benefits = @("SSR compatible", "Error handling", "Type safe", "Persistent state")
            }
        )
    }
    
    "Express.js" = @{
        middleware = @(
            @{
                name = "Error Handler Middleware"
                pattern = "error-handler"
                code = @"
// middleware/error-handler.ts
import { Request, Response, NextFunction } from 'express'
import { ZodError } from 'zod'

export interface AppError extends Error {
  statusCode?: number
  isOperational?: boolean
}

export const errorHandler = (
  error: AppError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Zod validation errors
  if (error instanceof ZodError) {
    return res.status(400).json({
      error: 'Validation Error',
      details: error.errors
    })
  }

  // Operational errors
  if (error.isOperational) {
    return res.status(error.statusCode || 500).json({
      error: error.message
    })
  }

  // Programming errors - don't leak to client
  console.error('Unexpected Error:', error)
  
  res.status(500).json({
    error: 'Internal Server Error'
  })
}

export const asyncHandler = (fn: Function) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next)
  }
}
"@
                description = "Comprehensive error handling middleware with async support"
                benefits = @("Centralized error handling", "Security", "Better debugging")
            }
        )
        routes = @(
            @{
                name = "Route with Validation"
                pattern = "route-validation"
                code = @"
// routes/users.ts
import { Router } from 'express'
import { z } from 'zod'
import { asyncHandler } from '../middleware/error-handler'
import { validate } from '../middleware/validate'

const router = Router()

const CreateUserSchema = z.object({
  body: z.object({
    name: z.string().min(1),
    email: z.string().email(),
    age: z.number().min(18).optional()
  })
})

router.post('/users', 
  validate(CreateUserSchema),
  asyncHandler(async (req, res) => {
    const { name, email, age } = req.body
    
    // Business logic here
    const user = await userService.create({ name, email, age })
    
    res.status(201).json({ user })
  })
)

export { router as userRoutes }
"@
                description = "Route with Zod validation and async error handling"
                benefits = @("Input validation", "Type safety", "Error handling")
            }
        )
    }
    
    "Vue.js" = @{
        components = @(
            @{
                name = "Composable with Error Handling"
                pattern = "composable-error"
                code = @"
// composables/useApi.ts
import { ref, computed } from 'vue'

export function useApi<T>(url: string) {
  const data = ref<T | null>(null)
  const error = ref<Error | null>(null)
  const isLoading = ref(false)

  const execute = async () => {
    try {
      isLoading.value = true
      error.value = null
      
      const response = await fetch(url)
      if (!response.ok) {
        throw new Error(`HTTP Error: `${response.status}`)
      }
      
      data.value = await response.json()
    } catch (err) {
      error.value = err instanceof Error ? err : new Error('Unknown error')
    } finally {
      isLoading.value = false
    }
  }

  const refresh = () => execute()

  const isSuccess = computed(() => data.value !== null && error.value === null)
  const isError = computed(() => error.value !== null)

  return {
    data: readonly(data),
    error: readonly(error),
    isLoading: readonly(isLoading),
    isSuccess,
    isError,
    execute,
    refresh
  }
}
"@
                description = "Vue 3 composable with comprehensive error handling"
                benefits = @("Reusability", "Reactive state", "Error handling", "Type safety")
            }
        )
    }
}

function Get-ProjectFramework {
    param([string]$Path)
    
    if ($Framework) { return $Framework }
    
    # Quick framework detection
    if (Test-Path "$Path\next.config.js") { return "Next.js" }
    if (Test-Path "$Path\angular.json") { return "Angular" }
    if (Test-Path "$Path\vue.config.js") { return "Vue.js" }
    if (Test-Path "$Path\svelte.config.js") { return "Svelte" }
    
    # Check package.json for framework hints
    if (Test-Path "$Path\package.json") {
        $packageContent = Get-Content "$Path\package.json" | ConvertFrom-Json
        if ($packageContent.dependencies) {
            if ($packageContent.dependencies."next") { return "Next.js" }
            if ($packageContent.dependencies."react") { return "React" }
            if ($packageContent.dependencies."vue") { return "Vue.js" }
            if ($packageContent.dependencies."express") { return "Express.js" }
        }
    }
    
    return "Generic"
}

function Get-RelevantPatterns {
    param([string]$Framework, [string]$Component, [switch]$Security, [switch]$Performance, [switch]$Components)
    
    if (-not $PATTERN_DATABASE.ContainsKey($Framework)) {
        return @()
    }
    
    $frameworkPatterns = $PATTERN_DATABASE[$Framework]
    $relevantPatterns = @()
    
    # Filter by category if specified
    if ($Security -and $frameworkPatterns.ContainsKey("security")) {
        $relevantPatterns += $frameworkPatterns.security
    }
    
    if ($Performance -and $frameworkPatterns.ContainsKey("performance")) {
        $relevantPatterns += $frameworkPatterns.performance
    }
    
    if ($Components) {
        $relevantPatterns += Get-ComponentLibrarySuggestions -Framework $Framework
    }
    
    # Filter by component type if specified
    if ($Component) {
        $componentLower = $Component.ToLower()
        foreach ($category in $frameworkPatterns.Keys) {
            if ($category -like "*$componentLower*" -or $componentLower -like "*$category*") {
                $relevantPatterns += $frameworkPatterns[$category]
            }
        }
    }
    
    # If no specific filters, return most common patterns
    if (-not $Security -and -not $Performance -and -not $Component -and -not $Components) {
        if ($frameworkPatterns.ContainsKey("components")) {
            $relevantPatterns += $frameworkPatterns.components | Select-Object -First 2
        }
        if ($frameworkPatterns.ContainsKey("hooks")) {
            $relevantPatterns += $frameworkPatterns.hooks | Select-Object -First 1
        }
        if ($frameworkPatterns.ContainsKey("api")) {
            $relevantPatterns += $frameworkPatterns.api | Select-Object -First 1
        }
        # Also include component library suggestions by default
        $relevantPatterns += Get-ComponentLibrarySuggestions -Framework $Framework
    }
    
    return $relevantPatterns
}

function Get-ComponentLibrarySuggestions {
    param([string]$Framework)
    
    $componentLibraryPath = Join-Path (Split-Path $PSScriptRoot -Parent) "component-libraries-research.json"
    
    if (-not (Test-Path $componentLibraryPath)) {
        return @()
    }
    
    try {
        $libraryData = Get-Content $componentLibraryPath | ConvertFrom-Json
        $frameworkKey = $Framework.ToLower() -replace '\.js$', '' -replace '\s+', ''
        
        # Map framework names to component library keys
        $frameworkMapping = @{
            "nextjs" = "nextjs"
            "next" = "nextjs"
            "react" = "react"
            "angular" = "angular"
            "vue" = "vue"
            "vuejs" = "vue"
            "svelte" = "svelte"
            "flutter" = "flutter"
            "electron" = "electron"
            "expo" = "expo"
        }
        
        $mappedFramework = $frameworkMapping[$frameworkKey]
        if (-not $mappedFramework -or -not $libraryData.componentLibrariesDatabase.$mappedFramework) {
            return @()
        }
        
        $libraries = $libraryData.componentLibrariesDatabase.$mappedFramework.primary
        $suggestions = @()
        
        foreach ($lib in $libraries) {
            $suggestions += @{
                name = "Component Library: $($lib.name)"
                pattern = "ui-component-library"
                description = $lib.description
                benefits = @("Pre-built components", "Consistent design", "Faster development", $lib.useCase)
                code = @"
# Install $($lib.name)
$($lib.install)

# Usage Example (adapt to your needs):
import { Button, Card, Input } from '$($lib.name.ToLower() -replace '\s+', '-')'

export function ExampleComponent() {
  return (
    <Card>
      <Input placeholder="Enter text..." />
      <Button>Submit</Button>
    </Card>
  )
}

# Documentation: $($lib.documentation)
"@
                install = $lib.install
                documentation = $lib.documentation
                popularity = $lib.popularity
            }
        }
        
        return $suggestions
        
    } catch {
        Write-Warning "Failed to load component library suggestions: $($_.Exception.Message)"
        return @()
    }
}

function Analyze-ProjectContext {
    param([string]$Path, [string]$Framework)
    
    $context = @{
        hasTests = $false
        hasTypeScript = $false
        hasStateManagement = $false
        hasRouting = $false
        hasUILibrary = $false
        suggestions = @()
    }
    
    # Check for TypeScript
    if (Test-Path "$Path\tsconfig.json") {
        $context.hasTypeScript = $true
    }
    
    # Check for testing setup and UI libraries
    if (Test-Path "$Path\package.json") {
        $packageContent = Get-Content "$Path\package.json" | ConvertFrom-Json
        
        # Check testing frameworks
        $testFrameworks = @("vitest", "jest", "cypress", "playwright")
        foreach ($framework in $testFrameworks) {
            if ($packageContent.devDependencies.$framework -or $packageContent.dependencies.$framework) {
                $context.hasTests = $true
                break
            }
        }
        
        # Check for state management
        $stateLibs = @("zustand", "redux", "@reduxjs/toolkit", "pinia", "vuex")
        foreach ($lib in $stateLibs) {
            if ($packageContent.dependencies.$lib) {
                $context.hasStateManagement = $true
                break
            }
        }
        
        # Check for UI libraries
        $uiLibs = @("@mui/material", "@chakra-ui/react", "antd", "@angular/material", "primeng", "vuetify", "primevue", "carbon-components-svelte")
        foreach ($lib in $uiLibs) {
            if ($packageContent.dependencies.$lib) {
                $context.hasUILibrary = $true
                break
            }
        }
    }
    
    # Generate context-based suggestions
    if (-not $context.hasTests) {
        $context.suggestions += "Consider adding a testing framework (Vitest recommended for modern projects)"
    }
    
    if (-not $context.hasTypeScript) {
        $context.suggestions += "Consider migrating to TypeScript for better type safety"
    }
    
    if (-not $context.hasUILibrary) {
        $context.suggestions += "Consider adding a component library for faster UI development (use --Components flag to see options)"
    }
    
    return $context
}

function Show-PatternSuggestions {
    param($Patterns, $Framework, $Context)
    
    if ($JsonOutput) {
        @{
            framework = $Framework
            patterns = $Patterns
            context = $Context
        } | ConvertTo-Json -Depth 10
        return
    }
    
    Write-Host "🎯 FRAMEWORK-SPECIFIC PATTERN SUGGESTIONS" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "Framework: $Framework" -ForegroundColor Yellow
    Write-Host ""
    
    if ($Patterns.Count -eq 0) {
        Write-Host "❌ No specific patterns found for this framework/criteria" -ForegroundColor Red
        Write-Host "💡 Try using different filters or check if the framework is supported" -ForegroundColor Yellow
        return
    }
    
    foreach ($pattern in $Patterns) {
        Write-Host "📋 Pattern: $($pattern.name)" -ForegroundColor Green
        Write-Host "   Type: $($pattern.pattern)" -ForegroundColor Gray
        Write-Host "   Description: $($pattern.description)" -ForegroundColor White
        
        if ($pattern.benefits) {
            Write-Host "   Benefits:" -ForegroundColor Cyan
            foreach ($benefit in $pattern.benefits) {
                Write-Host "     • $benefit" -ForegroundColor Gray
            }
        }
        
        Write-Host ""
        Write-Host "   Code Example:" -ForegroundColor Yellow
        Write-Host $pattern.code -ForegroundColor White
        Write-Host ""
        Write-Host "─" * 80 -ForegroundColor Gray
        Write-Host ""
    }
    
    # Show context suggestions
    if ($Context.suggestions.Count -gt 0) {
        Write-Host "💡 PROJECT IMPROVEMENT SUGGESTIONS" -ForegroundColor Magenta
        foreach ($suggestion in $Context.suggestions) {
            Write-Host "   • $suggestion" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    Write-Host "🚀 NEXT STEPS" -ForegroundColor Cyan
    Write-Host "1. Copy and adapt the patterns to your specific use case" -ForegroundColor White
    Write-Host "2. Run /analyze-codebase to see how well your code follows these patterns" -ForegroundColor White
    Write-Host "3. Use /optimize-performance for performance-specific improvements" -ForegroundColor White
    Write-Host "4. Consider implementing the project improvement suggestions" -ForegroundColor White
}

# Main execution
try {
    $framework = Get-ProjectFramework -Path $ProjectPath
    
    Write-Host "🔍 Analyzing project for pattern suggestions..." -ForegroundColor Cyan
    Write-Host "Framework detected: $framework" -ForegroundColor Green
    
    $patterns = Get-RelevantPatterns -Framework $framework -Component $Component -Security:$Security -Performance:$Performance -Components:$Components
    $context = Analyze-ProjectContext -Path $ProjectPath -Framework $framework
    
    Show-PatternSuggestions -Patterns $patterns -Framework $framework -Context $context
    
} catch {
    Write-Host "❌ Pattern suggestion failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}