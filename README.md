# FoodTrack Database

Proyecto académico de una base relacional para gestionar foodtrucks, sus productos, ubicaciones y pedidos. El motor objetivo es **Microsoft SQL Server** y **DBeaver** se utiliza como cliente de consulta.

## Modelo

El modelo se deriva de los CSV provistos en [`data/`](data/). Sus relaciones son:

- Un foodtruck tiene muchos productos, pedidos y ubicaciones.
- Un pedido tiene muchos ítems.
- Un producto puede aparecer en muchos ítems de pedido.

![Diagrama entidad-relación](docs/foodtrack-er.png)

El script define `location_id` como clave primaria de `locations`. La columna `comments` es una evolución posterior del modelo, por eso no forma parte del diagrama base.

```mermaid
erDiagram
    foodtrucks ||--o{ products : ofrece
    foodtrucks ||--o{ orders : recibe
    foodtrucks ||--o{ locations : opera_en
    orders ||--o{ order_items : contiene
    products ||--o{ order_items : aparece_en
```

## Estructura

```text
data/       CSV de origen
docs/       Diagrama ER
scripts/    Scripts SQL ordenados por ejecución
cargar_datos.py  Carga programática de pedidos
```

## Ejecución en SQL Server con DBeaver

Abrí una conexión a SQL Server en DBeaver y ejecutá los archivos de `scripts/` en este orden:

1. `01_create_database.sql` — conectado a `master`.
2. `02_create_tables.sql`
3. `03_constraints.sql`
4. `04_schema_update.sql`
5. `07_create_failed_orders.sql` — necesario para el extra de Python.
6. `05_load_data.sql` — después de reemplazar las rutas de ejemplo por rutas que el **servicio de SQL Server** pueda leer. Carga las tres tablas base; sus bloques `orders` y `order_items` están comentados.
7. Elegí una de estas rutas para `orders`:
   - **BULK INSERT:** descomentá y ejecutá primero el bloque `orders`, luego el bloque `order_items` de `05_load_data.sql`.
   - **Python:** ejecutá `cargar_datos.py` y después descomentá y ejecutá solamente el bloque `order_items`.
8. `06_validate_data.sql`

La carga completa espera los conteos: 2 foodtrucks, 4 productos, 2 ubicaciones, 2 pedidos y 3 ítems. Las restricciones impiden precios no positivos, stock negativo, cantidades no positivas, totales negativos y estados de pedido no permitidos.

> `BULK INSERT` lee archivos desde el equipo o contenedor donde se ejecuta SQL Server; no desde DBeaver. Si el servidor no puede acceder a la ruta, usá el asistente de importación de DBeaver o una ruta compartida y autorizada.

## Carga programática con Python

El extra `cargar_datos.py` inserta pedidos desde `data/orders.csv` y registra cada fallo en `dbo.failed_orders`. Es la vía prevista para cargar `orders`; si preferís cargar esa tabla con `BULK INSERT`, descomentá su bloque en `05_load_data.sql` y omití esta ejecución.

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
cp .env.example .env
python cargar_datos.py
```

Completá `.env` con los datos de tu instancia SQL Server. Este archivo está ignorado por Git y no debe publicarse. Antes de ejecutar Python, corré `01` a `04` y `07`; cargá primero `foodtrucks` con el script SQL, porque `orders.foodtruck_id` es una clave foránea.

Para usar otro archivo de pedidos:

```bash
python cargar_datos.py --file /ruta/a/orders.csv
```

## Tecnologías

- Microsoft SQL Server
- DBeaver
- Git y GitHub
- Python 3 y `pyodbc`
