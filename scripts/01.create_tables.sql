CREATE TABLE foodtrucks(
    foodtruck_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    cuisine_type VARCHAR(500) NOT NULL,
    city VARCHAR(100) NOT NULL,
)

CREATE TABLE locations(
    location_id INT PRIMARY KEY,
    foodtruck_id INT NOT NULL,
    location_date DATE NOT NULL,
    zone VARCHAR(100),
    FOREIGN KEY (foodtruck_id) REFERENCES foodtrucks(foodtruck_id)
)