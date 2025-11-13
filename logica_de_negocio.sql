/* ============================== SCRIPT LOGICA DE NEGOCIO ==============================
Descripción: 
- 
---------------------------------------------------------------------------------
Manejo de errores:
-12 = El modelo no tiene estaciones asignadas.
-11 = El auto está en produccion.
-10 = Estacion ocupada.
-1 = No existe.
0 = Exito.
=====================================================================================
*/



DROP PROCEDURE IF EXISTS `generar_automoviles_pedido`;

DELIMITER $$
USE `terminalautomotriz`$$

CREATE PROCEDURE `generar_automoviles_pedido` (IN p_pedido_numero INT)
BEGIN
    --  Declarar variables de manejo de errores
    DECLARE nResultado INT DEFAULT 0;
    DECLARE cMensaje VARCHAR(255) DEFAULT '';
    
    -- Declarar variables de lógica
    DECLARE v_modelo_id INT;
    DECLARE v_cantidad INT;
    DECLARE v_contador INT DEFAULT 0;
    
    DECLARE v_chasis VARCHAR(45);
    DECLARE v_patente VARCHAR(45);
    
    DECLARE v_patente_candidata VARCHAR(45);
    DECLARE v_patente_existe INT DEFAULT 0;
    DECLARE v_pedido_existe INT DEFAULT 0;
    
    DECLARE v_done INT DEFAULT FALSE;

    -- Declarar el cursor
    DECLARE cur_detalles CURSOR FOR
        SELECT modelo_id_modelo, cantidad
        FROM detalle_del_pedido
        WHERE pedido_numero = p_pedido_numero;

    -- Declarar 'handlers'
    -- Handler para el fin del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    -- Handler para cualquier error SQL
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET nResultado = -100; -- Código de falla SQL
        SET cMensaje = 'Error SQL inesperado. Se detuvo la generacion.';
    END;
    
    -- Valida si existe el pedido
    SELECT COUNT(*) 
    INTO v_pedido_existe 
    FROM pedido 
    WHERE numero = p_pedido_numero;

    IF v_pedido_existe = 0 THEN
        SET nResultado = -1;
        SET cMensaje = 'El numero de pedido no existe.';
    ELSE
        -- Lógica Principal
        OPEN cur_detalles;

        read_loop: LOOP
            FETCH cur_detalles INTO v_modelo_id, v_cantidad;
            IF v_done THEN
                LEAVE read_loop;
            END IF;

            SET v_contador = 0;
            WHILE v_contador < v_cantidad DO
                
                SET v_chasis = SUBSTRING(REPLACE(UUID(), '-', ''), 1, 17);

                generar_patente_loop: LOOP
                    SET v_patente_candidata = CONCAT(
                        CHAR(65 + FLOOR(RAND() * 26)),
                        CHAR(65 + FLOOR(RAND() * 26)),
                        CHAR(65 + FLOOR(RAND() * 26)),
                        LPAD(FLOOR(RAND() * 1000), 3, '0')
                    );

                    SELECT COUNT(*) 
                    INTO v_patente_existe 
                    FROM automovil 
                    WHERE patente = v_patente_candidata;

                    IF v_patente_existe = 0 THEN
                        SET v_patente = v_patente_candidata;
                        LEAVE generar_patente_loop;
                    END IF;
                END LOOP generar_patente_loop;

                -- Insertar el automóvil
                INSERT INTO automovil 
                    (numero_de_chasis, patente, fecha_finalizacion, pedido_numero, modelo_id_modelo)
                VALUES 
                    (v_chasis, v_patente, NULL, p_pedido_numero, v_modelo_id);
                
                SET v_contador = v_contador + 1;
            END WHILE;
        END LOOP read_loop;

        CLOSE cur_detalles;
    END IF;

    SELECT nResultado, cMensaje;

END$$

DELIMITER ;


USE `terminalautomotriz`;

DROP PROCEDURE IF EXISTS `ingresar_auto_a_linea`;

DELIMITER $$
USE `terminalautomotriz`$$
CREATE PROCEDURE `ingresar_auto_a_linea` (
    IN p_patente VARCHAR(45)
)
BEGIN
    -- 1. Declarar variables de manejo de errores
    DECLARE nResultado INT DEFAULT 0;         -- 0 = Éxito
    DECLARE cMensaje VARCHAR(255) DEFAULT ''; -- '' = Éxito

    -- 2. Declarar variables de lógica
    DECLARE v_chasis_propio VARCHAR(45);
    DECLARE v_modelo_id INT;
    DECLARE v_primera_estacion_id INT;
    DECLARE v_chasis_ocupante VARCHAR(45) DEFAULT NULL;
    DECLARE v_auto_ya_en_linea INT DEFAULT 0;

    -- 3. Identificar el Auto
    SELECT numero_de_chasis, modelo_id_modelo
    INTO v_chasis_propio, v_modelo_id
    FROM automovil
    WHERE patente = p_patente
    LIMIT 1;

    -- 
    IF v_chasis_propio IS NULL THEN
        -- Patente no encontrada
        SET nResultado = -1;
        SET cMensaje = 'Patente no encontrada';
    ELSE
        -- Validamos si el auto está en producción
        SELECT COUNT(*)
        INTO v_auto_ya_en_linea
        FROM historial_produccion
        WHERE automovil_numero_de_chasis = v_chasis_propio 
          AND fecha_hora_egreso IS NULL;

        IF v_auto_ya_en_linea > 0 THEN
            -- El auto ya está en producción
            SET nResultado = -11;
            SET cMensaje = 'El auto ya se encuentra en produccion';
        ELSE
            -- Validamos si se encuentra la primer estacion
            SELECT MIN(id_estacion)
            INTO v_primera_estacion_id
            FROM estacion
            WHERE modelo_id_modelo = v_modelo_id;

            IF v_primera_estacion_id IS NULL THEN
                -- El modelo no tiene estaciones
                SET nResultado = -12;
                SET cMensaje = 'El modelo del auto no tiene estaciones asignadas';
            ELSE
                -- Validamos si la estacion se encuentra ocupada
                SELECT automovil_numero_de_chasis
                INTO v_chasis_ocupante
                FROM historial_produccion
                WHERE estacion_id_estacion = v_primera_estacion_id 
                  AND fecha_hora_egreso IS NULL
                LIMIT 1;

                IF v_chasis_ocupante IS NOT NULL THEN
                    -- Estación ocupada
                    SET nResultado = -10;
                    SET cMensaje = CONCAT('Estacion ocupada por el chasis: ', v_chasis_ocupante);
                END IF;
            END IF;
        END IF;
    END IF;
 
    IF nResultado = 0 THEN
        -- Si todas las validaciones pasaron, insertamos el auto
        INSERT INTO historial_produccion 
            (automovil_numero_de_chasis, estacion_id_estacion, fecha_hora_ingreso, fecha_hora_egreso)
        VALUES 
            (v_chasis_propio, v_primera_estacion_id, NOW(), NULL);
    END IF;

    SELECT nResultado, cMensaje;

END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS `avanzar_auto_estacion`;

DELIMITER $$
USE `terminalautomotriz`$$
CREATE PROCEDURE `avanzar_auto_estacion` (
    IN p_patente VARCHAR(45)
)
proc_main: BEGIN
    -- Declarar variables de estado
    DECLARE nResultado INT DEFAULT 0;
    DECLARE cMensaje VARCHAR(255) DEFAULT '';

    -- 2. Declarar variables de lógica
    DECLARE v_chasis_propio VARCHAR(45);
    DECLARE v_modelo_id INT;
    DECLARE v_estacion_actual_id INT;
    DECLARE v_estacion_siguiente_id INT DEFAULT NULL;
    DECLARE v_chasis_ocupante VARCHAR(45) DEFAULT NULL;

    -- Handler para Errores SQL
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET nResultado = -100;
        SET cMensaje = 'Error SQL inesperado. Transaccion revertida.';
        SELECT nResultado, cMensaje;
    END;

    -- Encontrar el auto y su estación actual
    -- Buscamos el auto que esté en una estación
    SELECT 
        a.numero_de_chasis, 
        a.modelo_id_modelo, 
        h.estacion_id_estacion
    INTO 
        v_chasis_propio, 
        v_modelo_id, 
        v_estacion_actual_id
    FROM automovil a
    JOIN historial_produccion h ON a.numero_de_chasis = h.automovil_numero_de_chasis
    WHERE a.patente = p_patente AND h.fecha_hora_egreso IS NULL
    LIMIT 1;

    -- Validamos si existe el auto o si está en produccion
    IF v_chasis_propio IS NULL THEN
        SET nResultado = -1;
        SET cMensaje = 'Patente no encontrada o el auto no esta en produccion.';
        LEAVE proc_main; -- Salir del procedimiento
    END IF;

    --  Encontrar la siguiente estación
    -- La siguiente es la que tiene el ID mínimo que sea MAYOR al actual.
    SELECT MIN(id_estacion)
    INTO v_estacion_siguiente_id
    FROM estacion
    WHERE modelo_id_modelo = v_modelo_id 
      AND id_estacion > v_estacion_actual_id;
      
    -- Iniciar la transacción
    START TRANSACTION;

    -- Verifica si es la última estación o hay que moverlo

    IF v_estacion_siguiente_id IS NULL THEN
        -- Si es la última estación
        
        -- Finalizar el trabajo en la estación actual
        UPDATE historial_produccion 
        SET fecha_hora_egreso = NOW() 
        WHERE automovil_numero_de_chasis = v_chasis_propio 
          AND estacion_id_estacion = v_estacion_actual_id;
        
        -- Finalizar el automóvil
        UPDATE automovil 
        SET fecha_finalizacion = NOW() 
        WHERE numero_de_chasis = v_chasis_propio;
        
        SET nResultado = 1;
        SET cMensaje = 'Auto finalizado. Salio de la ultima estacion.';

    ELSE
        -- Mover a la siguiente estación
        
        -- Validamos si la estacion está ocupada
        SELECT automovil_numero_de_chasis
        INTO v_chasis_ocupante
        FROM historial_produccion
        WHERE estacion_id_estacion = v_estacion_siguiente_id 
          AND fecha_hora_egreso IS NULL
        LIMIT 1;

        IF v_chasis_ocupante IS NOT NULL THEN
            -- Estación ocupada. Revertir y reportar.
            SET nResultado = -10;
            SET cMensaje = CONCAT('Siguiente estacion (', v_estacion_siguiente_id, ') esta ocupada por el chasis: ', v_chasis_ocupante);
            ROLLBACK;
        ELSE
            -- Mover el auto
            
            -- Salir de la estación actual
            UPDATE historial_produccion 
            SET fecha_hora_egreso = NOW() 
            WHERE automovil_numero_de_chasis = v_chasis_propio 
              AND estacion_id_estacion = v_estacion_actual_id;
            
            -- Ingresar a la siguiente estación
            INSERT INTO historial_produccion 
                (automovil_numero_de_chasis, estacion_id_estacion, fecha_hora_ingreso, fecha_hora_egreso)
            VALUES 
                (v_chasis_propio, v_estacion_siguiente_id, NOW(), NULL);
            
            SET cMensaje = CONCAT('Auto movido de estacion ', v_estacion_actual_id, ' a ', v_estacion_siguiente_id);
        END IF;
    END IF;
    
    IF nResultado >= 0 THEN
        COMMIT;
    END IF;

    SELECT nResultado, cMensaje;

END proc_main;
$$

DELIMITER ;