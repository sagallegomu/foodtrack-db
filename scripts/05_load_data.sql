/*
    Carga los CSV con BULK INSERT.
    SQL Server corre en Docker: montá la carpeta data/ del proyecto como
    /var/opt/mssql/import dentro del contenedor antes de ejecutar este script.
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
