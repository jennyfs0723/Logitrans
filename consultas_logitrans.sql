USE logitrans;

SHOW TABLES;

-- 1. Todos los envios de un cliente especifico.
SELECT * FROM envios WHERE id_cliente = 2;

-- 2. ¿Qué vehículos tienen consumo promedio menor o igual a 12 litros?
SELECT * FROM vehiculo WHERE consumo_promedio_combustible <= 12;

-- 3. ¿Cuáles son los envíos de tipo Express para la zona Norte?
SELECT * FROM envios WHERE tipo_servicio = 'express' AND ruta_distribucion = 1;

-- 4. ¿Qué conductores tienen licencia tipo A o tipo B?
SELECT * FROM conductores WHERE tipo_licencia IN ('A1','A2','B') ORDER BY nombres;

-- 5. ¿Cuáles son los envíos realizados en febrero de 2024?
SELECT * FROM envios WHERE fecha_hora_recepcion > '2024-01-31 00:00:00' 
AND fecha_hora_recepcion < '2024-03-01 00:00:00'; 

-- conteo de envios realizados en febrero 
SELECT COUNT(fecha_hora_recepcion)
FROM envios
WHERE fecha_hora_recepcion > '2024-01-31 00:00:00' 
AND fecha_hora_recepcion < '2024-03-01 00:00:00' ;

-- 6. ¿Qué vehículos son de tipo Camión, Furgoneta o Van?
SELECT * FROM vehiculo WHERE tipo_vehiculo IN('camion','furgoneta','van');

-- 7. ¿Cuáles son los clientes con nombres que contienen las palabras "comercial" o "distribuidora"?
SELECT * FROM cliente WHERE nombre_o_razon_social LIKE '%comercial%' 
OR nombre_o_razon_social LIKE '%distribuidora%';

-- 8. ¿Qué seguimientos de envíos no tienen coordenadas GPS registradas?
SELECT * FROM seguimiento_envios WHERE coordenadas_gps IS NULL;

-- conteo de seguimientos que no tienen coordenadas
SELECT COUNT(coordenadas_gps)
FROM seguimiento_envios
WHERE coordenadas_gps IS NULL;

-- 9. ¿Cuáles son los envíos ordenados por estado y fecha?
SELECT * FROM envios ORDER BY estado_actual , fecha_hora_recepcion;

-- tambien se puede ver en la tabla solo estado y fecha 
SELECT estado_actual, fecha_hora_recepcion FROM envios ORDER BY estado_actual, fecha_hora_recepcion;

-- 10. ¿Cuál es el tiempo promedio de entrega por ruta?
-- renombramos el tiempo estimado como promedio de entrega

SELECT ruta_distribucionID, AVG(tiempo_estimado) AS promedio_entrega FROM ruta_distribucion
GROUP BY ruta_distribucionID;