# Guía de ejecución en Windows

Esta guía asume que SQL Server se ejecuta en el contenedor Docker `sql_server_demo` y que expone el puerto `1433` en Windows.

## 1. Instalar y verificar requisitos

Necesitás tener instalados:

- Docker Desktop, con el contenedor SQL Server iniciado.
- DBeaver.
- Python 3 (la misma arquitectura que tu Windows, normalmente 64 bits).
- Microsoft ODBC Driver 18 for SQL Server. Descargalo e instalalo desde la [documentación oficial de Microsoft](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver17). Elegí el instalador x64, x86 o ARM64 que corresponda a tu equipo. Si el instalador lo solicita, instalá también Microsoft Visual C++ Redistributable.

## 2. Copiar los CSV al contenedor

Abrí **PowerShell** en la carpeta raíz de `foodtrack-db`. Reemplazá `C:\ruta\a\foodtrack-db` por la ubicación real del repositorio si es diferente:

```powershell
docker exec sql_server_demo mkdir -p /var/opt/mssql/import
docker cp "C:\ruta\a\foodtrack-db\data\." sql_server_demo:/var/opt/mssql/import
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
| Usuario | `sa` |
| Contraseña | La contraseña definida al crear el contenedor |

Probá la conexión antes de continuar.

## 4. Crear esquema y cargar tablas base

Ejecutá en DBeaver, por orden:

1. `scripts/01_create_database.sql` conectado a `master`.
2. Conectate a la nueva base `FoodTrack`.
3. `scripts/02_create_tables.sql`.
4. `scripts/03_constraints.sql`.
5. `scripts/04_schema_update.sql`.
6. `scripts/07_create_failed_orders.sql`.
7. En `scripts/05_load_data.sql`, ejecutá únicamente los tres bloques activos: `foodtrucks`, `products` y `locations`.

No descomentés los bloques de `orders` ni `order_items`: Python los cargará en el paso siguiente.

## 5. Cargar `orders` y `order_items` con Python

Desde PowerShell, en la raíz del repositorio:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
py -m pip install -r requirements.txt
Copy-Item .env.example .env
```

Si PowerShell bloquea la activación, permitila solo durante esta sesión:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

Editá `.env` y completá la contraseña:

```env
FOODTRACK_DB_SERVER=localhost,1433
FOODTRACK_DB_NAME=FoodTrack
FOODTRACK_DB_USER=sa
FOODTRACK_DB_PASSWORD=TU_CONTRASENA
FOODTRACK_DB_DRIVER=ODBC Driver 18 for SQL Server
```

Ejecutá la carga:

```powershell
py cargar_datos.py
```

El resultado esperado es 2 pedidos y 3 ítems insertados, sin rechazados. Los errores de inserción se guardan en `dbo.failed_orders`.

## 6. Validar

En DBeaver ejecutá `scripts/06_validate_data.sql`. Los conteos esperados son: 2 foodtrucks, 4 productos, 2 ubicaciones, 2 pedidos y 3 ítems.
