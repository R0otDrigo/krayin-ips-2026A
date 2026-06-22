# 🚀 Implementación de CI/CD con GitHub Actions - Guía Paso a Paso

**Autor:** Ronald Camani (@ronaldcamani)  
**Proyecto:** Krayin CRM - IPS 2026-A (EPIS-UNSA)  
**Fecha de creación:** Junio 2026  
**Estado:** En desarrollo y documentación

---

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Workflows Actuales en el Repositorio](#workflows-actuales-en-el-repositorio)
3. [Estructura de los Workflows](#estructura-de-los-workflows)
4. [Detalles de cada Workflow](#detalles-de-cada-workflow)
5. [Cómo funcionan los Workflows](#cómo-funcionan-los-workflows)
6. [Configuración de Secrets y Variables](#configuración-de-secrets-y-variables)
7. [Cómo ejecutar y verificar los Workflows](#cómo-ejecutar-y-verificar-los-workflows)
8. [Monitoreo de Ejecuciones](#monitoreo-de-ejecuciones)
9. [Troubleshooting](#troubleshooting)
10. [Próximas mejoras planificadas](#próximas-mejoras-planificadas)

---

## 📌 Resumen Ejecutivo

**¿Qué es CI/CD?**
- **CI (Continuous Integration):** Integración continua — validar automáticamente cada cambio de código
- **CD (Continuous Deployment):** Despliegue continuo — automatizar el despliegue a producción/staging

**¿Qué hace en este proyecto?**

El CI/CD del proyecto Krayin CRM automatiza:
- ✅ Validación de código PHP (sintaxis, estándares PSR-12)
- ✅ Ejecución de pruebas unitarias y funcionales
- ✅ Testing de interfaz de usuario (E2E con Playwright)
- ✅ Análisis estático de código
- ✅ Generación automática de commits (para demostración)
- ✅ Notificación de resultados en PRs

**Beneficios:**
- 🎯 Errores detectados **antes** de mergear a la rama principal
- ⏱️ Reducción de tiempo en pruebas manuales
- 📊 Garantía de consistencia en la calidad
- 🔄 Procesos repetitivos automatizados

---

## 📂 Workflows Actuales en el Repositorio

El repositorio contiene 3 workflows GitHub Actions ubicados en `.github/workflows/`:

| # | Nombre del Workflow | Archivo | Rama | Disparador |
|---|---|---|---|---|
| 1 | **CI - Continuous Integration** | `ci.yml` | main, develop, 2.2 | push, pull_request |
| 2 | **E2E Tests - Playwright (Admin)** | `admin_playwright_tests.yml` | main, develop, 2.2 | push, pull_request, schedule |
| 3 | **Auto Commits - Scheduled** | `auto_commits.yml` | Todas | schedule (cron) |

**Ubicación en GitHub:**
```
https://github.com/R0otDrigo/krayin-ips-2026A
  └─ .github/
     └─ workflows/
        ├─ ci.yml
        ├─ admin_playwright_tests.yml
        └─ auto_commits.yml
```

**Para verlos ejecutándose:**
```
Repositorio → Actions → [Seleccionar workflow]
```

---

## 🔧 Estructura de los Workflows

### Estructura general de un workflow YAML:

```yaml
name: Nombre del Workflow                    # Nombre visible en GitHub Actions

on:                                          # Disparadores (triggers)
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  schedule:
    - cron: '0 2 * * *'

jobs:                                        # Trabajos a ejecutar
  job-name:
    runs-on: ubuntu-latest                  # Ambiente de ejecución
    
    services:                                # Servicios auxiliares (BD, Redis)
      mysql:
        image: mysql:8.0
    
    steps:                                   # Pasos del job
      - name: Step 1 - Checkout code
        uses: actions/checkout@v3
      
      - name: Step 2 - Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: 8.3
      
      - name: Step 3 - Install dependencies
        run: composer install
      
      - name: Step 4 - Run tests
        run: php vendor/bin/phpunit
```

---

## 🔍 Detalles de cada Workflow

### **Workflow 1: CI - Continuous Integration (`ci.yml`)**

**Propósito:** Validar cada push y PR contra código PHP, tests y estándares

**Cuándo se ejecuta:**
- ✅ Cuando haces `git push` a las ramas main, develop, o 2.2
- ✅ Cuando abres un Pull Request hacia esas ramas

**¿Qué verifica?**

1. **Checkout del código** → Descarga el repositorio
2. **Setup PHP 8.3** → Instala PHP con extensiones necesarias
3. **Cache de Composer** → Almacena en caché las librerías para acelerar
4. **Install dependencies** → `composer install` (descarga librerías PHP)
5. **Create .env.testing** → Copia archivo de configuración para tests
6. **Generate app key** → `php artisan key:generate --env=testing`
7. **Run migrations** → `php artisan migrate --env=testing`
8. **PHP-CS-Fixer** → Verifica que el código cumpla con PSR-12
9. **PHPStan** → Análisis estático para detectar errores lógicos
10. **PHPUnit Tests** → Ejecuta pruebas unitarias
11. **Upload coverage** → Envía reporte de cobertura de código

**Salida esperada si TODO PASA ✅:**
```
✅ All checks passed
├─ CI / test ... completed in 2m 45s
└─ Code coverage: 85%
```

**Salida si FALLA ❌:**
```
❌ Some checks failed
├─ CI / test ... failed after 1m 20s
└─ Error: PHPUnit tests failed
   └─ See details for log
```

---

### **Workflow 2: E2E Tests - Playwright Admin (`admin_playwright_tests.yml`)**

**Propósito:** Pruebas automatizadas de la interfaz de usuario del panel admin

**Cuándo se ejecuta:**
- ✅ En cada `push` y `pull_request`
- ✅ Diariamente a las 02:00 UTC (cron schedule)

**¿Qué prueba?**

Este workflow inicia la aplicación Laravel localmente y simula un usuario real usando Playwright:

1. Navega a la página de login
2. Ingresa credenciales (admin@example.com / admin123)
3. Verifica que el dashboard carga correctamente
4. Prueba crear/editar/eliminar registros
5. Valida que la interfaz responda correctamente

**Pasos que ejecuta:**
1. Checkout código
2. Setup PHP 8.3
3. Install dependencias PHP (`composer install`)
4. Setup Node.js 18
5. Install Playwright (`npm install @playwright/test`)
6. Start Laravel server (`php artisan serve`)
7. Wait 5 segundos para que inicie
8. Run Playwright tests (`npx playwright test`)
9. Upload artifacts (reportes y screenshots)

**Artifacts generados** (si hay fallos):
- `playwright-report/index.html` — Reporte HTML interactivo
- `playwright-report/test-results/` — Screenshots de los fallos

---

### **Workflow 3: Auto Commits - Scheduled (`auto_commits.yml`)**

**Propósito:** Generador automático de commits (demostración de automation)

**Cuándo se ejecuta:**
- ✅ Cada domingo a las 00:00 UTC (schedule cron)

**¿Qué hace?**
1. Checkout del código
2. Actualiza archivo `AUTOMATION.log` con timestamp
3. Configura user de git (`action@github.com`)
4. Commit automático: `"chore: automated weekly commit via Actions"`
5. Push a la rama actual

**Propósito:** Demostrar que GitHub Actions puede automatizar incluso operaciones de git, útil para tareas recurrentes.

---

## ⚙️ Cómo funcionan los Workflows

### Diagrama de flujo - CI:

```
Developer hace push a rama 2.2
         │
         ▼
GitHub recibe el push
         │
         ▼
Dispara workflow "ci.yml"
         │
         ▼
┌────────────────────────────────────┐
│ Job: test                          │
│ Runs-on: ubuntu-latest             │
├────────────────────────────────────┤
│ Step 1: Checkout                   │ ← Descarga código
│ Step 2: Setup PHP 8.3              │ ← Instala PHP
│ Step 3: Cache Composer             │ ← Caché (acelera)
│ Step 4: Install dependencies       │ ← composer install
│ Step 5: Create .env                │ ← Config para tests
│ Step 6: Generate key               │ ← App key
│ Step 7: Run migrations             │ ← BD lista
│ Step 8: PHP-CS-Fixer               │ ← Estándares?
│ Step 9: PHPStan                    │ ← Errores lógicos?
│ Step 10: PHPUnit tests             │ ← Tests OK?
│ Step 11: Upload coverage           │ ← Reporta cobertura
└────────────────────────────────────┘
         │
         ├─→ SI TODO ✅ PASA
         │     └─→ PR se marca como "checks passed"
         │         └─→ Puedes mergear a 2.2
         │
         └─→ SI ALGO ❌ FALLA
               └─→ PR se marca como "checks failed"
                   └─→ Ves errores en detalles
                       └─→ No puedes mergear hasta arreglar
```

### Diagrama de flujo - E2E Tests:

```
Después que pasa CI
         │
         ▼
Dispara workflow "admin_playwright_tests.yml"
         │
         ▼
Levanta servidor: php artisan serve
         │
         ▼
Inicia navegador automatizado (Playwright)
         │
         ▼
Simula clicks, rellena forms, verifica respuestas
         │
         ├─→ SI TODO ✅ OK
         │     └─→ Test passed
         │
         └─→ SI FALLO ❌
               └─→ Screenshot del error
                   └─→ Descargable en artifacts
```

---

## 🔐 Configuración de Secrets y Variables

### ¿Para qué sirven?

- **Secrets:** Información sensible (tokens, API keys, contraseñas)
- **Variables:** Configuración no sensible (versiones, hosts, emails)

### ¿Dónde agregarlos?

```
Repositorio → Settings → Secrets and variables → Actions
```

### Secrets usados en este proyecto (si hay):

| Nombre | Descripción | Ejemplo de valor |
|--------|-------------|------------------|
| `GITHUB_TOKEN` | Token automático de GitHub (ya existe) | (auto) |
| `GH_PAGES_TOKEN` | Token para publicar en Pages (si lo necesitas) | `ghp_xxxxx` |
| `SLACK_WEBHOOK` | Para notificaciones Slack (opcional) | `https://hooks.slack.com/...` |

### Variables usadas:

| Nombre | Descripción | Valor actual |
|--------|-------------|--------------|
| `PHP_VERSION` | Versión de PHP | `8.3` |
| `COMPOSER_VERSION` | Versión de Composer | `2.5` |
| `NODE_VERSION` | Versión de Node.js | `18` |

### Cómo agregar un Secret:

**Opción 1: Por GUI (GitHub Web)**
```
1. Repositorio → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: GH_PAGES_TOKEN
4. Value: ghp_xxxxx (tu token)
5. Click "Add secret"
```

**Opción 2: Por GitHub CLI**
```bash
gh secret set GH_PAGES_TOKEN --body "ghp_xxxxx"
```

**Opción 3: En el workflow YAML**
```yaml
steps:
  - name: Use secret
    env:
      MY_SECRET: ${{ secrets.GH_PAGES_TOKEN }}
    run: echo "Secret loaded"
```

---

## ▶️ Cómo ejecutar y verificar los Workflows

### Opción 1: Automático (push/PR)

```bash
# Haces un push a la rama 2.2
git add .
git commit -m "feat: nueva funcionalidad"
git push origin feature/nueva-func

# GitHub detecta el push → dispara ci.yml automáticamente
# Ves el workflow en ejecución en: Actions → CI
```

### Opción 2: Manual (desde GitHub Web)

```
Repositorio → Actions → [Seleccionar workflow]
  → Click "Run workflow"
  → Selecciona rama (2.2)
  → Click "Run workflow"
```

### Opción 3: Ejecutar localmente (simular)

```bash
# Instalar act (simulador de GitHub Actions)
# macOS:
brew install act

# Linux:
sudo apt-get install act

# Windows (PowerShell):
choco install act-cli

# Ejecutar workflow localmente
act -j test  # Ejecuta el job "test"
act          # Ejecuta todos los jobs
```

---

## 📊 Monitoreo de Ejecuciones

### Dónde ver los Workflows:

```
https://github.com/R0otDrigo/krayin-ips-2026A/actions
```

### Ver un workflow específico:

1. **Click en "Actions"** en la página principal del repo
2. **Selecciona el workflow** en la izquierda (ej: "CI - Continuous Integration")
3. **Haz click en el run** que quieras ver (arriba está el más reciente)
4. **Expande cada step** para ver logs detallados

### Estructura de la página de Actions:

```
┌─────────────────────────────────────────────────────┐
│ All workflows                                       │
├─────────────────────────────────────────────────────┤
│ ✅ CI - Continuous Integration                     │
│ ✅ E2E Tests - Playwright (Admin)                  │
│ ✅ Auto Commits - Scheduled                        │
└─────────────────────────────────────────────────────┘

    ↓ (click en CI)

┌─────────────────────────────────────────────────────┐
│ CI - Continuous Integration                         │
├─────────────────────────────────────────────────────┤
│ Branch: 2.2                                         │
│ ✅ Commit: "feat: nuevo código"                    │
│    └─ Completed in 2m 45s                          │
│ ✅ PR #123                                         │
│    └─ Completed in 2m 20s                          │
│ ❌ Commit: "bug: arreglar algo"                    │
│    └─ Failed after 1m 15s                          │
└─────────────────────────────────────────────────────┘

    ↓ (click en el commit)

┌─────────────────────────────────────────────────────┐
│ CI - Continuous Integration › feat: nuevo código    │
├─────────────────────────────────────────────────────┤
│ Job: test                                           │
│                                                     │
│ ✅ Checkout code                    ... 0.5s       │
│ ✅ Setup PHP 8.3                    ... 2.1s       │
│ ✅ Cache Composer packages          ... 0.3s       │
│ ✅ Install dependencies             ... 12.5s      │
│ ✅ Create .env.testing              ... 0.2s       │
│ ✅ Generate app key                 ... 0.8s       │
│ ✅ Run migrations                   ... 3.2s       │
│ ✅ Run PHP-CS-Fixer                 ... 1.5s       │
│ ✅ Run PHPStan analysis             ... 4.2s       │
│ ✅ Run PHPUnit tests                ... 15.3s      │
│ ✅ Upload coverage to Codecov       ... 2.1s       │
│                                                     │
│ Total time: 2m 45s ✅ Success                      │
└─────────────────────────────────────────────────────┘
```

### Ver logs de un step específico:

```
Click en cualquier step expandido
↓
Verás salida completa del comando, ej:

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

### Problema 1: ❌ "PHP extensions are missing"

**Síntoma:**
```
Error: Required extension 'mysql' is not installed.
```

**Causa:** El workflow no tiene instaladas las extensiones PHP necesarias.

**Solución:**
```yaml
- name: Setup PHP with extensions
  uses: shivammathur/setup-php@v2
  with:
    php-version: 8.3
    extensions: mysql, redis, curl, json, xml, mbstring, pdo
```

---

### Problema 2: ❌ "Composer lock file out of sync"

**Síntoma:**
```
Root composer.json was modified, running an update.
This will change the contents of composer.lock.
```

**Causa:** El archivo `composer.lock` en el repo no coincide con `composer.json`.

**Solución (local):**
```bash
composer update --no-interaction
git add composer.lock
git commit -m "chore: update composer.lock"
git push
```

---

### Problema 3: ❌ "Database connection timeout"

**Síntoma:**
```
SQLSTATE[HY000]: General error: 1030 Got error
Cannot connect to MySQL server
```

**Causa:** El servicio MySQL no está listo cuando PHP intenta conectar.

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

### Problema 4: ❌ "Tests failing locally but passing in Actions (o viceversa)"

**Causa:** Diferencias en ambiente (PHP version, extensiones, SO).

**Solución:**
```bash
# Instalar misma versión de PHP localmente que en Actions
php -v  # Verificar versión

# Usar mismo .env que los tests
cp .env.example .env.testing

# Ejecutar tests como lo hace Actions
php vendor/bin/phpunit --configuration phpunit.xml
```

---

### Problema 5: ❌ "Playwright tests timeout"

**Síntoma:**
```
Timeout: waiting for element to be visible (30000ms)
```

**Causa:** La aplicación no inicia a tiempo o la URL no es accesible.

**Solución:**
```yaml
- name: Start Laravel development server
  run: |
    php artisan serve --host=127.0.0.1 --port=8000 &
    sleep 10  # Aumentar tiempo de espera
```

---

## 🚀 Próximas mejoras planificadas

De acuerdo al Issue #37 (Documentación Técnica) y #38 (Optimización del Despliegue):

- [ ] **Issue #25:** Despliegue Continuo (CD) a Staging
  - Workflow que despliega automáticamente a servidor staging
  - Ejecutar migraciones en staging
  - Publicar burndown chart en GitHub Pages

- [ ] **Issue #15:** Integración del Burndown Chart
  - Script que calcula burndown basado en issues cerrados
  - Generar gráfico PNG/HTML
  - Publicar en GitHub Pages automáticamente

- [ ] **Issue #38:** Notificaciones automáticas
  - Slack: alertar cuando pipeline falla
  - Email: resumen de ejecuciones diarias
  - Webhook: integración con sistemas externos

- [ ] **Seguridad:**
  - Agregar SonarQube para análisis de vulnerabilidades
  - SAST (Static Application Security Testing)
  - Dependency scanning con GitHub's Dependabot

- [ ] **Performance:**
  - Lighthouse CI para auditorías de rendimiento
  - Load testing automático
  - Cache optimization validation

---

## 📸 Capturas de Referencia

### Captura 1: Página principal de Actions
```
URL: https://github.com/R0otDrigo/krayin-ips-2026A/actions
Deberías ver:
✅ 3 workflows listados
✅ Estado de últimas ejecuciones
✅ Duración de cada job
```

### Captura 2: Detalles de un run
```
URL: https://github.com/R0otDrigo/krayin-ips-2026A/actions/runs/[RUN_ID]
Deberías ver:
✅ Job "test" expandido
✅ Todos los steps con checkmarks
✅ Duración de 2-3 minutos
```

### Captura 3: PR con checks
```
URL: https://github.com/R0otDrigo/krayin-ips-2026A/pull/[PR_NUMBER]
Deberías ver:
✅ Sección "Checks" (debajo del PR description)
✅ "All checks passed" o detalles de fallos
✅ Posibilidad de mergear si todo pasa
```

---

## 📚 Referencias y Recursos

- **GitHub Actions Documentation:** https://docs.github.com/en/actions
- **Krayin CRM Official Docs:** https://devdocs.krayincrm.com/
- **Laravel Testing Guide:** https://laravel.com/docs/testing
- **Playwright Documentation:** https://playwright.dev/
- **PHP-CS-Fixer Guide:** https://cs.symfony.com/
- **PHPStan Documentation:** https://phpstan.org/
- **PHPUnit Documentation:** https://phpunit.de/

---

## ✅ Checklist de Implementación

Para confirmar que la documentación es completa:

- [x] Explicar qué es CI/CD y por qué es importante
- [x] Listar los 3 workflows existentes
- [x] Documentar cada workflow en detalle
- [x] Explicar cómo se disparan (triggers)
- [x] Mostrar estructura YAML básica
- [x] Explicar cómo configurar secrets
- [x] Instrucciones para ejecutar y verificar
- [x] Cómo monitorear en GitHub Web
- [x] Soluciones para 5 problemas comunes
- [x] Próximas mejoras planificadas
- [x] Referencias útiles

---

## 👤 Contribuyentes

**Documentación redactada por:** Ronald Camani (@ronaldcamani)  
**Equipo del Proyecto:**
- Ronald Camani (@ronaldcamani)
- Chikistrikis21 (@chikistrikis21)
- Fernando-Solsol (@Fernando-Solsol)
- Diego-Schreiber (@Diego-Schreiber)
- R0otDrigo (@R0otDrigo)

**Última actualización:** Junio 2026

---

## 🎯 Conclusión

Este documento complementa la página de Wiki existente con:
- ✅ Explicaciones paso a paso del flujo
- ✅ Diagramas de cómo funcionan
- ✅ Troubleshooting práctico
- ✅ Links directos a donde verificar
- ✅ Mejoras futuras identificadas

**Para consultas o actualizaciones, referirse a Issue #37: Documentación Técnica del Proceso Scrum + DevOps**

---
