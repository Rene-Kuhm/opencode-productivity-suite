# OpenCode Global Rules

Estas reglas aplican a todas las conversaciones con OpenCode.

## Formato de Salida Optimizado

### Todo Lists (Formato Obligatorio)
```
📋 Tasks | 🎯 [Section Name]
┌─ ✅ Completed task
├─ 🔄 Current task (only ONE in progress)
├─ ⏳ Pending task
└─ 📝 Final task
```

### Color Coding por Secciones
- 🎯 **Development** - #00ff88 (verde brillante)
- 🎮 **Testing** - #ff6b35 (naranja)
- 🚀 **Deploy** - #4285f4 (azul Google)
- 📚 **Docs** - #9c27b0 (púrpura)
- 🔧 **Config** - #ff9800 (ámbar)

### Comunicación Eficiente
- **NUNCA** usar frases de relleno ("Great question!", "I'll help you...")
- **NUNCA** explicar lo que vas a hacer antes de hacerlo
- **SIEMPRE** ir directo al punto
- **USAR** emojis SOLO en headers de secciones
- **LIMITAR** explicaciones a máximo 2 líneas por concepto

## Idioma

- Responder en el idioma del usuario
- Documentacion de codigo en ingles
- Comentarios de codigo en ingles
- Commits en ingles (Conventional Commits)

## TypeScript Standards

### Obligatorio

- **Strict mode** habilitado
- **NO usar `any`** - usar `unknown` y type guards
- **Zod** para validacion de inputs externos
- **Tipos explicitos** en funciones publicas
- **Interfaces** para objetos, **types** para unions

### Configuracion para Bun

Cuando se detecte un proyecto que usa Bun (presencia de `bunfig.toml` o `bun.lockb`):

#### Dependencias requeridas
```bash
# Instalar tipos de Bun
bun add -d @types/bun
```

#### tsconfig.json optimizado para Bun
```json
{
  "compilerOptions": {
    // Environment setup & latest features
    "lib": ["ESNext"],
    "target": "ESNext", 
    "module": "Preserve",
    "moduleDetection": "force",
    "jsx": "react-jsx",
    "allowJs": true,

    // Bundler mode - habilita caracteristicas especiales de Bun
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,  // Importar .ts directamente
    "verbatimModuleSyntax": true,
    "noEmit": true,

    // Best practices
    "strict": true,
    "skipLibCheck": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,

    // Opcional - mas estricto
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "noPropertyAccessFromIndexSignature": false
  }
}
```

#### Caracteristicas habilitadas con esta config:
- **Top-level await**: `const data = await fetch('/api')` (sin async function)
- **Importaciones .ts**: `import utils from './file.ts'`
- **JSX sin imports**: No necesitas `import React from 'react'`
- **Bun APIs**: Acceso completo a `Bun.serve()`, `Bun.file()`, etc.

#### Deteccion automatica de contexto:
- **Monorepo con Bun**: Aplicar en packages que no sean Next.js/Expo
- **Scripts de backend**: Aplicar en APIs, workers, scripts de utilidades
- **Next.js**: Usar configuracion de Next.js + tipos de Bun solo si es necesario
- **Expo**: Mantener configuracion de Expo + React Native

### Naming Conventions

| Tipo | Convencion | Ejemplo |
|------|------------|---------|
| Constants | UPPER_SNAKE_CASE | `MAX_RETRIES` |
| Classes | PascalCase | `UserService` |
| Functions | camelCase | `getUserById` |
| Variables | camelCase | `userName` |
| Files (services) | kebab-case | `user-service.ts` |
| Files (components) | PascalCase | `UserCard.tsx` |
| Interfaces | PascalCase con I prefix (opcional) | `User` o `IUser` |
| Types | PascalCase | `UserRole` |

## Next.js Best Practices

- **Server Components** por defecto
- `'use client'` solo cuando necesario (hooks, eventos)
- **Metadata API** para SEO
- **Loading/Error boundaries** en cada ruta
- **Route handlers** en `app/api/`
- **Server Actions** para mutaciones simples

## React Patterns

```typescript
// Prefer: Componentes funcionales
export function UserCard({ user }: UserCardProps) {
  return <div>{user.name}</div>;
}

// Prefer: Custom hooks para logica reutilizable
export function useUser(id: string) {
  return useQuery(['user', id], () => fetchUser(id));
}

// Avoid: useEffect para data fetching (usar React Query o Server Components)
```

## Git Workflow

### Conventional Commits

```
<type>(<scope>): <description>

feat: Nueva funcionalidad
fix: Bug fix
docs: Documentacion
style: Formato (no afecta logica)
refactor: Refactoring sin cambio de funcionalidad
perf: Mejora de performance
test: Tests
chore: Tareas de mantenimiento
```

### Branch Naming

```
feature/add-user-authentication
fix/login-button-disabled
hotfix/security-patch
```

## Security Guidelines

### NUNCA

- Hardcodear secrets
- Loggear datos sensibles
- Confiar en input del cliente
- Usar `eval()` o `innerHTML` con datos del usuario
- Deshabilitar CORS completamente

### SIEMPRE

- Validar TODOS los inputs
- Sanitizar outputs
- Usar HTTPS
- HttpOnly cookies para tokens
- Principio de minimo privilegio

## Testing Requirements

### Unit Tests

- Testear logica de negocio
- Mockear dependencias externas
- Patron AAA (Arrange-Act-Assert)
- Nombres descriptivos

### Integration Tests

- API endpoints
- Database operations
- External services (mockeados)

### E2E Tests

- Flujos criticos del usuario
- Happy path + error cases

## Code Review Checklist

- [ ] No hay `any` types
- [ ] Inputs validados
- [ ] Errores manejados
- [ ] Tests incluidos
- [ ] No secrets hardcodeados
- [ ] Performance considerada
- [ ] Accesibilidad (a11y)
- [ ] Documentacion actualizada

## Herramientas Preferidas

| Categoria | Herramienta |
|-----------|-------------|
| Package Manager | pnpm |
| Runtime (alternativo) | Bun |
| Linter/Formatter | Biome |
| Testing | Vitest + RTL + Playwright |
| Styling | Tailwind CSS |
| State | React Query / Zustand |
| Forms | React Hook Form + Zod |
| Database | Prisma |
| Auth | NextAuth.js |

## MCP Servers Disponibles

Usa estos servidores MCP cuando sea apropiado:

- `context7` - Buscar documentacion de librerias
- `sentry` - Ver errores de produccion
- `github` - Operaciones de GitHub
- `shadcn` - Componentes de UI
- `gh_grep` - Buscar ejemplos de codigo en GitHub

### Ejemplo de uso

```
Busca como implementar autenticacion con NextAuth. use context7
```

## Agentes Especializados

Invoca agentes con `@nombre` cuando necesites expertise especifico:

- `@architect` - Analisis de arquitectura y SOLID
- `@builder` - Implementacion de codigo
- `@debugger` - Resolucion de bugs
- `@security-auditor` - Auditoria de seguridad
- `@docs-writer` - Documentacion
- `@test-engineer` - Testing
- `@devops` - Infraestructura y CI/CD

### Ejemplo

```
@architect Analiza la estructura de este proyecto y sugiere mejoras
```

## Performance Guidelines

### Frontend

- Lazy loading para componentes grandes
- Image optimization con next/image
- Code splitting automatico
- Memoization cuando sea necesario

### Backend

- Evitar N+1 queries
- Implementar caching (Redis)
- Pagination para listas
- Connection pooling

## Error Handling

```typescript
// Patron recomendado
import { Result, ok, err } from '@/lib/result';

async function getUser(id: string): Promise<Result<User, Error>> {
  try {
    const user = await db.user.findUnique({ where: { id } });
    if (!user) return err(new NotFoundError('User not found'));
    return ok(user);
  } catch (error) {
    return err(new DatabaseError('Failed to fetch user'));
  }
}
```

## Logging

```typescript
// Usar structured logging
import { logger } from '@/lib/logger';

logger.info('User created', { userId: user.id, email: user.email });
logger.error('Failed to create user', { error, input: sanitizedInput });
```

---

*Configuracion OpenCode v1.0.0*
*Adaptado para Claude como modelo principal*