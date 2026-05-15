# MediCheck

MediCheck es una aplicación móvil desarrollada con Flutter cuyo objetivo es ayudar a cuidadores y familiares a gestionar la medicación y las citas médicas de personas dependientes.

Muchas personas mayores o dependientes necesitan tomar varios medicamentos al día y acudir a diferentes citas médicas. Llevar el control de todo esto puede resultar complicado si se hace de forma manual o con varias herramientas diferentes. MediCheck nace como una pequeña solución para centralizar esa información en una sola aplicación sencilla de usar.

Este proyecto ha sido desarrollado como parte del **Proyecto Intermodular del ciclo de Desarrollo de Aplicaciones Multiplataforma (DAM)** en el **IES Albarregas**.

---

# Objetivo del proyecto

El objetivo principal de MediCheck es facilitar el seguimiento de tratamientos médicos y citas para personas dependientes.

La aplicación permite gestionar información básica de pacientes, registrar tratamientos médicos y llevar un control de las citas médicas programadas.

De esta forma se busca que cuidadores o familiares puedan consultar rápidamente la información importante desde una única aplicación.

---

# Tecnologías utilizadas

Para el desarrollo del proyecto se han utilizado las siguientes tecnologías:

- **Flutter** como framework principal para crear la aplicación móvil.
- **Firebase Auth** para el sistema de autenticación seguro.
- **Cloud Firestore** como base de datos NoSQL en tiempo real para pacientes, citas y medicaciones.
- **Firebase Storage** para el almacenamiento de imágenes de perfil.
- **Firebase Cloud Messaging (FCM)** para el envío de notificaciones push.
- **Flutter Local Notifications** para el sistema de recordatorios offline.
- **Provider** para la gestión del estado de la aplicación.
- **API OpenFDA** para la validación clínica de tratamientos y prospectos.

---

# Arquitectura del proyecto

La aplicación sigue una arquitectura modular y escalable, separando la lógica de negocio de la interfaz:

- **models**: Definición de objetos de datos (Paciente, Medicación, Cita, Incidencia).
- **providers**: Gestión del estado reactivo y sincronización con la UI.
- **services**: Lógica de comunicación con Firebase y APIs externas.
- **screens**: Vistas organizadas por módulos (Auth, Admin, Pacientes, etc.).
- **widgets**: Componentes reutilizables siguiendo Atomic Design.

---

# Funcionalidades principales

MediCheck ha evolucionado de un prototipo a un **MVP completo** con las siguientes capacidades:

### 🔐 Seguridad y Roles
- **Role-Based Access Control (RBAC)**: Distinción clara entre perfiles de **Administrador** y **Cuidador**.
- Autenticación persistente y recuperación de contraseña.

### 👥 Gestión de Pacientes y Cuidadores
- El Administrador puede dar de alta pacientes y **transferirlos** entre diferentes cuidadores.
- Los cuidadores solo ven la información de los pacientes asignados a su cargo.

### 💊 Control de Medicación Avanzado
- Registro detallado de tomas (dosis, frecuencia, duración).
- **Validación Clínica**: Integración con la base de datos de la FDA para detectar solapamientos de tratamientos y consultar prospectos reales.
- Historial de tomas en tiempo real.

### 📅 Agenda de Citas Médicas
- Calendario de citas para cada paciente.
- Notificaciones automáticas **30 minutos antes** de cada cita.
- Sistema de confirmación de asistencia desde el dashboard.

### 🔔 Notificaciones Inteligentes
- **Recordatorios de tomas**: Alarma local que suena incluso sin conexión a internet.
- **Mensajes Push**: Comunicación directa desde el servidor para avisos urgentes.

### 🚨 Protocolo SOS
- Botón de emergencia que simula el envío de ubicación y alerta a las autoridades en tiempo real.

---

# Gestión de datos

A diferencia de las versiones iniciales, la aplicación cuenta ahora con una **integración completa con Firebase**. Los datos no son volátiles y se sincronizan entre diferentes dispositivos en tiempo real.

---

# Próximas mejoras (Roadmap)

- **Login Biométrico**: Huella dactilar y reconocimiento facial.
- **Exportación a PDF**: Generación de informes automáticos para médicos.
- **Modo Offline extendido**: Sincronización diferida más robusta.

---

# Documentación

La documentación técnica completa del proyecto se encuentra en la carpeta:

```
/docs
```

En esta carpeta se incluye el manual técnico del MVP desarrollado durante esta fase del proyecto.

---

# Autor

Miguel González Jiménez

Proyecto Intermodular  
Desarrollo de Aplicaciones Multiplataforma (DAM)  
IES Albarregas

---

# Licencia

Este proyecto ha sido desarrollado con fines educativos como parte de la formación en el ciclo de Desarrollo de Aplicaciones Multiplataforma.
