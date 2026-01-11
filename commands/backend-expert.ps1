# 🚀 Backend Expert Command - Enterprise Backend Generation
# Command: /backend-expert

param(
    [string]$ProjectPath = ".",
    [string]$Action = "analyze",
    [string]$Framework = "",
    [string]$Scale = "medium",
    [string]$Architecture = "auto",
    [switch]$Microservices = $false,
    [switch]$JsonOutput = $false
)

# Import Backend Expert System
$backendSystemPath = Join-Path (Split-Path $PSScriptRoot -Parent) "automation\backend-expert-system.ps1"

if (-not (Test-Path $backendSystemPath)) {
    Write-Error "❌ Backend Expert System not found: $backendSystemPath"
    exit 1
}

. $backendSystemPath

# Enterprise Code Templates
$ENTERPRISE_TEMPLATES = @{
    "domain-entity" = @"
import { AggregateRoot } from '@nestjs/cqrs';
import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class {EntityName} extends AggregateRoot {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP', onUpdate: 'CURRENT_TIMESTAMP' })
  updatedAt: Date;

  constructor(name: string) {
    super();
    this.name = name;
    
    // Raise domain event
    this.apply(new {EntityName}CreatedEvent(this.id, name));
  }

  // Business logic methods
  updateName(newName: string): void {
    if (!newName || newName.trim().length === 0) {
      throw new Error('Name cannot be empty');
    }
    
    const oldName = this.name;
    this.name = newName;
    
    this.apply(new {EntityName}NameUpdatedEvent(this.id, oldName, newName));
  }
}
"@

    "domain-event" = @"
export class {EntityName}CreatedEvent {
  constructor(
    public readonly id: string,
    public readonly name: string,
    public readonly occurredOn: Date = new Date(),
  ) {}
}

export class {EntityName}NameUpdatedEvent {
  constructor(
    public readonly id: string,
    public readonly oldName: string,
    public readonly newName: string,
    public readonly occurredOn: Date = new Date(),
  ) {}
}
"@

    "repository-interface" = @"
import { {EntityName} } from '../entities/{entity-name}.entity';

export interface I{EntityName}Repository {
  save(entity: {EntityName}): Promise<{EntityName}>;
  findById(id: string): Promise<{EntityName} | null>;
  findAll(): Promise<{EntityName}[]>;
  delete(id: string): Promise<void>;
}

export const I{EntityName}Repository = Symbol('I{EntityName}Repository');
"@

    "command-handler" = @"
import { CommandHandler, ICommandHandler, EventBus } from '@nestjs/cqrs';
import { Inject } from '@nestjs/common';
import { Create{EntityName}Command } from '../commands/create-{entity-name}.command';
import { {EntityName} } from '../../domain/entities/{entity-name}.entity';
import { I{EntityName}Repository } from '../../domain/repositories/{entity-name}.repository';

@CommandHandler(Create{EntityName}Command)
export class Create{EntityName}Handler implements ICommandHandler<Create{EntityName}Command> {
  constructor(
    @Inject(I{EntityName}Repository)
    private readonly repository: I{EntityName}Repository,
    private readonly eventBus: EventBus,
  ) {}

  async execute(command: Create{EntityName}Command): Promise<{EntityName}> {
    const { name } = command;
    
    const entity = new {EntityName}(name);
    const savedEntity = await this.repository.save(entity);
    
    // Publish domain events
    savedEntity.getUncommittedEvents().forEach(event => {
      this.eventBus.publish(event);
    });
    
    savedEntity.markEventsAsCommitted();
    
    return savedEntity;
  }
}
"@

    "query-handler" = @"
import { QueryHandler, IQueryHandler } from '@nestjs/cqrs';
import { Inject } from '@nestjs/common';
import { Get{EntityName}Query } from '../queries/get-{entity-name}.query';
import { {EntityName}ReadModel } from '../read-models/{entity-name}.read-model';
import { I{EntityName}ReadModelRepository } from '../repositories/{entity-name}-read-model.repository';

@QueryHandler(Get{EntityName}Query)
export class Get{EntityName}Handler implements IQueryHandler<Get{EntityName}Query> {
  constructor(
    @Inject(I{EntityName}ReadModelRepository)
    private readonly readModelRepository: I{EntityName}ReadModelRepository,
  ) {}

  async execute(query: Get{EntityName}Query): Promise<{EntityName}ReadModel | null> {
    const { id } = query;
    return this.readModelRepository.findById(id);
  }
}
"@

    "api-controller" = @"
import { Controller, Get, Post, Put, Delete, Body, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { Create{EntityName}Command } from '../application/commands/create-{entity-name}.command';
import { Update{EntityName}Command } from '../application/commands/update-{entity-name}.command';
import { Delete{EntityName}Command } from '../application/commands/delete-{entity-name}.command';
import { Get{EntityName}Query } from '../application/queries/get-{entity-name}.query';
import { GetAll{EntityName}sQuery } from '../application/queries/get-all-{entity-name}s.query';
import { Create{EntityName}Dto } from './dtos/create-{entity-name}.dto';
import { Update{EntityName}Dto } from './dtos/update-{entity-name}.dto';
import { {EntityName}ResponseDto } from './dtos/{entity-name}-response.dto';

@ApiTags('{entity-name}s')
@Controller('{entity-name}s')
export class {EntityName}Controller {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new {entity-name}' })
  @ApiResponse({ status: 201, description: 'The {entity-name} has been successfully created.', type: {EntityName}ResponseDto })
  async create(@Body() createDto: Create{EntityName}Dto): Promise<{EntityName}ResponseDto> {
    const command = new Create{EntityName}Command(createDto.name);
    const result = await this.commandBus.execute(command);
    return {EntityName}ResponseDto.from(result);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get {entity-name} by id' })
  @ApiResponse({ status: 200, description: 'The {entity-name} has been successfully retrieved.', type: {EntityName}ResponseDto })
  async findById(@Param('id') id: string): Promise<{EntityName}ResponseDto | null> {
    const query = new Get{EntityName}Query(id);
    const result = await this.queryBus.execute(query);
    return result ? {EntityName}ResponseDto.from(result) : null;
  }

  @Get()
  @ApiOperation({ summary: 'Get all {entity-name}s' })
  @ApiResponse({ status: 200, description: 'All {entity-name}s have been successfully retrieved.', type: [{EntityName}ResponseDto] })
  async findAll(): Promise<{EntityName}ResponseDto[]> {
    const query = new GetAll{EntityName}sQuery();
    const results = await this.queryBus.execute(query);
    return results.map(result => {EntityName}ResponseDto.from(result));
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update {entity-name} by id' })
  @ApiResponse({ status: 200, description: 'The {entity-name} has been successfully updated.', type: {EntityName}ResponseDto })
  async update(@Param('id') id: string, @Body() updateDto: Update{EntityName}Dto): Promise<{EntityName}ResponseDto> {
    const command = new Update{EntityName}Command(id, updateDto.name);
    const result = await this.commandBus.execute(command);
    return {EntityName}ResponseDto.from(result);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete {entity-name} by id' })
  @ApiResponse({ status: 204, description: 'The {entity-name} has been successfully deleted.' })
  async delete(@Param('id') id: string): Promise<void> {
    const command = new Delete{EntityName}Command(id);
    await this.commandBus.execute(command);
  }
}
"@

    "docker-compose" = @"
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - '3000:3000'
    environment:
      - NODE_ENV=development
      - DATABASE_HOST=postgres
      - DATABASE_PORT=5432
      - DATABASE_NAME=app_db
      - DATABASE_USERNAME=postgres
      - DATABASE_PASSWORD=postgres
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - postgres
      - redis
    volumes:
      - .:/usr/src/app
      - /usr/src/app/node_modules
    command: npm run start:dev

  postgres:
    image: postgres:15-alpine
    ports:
      - '5432:5432'
    environment:
      - POSTGRES_DB=app_db
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    ports:
      - '6379:6379'
    volumes:
      - redis_data:/data

  prometheus:
    image: prom/prometheus:latest
    ports:
      - '9090:9090'
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus

  grafana:
    image: grafana/grafana:latest
    ports:
      - '3001:3000'
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards

volumes:
  postgres_data:
  redis_data:
  prometheus_data:
  grafana_data:
"@

    "dockerfile" = @"
# Multi-stage build for production optimization
FROM node:18-alpine AS builder

# Install dependencies for native modules
RUN apk add --no-cache python3 make g++

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:18-alpine AS production

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nestjs -u 1001

WORKDIR /usr/src/app

# Copy built application from builder stage
COPY --from=builder --chown=nestjs:nodejs /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /usr/src/app/dist ./dist
COPY --from=builder --chown=nestjs:nodejs /usr/src/app/package*.json ./

# Switch to non-root user
USER nestjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node dist/health-check.js

# Start the application
CMD ["node", "dist/main.js"]
"@

    "kubernetes-deployment" = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-app
  labels:
    app: backend-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend-app
  template:
    metadata:
      labels:
        app: backend-app
    spec:
      containers:
      - name: backend-app
        image: backend-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_HOST
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: host
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
          requests:
            memory: "256Mi"
            cpu: "250m"
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: ClusterIP
"@
}

# Action implementations
function Invoke-BackendAnalyze {
    param([string]$ProjectPath, [string]$Framework, [string]$Scale)
    
    Write-Host "🔍 Analyzing backend project for enterprise patterns..." -ForegroundColor Cyan
    
    $analysis = Get-BackendExpertAnalysis -ProjectPath $ProjectPath -Framework $Framework -Scale $Scale
    
    return $analysis
}

function Invoke-BackendConfigure {
    param([string]$ProjectPath, [object]$Analysis)
    
    Write-Host "⚙️ Configuring enterprise backend setup..." -ForegroundColor Yellow
    
    $configDir = Join-Path $ProjectPath ".opencode"
    if (-not (Test-Path $configDir)) {
        New-Item -Path $configDir -ItemType Directory -Force | Out-Null
    }
    
    # Create enterprise configuration
    $config = @{
        backend = @{
            framework = $Analysis.framework
            architecture = $Analysis.architecture.pattern
            scale = $Analysis.complexity
            patterns = $Analysis.developmentPatterns
            technology = $Analysis.technologyStack
        }
        generated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    } | ConvertTo-Json -Depth 10
    
    Set-Content -Path "$configDir\backend-config.json" -Value $config
    
    Write-Host "✅ Backend configuration saved to .opencode/backend-config.json" -ForegroundColor Green
}

function Invoke-BackendGenerate {
    param([string]$ProjectPath, [string]$EntityName = "User")
    
    Write-Host "🚀 Generating enterprise backend code structure..." -ForegroundColor Magenta
    
    # Create directory structure
    $srcPath = Join-Path $ProjectPath "src"
    $directories = @(
        "domain/entities",
        "domain/events", 
        "domain/repositories",
        "domain/services",
        "application/commands",
        "application/queries",
        "application/handlers",
        "infrastructure/persistence",
        "infrastructure/messaging",
        "presentation/controllers",
        "presentation/dtos"
    )
    
    foreach ($dir in $directories) {
        $fullPath = Join-Path $srcPath $dir
        if (-not (Test-Path $fullPath)) {
            New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
        }
    }
    
    # Generate code files
    $entityLower = $EntityName.ToLower()
    
    # Domain Entity
    $entityCode = $ENTERPRISE_TEMPLATES["domain-entity"] -replace "\{EntityName\}", $EntityName -replace "\{entity-name\}", $entityLower
    Set-Content -Path "$srcPath/domain/entities/$entityLower.entity.ts" -Value $entityCode
    
    # Domain Events
    $eventCode = $ENTERPRISE_TEMPLATES["domain-event"] -replace "\{EntityName\}", $EntityName
    Set-Content -Path "$srcPath/domain/events/$entityLower.events.ts" -Value $eventCode
    
    # Repository Interface
    $repoCode = $ENTERPRISE_TEMPLATES["repository-interface"] -replace "\{EntityName\}", $EntityName -replace "\{entity-name\}", $entityLower
    Set-Content -Path "$srcPath/domain/repositories/$entityLower.repository.ts" -Value $repoCode
    
    # Command Handler
    $commandCode = $ENTERPRISE_TEMPLATES["command-handler"] -replace "\{EntityName\}", $EntityName -replace "\{entity-name\}", $entityLower
    Set-Content -Path "$srcPath/application/handlers/create-$entityLower.handler.ts" -Value $commandCode
    
    # Query Handler  
    $queryCode = $ENTERPRISE_TEMPLATES["query-handler"] -replace "\{EntityName\}", $EntityName -replace "\{entity-name\}", $entityLower
    Set-Content -Path "$srcPath/application/handlers/get-$entityLower.handler.ts" -Value $queryCode
    
    # API Controller
    $controllerCode = $ENTERPRISE_TEMPLATES["api-controller"] -replace "\{EntityName\}", $EntityName -replace "\{entity-name\}", $entityLower
    Set-Content -Path "$srcPath/presentation/controllers/$entityLower.controller.ts" -Value $controllerCode
    
    Write-Host "✅ Enterprise code structure generated for $EntityName" -ForegroundColor Green
}

function Invoke-BackendDeploy {
    param([string]$ProjectPath)
    
    Write-Host "🚀 Setting up production deployment configurations..." -ForegroundColor Cyan
    
    # Generate Docker Compose
    Set-Content -Path "$ProjectPath/docker-compose.yml" -Value $ENTERPRISE_TEMPLATES["docker-compose"]
    
    # Generate Dockerfile
    Set-Content -Path "$ProjectPath/Dockerfile" -Value $ENTERPRISE_TEMPLATES["dockerfile"]
    
    # Generate Kubernetes deployment
    $k8sDir = Join-Path $ProjectPath "k8s"
    if (-not (Test-Path $k8sDir)) {
        New-Item -Path $k8sDir -ItemType Directory -Force | Out-Null
    }
    Set-Content -Path "$k8sDir/deployment.yaml" -Value $ENTERPRISE_TEMPLATES["kubernetes-deployment"]
    
    # Generate monitoring configuration
    $monitoringDir = Join-Path $ProjectPath "monitoring"
    if (-not (Test-Path $monitoringDir)) {
        New-Item -Path $monitoringDir -ItemType Directory -Force | Out-Null
    }
    
    $prometheusConfig = @"
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'nestjs-app'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
    
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
      
  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
"@
    
    Set-Content -Path "$monitoringDir/prometheus.yml" -Value $prometheusConfig
    
    Write-Host "✅ Production deployment configurations created" -ForegroundColor Green
    Write-Host "📁 Files created:" -ForegroundColor White
    Write-Host "  • docker-compose.yml - Multi-service development environment" -ForegroundColor Gray
    Write-Host "  • Dockerfile - Production-optimized container" -ForegroundColor Gray
    Write-Host "  • k8s/deployment.yaml - Kubernetes deployment" -ForegroundColor Gray
    Write-Host "  • monitoring/prometheus.yml - Monitoring configuration" -ForegroundColor Gray
}

# Main command execution
switch ($Action.ToLower()) {
    "analyze" {
        $analysis = Invoke-BackendAnalyze -ProjectPath $ProjectPath -Framework $Framework -Scale $Scale
        
        if ($JsonOutput) {
            $analysis | ConvertTo-Json -Depth 10
        } else {
            # Analysis output is handled by the backend-expert-system.ps1
        }
    }
    
    "configure" {
        $analysis = Invoke-BackendAnalyze -ProjectPath $ProjectPath -Framework $Framework -Scale $Scale
        Invoke-BackendConfigure -ProjectPath $ProjectPath -Analysis $analysis
    }
    
    "generate" {
        $entityName = if ($Framework) { $Framework } else { "User" }
        Invoke-BackendGenerate -ProjectPath $ProjectPath -EntityName $entityName
    }
    
    "deploy" {
        Invoke-BackendDeploy -ProjectPath $ProjectPath
    }
    
    "full" {
        Write-Host "🚀 Running full backend expert setup..." -ForegroundColor Cyan
        
        $analysis = Invoke-BackendAnalyze -ProjectPath $ProjectPath -Framework $Framework -Scale $Scale
        Invoke-BackendConfigure -ProjectPath $ProjectPath -Analysis $analysis
        Invoke-BackendGenerate -ProjectPath $ProjectPath
        Invoke-BackendDeploy -ProjectPath $ProjectPath
        
        Write-Host ""
        Write-Host "🎉 Enterprise backend setup complete!" -ForegroundColor Green
        Write-Host "🔧 Configuration: .opencode/backend-config.json" -ForegroundColor White
        Write-Host "🏗️ Architecture: $($analysis.architecture.pattern)" -ForegroundColor White
        Write-Host "⚡ Patterns: $($analysis.developmentPatterns -join ', ')" -ForegroundColor White
        Write-Host ""
        Write-Host "⚡ Next steps:" -ForegroundColor Yellow
        Write-Host "  1. npm install - Install dependencies" -ForegroundColor White
        Write-Host "  2. docker-compose up -d - Start development environment" -ForegroundColor White
        Write-Host "  3. npm run start:dev - Start the application" -ForegroundColor White
    }
    
    default {
        Write-Host "❌ Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available actions: analyze, configure, generate, deploy, full" -ForegroundColor Yellow
        exit 1
    }
}