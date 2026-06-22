# Implementación de CI/CD con GitHub Actions

## 📋 Tabla de Contenidos
1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Workflows Actuales](#workflows-actuales)
3. [Estructura de los Workflows](#estructura-de-los-workflows)
4. [Detalles de cada Workflow](#detalles-de-cada-workflow)
5. [Cómo funcionan los Workflows](#cómo-funcionan-los-workflows)
6. [Configuración de Secrets y Variables](#configuración-de-secrets-y-variables)
7. [Cómo ejecutar y verificar](#cómo-ejecutar-y-verificar)
8. [Monitoreo de Ejecuciones](#monitoreo-de-ejecuciones)
9. [Troubleshooting](#troubleshooting)

---

## 📌 Resumen Ejecutivo

**¿Qué es CI/CD?**
- **CI (Continuous Integration):** Validar automáticamente cada cambio de código
- **CD (Continuous Deployment):** Automatizar el despliegue a producción/staging

**¿Qué hace en este proyecto?**

El CI/CD del proyecto Krayin CRM automatiza:
- ✅ Validación de código PHP (sintaxis, estándares PSR-12)
- ✅ Ejecución de pruebas unitarias y funcionales
- ✅ Testing de interfaz de usuario (E2E con Playwright)
- ✅ Análisis estático de código
- ✅ Generación automática de commits

**Beneficios:**
- 🎯 Errores detectados **antes** de mergear a la rama principal
- ⏱️ Reducción de tiempo en pruebas manuales
- 📊 Garantía de consistencia en la calidad

---

## 📂 Workflows Actuales

El repositorio contiene 3 workflows ubicados en `.github/workflows/`:

| Nombre | Archivo | Disparador | Descripción |
|--------|---------|-----------|-------------|
| **CI** | `ci.yml` | push, pull_request | Valida código, tests y estándares |
| **E2E Tests** | `admin_playwright_tests.yml` | push, pull_request, schedule | Pruebas de interfaz con Playwright |
| **Auto Commits** | `auto_commits.yml` | schedule (cron) | Commits automáticos semanales |

**Ver en GitHub:**
```
Repositorio → Actions → [Seleccionar workflow]
```

---

## 🔧 Estructura de los Workflows

Estructura básica de un workflow YAML:

```yaml
name: Nombre del Workflow                    # Nombre visible

on:                                          # Disparadores
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:                                        # Trabajos
  job-name:
    runs-on: ubuntu-latest                  # Ambiente
    
    steps:                                   # Pasos
      - name: Step 1
        uses: actions/checkout@v3
      
      - name: Step 2
        run: composer install
```

---

## 🔍 Detalles de cada Workflow

### **Workflow 1: CI - Continuous Integration (`ci.yml`)**

**Cuándo se ejecuta:** Cada push y PR a ramas main, develop, 2.2

**¿Qué verifica?**
1. Descarga el repositorio
2. Instala PHP 8.3 con extensiones
3. Caché de dependencias Composer
4. Instala dependencias (`composer install`)
5. Copia `.env.testing` y genera app key
6. Ejecuta migraciones de BD
7. Valida código con PHP-CS-Fixer (PSR-12)
8. Análisis estático con PHPStan
9. Ejecuta pruebas unitarias (PHPUnit)
10. Carga reporte de cobertura

**Salida esperada:**
```
✅ All checks passed
├─ Completed in 2m 45s
└─ Code coverage: 85%
```

---

### **Workflow 2: E2E Tests - Playwright (`admin_playwright_tests.yml`)**

**Cuándo se ejecuta:** Cada push, PR y diariamente a las 02:00 UTC

**¿Qué prueba?**

Simula usuario real en el panel admin:
- Navega a login
- Ingresa credenciales (admin@example.com / admin123)
- Verifica dashboard
- Prueba crear/editar/eliminar registros
- Valida respuestas de interfaz

**Pasos:**
1. Checkout y setup PHP
2. Instala dependencias PHP
3. Setup Node.js 18
4. Instala Playwright
5. Inicia servidor Laravel
6. Ejecuta tests de Playwright
7. Carga artifacts (reportes y screenshots)

**Artifacts** (si hay fallos):
- `playwright-report/index.html` — Reporte interactivo
- `playwright-report/test-results/` — Screenshots

---

### **Workflow 3: Auto Commits (`auto_commits.yml`)**

**Cuándo se ejecuta:** Cada domingo a las 00:00 UTC

**¿Qué hace?**
- Actualiza archivo `AUTOMATION.log` con timestamp
- Commit automático: `"chore: automated weekly commit via Actions"`
- Push a la rama actual

Demuestra automatización de procesos recurrentes.

---

## ⚙️ Cómo funcionan los Workflows

### Flujo de CI:

```
Developer hace push a rama 2.2
         ↓
GitHub dispara workflow "ci.yml"
         ↓
┌──────────────────────────────────┐
│ Job: test (ubuntu-latest)       │
│ - Checkout código               │
│ - Setup PHP 8.3                 │
│ - Install dependencies          │
│ - Run PHP-CS-Fixer              │
│ - Run PHPStan                   │
│ - Run PHPUnit tests             │
│ - Upload coverage               │
└──────────────────────────────────┘
         ↓
    ✅ TODO PASA              ❌ ALGO FALLA
         ↓                         ↓
    PR checks                  PR bloqueado
    "passed"              "failed" (ve errores)
         ↓                         ↓
    Puedes                    Arregla y
    mergear                   reintenta
```

### Flujo de E2E Tests:

```
Después que pasa CI
         ↓
Dispara "admin_playwright_tests.yml"
         ↓
Levanta servidor: php artisan serve
         ↓
Inicia navegador automatizado (Playwright)
         ↓
Simula clicks, rellena forms, verifica respuestas
         ↓
    ✅ OK              ❌ FALLO
     ↓                   ↓
Test passed         Screenshot + artifact
```

---

## 🔐 Configuración de Secrets y Variables

### ¿Dónde agregarlos?

```
Repositorio → Settings → Secrets and variables → Actions
```

### Secrets requeridos (información sensible):

| Nombre | Descripción |
|--------|-------------|
| `GITHUB_TOKEN` | Token automático (ya existe) |
| `GH_PAGES_TOKEN` | Para publicar en Pages |
| `SLACK_WEBHOOK` | Para notificaciones Slack |

### Variables (configuración):

| Variable | Valor |
|----------|-------|
| `PHP_VERSION` | `8.3` |
| `COMPOSER_VERSION` | `2.5` |
| `NODE_VERSION` | `18` |

### Cómo agregar un Secret:

**Opción 1: GUI**
```
Settings → Secrets and variables → Actions
→ New repository secret
→ Name: GH_PAGES_TOKEN
→ Value: ghp_xxxxx
→ Add secret
```

**Opción 2: GitHub CLI**
```bash
gh secret set GH_PAGES_TOKEN --body "ghp_xxxxx"
```

**Opción 3: En YAML**
```yaml
steps:
  - name: Use secret
    env:
      MY_SECRET: ${{ secrets.GH_PAGES_TOKEN }}
    run: echo "Secret loaded"
```

---

## ▶️ Cómo ejecutar y verificar

### Opción 1: Automático (push/PR)

```bash
git add .
git commit -m "feat: nueva funcionalidad"
git push origin feature/nueva-func

# GitHub dispara ci.yml automáticamente
# Ver en: Actions → CI
```

### Opción 2: Manual (GitHub Web)

```
Actions → [Seleccionar workflow]
→ Run workflow
→ Selecciona rama (2.2)
→ Run workflow
```

### Opción 3: Ejecutar localmente

```bash
# Instalar act (simulador de GitHub Actions)
brew install act  # macOS
sudo apt-get install act  # Linux
choco install act-cli  # Windows

# Ejecutar workflow localmente
act -j test  # Ejecuta job "test"
act          # Ejecuta todos
```

---

## 📊 Monitoreo de Ejecuciones

### Dónde ver:

```
https://github.com/R0otDrigo/krayin-ips-2026A/actions
```

### Navegación:

1. Click en **"Actions"**
2. Selecciona workflow en la izquierda
3. Click en el run que quieras ver
4. Expande cada step para ver logs

### Estructura esperada:

```
✅ CI - Continuous Integration
  └─ Commit: "feat: nuevo código"
     └─ ✅ Job: test
        └─ ✅ Checkout code             ... 0.5s
        └─ ✅ Setup PHP 8.3             ... 2.1s
        └─ ✅ Cache Composer            ... 0.3s
        └─ ✅ Install dependencies      ... 12.5s
        └─ ✅ Create .env.testing       ... 0.2s
        └─ ✅ Run migrations            ... 3.2s
        └─ ✅ PHP-CS-Fixer             ... 1.5s
        └─ ✅ PHPStan analysis         ... 4.2s
        └─ ✅ PHPUnit tests            ... 15.3s
        └─ ✅ Upload coverage          ... 2.1s
     └─ Total: 2m 45s ✅ Success
```

### Ver logs de un step:

Click en el step expandido para ver salida completa:

```
PHPUnit 10.0.0 by Sebastian Bergmann

........ 8/8 (100%)

Time: 00:45.678, Memory: 256.00 MB

OK (8 tests, 24 assertions)

Code Coverage Report:
  Classes:  85.71% ( 6/ 7)
  Methods:  90.00% (18/20)
  Lines:    85.71% (60/70)
```

---

## 🔧 Troubleshooting

### Problema 1: "PHP extensions are missing"

**Error:**
```
Error: Required extension 'mysql' is not installed.
```

**Solución:**
```yaml
- name: Setup PHP with extensions
  uses: shivammathur/setup-php@v2
  with:
    php-version: 8.3
    extensions: mysql, redis, curl, json, xml, mbstring, pdo
```

---

### Problema 2: "Composer lock file out of sync"

**Error:**
```
Root composer.json was modified, running an update.
```

**Solución local:**
```bash
composer update --no-interaction
git add composer.lock
git commit -m "chore: update composer.lock"
git push
```

---

### Problema 3: "Database connection timeout"

**Error:**
```
SQLSTATE[HY000]: General error: 1030 Got error
```

**Solución en YAML:**
```yaml
services:
  mysql:
    image: mysql:8.0
    env:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: krayin_test
    options: >-
      --health-cmd="mysqladmin ping"
      --health-interval=10s
      --health-timeout=5s
      --health-retries=3
```

---

### Problema 4: "Tests failing locally but passing in Actions"

**Causa:** Diferencias en ambiente (PHP version, extensiones, SO)

**Solución:**
```bash
php -v  # Verificar versión local

cp .env.example .env.testing

# Ejecutar tests como Actions
php vendor/bin/phpunit --configuration phpunit.xml
```

---

### Problema 5: "Playwright tests timeout"

**Error:**
```
Timeout: waiting for element to be visible (30000ms)
```

**Solución:**
```yaml
- name: Start Laravel development server
  run: |
    php artisan serve --host=127.0.0.1 --port=8000 &
    sleep 10  # Aumentar tiempo de espera
```

---

## 📚 Referencias

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Krayin CRM Docs](https://devdocs.krayincrm.com/)
- [Laravel Testing](https://laravel.com/docs/testing)
- [Playwright Documentation](https://playwright.dev/)
- [PHP-CS-Fixer](https://cs.symfony.com/)
- [PHPStan](https://phpstan.org/)
- [PHPUnit](https://phpunit.de/)
