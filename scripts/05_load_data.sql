/*
    Carga los CSV con BULK INSERT.
    SQL Server corre en Docker. En macOS o Windows se usa el mismo BULK INSERT:
    la única diferencia es el comando para copiar data/ al contenedor.

    macOS (Terminal):
    docker cp "/ruta/a/foodtrack-db/data/." sql_server_demo:/var/opt/mssql/import

    Windows (PowerShell):
    docker cp "C:\ruta\a\foodtrack-db\data\." sql_server_demo:/var/opt/mssql/import

    Después de copiar los CSV, ejecutá los bloques BULK INSERT de este archivo.
    Las rutas FROM son Linux porque indican la ubicación dentro del contenedor.
*/
USE FoodTrack;

BULK INSERT dbo.foodtrucks
FROM '/var/opt/mssql/import/foodtrucks.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', TABLOCK);

BULK INSERT dbo.products
FROM '/var/opt/mssql/import/products.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', TABLOCK);

BULK INSERT dbo.locations
FROM '/var/opt/mssql/import/locations.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', TABLOCK);

-- Para demostrar el extra de Python, omití este bloque y ejecutá cargar_datos.py.
-- Ejecutalo solamente si querés cargar orders también con BULK INSERT.
/*
BULK INSERT dbo.orders
FROM '/var/opt/mssql/import/orders.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', TABLOCK);
*/

-- Ejecutá este bloque después de cargar orders, ya sea por BULK INSERT o Python.
/*
BULK INSERT dbo.order_items
FROM '/var/opt/mssql/import/order_items.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', TABLOCK);
*/
