# Zero Defect Programming Prompts - OpenCode

## 🛡️ Zero Defect Validation
```markdown
### /zero-check
Comprehensive zero-defect validation:
- **Type Safety**: Ultra-strict TypeScript checking with Biome
- **Security Scan**: @security-auditor full OWASP analysis
- **Input Validation**: Runtime + compile-time checks with Zod
- **Defensive Patterns**: Assertions and boundary validation
- **Test Quality**: Mutation testing for edge cases
- **Performance**: Baseline regression detection

Execute all validation layers before proceeding. ZERO tolerance for errors.
```

## ⚡ Fail-Fast Validation
```markdown
### /fail-fast
Immediate failure detection workflow:
- **Compile Errors**: Zero tolerance for type issues
- **Runtime Assertions**: Validate all assumptions
- **Input Boundaries**: Check all data constraints  
- **Security Gates**: Block on any vulnerability
- **Performance Gates**: Alert on degradation

Stop immediately on ANY validation failure. Prevention > Detection.
```

## 🔍 Enhanced Code Review - Zero Defect
```markdown
### /review-zero-defect
Zero Defect Analysis - NO ERRORS TOLERATED:
- **Type Safety**: ZERO `any` types, strict TypeScript compliance
- **Input Validation**: ALL inputs validated with Zod schemas
- **Error Handling**: Result pattern, no uncaught exceptions
- **Security**: OWASP compliance, no security vulnerabilities  
- **Performance**: No regressions, baseline comparison
- **Test Coverage**: 90%+ coverage, edge cases included
- **Defensive Programming**: Assertions, boundary checks, fail-safe defaults

BLOCKING ISSUES:
- Type errors, security vulnerabilities, missing validations
- Performance regressions, test failures, OWASP violations

Focus on PREVENTION over detection. Fail fast, fail safe.
```

## 🎯 Pre-Development Validation
```markdown
### /validate-requirements
Requirements validation for zero defects:
- **Edge Cases**: Identify all boundary conditions
- **Error Scenarios**: List all possible failure modes
- **Security Implications**: Early threat modeling
- **Performance Requirements**: Define baseline expectations
- **Integration Points**: Validate all external dependencies

Use @architect for design analysis and @security-auditor for security review.
Complete BEFORE any implementation begins.
```

## 🔧 Development-Time Protection
```markdown
### /real-time-validation
Continuous validation during development:
- **Biome Linting**: Real-time code quality enforcement
- **TypeScript Strict**: Immediate type error detection  
- **Security Scanning**: Live vulnerability detection
- **Test Execution**: Background unit test execution
- **Performance Monitoring**: Real-time regression alerts

Enable all protection layers during active development.
```

## 🚪 Pre-Commit Gates
```markdown
### /pre-commit-validation
Mandatory validation before any commit:
- **Type Safety Gate**: Zero type errors allowed
- **Security Gate**: OWASP compliance required
- **Test Coverage Gate**: 90% minimum coverage
- **Performance Gate**: No regression tolerance
- **Code Quality Gate**: Biome rules compliance

ALL gates must pass. NO EXCEPTIONS for commits.
```

## 🔄 CI/CD Integration
```markdown
### /cicd-validation
Multi-layer testing pipeline:
- **Unit Tests**: 95% coverage requirement
- **Integration Tests**: All external dependencies
- **E2E Tests**: Critical user journeys  
- **Security Tests**: SAST/DAST automated scanning
- **Performance Tests**: Baseline comparison
- **Mutation Tests**: Test quality validation

Each layer must pass before promotion to next stage.
```

## 🎮 Advanced Patterns
```markdown
### /defensive-programming
Implement defensive programming patterns:
- **Input Validation**: Zod schemas for all external data
- **Boundary Checks**: Assert all assumptions
- **Error Handling**: Result pattern for all operations
- **Type Guards**: Runtime type validation
- **Assertion Functions**: Critical path validation

Example implementation:
```typescript
function assertIsPositive(x: number): asserts x is number {
  if (x <= 0) throw new Error('Must be positive');
}

const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
});

type Result<T, E = Error> = 
  | { ok: true; data: T }
  | { ok: false; error: E };
```

Apply patterns consistently across entire codebase.
```

## 📊 Quality Metrics
```markdown
### /quality-metrics
Zero defect quality indicators:
- **Defect Escape Rate**: < 0.1% (target: 0%)
- **Build Failure Rate**: < 1% 
- **Security Vulnerabilities**: 0 (ZERO tolerance)
- **Type Errors**: 0 (ZERO tolerance)
- **Test Coverage**: > 90% (target: 95%+)
- **Performance Regression**: < 5%

Monitor continuously and alert on any deviation.
```

## 🔬 Formal Verification
```markdown
### /formal-verification
Mathematical proof of correctness for critical code:
- **Memory Safety**: No buffer overflows or null derefs
- **Type Safety**: Compile-time guarantee of type correctness
- **Business Logic**: Proof of algorithm correctness
- **Security Properties**: Cryptographic protocol verification
- **Concurrency Safety**: Race condition prevention

Apply to authentication, payment, and security-critical modules.
```

## 🚨 Emergency Protocols
```markdown
### /emergency-fix
Zero defect emergency response:
- **Immediate Rollback**: Revert to last known good state
- **Root Cause Analysis**: Identify WHY defect escaped
- **Process Improvement**: Update gates to prevent recurrence  
- **Validation Enhancement**: Add new checks for failure mode
- **Team Learning**: Document and share prevention strategies

Never just fix the symptom - prevent the class of errors.
```