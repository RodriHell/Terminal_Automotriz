/* ======================= SCRIPT CONSTRUCCION DE PROCEDIMIENTOS DE REPORTES ================================
6) Dado un número de pedido, se requiere listar los vehículos indicando el chasis, si se  
encuentra finalizado, y si no esta terminado, indicar en qué estación se encuentra.  
7) Dado un número de pedido, se requiere listar los insumos que será necesario  
solicitar, indicando código de insumo y cantidad requerida para ese pedido.  
8) Dada una línea de montaje, indicar el tiempo promedio de construcción de los vehículos (tener en cuenta sólo los vehículos terminados).
=============================================================================================================
*/

-- Punto 6 

DELIMITER $$
CREATE PROCEDURE reporte_vehiculos_por_pedido(IN p_numero_pedido INT)
BEGIN
    SELECT a.numero_de_chasis,
	CASE WHEN a.fecha_finalizacion IS NOT NULL THEN 'Finalizado' ELSE e.nombre END AS estado_actual
    FROM automovil a LEFT JOIN historial_produccion hp ON a.numero_de_chasis = hp.automovil_numero_de_chasis
	AND hp.fecha_hora_egreso IS NULL
    LEFT JOIN estacion e ON hp.estacion_id_estacion = e.id_estacion
    WHERE a.pedido_numero = p_numero_pedido 
    AND (a.fecha_finalizacion IS NOT NULL OR e.id_estacion IS NOT NULL);
END$$

DELIMITER ;

-- Punto 7

DELIMITER $$

CREATE PROCEDURE listar_insumos_por_pedido(IN p_pedido_numero INT)
BEGIN
    SELECT i.codigo_insumo, i.descripcion_insumo, SUM(d.cantidad * ipm.cantidad) AS cantidad_requerida
    FROM detalle_del_pedido d JOIN insumo_por_modelo ipm 
	ON d.modelo_id_modelo = ipm.modelo_id_modelo JOIN insumo i
	ON ipm.insumo_codigo_insumo = i.codigo_insumo
    WHERE d.pedido_numero = p_pedido_numero
    GROUP BY i.codigo_insumo, i.descripcion_insumo ORDER BY i.codigo_insumo;
END $$

DELIMITER ;

-- Punto 8

DELIMITER $$
CREATE PROCEDURE tiempo_promedio_construccion(IN p_modelo_id INT)
BEGIN
    SELECT m.nombre AS modelo, SEC_TO_TIME(AVG(TIMESTAMPDIFF(SECOND, hp.min_ingreso,hp.max_egreso))) 
    AS tiempo_promedio
    FROM automovil a JOIN modelo m 
	ON a.modelo_id_modelo = m.id_modelo
    JOIN (
        SELECT automovil_numero_de_chasis,
		MIN(fecha_hora_ingreso) AS min_ingreso,
		MAX(fecha_hora_egreso) AS max_egreso
        FROM historial_produccion
        GROUP BY automovil_numero_de_chasis) 
        hp 
		ON hp.automovil_numero_de_chasis = a.numero_de_chasis
		WHERE a.modelo_id_modelo = p_modelo_id AND hp.max_egreso IS NOT NULL
		GROUP BY m.nombre;
END $$

DELIMITER ;