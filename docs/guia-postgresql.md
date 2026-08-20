# Guía de importación CSV con PostgreSQL

> Esta es una alternativa de referencia. La consigna original de FoodTrack pide **Microsoft SQL Server**; usá PostgreSQL solo si el docente autoriza explícitamente cambiar de motor. Los scripts de `scripts/` y `cargar_datos.py` fueron hechos para SQL Server y deben adaptarse antes de usarlos en PostgreSQL.

## Opción recomendada: asistente de DBeaver

Es la opción más simple, porque DBeaver lee los CSV desde tu equipo y no exige dar rutas locales al servidor PostgreSQL.

1. Creá primero las tablas equivalentes en PostgreSQL, con sus claves y restricciones.
2. En DBeaver, clic derecho sobre una tabla → **Import Data** → **CSV**.
3. Elegí el archivo CSV, verificá que el separador sea coma y que la primera fila sea encabezado.
4. Revisá el mapeo de columnas y ejecutá la importación.
5. Repetí en este orden: `foodtrucks`, `products`, `locations`, `orders`, `order_items`.

Este orden respeta las claves foráneas.

## Opción por comando: `\copy` de `psql`

`\copy` se ejecuta desde el cliente `psql` y lee los archivos desde el computador del estudiante, no desde el servidor PostgreSQL. Por ello suele ser más cómodo que `COPY FROM` cuando PostgreSQL corre en Docker o en una máquina remota.

Abrí `psql`, conectate a la base y ejecutá un comando por archivo. Reemplazá la ruta por la de tu equipo:

```sql
\copy foodtrucks (foodtruck_id, name, cuisine_type, city)
FROM 'C:/ruta/a/foodtrack-db/data/foodtrucks.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy products (product_id, foodtruck_id, name, price, stock)
FROM 'C:/ruta/a/foodtrack-db/data/products.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy locations (location_id, foodtruck_id, location_date, zone)
FROM 'C:/ruta/a/foodtrack-db/data/locations.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy orders (order_id, foodtruck_id, order_date, status, total)
FROM 'C:/ruta/a/foodtrack-db/data/orders.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy order_items (order_item_id, order_id, product_id, quantity)
FROM 'C:/ruta/a/foodtrack-db/data/order_items.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
```

En macOS o Linux, una ruta de ejemplo sería `/Users/tu_usuario/.../foodtrucks.csv`.

## Validar

```sql
SELECT 'foodtrucks' AS tabla, COUNT(*) AS filas FROM foodtrucks
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'locations', COUNT(*) FROM locations
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;
```

Los resultados esperados son 2, 4, 2, 2 y 3 filas.

## Nota sobre `COPY FROM`

`COPY FROM '/ruta/archivo.csv'` es una instrucción de servidor: PostgreSQL debe poder leer esa ruta. `\copy` funciona desde el cliente y evita ese requisito. Consultá la [documentación oficial de PostgreSQL](https://www.postgresql.org/docs/current/sql-copy.html) para conocer las diferencias.
