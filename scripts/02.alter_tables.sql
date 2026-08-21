ALTER TABLE dbo.locations
ADD CONSTRAINT FK_locations_foodtrucks
FOREIGN KEY (foodtruck_id) REFERENCES foodtrucks(foodtruck_id)
CONSTRAINT UQ_locations_foodtruck_date UNIQUE (foodtruck_id, location_date);