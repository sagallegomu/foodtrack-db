"""Carga orders.csv y order_items.csv en SQL Server."""

import csv
import os
from pathlib import Path

import pyodbc
from dotenv import load_dotenv


PROJECT_ROOT = Path(__file__).parent


def crear_cadena_conexion():
    """Lee .env y construye la cadena de conexión a SQL Server."""
    load_dotenv()
    return (
        f"DRIVER={{{os.environ['FOODTRACK_DB_DRIVER']}}};"
        f"SERVER={os.environ['FOODTRACK_DB_SERVER']};"
        f"DATABASE={os.environ['FOODTRACK_DB_NAME']};"
        f"UID={os.environ['FOODTRACK_DB_USER']};"
        f"PWD={os.environ['FOODTRACK_DB_PASSWORD']};"
        "TrustServerCertificate=yes;"
    )


class CargadorDatos:
    """Se conecta a SQL Server y carga los dos CSV de pedidos."""

    def __init__(self):
        self.conexion = pyodbc.connect(crear_cadena_conexion())
        self.cursor = self.conexion.cursor()
        self.pedidos_cargados = 0
        self.items_cargados = 0

    def cargar_pedidos(self):
        """Inserta cada fila de data/orders.csv."""
        archivo = PROJECT_ROOT / "data" / "orders.csv"

        with archivo.open(encoding="utf-8", newline="") as csv_file:
            for fila in csv.DictReader(csv_file):
                try:
                    self.cursor.execute(
                        """
                        INSERT INTO dbo.orders (order_id, foodtruck_id, order_date, status, total)
                        VALUES (?, ?, ?, ?, ?)
                        """,
                        fila["order_id"],
                        fila["foodtruck_id"],
                        fila["order_date"],
                        fila["status"],
                        fila["total"],
                    )
                    self.conexion.commit()
                    self.pedidos_cargados += 1
                except Exception as error:
                    self.conexion.rollback()
                    print(f"Pedido {fila['order_id']} no cargado: {error}")

    def cargar_items(self):
        """Inserta cada fila de data/order_items.csv después de los pedidos."""
        archivo = PROJECT_ROOT / "data" / "order_items.csv"

        with archivo.open(encoding="utf-8", newline="") as csv_file:
            for fila in csv.DictReader(csv_file):
                try:
                    self.cursor.execute(
                        """
                        INSERT INTO dbo.order_items (order_item_id, order_id, product_id, quantity)
                        VALUES (?, ?, ?, ?)
                        """,
                        fila["order_item_id"],
                        fila["order_id"],
                        fila["product_id"],
                        fila["quantity"],
                    )
                    self.conexion.commit()
                    self.items_cargados += 1
                except Exception as error:
                    self.conexion.rollback()
                    print(f"Ítem {fila['order_item_id']} no cargado: {error}")

    def cerrar_conexion(self):
        """Cierra la conexión al terminar la carga."""
        self.conexion.close()


def main():
    cargador = CargadorDatos()

    try:
        cargador.cargar_pedidos()
        cargador.cargar_items()
        print(
            f"Carga finalizada: {cargador.pedidos_cargados} pedidos y "
            f"{cargador.items_cargados} ítems insertados."
        )
    finally:
        cargador.cerrar_conexion()


if __name__ == "__main__":
    main()
