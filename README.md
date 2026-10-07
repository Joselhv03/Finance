# 💰 Finance

Una aplicación móvil para llevar el control de tus ingresos en bolívares, tus ahorros en dólares y su distribución entre distintas cuentas de ahorro.

## ✨ Funcionalidades

- 🔐 Autenticación de usuarios (registro, login, sesión persistente) con Supabase Auth
- 🧭 Navegación por pestañas: Resumen, Cuentas, Meses y Perfil
- 📊 Resumen del mes actual: ingresos en bolívares, total ahorrado en dólares, monto pendiente por distribuir y los últimos movimientos registrados
- 🏦 Cuentas de ahorro personalizables: nombre, color propio y meta de ahorro opcional (con barra de progreso), con tarjetas desplegables y edición/eliminación
- ➕ Registro de 5 tipos de movimiento desde una sola pantalla:
  - Ingreso en bolívares
  - Ingreso en dólares
  - Compra de dólares (con tasa de cambio y cálculo del total en Bs en vivo)
  - Ahorro (distribución de dólares hacia una cuenta)
  - Egreso (retiro de dólares de una cuenta, con motivo)
- 📅 Historial por mes: selector de mes/año con el detalle completo de ingresos, compras, ahorros distribuidos y egresos de ese mes, con opción de eliminar cualquier movimiento
- 👤 Perfil editable: nombre de usuario y contraseña.
- 🔄 Actualización automática entre pantallas al registrar o eliminar un movimiento, sin necesidad de recargar manualmente

## 🏗️ Arquitectura: MVC

El proyecto sigue el patrón Modelo-Vista-Controlador, adaptado a Flutter, para mantener el código organizado y cada capa con una única responsabilidad:

```
lib/
├── Models/          → Forma de los datos: Account, Month, IncomeBs, IncomeDollars,
│                      Buy, Movement, Spent, UserProfile
├── Controllers/      → Lógica de negocio: ChangeNotifier por pantalla, coordinan
│                      Services y notifican a la Vista cuando algo cambia
├── services/         → Única capa que habla con Supabase (auth, consultas, inserts)
├── views/            → Pantallas (screens)
└── widgets/          → Componentes reutilizables (tarjetas, campos, selectores)
```

Las pantallas se comunican con sus Controllers a través de **Provider**, y una señal global (`AppRefreshSignal`) permite que, al guardar o eliminar un movimiento, todas las pantallas afectadas se actualicen solas sin acoplarse entre sí.

## 🛠️ Stack tecnológico

| Categoría | Tecnología |
|---|---|
| Frontend | Flutter + Dart |
| Manejo de estado | Provider (ChangeNotifier) |
| Backend / Base de datos | Supabase (PostgreSQL + Auth) |
| Lógica de datos | Triggers en PostgreSQL (mantienen totales de cuentas y meses actualizados automáticamente) |
| Tipografías | Google Fonts (Newsreader, IBM Plex Sans, IBM Plex Mono) |
| Variables de entorno | flutter_dotenv |

## 🗄️ Modelo de datos (resumen)

- **Account** — cuentas de ahorro del usuario (nombre, color, meta, total)
- **Month** — un registro por mes (ingresos, ahorrado, egresos), identificado por nombre ("Septiembre 2026")
- **Income_bs** / **Income_dollars** — ingresos registrados en bolívares o en dólares
- **Buy** — compras de dólares (monto, tasa, bolívares usados)
- **Movement** — distribución de dólares hacia una cuenta de ahorro
- **Spent** — retiros de dólares desde una cuenta de ahorro

Todas las tablas cuentan con **Row Level Security (RLS)** habilitado, garantizando que cada usuario solo pueda acceder y modificar sus propios datos. Los totales de `Account` y `Month` se mantienen al día mediante **triggers de PostgreSQL**, que reaccionan automáticamente a cada inserción, edición o eliminación.

## 🚀 Cómo correrlo localmente

```bash
# Clonar el repositorio
git clone https://github.com/Joselhv03/finance_app.git
cd finance_app

# Instalar dependencias
flutter pub get

# Crear un archivo .env en la raíz con tus credenciales de Supabase
# SUPABASE_URL=tu_url
# SUPABASE_ANON_KEY=tu_publishable_key

# Correr en un emulador o dispositivo conectado
flutter run
```

## 👤 Autor

Desarrollado por **Ing. José Hurtado** como proyecto personal 🚀
