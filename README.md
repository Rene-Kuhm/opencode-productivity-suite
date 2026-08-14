# 🚀 OpenCode Productivity Suite v3.0

**PowerShell automation for OpenCode: framework detection, project scaffolding and code-analysis commands.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenCode](https://img.shields.io/badge/built%20for-OpenCode-blue.svg)](https://opencode.dev)
[![Frameworks](https://img.shields.io/badge/Frameworks-38+-orange.svg)](#framework-support)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)](#requirements)

## 🎯 What this is

A set of PowerShell scripts that take the repetitive part out of starting and
auditing a project under OpenCode. It inspects what you already have, sets up
what matches it, and adds commands you can run against an existing codebase.

It is tooling, not magic: everything here is a script you can read in
`automation/` and `commands/`.

### 🧰 What it does
- **🧠 Framework detection**: inspects the project and recognises 38+ frameworks
- **🎯 Analysis commands**: codebase review, performance and security passes,
  pattern suggestions
- **🎨 Component libraries**: installs Material-UI, shadcn/ui, Angular Material
  and friends to match the framework it found
- **🚀 Tailwind setup**: installs Tailwind CSS v4.1+ only when the project is a
  UI framework, instead of always
- **🏗️ Backend scaffolding**: generates DDD, CQRS and microservice layouts
- **🪝 Git hooks**: installs pre-commit checks
- **🛡️ Zero-defect checklist**: a documented review process (see
  `.opencode/zero-defect-config.md`) — a discipline to follow, not a guarantee
  the tooling can enforce for you

---

## 🚀 One-Command Installation

```powershell
# Complete system setup in 30 seconds
curl -L https://raw.githubusercontent.com/Rene-Kuhm/opencode-productivity-suite/main/deploy/production-setup.ps1 | powershell
```

**What you get instantly:**
- ✅ 38+ frameworks automatically detected and optimized
- ✅ AI-powered intelligent commands ready to use
- ✅ Smart Tailwind CSS v4.1+ detection (only for UI frameworks)
- ✅ Component library auto-installation (Material-UI, shadcn/ui, Angular Material, etc.)
- ✅ Enterprise backend generation (DDD, CQRS, Event Sourcing, microservices)
- ✅ Real-time team dashboard with Zero Defect scoring
- ✅ Framework-specific configurations applied automatically
- ✅ Desktop shortcuts and production-ready environment

---

## 🧠 AI-Powered Intelligent Commands

### 🎯 **Core Intelligence Commands**
```bash
/analyze-codebase          # "Your project has 3 code smells in auth module"
/suggest-patterns          # "Consider using Result pattern here"  
/optimize-performance      # "This query causes N+1 problem, fixing..."
/security-audit           # "Found 2 vulnerabilities, patching..."
```

### 🔧 **Enhanced Setup Commands**
```bash
/init-zero-defect          # Smart auto-initialization with framework + Tailwind detection
/detect-framework          # Advanced framework detection (38+ supported)
/validate-setup           # Comprehensive setup validation
/suggest-patterns --Components # Get top-tier component library recommendations
/tailwind-hacker              # Ultra-advanced Tailwind CSS v4.1+ management
/backend-expert              # Enterprise backend generation (DDD, CQRS, microservices)
```

### 📊 **Team Management Commands**
```bash
/team-dashboard           # Real-time team metrics and rankings
/team-dashboard --live    # Live updating dashboard
/team-report --format=html # Generate team performance reports
```

---

## 🎯 Advanced Framework Detection

### **38+ Frameworks Automatically Detected**

#### 🎨 **Frontend Frameworks (11) + Smart Tailwind + Component Libraries**
- **Next.js** 14.x - App Router, Server Components + Tailwind v4.1+ + shadcn/ui auto-install
- **React** 18.x - Concurrent features, Suspense + Tailwind v4.1+ + Material-UI (MUI) auto-install
- **Vue.js** 3.x - Composition API, Reactivity + Tailwind v4.1+ + Vuetify auto-install
- **Angular** 17.x - Standalone components, Signals + Tailwind v4.1+ + Angular Material auto-install
- **Svelte** 4.x - Component optimization + Tailwind v4.1+ + shadcn-svelte auto-install
- **Nuxt** 3.x - Auto-imports, server-side optimization + Tailwind v4.1+
- **Astro** 4.x - Islands architecture, partial hydration + Tailwind v4.1+ + Astro UI
- **Qwik** 1.x - Resumability, O(1) loading + Tailwind v4.1+ + Qwik UI
- **SolidJS** 1.x - Fine-grained reactivity + Tailwind v4.1+ + Solid UI
- **Remix** 2.x - Web standards focus + Tailwind v4.1+
- **SvelteKit** 2.x - Full-stack Svelte + Tailwind v4.1+
- **Fresh** 1.x - Deno-native framework + Tailwind v4.1+

#### ⚙️ **Backend Frameworks (11)**
- **Express.js** 4.x - Security middleware, API optimization
- **NestJS** 10.x - Decorator patterns, enterprise architecture
- **FastAPI** 0.1x - Async optimization, auto-documentation
- **Django** 4.x - ORM optimization, security patterns
- **Spring Boot** 3.x - Microservice patterns
- **Laravel** 10.x - Eloquent optimization
- **Ruby on Rails** 7.x - Convention over configuration
- **ASP.NET Core** 8.x - Performance optimization
- **Fastify** 4.x - High-performance Node.js
- **Koa.js** 2.x - Middleware patterns
- **Flask** 3.x - Microframework optimization

#### 📱 **Mobile Frameworks (4) + Smart Detection**
- **Flutter** 3.x - Widget optimization, performance patterns + Material Design UI (No Tailwind - native styling)
- **React Native** 0.72.x - Native bridge optimization + React Native Elements (No Tailwind - native components)
- **Expo** 49.x - Universal app patterns + NativeBase auto-install (No Tailwind - React Native styling)
- **Ionic** 7.x - Hybrid app optimization + Tailwind v4.1+ (Web-based hybrid)

#### 🖥️ **Desktop & Specialized (12)**
- **Electron** 27.x - Desktop app optimization
- **Tauri** 1.x - Rust-powered desktop apps
- **Unity** 2023.x - Game development patterns
- **Vite** 5.x - Build tool optimization
- **Bun** 1.x - Runtime optimization
- And more...

### **Intelligent Framework Configuration**

Each framework gets:
- ✅ **Ultra-strict TypeScript** configuration
- ✅ **Framework-specific linting** rules (Biome optimization)
- ✅ **Performance optimization** patterns
- ✅ **Security compliance** (OWASP Top 10)
- ✅ **Best practices** automatically applied
- ✅ **Testing framework** setup
- ✅ **VS Code integration** with extensions
- ✅ **Build optimization** configuration
- ✅ **Component library recommendations** and auto-installation
- ✅ **Smart Tailwind CSS detection** with v4.1+ hacker system
- ✅ **Enterprise backend generation** with DDD, CQRS, Event Sourcing
- ✅ **Modern CSS features** (container queries, color-mix, cascade layers)

---

## 📊 Real-Time Team Dashboard

### **Live Team Metrics**
```
🏆 Zero Defects Team Rankings - This Week
├─ 🥇 Juan: 97% Zero Defects, 45 clean commits
├─ 🥈 María: 94% Zero Defects, 38 commits  
├─ 🥉 Pedro: 89% Zero Defects, 25 commits
└─ 🏅 Ana: 85% Zero Defects, 19 commits
```

### **Dashboard Features**
- **📈 Real-time Zero Defect scoring** for each team member
- **🎯 Individual and team productivity metrics**
- **🏆 Achievement system** with weekly awards
- **📊 Performance trends** and improvement recommendations
- **📱 Multiple export formats** (HTML, JSON, CSV)
- **⚡ Live updating mode** for continuous monitoring
- **🎮 Gamification** with rankings and achievements

### **Metrics Tracked**
- Zero Defect Score percentage
- Clean commits vs total commits
- Tests written and coverage
- Security issues found and fixed
- Performance optimizations implemented
- Code quality trends over time

---

## 🛡️ Zero Defect Programming

### **What the checklist covers**
- **🔒 OWASP Top 10** as the security reference
- **⚡ Performance optimization** with AI analysis
- **🧪 Automated testing** requirements
- **📏 Code quality** enforcement
- **🛡️ Security vulnerability** detection and fixing
- **🔧 Real-time validation** during development

### **Multi-Layer Validation**
1. **Pre-Development**: Requirements validation, architecture review
2. **Development-Time**: Real-time linting, TypeScript strict mode
3. **Pre-Commit**: Type safety, security scan, test coverage (90%+ required)
4. **CI/CD**: 7-layer pipeline validation
5. **Production**: Continuous monitoring and alerting

---

## 📁 Complete System Architecture

```
📦 opencode-productivity-suite/
├── 🤖 automation/                    # Advanced Framework Detection
│   ├── advanced-framework-detection.ps1   # 38+ framework detection engine
│   └── auto-init-zero-defect-enhanced.ps1 # Enhanced auto-initialization
│
├── 🧠 commands/                      # AI-Powered Intelligent Commands
│   ├── analyze-codebase.ps1              # Comprehensive project analysis
│   ├── suggest-patterns.ps1              # Framework-specific patterns
│   ├── optimize-performance.ps1          # Performance optimization
│   └── security-audit.ps1               # OWASP security audit
│
├── 📊 dashboard/                     # Real-Time Team Dashboard
│   └── team-dashboard.ps1               # Live team metrics and rankings
│
├── 🚀 deploy/                       # Production Deployment
│   └── production-setup.ps1             # One-command setup script
│
├── ⚙️ framework-configs/            # Framework-Specific Configurations
│   ├── nextjs-zero-defect.json         # Next.js optimization
│   ├── react-zero-defect.json          # React optimization
│   ├── vue-zero-defect.json            # Vue.js optimization
│   ├── angular-zero-defect.json        # Angular optimization
│   ├── express-zero-defect.json        # Express.js optimization
│   ├── flutter-zero-defect.yaml        # Flutter optimization
│   ├── qwik-zero-defect.json          # Qwik optimization
│   ├── solid-zero-defect.json         # SolidJS optimization
│   └── README.md                       # Framework documentation
│
├── 🧪 tests/                       # Automated Testing Suite
│   └── framework-detection-tests.ps1   # Validation and testing
│
├── 📚 project-templates/            # Project Templates
│   ├── zero-defect-config.md          # Zero Defect methodology
│   ├── biome-zero-defect.json         # Ultra-strict linting
│   ├── tsconfig-zero-defect.json      # TypeScript configuration
│   ├── pre-commit-gates.yaml          # Validation gates
│   └── zero-defect-cicd.yml          # CI/CD pipeline
│
└── 📖 examples/                    # Implementation Examples
    ├── zero-defect-patterns.ts        # Defensive programming patterns
    └── framework-examples/            # Real-world examples
```

---

## 🎯 Framework-Specific Intelligence

### **Next.js Optimization**
```typescript
// Automatic Server Component optimization
export default async function UsersPage() {
  const users = await getUsers() // Server-side data fetching
  return <UsersList users={users} />
}

// Performance monitoring with Web Vitals
// SEO optimization with Metadata API
// Security headers with middleware
```

### **React Performance Patterns**
```typescript
// Automatic memoization suggestions
const UserCard = memo<UserCardProps>(({ user, onClick }) => {
  const handleClick = useCallback(() => onClick(user.id), [user.id, onClick])
  return <div onClick={handleClick}>{user.name}</div>
})

// Hook optimization recommendations
// Bundle size analysis and optimization
```

### **Flutter Widget Optimization**
```dart
// Automatic const constructor enforcement
const UserCard({
  super.key,
  required this.user,
  this.onTap,
});

// Performance monitoring with RepaintBoundary
// Memory leak detection and prevention
```

### **Express.js Security Hardening**
```javascript
// Automatic security middleware
app.use(helmet())
app.use(cors({ origin: process.env.ALLOWED_ORIGINS }))
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }))

// Input validation with Zod
// SQL injection prevention
```

---

## 📈 What it saves you

No benchmarks are published here, because none have been run. What the scripts
replace is concrete enough without them:

| Instead of | You run |
|--------|--------|
| Identifying the stack and wiring its tooling by hand | One detection pass |
| Installing and configuring Tailwind per project | Automatic, and only for UI frameworks |
| Copying a component library's setup steps | One command for the matching library |
| Writing the same DDD/CQRS skeleton again | A generated layout |
| Adding the same pre-commit checks to each repo | The hook installer |

If you measure a real before/after in your own projects, numbers here would be
a welcome pull request.

---

## 🚀 Quick Start Guide

### **1. Install the System (30 seconds)**
```powershell
curl -L https://raw.githubusercontent.com/Rene-Kuhm/opencode-productivity-suite/main/deploy/production-setup.ps1 | powershell
```

### **2. Initialize Any Project**
```bash
cd your-project
/init-zero-defect
# System automatically detects framework and applies optimizations
```

### **3. Start Development**
```bash
# Analyze your codebase
/analyze-codebase

# Get framework-specific suggestions  
/suggest-patterns

# Optimize performance
/optimize-performance

# Security audit
/security-audit --deep

# View team dashboard
/team-dashboard --live
```

### **4. What you get**
- ✅ **Automatic framework detection** and matching configuration
- ✅ **Code quality** feedback as you commit
- ✅ **A review checklist** the team can hold each other to
- ✅ **Performance optimization** suggestions

---

## 🎮 Team Collaboration Features

### **Live Team Dashboard**
```bash
# Real-time team metrics
/team-dashboard --live

# Generate reports
/team-dashboard --format=html --output=./reports/

# Export data
/team-dashboard --format=csv --output=team-metrics.csv
```

### **Achievement System**
- 🥇 **Zero Defect Champion**: Highest quality score
- 📝 **Commit Hero**: Most productive developer
- 🧪 **Testing Master**: Best test coverage
- 🛡️ **Security Guardian**: Zero security issues
- ⚡ **Performance Pro**: Most optimizations

### **Team Recommendations**
- 📈 **Focus areas** for team improvement
- 🎯 **Individual coaching** suggestions
- 🛡️ **Security training** recommendations
- 🧪 **Testing strategy** improvements

---

## 🧠 AI-Powered Analysis Examples

### **Code Quality Analysis**
```
🔍 ANALYSIS RESULTS:
✅ TypeScript strict mode enabled
⚠️ 3 code smells detected in auth module
❌ Missing input validation in API routes
💡 Suggestion: Implement Zod validation schemas
```

### **Performance Optimization**
```
⚡ PERFORMANCE ANALYSIS:
🚀 Bundle size: 245KB (excellent)
🐌 N+1 query detected in user listing
⚡ Suggestion: Implement eager loading
📈 Potential 40% performance improvement
```

### **Security Audit**
```
🛡️ SECURITY AUDIT (OWASP Top 10):
✅ A01 - Access Control: Compliant
❌ A02 - Crypto Failures: Hardcoded secret found
⚠️ A03 - Injection: Potential XSS vulnerability
🔧 Auto-fix available for 2/3 issues
```

### **Smart Detection & Pattern Suggestions**
```
🎯 REACT PROJECT DETECTED:
🚀 Auto-installing Tailwind CSS v4.1+ (UI Framework detected)
🎨 Component Library: Material-UI recommended for enterprise apps
💡 Replace useState with useReducer for complex state
🔧 Add React.memo to UserCard component
⚡ Use useCallback for event handlers
🌈 Modern CSS: Glass morphism, container queries, color-mix() enabled
📚 Example code provided for each suggestion

🏗️ NESTJS PROJECT DETECTED:
❌ Skipping Tailwind CSS (Backend Framework detected)
🚀 Auto-generating Enterprise Backend Architecture
🏗️ Architecture: DDD + CQRS + Event Sourcing
💎 Patterns: Domain entities, Aggregates, Repository pattern
🛡️ Security: JWT + OAuth2 + RBAC + Policy engines
📊 Observability: OpenTelemetry + Prometheus + Structured logging
🚀 Deployment: Docker + Kubernetes + Service Mesh ready
```

---

## 🎯 Advanced Configuration

### **Team Setup**
```powershell
# Team environment with dashboard
./production-setup.ps1 -TeamSetup -GitHubToken your-token
```

### **Framework-Specific Setup**
```bash
# Force specific framework
/init-zero-defect --framework=react
/init-zero-defect --framework=nextjs
/init-zero-defect --framework=flutter
```

### **Custom Analysis**
```bash
# Focus on specific areas
/analyze-codebase --security --performance
/suggest-patterns --framework=react --focus=hooks
/optimize-performance --autofix
```

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### **Development Setup**
```bash
git clone https://github.com/Rene-Kuhm/opencode-productivity-suite.git
cd opencode-productivity-suite

# Test framework detection
./tests/framework-detection-tests.ps1

# Test installation
./deploy/production-setup.ps1 -Verbose
```

---

## 📚 Documentation

- **[Framework Configurations](framework-configs/README.md)** - Complete framework support guide
- **[Installation Guide](docs/installation.md)** - Detailed setup instructions
- **[Command Reference](docs/commands.md)** - All intelligent commands
- **[Team Dashboard Guide](docs/dashboard.md)** - Team collaboration features
- **[Troubleshooting](docs/troubleshooting.md)** - Common issues and solutions

---

## 🏆 Why you might want it

### **What it is good at**
1. **🧠 Framework detection**: recognises 38+ frameworks and configures to match
2. **🎯 Context-aware commands**: analysis passes that know what stack they are on
3. **⚡ One-command setup**: the whole environment from a single script
4. **🛡️ A written review process**: `.opencode/zero-defect-config.md` gives the
   team one checklist to argue about instead of five opinions

### **Where it does not fit**
- **PowerShell only.** No bash port, so Linux and macOS are out unless you run
  PowerShell Core.
- **Opinionated scaffolding.** The DDD/CQRS layouts are one particular take; if
  yours differs you will be deleting as much as you keep.
- **Detection over inference.** It matches on what is in the project, so an
  unusual setup may simply not be recognised.
- **No metrics.** The quality checklist is a discipline, not something the
  scripts can verify for you.

---

## 📞 Support & Community

- **🐛 Issues**: [GitHub Issues](https://github.com/Rene-Kuhm/opencode-productivity-suite/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/Rene-Kuhm/opencode-productivity-suite/discussions)
- **📖 Wiki**: [Documentation Wiki](https://github.com/Rene-Kuhm/opencode-productivity-suite/wiki)
- **📧 Contact**: rene.kuhm@example.com

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **OpenCode Team** for the revolutionary development platform
- **AI Research Community** for making intelligent analysis possible
- **Open Source Contributors** who help improve this system
- **Beta Testers** who validated the productivity improvements

---

<div align="center">

## 🚀 **Try it**

Read `deploy/production-setup.ps1` first — piping a script straight into a
shell is worth a look before you run it.

```powershell
curl -L https://raw.githubusercontent.com/Rene-Kuhm/opencode-productivity-suite/main/deploy/production-setup.ps1 | powershell
```

**🎯 One-command setup • 🧠 38+ frameworks detected • 🪝 Git hooks • 🛡️ A review checklist worth arguing about**

---

**Built with ❤️ for the global development community**

*Transform your workflow today - Join the productivity revolution!*

</div>