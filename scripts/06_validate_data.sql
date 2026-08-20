USE [foodtrucks];

-- Conteos esperados para los CSV incluidos: 2, 4, 2, 2 y 3 respectivamente.
SELECT 'foodtrucks' AS table_name, COUNT(*) AS row_count FROM dbo.foodtrucks
UNION ALL SELECT 'products', COUNT(*) FROM dbo.products
UNION ALL SELECT 'locations', COUNT(*) FROM dbo.locations
UNION ALL SELECT 'orders', COUNT(*) FROM dbo.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM dbo.order_items;

-- Pedidos e ítems: permite comprobar las relaciones entre las tablas.
SELECT
    o.order_id,
    f.name AS foodtruck,
    o.order_date,
    o.status,
    p.name AS product,
    oi.quantity,
    o.total
FROM dbo.orders AS o
INNER JOIN dbo.foodtrucks AS f ON f.foodtruck_id = o.foodtruck_id
INNER JOIN dbo.order_items AS oi ON oi.order_id = o.order_id
INNER JOIN dbo.products AS p ON p.product_id = oi.product_id
ORDER BY o.order_id, oi.order_item_id;

-- Estas tres consultas deben devolver cero filas.
SELECT * FROM dbo.products WHERE price <= 0 OR stock < 0;
SELECT * FROM dbo.order_items WHERE quantity <= 0;
SELECT * FROM dbo.orders WHERE total < 0;
