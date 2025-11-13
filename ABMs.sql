/* ============================== SCRIPT ABM ==============================
Descripción: Stored Procedures para Alta, Baja y Modificación de:
- Concesionarias
- Pedidos (Cabecera + Detalle)
- Proveedores
- Insumos
Notas: 
- Se validan claves primarias y uso de foreign keys.
- Las tablas y columnas se han adaptado al nuevo esquema 'terminalautomotriz'.
---------------------------------------------------------------------------------
Manejo de errores:
-3 = Ya existe.
-2 = FK bloquea/no se puede eliminar.
-1 = No existe.
0 = Exito.
=====================================================================================
*/


/* ------------------------------- ABM CONCESIONARIA ----------------------------------------- */ 

-- ALTA
DELIMITER // 
CREATE PROCEDURE altaConcesionaria(
    IN p_id_concesionario INT,
    IN p_nombre VARCHAR(45),
    IN p_direccion VARCHAR(45),
    IN p_telefono VARCHAR(45),
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verificar si ya existe un concesionario con esa PK
    IF EXISTS (SELECT 1 FROM concesionario WHERE id_concesionario = p_id_concesionario) THEN
        SET nResultado = -3;
        SET cMensaje = 'El concesionario ya existe con esa clave primaria.';
    ELSE
        -- Insertar nuevo registro
        INSERT INTO concesionario (id_concesionario, nombre, direccion, telefono)
        VALUES (p_id_concesionario, p_nombre, p_direccion, p_telefono);
    
        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;


-- BAJA
DELIMITER // 
CREATE PROCEDURE bajaConcesionaria(
    IN p_id_concesionario INT,
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verificar si el concesionario existe
    IF NOT EXISTS (SELECT 1 FROM concesionario WHERE id_concesionario = p_id_concesionario) THEN
        SET nResultado = -1;
        SET cMensaje = 'El concesionario no existe.';
    -- Verificar si tiene pedidos asociados
    ELSEIF EXISTS (SELECT 1 FROM pedido WHERE concesionario_id_concesionario = p_id_concesionario) THEN
        SET nResultado = -2;
        SET cMensaje = 'No se puede eliminar el concesionario porque tiene pedidos asociados.';
    ELSE
        -- Si existe y no tiene FK asociadas, se elimina
        DELETE FROM concesionario WHERE id_concesionario = p_id_concesionario;
        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;


-- MODIFICACION
DELIMITER // 
CREATE PROCEDURE modificarConcesionaria(
    IN p_id_concesionario INT,
    IN p_nombre VARCHAR(45),
    IN p_direccion VARCHAR(45),
    IN p_telefono VARCHAR(45),
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verificar si el concesionario a modificar existe
    IF NOT EXISTS (SELECT 1 FROM concesionario WHERE id_concesionario = p_id_concesionario) THEN
        SET nResultado = -1;
        SET cMensaje = 'El concesionario a modificar no existe.';
    ELSE
        -- Si existe, se actualizan los campos
        UPDATE concesionario
        SET
            nombre = p_nombre,
            direccion = p_direccion,
            telefono = p_telefono
        WHERE id_concesionario = p_id_concesionario;

        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;


/* ------------------------------- ABM PROVEEDORES ----------------------------------------- */ 

-- ALTA
DELIMITER //
CREATE PROCEDURE altaProveedor(
    IN p_id_proveedor INT,
    IN p_nombre VARCHAR(45),
    IN p_direccion VARCHAR(45),
    IN p_telefono VARCHAR(45),
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verificar si ya existe un proveedor con esa PK
    IF EXISTS (SELECT 1 FROM proveedor WHERE id_proveedor = p_id_proveedor) THEN
        SET nResultado = -3;
        SET cMensaje = 'El proveedor ya existe con esa clave primaria.';
    ELSE
        -- Insertar nuevo registro
        INSERT INTO proveedor (id_proveedor, nombre_proveedor, direccion_proveedor, telefono_proveedor)
        VALUES (p_id_proveedor, p_nombre, p_direccion, p_telefono);

        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;


-- BAJA
DELIMITER //
CREATE PROCEDURE bajaProveedor(
    IN p_id_proveedor INT,
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verificar si el proveedor existe
    IF NOT EXISTS (SELECT 1 FROM proveedor WHERE id_proveedor = p_id_proveedor) THEN
        SET nResultado = -1;
        SET cMensaje = 'El proveedor no existe.';
    -- Verificar si tiene compras o insumos suministrados asociados
    ELSEIF EXISTS (SELECT 1 FROM compra WHERE proveedor_id_proveedor = p_id_proveedor)
        OR EXISTS (SELECT 1 FROM proveedor_suministra_insumo WHERE proveedor_id_proveedor = p_id_proveedor) THEN
        SET nResultado = -2;
        SET cMensaje = 'No se puede eliminar el proveedor porque tiene compras o insumos asociados.';
    ELSE
        -- Si existe y no tiene FK asociadas, se elimina
        DELETE FROM proveedor WHERE id_proveedor = p_id_proveedor;
        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;


-- MODIFICACION
DELIMITER //
CREATE PROCEDURE modificarProveedor(
    IN p_id_proveedor INT,
    IN p_nombre VARCHAR(45),
    IN p_direccion VARCHAR(45),
    IN p_telefono VARCHAR(45),
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verificar si el proveedor a modificar existe
    IF NOT EXISTS (SELECT 1 FROM proveedor WHERE id_proveedor = p_id_proveedor) THEN
        SET nResultado = -1;
        SET cMensaje = 'El proveedor a modificar no existe.';
    ELSE
        -- Si existe, se actualizan los campos
        UPDATE proveedor
        SET
            nombre_proveedor = p_nombre,
            direccion_proveedor = p_direccion,
            telefono_proveedor = p_telefono
        WHERE id_proveedor = p_id_proveedor;

        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;


/* ------------------------------- ABM INSUMOS ----------------------------------------- */ 

-- ALTA
DELIMITER // 
CREATE PROCEDURE altaInsumo(
    IN p_codigo_insumo INT,
    IN p_descripcion_insumo VARCHAR(45),
    IN p_precio_insumo FLOAT,
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verificar si ya existe un insumo con esa PK
    IF EXISTS (SELECT 1 FROM insumo WHERE codigo_insumo = p_codigo_insumo) THEN
        SET nResultado = -3;
        SET cMensaje = 'El insumo ya existe con esa clave primaria.';
    ELSE
        -- Insertar nuevo registro
        INSERT INTO insumo (codigo_insumo, descripcion_insumo, precio_insumo)
        VALUES (p_codigo_insumo, p_descripcion_insumo, p_precio_insumo);

        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;


-- BAJA
DELIMITER //
CREATE PROCEDURE bajaInsumo(
    IN p_codigo_insumo INT,
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verificar si existe el insumo
    IF NOT EXISTS (SELECT 1 FROM insumo WHERE codigo_insumo = p_codigo_insumo) THEN
        SET nResultado = -1;
        SET cMensaje = 'El insumo no existe.';
    -- Verificar uso en tablas relacionadas
    ELSEIF EXISTS (SELECT 1 FROM tarea_CON_insumo WHERE insumo_codigo_insumo = p_codigo_insumo)
        OR EXISTS (SELECT 1 FROM detalle_compra_insumo WHERE insumo_codigo_insumo = p_codigo_insumo)
        OR EXISTS (SELECT 1 FROM insumo_por_modelo WHERE insumo_codigo_insumo = p_codigo_insumo)
        OR EXISTS (SELECT 1 FROM proveedor_suministra_insumo WHERE insumo_codigo_insumo = p_codigo_insumo) THEN
        SET nResultado = -2;
        SET cMensaje = 'No se puede eliminar el insumo porque está en uso.';
    ELSE
        -- Si existe y no está en uso, se elimina
        DELETE FROM insumo WHERE codigo_insumo = p_codigo_insumo;
        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;

-- MODIFICACION
DELIMITER //
CREATE PROCEDURE modificarInsumo(
    IN p_codigo_insumo INT,
    IN p_descripcion_insumo VARCHAR(45),
    IN p_precio_insumo FLOAT,
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verificar si el insumo a modificar existe
    IF NOT EXISTS (SELECT 1 FROM insumo WHERE codigo_insumo = p_codigo_insumo) THEN
        SET nResultado = -1;
        SET cMensaje = 'El insumo a modificar no existe.';
    ELSE
        -- Si existe, se actualizan los campos
        UPDATE insumo
        SET
            descripcion_insumo = p_descripcion_insumo,
            precio_insumo = p_precio_insumo
        WHERE codigo_insumo = p_codigo_insumo;

        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;


/* ------------------------------- ABM PEDIDOS  ----------------------------------------- */ 

-- ALTA PEDIDO 
DELIMITER //
CREATE PROCEDURE altaPedido(
    IN p_numero_pedido INT,
    IN p_fecha_hora DATETIME,
    IN p_concesionario_id INT,
    IN p_modelo_id INT,
    IN p_cantidad INT,
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Valida si el pedido ya existe
    IF EXISTS (SELECT 1 FROM pedido WHERE numero = p_numero_pedido) THEN
        SET nResultado = -3;
        SET cMensaje = 'El número de pedido ya existe.';
    -- Valida que el concesionario y modelo existan
    ELSEIF NOT EXISTS (SELECT 1 FROM concesionario WHERE id_concesionario = p_concesionario_id) THEN
        SET nResultado = -1;
        SET cMensaje = 'El concesionario no existe.';
    ELSEIF NOT EXISTS (SELECT 1 FROM modelo WHERE id_modelo = p_modelo_id) THEN
        SET nResultado = -1;
        SET cMensaje = 'El modelo de automóvil no existe.';
    ELSE
        -- Inserta la cabecera del pedido
        INSERT INTO pedido (numero, fecha_hora, concesionario_id_concesionario)
        VALUES (p_numero_pedido, p_fecha_hora, p_concesionario_id);

        -- Inserta el primer detalle del pedido
        INSERT INTO detalle_del_pedido (cantidad, pedido_numero, modelo_id_modelo)
        VALUES (p_cantidad, p_numero_pedido, p_modelo_id);

        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;


-- BAJA PEDIDO (Elimina cabecera y todos sus detalles)
DELIMITER //
CREATE PROCEDURE bajaPedido(
    IN p_numero_pedido INT,
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    DECLARE num_autos INT;
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verificar si el pedido existe
    IF NOT EXISTS (SELECT 1 FROM pedido WHERE numero = p_numero_pedido) THEN
        SET nResultado = -1;
        SET cMensaje = 'El pedido no existe.';
    ELSE
        -- Contar los automóviles asociados a este pedido
        SELECT COUNT(*) INTO num_autos FROM automovil WHERE pedido_numero = p_numero_pedido;
        
        -- Si hay automóviles, no se puede eliminar
        IF num_autos > 0 THEN
            SET nResultado = -2;
            SET cMensaje = CONCAT('No se puede eliminar el pedido porque tiene ', num_autos, ' automóviles asociados.');
        ELSE
            -- Si no tiene FKs asociadas, eliminar primero los detalles y luego la cabecera
            DELETE FROM detalle_del_pedido WHERE pedido_numero = p_numero_pedido;
            DELETE FROM pedido WHERE numero = p_numero_pedido;
            SET nResultado = 0;
            SET cMensaje = '';
        END IF;
    END IF;
END //
DELIMITER ;


-- MODIFICACION DE DETALLE DEL PEDIDO (Modifica la cantidad de un modelo en un pedido)
DELIMITER //
CREATE PROCEDURE modificarDetalleDelPedido(
    IN p_pedido_numero INT,
    IN p_modelo_id INT,
    IN p_nueva_cantidad INT,
    OUT nResultado INT,
    OUT cMensaje VARCHAR(256)
)
BEGIN
    SET nResultado = 0;
    SET cMensaje = '';

    -- Verifica si el detalle del pedido existe
    IF NOT EXISTS (SELECT 1 FROM detalle_del_pedido WHERE pedido_numero = p_pedido_numero AND modelo_id_modelo = p_modelo_id) THEN
        SET nResultado = -1;
        SET cMensaje = 'El detalle del pedido a modificar no existe.';
    ELSE
        -- Si existe, se actualiza la cantidad
        UPDATE detalle_del_pedido
        SET cantidad = p_nueva_cantidad
        WHERE pedido_numero = p_pedido_numero AND modelo_id_modelo = p_modelo_id;

        SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;

