USE logitrans;

SHOW TABLES;

-- *** hago un insert de vehiulo para visualizar el punto 2, que la tabla con el metodo
-- left join pueda visualizar valores null ***
INSERT INTO vehiculo
(registro_unico,marca,modelo,anio,capacidad_carga,consumo_promedio_combustible,
numero_placa, fecha_adquisicion,km_actual,estado_operativo, tipo_vehiculo)
 VALUES
('M-003', 'yamaha', 'r15 v4', 2020, 3.0, 2.5, 'YVX63D', '2020-02-19', 125000,'activo','motocicleta');


-- 1. Utiliza INNER JOIN con WHERE para encontrar todos los envíos realizados por ciertos conductores a 
-- determinada zona geográfica.
SELECT 
    e.envioID,
    c.conductorID,
    c.nombres AS nombre,
    c.apellidos AS apellido,
    rd.ruta_distribucionID,
    rd.zona_geografica
FROM envios e
INNER JOIN ruta_distribucion rd ON e.ruta_distribucion = rd.ruta_distribucionID
INNER JOIN conductores c ON rd.id_conductor = c.conductorID
WHERE rd.zona_geografica = 'Medellín Norte';

-- 2. Aplica LEFT JOIN con ORDER BY para listar todos los vehículos y sus mantenimientos (si los tienen)
-- ordenados por kilómetros recorridos.

SELECT 
  	v.vehiculoID AS vehiculo,
 	mv.id_vehiculo AS mantenimiento,
 	v.km_actual AS kilometros_recorridos,
 	mv.descripcion_trabajo_realizado
FROM vehiculo v
LEFT JOIN mantenimiento_vehiculo mv ON v.vehiculoID = mv.id_vehiculo 
ORDER BY v.km_actual ;

-- 3. Usa RIGHT JOIN con GROUP BY y HAVING para encontrar rutas que tienen más de 50 envíos mensuales y 
-- calcular el tiempo promedio de entrega.

-- por falta de registros esto devolvera blanco todo asi que realizamos la consulta sin el 
-- having para corroborar que todo funciona correctamente 
SELECT 
    rd.ruta_distribucionID,
    rd.nombre AS nombre_ruta,
    COUNT(e.envioID) AS total_envios,
    AVG(rd.tiempo_estimado) AS tiempo_promedio_entrega
FROM envios e
RIGHT JOIN ruta_distribucion rd ON e.ruta_distribucion = rd.ruta_distribucionID
WHERE MONTH(e.fecha_hora_recepcion) = 1  
  AND YEAR(e.fecha_hora_recepcion) = 2026  
GROUP BY rd.ruta_distribucionID, rd.nombre
HAVING COUNT(e.envioID) > 50
ORDER BY tiempo_promedio_entrega;

-- sin el having:

SELECT 
	 rd.ruta_distribucionID,
	 rd.nombre AS nombre_ruta,
	 COUNT(e.envioID) AS total_envios,
	 AVG(rd.tiempo_estimado) AS tiempo_promedio_entrega -- usamos avg para calcular el tiempo promedio entrega
FROM envios e
RIGHT JOIN ruta_distribucion rd ON e.ruta_distribucion = rd.ruta_distribucionID
WHERE MONTH (e.fecha_hora_recepcion) = 1 -- aqui revisamos por mes 
  	AND YEAR (e.fecha_hora_recepcion) = 2026 -- es importante agregar el año para que no hayan meses iguales de diferentes años
GROUP BY rd.ruta_distribucionID, rd.nombre
ORDER BY tiempo_promedio_entrega;


-- 4. Implementa INNER JOIN múltiple con BETWEEN para listar seguimientos de envíos realizados en un 
-- período específico junto con los datos del cliente, conductor y vehículo.

SELECT 
    se.seguimiento_enviosID,
    e.envioID,
    c.nombre_o_razon_social AS nombre_cliente,
    co.nombres AS nombre_conductor,
    v.marca AS marca_vehiculo,
    v.numero_placa AS placa_vehiculo,
    se.fecha_hora AS fecha_seguimiento,
    se.actividad_realizada AS estado
FROM seguimiento_envios se
INNER JOIN envios e ON se.id_envio = e.envioID
INNER JOIN cliente c ON e.id_cliente = c.clienteID
INNER JOIN conductores co ON e.id_conductor = co.conductorID
INNER JOIN conductor_vehiculo cv ON co.conductorID = cv.conductorID AND e.id_vehiculo = cv.vehiculoID
INNER JOIN vehiculo v ON cv.vehiculoID = v.vehiculoID
WHERE se.fecha_hora BETWEEN '2026-03-01' AND '2026-03-31'
ORDER BY se.fecha_hora;
	 
	 
-- 5. Combina LEFT JOIN con IS NULL para identificar clientes que no han realizado envíos en los últimos 3 meses.

SELECT 
	 c.clienteID,
	 c.nombre_o_razon_social AS nombre,
	 e.envioID,
	 e.fecha_hora_recepcion
FROM cliente c
LEFT JOIN envios e ON c.clienteID = e.id_cliente AND e.fecha_hora_recepcion >= CURRENT_TIMESTAMP - INTERVAL 3 MONTH
WHERE e.envioID IS NULL
ORDER BY c.clienteID;
	 

-- 6. Utiliza INNER JOIN con IN para encontrar envíos que han pasado por ciertos centros de distribución 
-- específicos.

SELECT 
    e.envioID,
    DATE_FORMAT(s.fecha_hora, '%d/%m/%Y') AS fecha_seguimiento,
    s.ubicacion,
    s.actividad_realizada,
    c.nombre AS centro_distribucion
FROM envios e
INNER JOIN seguimiento_envios s ON e.envioID = s.id_envio
INNER JOIN centros_distribucion c ON s.id_centro_distribucion = c.centro_distribucionID
WHERE s.id_centro_distribucion IN (1, 2, 5);


-- 7. Aplica JOIN con función de agregación SUM y GROUP BY para calcular el consumo total de combustible
-- por tipo de vehículo y ruta.

SELECT 
    rd.codigo AS ruta,
    v.tipo_vehiculo,
    SUM(cc.cantidad) AS consumo_total_combustible,
    SUM(cc.costo) AS costo_total,
    SUM(rd.distancia_total_km) AS distancia_total
FROM consumo_combustible cc
JOIN vehiculo v ON cc.vehiculo = v.vehiculoID
JOIN ruta_distribucion rd ON v.vehiculoID = rd.id_vehiculo
GROUP BY rd.codigo, v.tipo_vehiculo;


-- 8. Usa INNER JOIN con LIKE para encontrar clientes con ciertas palabras en su razón social, junto con sus 
-- envíos recientes.
SELECT 
    c.clienteID,
    c.nombre_o_razon_social AS razon_social,
    e.envioID,
   DATE_FORMAT(e.fecha_hora_recepcion, '%d/%m/%Y') AS fecha,
    e.descripcion_contenido,
    e.estado_actual
FROM cliente c
INNER JOIN envios e ON c.clienteID = e.id_cliente
WHERE c.nombre_o_razon_social LIKE '%Textiles Antioquia%'
AND e.fecha_hora_recepcion >'2026-01-01';

-- 9. Implementa JOIN múltiple con subconsulta para identificar las rutas con tiempo de entrega inferior al 
-- promedio para su distancia.


SELECT 
    rd.ruta_distribucionID,
    rd.nombre,
    rd.distancia_total_km,
    rd.tiempo_estimado,
    sub.promedio_inferior
FROM ruta_distribucion rd
JOIN vehiculo v ON rd.id_vehiculo = v.vehiculoID
JOIN conductor_vehiculo cv ON v.vehiculoID = cv.vehiculoID
JOIN conductores c ON cv.conductorID = c.conductorID
JOIN (
    SELECT AVG(tiempo_estimado) AS promedio_inferior
    FROM ruta_distribucion
) sub
WHERE rd.tiempo_estimado < sub.promedio_inferior
ORDER BY rd.distancia_total_km;
-- si el promedio es inferior sale menor que el tiempo estimado, no supe otra forma de hacerlo..


-- 10. Combina LEFT JOIN con función de fecha para listar incidentes reportados en el último trimestre junto 
-- con los datos del vehículo y conductor, incluso si no ha habido incidentes.

SELECT 
    v.vehiculoID,
    c.conductorID,
    ids.incidentes_servicioID,
    DATE_FORMAT(ids.fecha_hora, '%d/%m/%Y') AS fecha,
    ids.descripcion
FROM vehiculo v
LEFT JOIN conductor_vehiculo cv ON v.vehiculoID = cv.vehiculoID
LEFT JOIN conductores c ON cv.conductorID = c.conductorID
LEFT JOIN incidentes_durante_servicio ids 
       ON ids.vehiculo_id = v.vehiculoID 
      AND ids.conductor_id = c.conductorID
      AND ids.fecha_hora BETWEEN '2026-01-01' AND '2026-03-31'
ORDER BY v.vehiculoID;

	 
