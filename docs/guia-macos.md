# Guía de ejecución en macOS

Esta guía asume que SQL Server se ejecuta en el contenedor Docker `sql_server_demo` y que expone el puerto `1433` en tu Mac.

## 1. Instalar y verificar requisitos

Necesitás tener instalados:

- Docker Desktop, con el contenedor SQL Server iniciado.
- DBeaver.
- Python 3 y Homebrew.
- `unixODBC` y Microsoft ODBC Driver 18, requeridos por Python para conectarse a SQL Server.

Desde Terminal ejecutá una sola vez:

```bash
brew install unixodbc
brew tap microsoft/mssql-release https://github.com/microsoft/homebrew-mssql-release
HOMEBREW_ACCEPT_EULA=Y brew install msodbcsql18
```

## 2. Copiar los CSV al contenedor

`BULK INSERT` se ejecuta dentro de SQL Server, por lo que primero copiamos los CSV al contenedor:

```bash
docker exec sql_server_demo mkdir -p /var/opt/mssql/import
docker cp "/Users/saragallegomunoz/Documents/Henry/Data Science/M2/Clase 1/foodtrack-db/data/." sql_server_demo:/var/opt/mssql/import
docker exec sql_server_demo ls -l /var/opt/mssql/import
```

El último comando debe mostrar los cinco archivos `.csv`.

## 3. Conectar DBeaver a SQL Server

Creá una conexión **SQL Server** con estos valores:

| Campo | Valor |
| --- | --- |
| Host | `localhost` |
| Puerto | `1433` |
| Base inicial | `master` |
| Usuario | Tu usuario configurado en SQL Server (por ejemplo, `sa`) |
| Contraseña | La contraseña definida al crear el contenedor |

Probá la conexión antes de continuar.

## 4. Crear esquema y cargar tablas base

Ejecutá en DBeaver, por orden:

1. `scripts/01_create_database.sql` conectado a `master`.
2. Conectate a la nueva base `FoodTrack`.
3. `scripts/02_create_tables.sql`.
4. `scripts/03_constraints.sql`.
5. `scripts/04_schema_update.sql`.
6. En `scripts/05_load_data.sql`, ejecutá únicamente los tres bloques activos: `foodtrucks`, `products` y `locations`.

No descomentés los bloques de `orders` ni `order_items`: Python los cargará en el paso siguiente.

## 5. Cargar `orders` y `order_items` con Python

En Terminal:

```bash
cd "/Users/saragallegomunoz/Documents/Henry/Data Science/M2/Clase 1/foodtrack-db"
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
cp .env.example .env
python -c "import pyodbc; print(pyodbc.drivers())"
```

El último comando debe mostrar `ODBC Driver 18 for SQL Server`.

Editá `.env` y completá la contraseña. Usá exactamente el nombre del driver instalado:

```env
FOODTRACK_DB_SERVER=localhost,1433
FOODTRACK_DB_NAME=FoodTrack
FOODTRACK_DB_USER=TU_USUARIO_SQL_SERVER
FOODTRACK_DB_PASSWORD=TU_CONTRASENA
FOODTRACK_DB_DRIVER=ODBC Driver 18 for SQL Server
```

Reemplazá `TU_USUARIO_SQL_SERVER` por el mismo usuario con el que DBeaver se conecta a SQL Server. Después ejecutá:

```bash
python cargar_datos.py
```

El resultado esperado es 2 pedidos y 3 ítems insertados, sin rechazados. Si aparece un error, el script lo muestra en pantalla.

## 6. Validar

En DBeaver ejecutá `scripts/06_validate_data.sql`. Los conteos esperados son: 2 foodtrucks, 4 productos, 2 ubicaciones, 2 pedidos y 3 ítems.

Como último paso opcional, ejecutá `scripts/07_create_failed_orders.sql`. Este script crea la tabla auxiliar `failed_orders` de forma independiente al cargador Python.
