USE FoodTrack;

-- Tabla auxiliar para conservar los pedidos que no pudieron cargarse con Python.
CREATE TABLE dbo.failed_orders (
    failed_order_id INT IDENTITY(1, 1) NOT NULL,
    source_order_id INT NULL,
    raw_data NVARCHAR(1000) NOT NULL,
    error_message NVARCHAR(2000) NOT NULL,
    failed_at DATETIME2 NOT NULL CONSTRAINT DF_failed_orders_failed_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_failed_orders PRIMARY KEY (failed_order_id)
);
