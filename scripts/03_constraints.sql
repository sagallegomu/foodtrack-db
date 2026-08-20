USE FoodTrack;

ALTER TABLE dbo.products
    ADD CONSTRAINT FK_products_foodtrucks
        FOREIGN KEY (foodtruck_id) REFERENCES dbo.foodtrucks (foodtruck_id),
        CONSTRAINT UQ_products_foodtruck_name UNIQUE (foodtruck_id, name),
        CONSTRAINT CK_products_price CHECK (price > 0),
        CONSTRAINT CK_products_stock CHECK (stock >= 0);

ALTER TABLE dbo.orders
    ADD CONSTRAINT FK_orders_foodtrucks
        FOREIGN KEY (foodtruck_id) REFERENCES dbo.foodtrucks (foodtruck_id),
        CONSTRAINT CK_orders_status CHECK (status IN (N'pendiente', N'entregado', N'cancelado')),
        CONSTRAINT CK_orders_total CHECK (total >= 0);

ALTER TABLE dbo.locations
    ADD CONSTRAINT FK_locations_foodtrucks
        FOREIGN KEY (foodtruck_id) REFERENCES dbo.foodtrucks (foodtruck_id),
        CONSTRAINT UQ_locations_foodtruck_date UNIQUE (foodtruck_id, location_date);

ALTER TABLE dbo.order_items
    ADD CONSTRAINT FK_order_items_orders
        FOREIGN KEY (order_id) REFERENCES dbo.orders (order_id),
        CONSTRAINT FK_order_items_products
        FOREIGN KEY (product_id) REFERENCES dbo.products (product_id),
        CONSTRAINT UQ_order_items_order_product UNIQUE (order_id, product_id),
        CONSTRAINT CK_order_items_quantity CHECK (quantity > 0);
