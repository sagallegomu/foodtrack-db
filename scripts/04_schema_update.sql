USE FoodTrack;

-- Evolución del esquema: permite guardar indicaciones o comentarios del pedido.
ALTER TABLE dbo.orders
    ADD comments NVARCHAR(255) NULL;
