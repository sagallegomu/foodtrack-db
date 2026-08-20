"""Carga orders.csv y order_items.csv en SQL Server."""

import csv
import os
from pathlib import Path

import pyodbc
from dotenv import load_dotenv


# Carga las credenciales definidas en el archivo .env.
load_dotenv()

PROJECT_ROOT = Path(__file__).parent
ORDERS_CSV = PROJECT_ROOT / "data" / "orders.csv"
ORDER_ITEMS_CSV = PROJECT_ROOT / "data" / "order_items.csv"


def registrar_error(cursor, order_id, row, error):
    """Guarda el detalle de una fila que no pudo insertarse."""
    cursor.execute(
        """
        INSERT INTO dbo.failed_orders (source_order_id, raw_data, error_message)
        VALUES (?, ?, ?)
        """,
        order_id,
        str(dict(row)),
        str(error),
    )


connection_string = (
    f"DRIVER={{{os.environ['FOODTRACK_DB_DRIVER']}}};"
    f"SERVER={os.environ['FOODTRACK_DB_SERVER']};"
    f"DATABASE={os.environ['FOODTRACK_DB_NAME']};"
    f"UID={os.environ['FOODTRACK_DB_USER']};"
    f"PWD={os.environ['FOODTRACK_DB_PASSWORD']};"
    "TrustServerCertificate=yes;"
)

connection = pyodbc.connect(connection_string)
cursor = connection.cursor()
orders_loaded = 0
items_loaded = 0

# Primero se cargan los pedidos, porque los ítems dependen de ellos.
with ORDERS_CSV.open(encoding="utf-8", newline="") as file:
    for row in csv.DictReader(file):
        try:
            cursor.execute(
                """
                INSERT INTO dbo.orders (order_id, foodtruck_id, order_date, status, total)
                VALUES (?, ?, ?, ?, ?)
                """,
                row["order_id"],
                row["foodtruck_id"],
                row["order_date"],
                row["status"],
                row["total"],
            )
            connection.commit()
            orders_loaded += 1
        except Exception as error:
            connection.rollback()
            registrar_error(cursor, row["order_id"], row, error)
            connection.commit()
            print(f"Pedido {row['order_id']} no cargado: {error}")

# Después se cargan los ítems de cada pedido.
with ORDER_ITEMS_CSV.open(encoding="utf-8", newline="") as file:
    for row in csv.DictReader(file):
        try:
            cursor.execute(
                """
                INSERT INTO dbo.order_items (order_item_id, order_id, product_id, quantity)
                VALUES (?, ?, ?, ?)
                """,
                row["order_item_id"],
                row["order_id"],
                row["product_id"],
                row["quantity"],
            )
            connection.commit()
            items_loaded += 1
        except Exception as error:
            connection.rollback()
            registrar_error(cursor, row["order_id"], row, error)
            connection.commit()
            print(f"Ítem {row['order_item_id']} no cargado: {error}")

connection.close()
print(f"Carga finalizada: {orders_loaded} pedidos y {items_loaded} ítems insertados.")
