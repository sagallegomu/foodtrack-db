/* Ejecutar conectado a la instancia de SQL Server (base master). */
IF DB_ID(N'foodtrucks') IS NULL
BEGIN
    CREATE DATABASE [foodtrucks];
END;
