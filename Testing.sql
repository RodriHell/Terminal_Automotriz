USE terminalautomotriz;
-- Test Etapa 2 
-- Variables para los resultados
SET @nResultado = 0;
SET @cMensaje = '';

-- ------------------- concesionaria ---------------------
-- Alta
USE terminalautomotriz;

CALL altaConcesionaria(1, 'Concesionario Alfa', 'Calle Falsa 123', '12345678', @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- Modificación
CALL modificarConcesionaria(1, 'Concesionario Beta', 'Av. Siempre Viva 742', '87654321', @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- Baja
CALL bajaConcesionaria(1, @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- ------------------- proveedor ---------------------

-- Alta
CALL altaProveedor(1, 'Proveedor A', 'Calle A 100', '111222333', @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- Modificación
CALL modificarProveedor(1, 'Proveedor B', 'Calle B 200', '999888777', @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- Baja
CALL bajaProveedor(1, @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- ------------------- insumos ---------------------

-- Alta
CALL altaInsumo(1, 'Pintura Roja', 2500.50, @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- Modificación
CALL modificarInsumo(1, 'Pintura Azul', 2700.75, @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- Baja
CALL bajaInsumo(1, @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- ------------------- pedidos ---------------------

-- Alta
CALL altaPedido(1, NOW(), 1, 1, 10, @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- Modificación de detalle
CALL modificarDetalleDelPedido(1, 1, 15, @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- Baja
CALL bajaPedido(1, @nResultado, @cMensaje);
SELECT @nResultado, @cMensaje;

-- Test Etapa 3

SET SQL_SAFE_UPDATES = 0;

DELETE FROM historial_produccion;
DELETE FROM automovil;
DELETE FROM detalle_del_pedido;
DELETE FROM pedido;
DELETE FROM concesionario;
DELETE FROM estacion;
DELETE FROM linea_de_montaje;
DELETE FROM tarea;
DELETE FROM modelo;

-- Creamos datos para la línea de montaje
INSERT INTO tarea (id_tarea, nombre) VALUES (1, 'Ensamblaje Chasis');
INSERT INTO tarea (id_tarea, nombre) VALUES (2, 'Pintura');

INSERT INTO modelo (id_modelo, nombre) VALUES (1, 'Chevrolet Chevy');
INSERT INTO modelo (id_modelo, nombre) VALUES (2, 'Camioneta 4x4');

-- Asignamos los modelos a sus líneas de montaje
INSERT INTO linea_de_montaje (modelo_id_modelo, capacidad_productiva) VALUES (1, 100);
INSERT INTO linea_de_montaje (modelo_id_modelo, capacidad_productiva) VALUES (2, 50);

-- Creamos las estaciones PARA EL MODELO 1
-- La primera será la de ID más bajo (ID 10)
INSERT INTO estacion (id_estacion, nombre, modelo_id_modelo, tarea_id_tarea) 
VALUES (10, 'Estacion de Chasis (Chevy)', 1, 1);
INSERT INTO estacion (id_estacion, nombre, modelo_id_modelo, tarea_id_tarea) 
VALUES (11, 'Estacion de Pintura (Chevy)', 1, 2);

-- Creamos el mismo pedido de prueba de antes
INSERT INTO concesionario (id_concesionario, nombre, direccion) 
VALUES (50, 'Concesionario Sur', 'Av. Siempre Viva 123');
INSERT INTO pedido (numero, fecha_hora, concesionario_id_concesionario) 
VALUES (100, NOW(), 50);
INSERT INTO detalle_del_pedido (cantidad, pedido_numero, modelo_id_modelo) 
VALUES (3, 100, 1); -- 3 Sedan
INSERT INTO detalle_del_pedido (cantidad, pedido_numero, modelo_id_modelo) 
VALUES (2, 100, 2); -- 2 Camioneta

SET SQL_SAFE_UPDATES = 1;

-- Generamos los autos (deben crearse 5)
CALL generar_automoviles_pedido(100);

--  Verificamos que los autos existen y el historial está vacío
SELECT * FROM automovil WHERE pedido_numero = 100;
SELECT * FROM historial_produccion; -- (Debe estar vacía)

-- Guardamos las patentes de 2 autos (del modelo 1) en variables
SELECT patente INTO @AUTO_1 FROM automovil WHERE modelo_id_modelo = 1 LIMIT 1;
SELECT patente INTO @AUTO_2 FROM automovil WHERE modelo_id_modelo = 1 LIMIT 1, 1;

SELECT @AUTO_1 AS 'Auto 1 a Ingresar', @AUTO_2 AS 'Auto 2 a Ingresar';

-- prueba exitosa
CALL ingresar_auto_a_linea(@AUTO_1);

-- prueba fallida (estacion ya ocupada)
CALL ingresar_auto_a_linea(@AUTO_2);

-- prueba fallida (auto en estacion)
CALL ingresar_auto_a_linea (@AUTO_1);

-- prueba fallida (patente no existe)
CALL ingresar_auto_a_linea ('ABC111');

CALL avanzar_auto_estacion(@AUTO_2);
SELECT * FROM automovil;
CALL ingresar_auto_a_linea('TAX444');

-- Test Etapa 4

-- Test Etapa 4 punto 6

CALL reporte_vehiculos_por_pedido(100);

-- Test Etapa 4 punto 7

INSERT INTO modelo (nombre)
VALUES ('Sedan XR');

INSERT INTO linea_de_montaje (modelo_id_modelo, capacidad_productiva)
VALUES (3, 20);  

INSERT INTO tarea (id_tarea, nombre)
VALUES
(3, 'Montaje motor'),
(4, 'Montaje ruedas');

INSERT INTO estacion (nombre, modelo_id_modelo, tarea_id_tarea)
VALUES
('Estación Motor', 1, 1),
('Estación Ruedas', 1, 2);

INSERT INTO insumo (codigo_insumo, precio_insumo, descripcion_insumo)
VALUES
(10, 200000, 'Motor 2.0'),
(20, 8000, 'Rueda 16"');

INSERT INTO insumo_por_modelo (modelo_id_modelo, insumo_codigo_insumo, cantidad)
VALUES
(1, 10, 1),   -- Un auto lleva 1 motor
(1, 20, 4);   -- Un auto lleva 4 ruedas

INSERT INTO concesionario (id_concesionario, nombre, direccion, telefono)
VALUES (5, 'Concesionaria Centro', 'Av. Siempre Viva 123', '444-5555');

INSERT INTO pedido (numero, fecha_hora, concesionario_id_concesionario)
VALUES (123, NOW(), 1);

INSERT INTO detalle_del_pedido (cantidad, pedido_numero, modelo_id_modelo)
VALUES (5, 123, 1);  -- Pedido 123 → 5 autos del modelo 1

CALL listar_insumos_por_pedido(123);

-- test Etapa 4 Punto 8

INSERT INTO linea_de_montaje (modelo_id_modelo, capacidad_productiva)
VALUES (3, 80) ON DUPLICATE KEY UPDATE capacidad_productiva = 80;
INSERT INTO automovil (numero_de_chasis, patente, pedido_numero, modelo_id_modelo)
VALUES ('CHASIS1', 'AAA111', 100, 1), ('CHASIS2', 'BBB222', 100, 2), ('CHASIS3', 'CCC333', 100, 3);
-- Simulamos autos que pasan por estaciones
-- Modelo 1
INSERT INTO historial_produccion VALUES 
('CHASIS1', 10, '2025-10-30 08:00:00', '2025-10-30 09:00:00'),
('CHASIS1', 11, '2025-10-30 09:15:00', '2025-10-30 11:00:00');
-- Modelo 2
INSERT INTO historial_produccion VALUES 
('CHASIS2', 10, '2025-10-30 07:30:00', '2025-10-30 10:30:00'),
('CHASIS2', 11, '2025-10-30 10:45:00', '2025-10-30 13:15:00');

-- Modelo 3
INSERT INTO historial_produccion VALUES 
('CHASIS3', 10, '2025-10-30 09:00:00', '2025-10-30 10:00:00'),
('CHASIS3', 11, '2025-10-30 10:30:00', '2025-10-30 12:30:00');

-- Finalizamos la producción
UPDATE automovil 
SET fecha_finalizacion = '2025-10-30 12:30:00'
WHERE numero_de_chasis IN ('CHASIS1', 'CHASIS2', 'CHASIS3');

-- 1. Promedio para el modelo 1
CALL tiempo_promedio_construccion(1);

-- 2. Promedio para el modelo 2 
CALL tiempo_promedio_construccion(2);

-- 3. Promedio para el modelo 3 
CALL tiempo_promedio_construccion(3);

-- Test Etapa 5

SHOW INDEX FROM pedido;
SHOW INDEX FROM automovil;
SHOW INDEX FROM estacion;
SHOW INDEX FROM modelo; 
SHOW INDEX FROM insumo;
SHOW INDEX FROM historial_produccion;