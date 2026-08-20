/* Ejecutar conectado a la instancia de SQL Server (base master). */
IF DB_ID(N'FoodTrack') IS NULL
BEGIN
    CREATE DATABASE FoodTrack;
END;
GO
