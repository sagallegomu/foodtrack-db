# Guía de importación CSV con MySQL

> Esta es una alternativa de referencia. La consigna original de FoodTrack pide **Microsoft SQL Server**; usá MySQL solo si el docente autoriza explícitamente cambiar de motor. Los scripts de `scripts/` y `cargar_datos.py` fueron hechos para SQL Server y deben adaptarse antes de usarlos en MySQL.

## Opción recomendada: asistente de DBeaver

Esta opción evita configuraciones de permisos para archivos locales:

1. Creá primero las tablas equivalentes en MySQL, con sus claves y restricciones.
2. En DBeaver, clic derecho sobre una tabla → **Import Data** → **CSV**.
3. Elegí el archivo, verificá separador coma y encabezado.
4. Revisá el mapeo de columnas y ejecutá la importación.
5. Repetí en este orden: `foodtrucks`, `products`, `locations`, `orders`, `order_items`.

## Opción por comando: `LOAD DATA LOCAL INFILE`

`LOCAL` indica que MySQL debe leer el CSV desde el equipo cliente, no desde el servidor. Ejecutá primero el siguiente comando si tenés permisos de administrador:

```sql
SET GLOBAL local_infile = 1;
```

Luego ejecutá una carga por tabla. Reemplazá las rutas por las de tu equipo:

```sql
LOAD DATA LOCAL INFILE 'C:/ruta/a/foodtrack-db/data/foodtrucks.csv'
INTO TABLE foodtrucks
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/ruta/a/foodtrack-db/data/products.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/ruta/a/foodtrack-db/data/locations.csv'
INTO TABLE locations
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/ruta/a/foodtrack-db/data/orders.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/ruta/a/foodtrack-db/data/order_items.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
```

En macOS o Linux, una ruta de ejemplo sería `/Users/tu_usuario/.../foodtrucks.csv`.

Si MySQL informa que la carga local está deshabilitada, usá el asistente de DBeaver o pedí al administrador habilitar `local_infile` tanto en el servidor como en el cliente.

## Validar

```sql
SELECT 'foodtrucks' AS tabla, COUNT(*) AS filas FROM foodtrucks
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'locations', COUNT(*) FROM locations
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;
```

Los resultados esperados son 2, 4, 2, 2 y 3 filas. Consultá la [documentación oficial de MySQL](https://dev.mysql.com/doc/refman/8.0/en/load-data.html) para las opciones y restricciones de `LOAD DATA LOCAL INFILE`.
