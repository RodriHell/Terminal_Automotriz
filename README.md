# Sistema de Gestión - Terminal Automotriz (MySQL)

Proyecto final para la materia de Bases de Datos I. Este repositorio contiene el diseño e implementación del backend para una terminal automotriz, simulando todo el proceso desde el pedido del concesionario hasta la fabricación en la línea de montaje.

# Descripción
El sistema gestiona la logística de producción de automóviles, controlando el stock de insumos, la asignación de tareas en estaciones de trabajo y el flujo de la línea de montaje mediante una "máquina de estados".

# Tecnologías y Conceptos Clave
Este proyecto demuestra el uso avanzado de SQL y lógica de backend:

* Diseño Relacional: Esquema normalizado con integridad referencial estricta (PK/FK).
* Stored Procedures: Lógica de negocio encapsulada en la base de datos (no en la app).
* Transacciones (ACID):** Uso de `START TRANSACTION`, `COMMIT` y `ROLLBACK` para asegurar la integridad de datos en procesos críticos (ej: mover un auto de estación).
* Manejo de Cursores y Loops: Para la generación masiva de pedidos y validación de patentes únicas.
* Reportes: Consultas complejas con `JOINs`, `GROUP BY`, subconsultas y funciones de tiempo para calcular métricas de producción.
* Optimización: Uso Índices para mejorar la performance de búsquedas y reportes.

# Estructura del Proyecto
* `1_Schema_DDL.sql`: Creación de tablas y relaciones.
* `2_ABM_Procedures.sql`: Procedimientos CRUD con validación de errores.
* `3_Logica_Negocio.sql`: Procedimientos complejos (Línea de montaje, generación de autos).
* `4_Reportes.sql`: Scripts para análisis de datos y métricas.
