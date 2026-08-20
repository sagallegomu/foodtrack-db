"""Carga pedidos desde un CSV de FoodTrack y registra errores en SQL Server."""

from __future__ import annotations

import argparse
import csv
import os
import sys
from datetime import datetime
from decimal import Decimal
from pathlib import Path
from typing import Mapping

try:
    import pyodbc
except ImportError:  # Mensaje claro si primero no se instalaron las dependencias.
    pyodbc = None


PROJECT_ROOT = Path(__file__).resolve().parent


def load_dotenv(path: Path) -> None:
    """Carga un .env simple sin sobrescribir variables ya presentes."""
    if not path.exists():
        return

    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def connection_string() -> str:
    required = ("FOODTRACK_DB_SERVER", "FOODTRACK_DB_NAME", "FOODTRACK_DB_USER", "FOODTRACK_DB_PASSWORD")
    missing = [key for key in required if not os.getenv(key)]
    if missing:
        raise RuntimeError(f"Faltan variables de conexión: {', '.join(missing)}")

    driver = os.getenv("FOODTRACK_DB_DRIVER", "ODBC Driver 18 for SQL Server")
    return (
        f"DRIVER={{{driver}}};"
        f"SERVER={os.environ['FOODTRACK_DB_SERVER']};"
        f"DATABASE={os.environ['FOODTRACK_DB_NAME']};"
        f"UID={os.environ['FOODTRACK_DB_USER']};"
        f"PWD={os.environ['FOODTRACK_DB_PASSWORD']};"
        "TrustServerCertificate=yes;"
    )


def parse_order(row: Mapping[str, str]) -> tuple[int, int, datetime.date, str, Decimal]:
    return (
        int(row["order_id"]),
        int(row["foodtruck_id"]),
        datetime.strptime(row["order_date"], "%Y-%m-%d").date(),
        row["status"].strip().lower(),
        Decimal(row["total"]),
    )


def log_failure(cursor, row: Mapping[str, str], error: Exception) -> None:
    source_id = row.get("order_id")
    try:
        source_id = int(source_id) if source_id else None
    except ValueError:
        source_id = None

    raw_data = ", ".join(f"{key}={value}" for key, value in row.items())
    cursor.execute(
        """
        INSERT INTO dbo.failed_orders (source_order_id, raw_data, error_message)
        VALUES (?, ?, ?)
        """,
        source_id,
        raw_data,
        str(error),
    )


def load_orders(csv_path: Path) -> tuple[int, int]:
    if pyodbc is None:
        raise RuntimeError("pyodbc no está instalado. Ejecutá: python -m pip install -r requirements.txt")
    if not csv_path.exists():
        raise FileNotFoundError(f"No existe el archivo: {csv_path}")

    connection = pyodbc.connect(connection_string())
    loaded = 0
    rejected = 0
    try:
        cursor = connection.cursor()
        with csv_path.open("r", encoding="utf-8", newline="") as csv_file:
            for row in csv.DictReader(csv_file):
                try:
                    cursor.execute(
                        """
                        INSERT INTO dbo.orders (order_id, foodtruck_id, order_date, status, total)
                        VALUES (?, ?, ?, ?, ?)
                        """,
                        parse_order(row),
                    )
                    connection.commit()
                    loaded += 1
                except Exception as error:
                    connection.rollback()
                    log_failure(cursor, row, error)
                    connection.commit()
                    rejected += 1
                    print(f"Pedido {row.get('order_id', '?')} rechazado: {error}", file=sys.stderr)
    finally:
        connection.close()

    return loaded, rejected


def main() -> int:
    parser = argparse.ArgumentParser(description="Carga data/orders.csv en SQL Server.")
    parser.add_argument(
        "--file",
        type=Path,
        default=PROJECT_ROOT / "data" / "orders.csv",
        help="Ruta del CSV de pedidos (por defecto: data/orders.csv).",
    )
    args = parser.parse_args()

    load_dotenv(PROJECT_ROOT / ".env")
    try:
        loaded, rejected = load_orders(args.file)
    except Exception as error:
        print(f"Error de carga: {error}", file=sys.stderr)
        return 1

    print(f"Carga finalizada: {loaded} pedido(s) insertado(s), {rejected} rechazado(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
