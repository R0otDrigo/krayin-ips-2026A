# Implementación de CI/CD con GitHub Actions

**Proyecto:** Krayin CRM - IPS 2026-A (EPIS-UNSA)  
**Última actualización:** Junio 2026

---

## 📌 1. Introducción y Arquitectura DevOps

La adopción de prácticas **DevOps** en este proyecto tiene como objetivo:
- ✅ Eliminar procesos manuales
- ✅ Reducir errores de integración
- ✅ Validar código antes de desplegarlo
- ✅ Garantizar consistencia en la calidad

Hemos implementado un flujo de **Integración Continua (CI)** y **Despliegue Continuo (CD)** utilizando **GitHub Actions**. Este flujo actúa como un puente automatizado entre el repositorio (código fuente) y el entorno de Staging (servidor de pruebas).

---

## 🐳 2. Fase Previa: Infraestructura como Código (Docker)

Antes de automatizar en GitHub Actions, estandarizamos el entorno usando Docker para garantizar que "funcione igual en todas partes".

**Archivos creados:**

| Archivo | Propósito |
|---------|----------|
| **`Dockerfile`** | Define imagen base PHP, instala extensiones (`pdo_mysql`, `gd`, `zip`), configura servidor web |
| **`docker-compose.yml`** | Orquesta servicios: contenedor web + base de datos MySQL/MariaDB en red aislada |

---

## ⚙️ 3. Integración Continua (CI) - *El Guardián del Código*

**¿Qué hace?** Verifica que el código no esté roto antes de intentar publicarlo.

### Eventos Disparadores
- `push` a rama `main/develop/2.2`
- `pull_request` abierto hacia estas ramas

### Pasos Automatizados del Workflow (`ci.yml`)

| Paso | Descripción | Tiempo |
|------|-------------|--------|
| **Checkout** | Clona repositorio en runner de GitHub | 2s |
| **Setup PHP** | Configura PHP 8.3 con extensiones | 5s |
| **Composer Install** | Instala dependencias backend | 45s |
| **Setup Entorno** | Copia `.env.example` → `.env`, genera key | 2s |
| **Análisis Estático** | Linters, pruebas unitarias, detección de errores | 30s |
| **PHPUnit Tests** | Ejecuta suite de tests | 15s |

**Resultado:**
- ✅ **PASA:** PR se marca "checks passed" → puedes mergear
- ❌ **FALLA:** PR bloqueado → debes arreglar errores

---

## 🚀 4. Despliegue Continuo (CD) - *Entrega a Staging*

**¿Qué hace?** Una vez CI finaliza exitosamente, despliega código validado al servidor Staging.

### Objetivo
Publicar código en servidor de pruebas para que Product Owner/QA prueben nuevas funcionalidades.

### Gestión de Credenciales (GitHub Secrets)

Por seguridad, credenciales están en **Settings → Secrets and variables → Actions**:

| Secret | Propósito |
|--------|----------|
| `SERVER_HOST` | IP/URL del servidor Staging |
| `SERVER_USER` | Usuario SSH para acceso |
| `SERVER_SSH_KEY` | Clave privada SSH (sin contraseña) |

### Flujo de Despliegue

```yaml
deploy:
  needs: build-and-test          # Solo si CI pasa
  runs-on: ubuntu-latest
  steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Deploy to Staging via SSH
      uses: appleboy/ssh-action@v0.1.6
      with:
        host: ${{ secrets.SERVER_HOST }}
        username: ${{ secrets.SERVER_USER }}
        key: ${{ secrets.SERVER_SSH_KEY }}
        script: |
          cd /var/www/krayincrm-staging
          git pull origin main
          composer install --no-interaction --prefer-dist
          php artisan migrate --force
          php artisan optimize:clear
```

---

## 📂 5. Workflows Implementados

El repositorio contiene 3 workflows en `.github/workflows/`:

### **Workflow 1: CI (`ci.yml`)**
- **Dispara:** Push, Pull Request
- **Valida:** Código PHP, estándares PSR-12, pruebas, análisis estático

### **Workflow 2: E2E Tests (`admin_playwright_tests.yml`)**
- **Dispara:** Push, Pull Request, diariamente 02:00 UTC
- **Prueba:** Interfaz usuario (login, dashboard, CRUD)
- **Genera:** Reporte HTML + screenshots de fallos

### **Workflow 3: Auto Commits (`auto_commits.yml`)**
- **Dispara:** Semanalmente (domingo 00:00 UTC)
- **Automatiza:** Generación de commits para demostración

---

## 🔐 6. Configuración de Secrets y Variables

### ¿Dónde configurar?
```
Repositorio → Settings → Secrets and variables → Actions
```

### Secrets (información sensible)

```bash
# Opción 1: GUI GitHub
# Settings → New repository secret

# Opción 2: GitHub CLI
gh secret set GH_PAGES_TOKEN --body "ghp_xxxxx"

# Opción 3: En YAML workflow
env:
  MY_SECRET: ${{ secrets.GH_PAGES_TOKEN }}
```

### Variables (configuración no sensible)

| Variable | Valor |
|----------|-------|
| `PHP_VERSION` | `8.3` |
| `COMPOSER_VERSION` | `2.5` |
| `NODE_VERSION` | `18` |

---

## ▶️ 7. Cómo Ejecutar y Verificar

### Opción 1: Automático (Push/PR)
```bash
git add .
git commit -m "feat: nueva funcionalidad"
git push origin feature/nueva-func

# GitHub dispara ci.yml automáticamente
# Ver en: Actions → CI
```

### Opción 2: Manual (GitHub Web)
```
Actions → [Workflow] → Run workflow → Rama (2.2) → Run
```

### Opción 3: Local (Simulador)
```bash
brew install act           # macOS
sudo apt-get install act   # Linux

act -j test                # Ejecuta job específico
act                        # Ejecuta todos los jobs
```

---

## 📊 8. Monitoreo de Ejecuciones

### Dónde ver
```
https://github.com/R0otDrigo/krayin-ips-2026A/actions
```

### Estructura de ejecución
```
Actions → [Workflow] → [Run] → [Job] → [Steps]
         
         ↓

✅ CI - Continuous Integration (2m 45s)
  ├─ ✅ Checkout code           (0.5s)
  ├─ ✅ Setup PHP 8.3           (2.1s)
  ├─ ✅ Cache Composer          (0.3s)
  ├─ ✅ Install dependencies    (12.5s)
  ├─ ✅ Run migrations          (3.2s)
  ├─ ✅ PHP-CS-Fixer           (1.5s)
  ├─ ✅ PHPStan analysis       (4.2s)
  ├─ ✅ PHPUnit tests          (15.3s)
  └─ ✅ Upload coverage        (2.1s)
```

---

## 🔧 9. Troubleshooting

### ❌ "PHP extensions are missing"
```yaml
- name: Setup PHP
  uses: shivammathur/setup-php@v2
  with:
    php-version: 8.3
    extensions: mysql, redis, curl, json, xml, mbstring, pdo
```

### ❌ "Composer lock file out of sync"
```bash
composer update --no-interaction
git add composer.lock
git commit -m "chore: update composer.lock"
git push
```

### ❌ "Database connection timeout"
```yaml
services:
  mysql:
    image: mysql:8.0
    env:
      MYSQL_ROOT_PASSWORD: root
    options: >-
      --health-cmd="mysqladmin ping"
      --health-interval=10s
      --health-timeout=5s
      --health-retries=3
```

### ❌ "Playwright tests timeout"
```yaml
- name: Start Laravel server
  run: |
    php artisan serve --host=127.0.0.1 --port=8000 &
    sleep 10  # Aumentar tiempo de espera
```

### ❌ "Tests fallan local pero pasan en Actions"
```bash
# Usar misma versión PHP local
php -v

# Usar mismo .env
cp .env.example .env.testing

# Ejecutar tests igual que Actions
php vendor/bin/phpunit --configuration phpunit.xml
```

---

## 📚 Referencias

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Krayin CRM Official Docs](https://devdocs.krayincrm.com/)
- [Laravel Testing](https://laravel.com/docs/testing)
- [Playwright Documentation](https://playwright.dev/)
- [PHP-CS-Fixer](https://cs.symfony.com/)
- [PHPStan](https://phpstan.org/)

---

**Responsable:** Ronald Camani (@ronaldcamani)  
**Proyecto:** Krayin CRM IPS 2026-A
