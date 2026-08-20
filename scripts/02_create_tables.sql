USE [foodtrucks];

CREATE TABLE dbo.foodtrucks (
    foodtruck_id INT NOT NULL,
    name NVARCHAR(100) NOT NULL,
    cuisine_type NVARCHAR(50) NOT NULL,
    city NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_foodtrucks PRIMARY KEY (foodtruck_id)
);

CREATE TABLE dbo.products (
    product_id INT NOT NULL,
    foodtruck_id INT NOT NULL,
    name NVARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    CONSTRAINT PK_products PRIMARY KEY (product_id)
);

CREATE TABLE dbo.orders (
    order_id INT NOT NULL,
    foodtruck_id INT NOT NULL,
    order_date DATE NOT NULL,
    status NVARCHAR(30) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    CONSTRAINT PK_orders PRIMARY KEY (order_id)
);

CREATE TABLE dbo.locations (
    location_id INT NOT NULL,
    foodtruck_id INT NOT NULL,
    location_date DATE NOT NULL,
    zone NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_locations PRIMARY KEY (location_id)
);

CREATE TABLE dbo.order_items (
    order_item_id INT NOT NULL,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT PK_order_items PRIMARY KEY (order_item_id)
);
