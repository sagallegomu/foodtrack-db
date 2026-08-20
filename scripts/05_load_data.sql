/*
    Carga los CSV con BULK INSERT.
    Reemplazá C:\ruta\a\foodtrack-db por una ruta local para EL SERVICIO de
    SQL Server. Esa ruta puede ser distinta a la ruta desde la que DBeaver ve
    los archivos.
*/
USE FoodTrack;
GO

BULK INSERT dbo.foodtrucks
FROM 'C:\ruta\a\foodtrack-db\data\foodtrucks.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', CODEPAGE = '65001', TABLOCK);
GO

BULK INSERT dbo.products
FROM 'C:\ruta\a\foodtrack-db\data\products.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', CODEPAGE = '65001', TABLOCK);
GO

BULK INSERT dbo.locations
FROM 'C:\ruta\a\foodtrack-db\data\locations.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', CODEPAGE = '65001', TABLOCK);
GO

-- Para demostrar el extra de Python, omití este bloque y ejecutá cargar_datos.py.
-- Ejecutalo solamente si querés cargar orders también con BULK INSERT.
/*
BULK INSERT dbo.orders
FROM 'C:\ruta\a\foodtrack-db\data\orders.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', CODEPAGE = '65001', TABLOCK);
GO
*/

-- Ejecutá este bloque después de cargar orders, ya sea por BULK INSERT o Python.
/*
BULK INSERT dbo.order_items
FROM 'C:\ruta\a\foodtrack-db\data\order_items.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', CODEPAGE = '65001', TABLOCK);
GO
*/
