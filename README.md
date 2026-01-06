# Health App 🚀⚡

Aplicación integral de gestión de salud, nutrición y entrenamiento con una estética **Actual**. El proyecto combina un frontend móvil moderno con un backend robusto y escalable.

---

## 🏛️ Arquitectura del Proyecto

### 🌐 Backend (Node.js & TypeScript)

El servidor está diseñado bajo un patrón de **Controladores y Rutas** altamente modular, priorizando la seguridad y el rendimiento.

- **Stack**:
  - **Runtime**: Node.js + TypeScript para tipado estático.
  - **ORM**: [Prisma](https://www.prisma.io/) interactuando con **PostgreSQL**.
  - **Seguridad**: Autenticación vía **JWT**, protección de headers con **Helmet**, y hashing de contraseñas con **BcryptJS**.
  - **Documentación**: Estructura clara de carpetas por responsabilidad (`controllers`, `routes`, `middleware`, `data`, `utils`).

### 🔴 Integración con Redis

Redis actúa como nuestra capa de optimización crítica para dos propósitos principales:

1. **Caching Inteligente**: Almacenamiento temporal de datos de lectura frecuente (catálogo de alimentos, rutinas base) para reducir la carga en la base de datos PostgreSQL.
2. **Rate Limiting**: Protección contra ataques de fuerza bruta y abuso de API, gestionando límites de peticiones por IP de forma distribuida.

---

### 📱 Frontend (Flutter)

La aplicación móvil utiliza una arquitectura **Clean-ish / Feature-first**, diseñada para ser escalable y fácil de mantener.

- **Gestión de Estado**: [Riverpod](https://riverpod.dev/). Permite una reactividad precisa y una inyección de dependencias desacoplada.
- **Navegación**: [GoRouter](https://pub.dev/packages/go_router) para manejo de rutas declarativas y sub-rutas anidadas.
- **Capas por Feature**:
  - **Presentation**: Widgets y UI (incluyendo el sistema de diseño de tarjetas neón).
  - **Domain**: Modelos de datos y lógica de negocio pura.
  - **Data**: Repositorios y API Clients (Dio) que gestionan la comunicación con el backend.
- **Diseño**: Sistema de diseño personalizado con animaciones fluidas (Flutter Animate) y efectos de **Glassmorphism**.

---

## 🛠️ Guía de Desarrollo

### Requisitos

- Flutter SDK (>= 3.2.0)
- Node.js & npm
- Instancia de PostgreSQL y Redis funcional.

### Configuración Rápida

1. **Backend**:
   ```bash
   cd backend
   npm install
   # Configura tu .env con DATABASE_URL y REDIS_URL
   npx prisma generate
   npm run dev
   ```
2. **Frontend**:
   ```bash
   flutter pub get
   flutter run
   ```

---

## 🎯 Visión del Proyecto

Proporcionar una herramienta técnica de alto nivel para usuarios que buscan el control total de su evolución física, integrando generación automática de dietas y seguimiento de medidas en un entorno visual futurista.

---

_Desarrollado con pasión por la tecnología y el fitness._
