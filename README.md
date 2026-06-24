<p align="center">
  <img alt="Krayips CRM" height="100" src="packages/Webkul/Admin/src/Resources/assets/images/logo.svg">
</p>

<h1 align="center">Krayips CRM</h1>
<p align="center"><i>Proyecto académico de gestión de relaciones con clientes, desarrollado e implementado con prácticas DevOps</i></p>

---

## Tabla de contenidos

1. [Sobre el proyecto](#sobre-el-proyecto)
2. [Equipo de desarrollo](#equipo-de-desarrollo)
3. [Arquitectura de la solución](#arquitectura-de-la-solución)
4. [Flujo de integración y despliegue continuo](#flujo-de-integración-y-despliegue-continuo)
5. [Cronología del proyecto (Sprints)](#cronología-del-proyecto-sprints)
6. [Resultados y evidencias del despliegue](#resultados-y-evidencias-del-despliegue)
7. [Antes y después: beneficios obtenidos](#antes-y-después-beneficios-obtenidos)
8. [Requisitos técnicos](#requisitos-técnicos)
9. [Licencia](#licencia)

---

## Sobre el proyecto

**Krayips CRM** nace como un ejercicio de implementación real sobre una base CRM en Laravel y Vue.js, donde el foco no estuvo en escribir el CRM desde cero, sino en **gestionarlo como un producto vivo**: con un backlog priorizado, historias de usuario, sprints definidos y, sobre todo, un pipeline de entrega que automatiza el paso del código del repositorio a un servidor en producción.

A diferencia de una instalación manual típica, este proyecto documenta el camino completo: desde que un desarrollador sube un cambio hasta que ese cambio queda visible en el entorno desplegado, pasando por integración continua, contenedores y una instancia en la nube.

El trabajo se organizó alrededor de 39 historias de usuario agrupadas en 5 sprints, cubriendo desde la gestión de cuentas y permisos hasta cotizaciones, embudos de venta y reportes de rendimiento.

## Equipo de desarrollo

| Integrante | Rol principal en el backlog |
|---|---|
| Rodrigo Estefanero | Roles y permisos, catálogo, campos personalizados, cotizaciones |
| Diego Schreiber | Cuentas de usuario, clasificación de prospectos, plantillas de correo |
| Fernando Solsol | Accesos, notificaciones, tareas, correo, cotizaciones |
| Rodolfo Soria | Recuperación de contraseña, formularios, kanban, reportes |
| Ronald Camani | Configuración general, etiquetas, multimoneda, papelera |

## Arquitectura de la solución

El sistema mantiene la base funcional de Laravel (backend) y Vue.js (frontend), pero la diferencia respecto a una instalación estándar está en la capa de infraestructura que se construyó alrededor:

| Componente | Tecnología utilizada | Función dentro del proyecto |
|---|---|---|
| Backend | Laravel (PHP 8.3) | Lógica de negocio, módulos de CRM |
| Frontend | Vue.js | Interfaz administrativa |
| Base de datos | MySQL 8.0 | Persistencia de leads, clientes y cotizaciones |
| Control de versiones | Git / GitHub | Repositorio central e issues del backlog |
| Integración continua | GitHub Actions | Build, pruebas y empaquetado automático |
| Contenerización | Docker | Empaquetado reproducible de la aplicación |
| Infraestructura | AWS EC2 | Servidor donde corre la instancia desplegada |

## Flujo de integración y despliegue continuo

El pipeline implementado sigue un recorrido lineal desde el código fuente hasta el entorno productivo:

```
 Desarrollador
      │  (commit / push)
      ▼
   GitHub  ──────────────► Pull Request + revisión de issue del backlog
      │
      ▼
 GitHub Actions
      │  build · lint · pruebas
      ▼
   Imagen Docker
      │  empaquetado de la app
      ▼
   AWS EC2
      │  contenedor en ejecución
      ▼
 Krayips CRM accesible en producción
```

Cada historia de usuario del backlog, una vez en estado *Done*, llega a este flujo sin intervención manual en el servidor: el contenedor se reconstruye y se reemplaza automáticamente.

## Cronología del proyecto (Sprints)

El backlog se organizó en 5 sprints entre el **1 de mayo** y el **8 de julio de 2026**. Las fechas mostradas corresponden a la planificación interna del equipo:

| Sprint | Periodo | Foco principal | Historias representativas |
|---|---|---|---|
| Sprint 0 | 01 may – 14 may | Cimientos del sistema: cuentas, accesos, roles | US39, US36, US15, US40, US16, US25 |
| Sprint 1 | 15 may – 28 may | Gestión de prospectos | US26, US02, US05, US01, US03, US09, US20, US38 |
| Sprint 2 | 29 may – 11 jun | Seguimiento comercial y productividad | US31, US34, US04, US10, US21, US07, US28, US06, US29 |
| Sprint 3 | 12 jun – 25 jun | Cotizaciones y catálogo | US13, US18, US22, US11, US08, US27, US12, US32, US35 |
| Sprint 4 | 26 jun – 08 jul | Organizaciones, auditoría y reportes | US37, US17, US33, US30, US14, US23, US24, US19 |

> Las fechas son referenciales y fueron definidas por el equipo para efectos de planificación y seguimiento del backlog en GitHub Projects.

## Resultados y evidencias del despliegue

A continuación se muestran capturas del panel administrativo del sistema, correspondientes a la instancia desplegada de Krayips CRM:

![Panel principal de Krayips CRM](https://raw.githubusercontent.com/krayin/temp-media/master/dashboard.png)
*Panel principal con indicadores de prospectos y ventas, generado a partir de las historias US06 y US19.*

![Krayips CRM en la nube](https://raw.githubusercontent.com/krayin/temp-media/master/cloud_hosting.png)
*Vista de la instancia corriendo sobre infraestructura en la nube (AWS EC2).*

![Tablero de gestión de prospectos](https://raw.githubusercontent.com/krayin/temp-media/master/krayin-saas.png)
*Vista del tablero de gestión, asociado a las historias US06, US26 y US01.*

## Antes y después: beneficios obtenidos

| Antes (proceso manual) | Después (con el pipeline implementado) |
|---|---|
| Despliegue manual vía FTP o SSH directo | Despliegue automático disparado por cada push a la rama principal |
| Configuración repetida en cada servidor | Imagen Docker única, reproducible en cualquier entorno |
| Errores humanos al copiar archivos o variables de entorno | Variables y build gestionados por GitHub Actions |
| Sin trazabilidad de qué cambio se desplegó | Cada despliegue queda asociado a un commit y a una historia del backlog |
| Tiempo de despliegue variable, dependiente de la persona | Tiempo de despliegue consistente y medible |

## Requisitos técnicos

- **Servidor**: instancia AWS EC2 (Ubuntu) con Docker instalado.
- **RAM**: 3 GB o superior.
- **PHP**: 8.3 o superior.
- **Composer**: 2.5 o superior.
- **MySQL**: 8.0.32 o superior.
- **Acceso administrativo**: definido en las historias US39 y US36 del backlog.

## Licencia

Este proyecto se basa en una distribución bajo licencia MIT y se utiliza con fines académicos para la implementación de prácticas de DevOps e integración continua.
