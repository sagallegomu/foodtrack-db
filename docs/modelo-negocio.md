# Modelo ER: reglas de negocio y mejoras

## Relaciones y reglas implementadas

| Relación | Cardinalidad | Regla de negocio |
| --- | --- | --- |
| `foodtrucks` - `products` | 1 a 0..N | Cada producto pertenece a un foodtruck; un foodtruck puede no tener productos cargados todavía. |
| `foodtrucks` - `orders` | 1 a 0..N | Cada pedido se realiza a un único foodtruck. |
| `foodtrucks` - `locations` | 1 a 0..N | Cada registro de ubicación pertenece a un foodtruck. |
| `orders` - `order_items` | 1 a 0..N | Cada ítem pertenece a un único pedido. La base actual permite crear un pedido antes de añadirle ítems. |
| `products` - `order_items` | 1 a 0..N | Cada ítem hace referencia a un único producto. |

Las restricciones de integridad definen valores obligatorios, precios positivos, stock no negativo, cantidades positivas, totales no negativos y estados de pedido permitidos. También evitan que un mismo producto se repita dentro de un pedido y que un foodtruck tenga dos ubicaciones en la misma fecha.

## Patrones de negocio implícitos

- **Catálogo por foodtruck:** `products.foodtruck_id` muestra que el menú no es global; cada foodtruck administra su propio catálogo y stock.
- **Operación móvil por día:** `locations.location_date` y `zone` modelan dónde opera cada foodtruck en una fecha dada.
- **Pedido como cabecera y detalle:** `orders` contiene información general del pedido y `order_items` contiene las líneas de compra. Es el patrón cabecera-detalle típico de una transacción comercial.
- **Estados operativos:** el estado permite seguir el ciclo de vida del pedido sin borrar su historial.
- **Evolución controlada:** `comments` se agrega sin alterar la estructura original, como una migración versionada.

## Mejoras recomendadas

| Mejora | Justificación |
| --- | --- |
| Agregar `unit_price` a `order_items` | El precio del producto puede cambiar con el tiempo. Guardar el precio vendido conserva el historial del pedido y permite calcular su total. |
| Validar que producto y pedido pertenezcan al mismo foodtruck | La estructura actual permite técnicamente agregar a un pedido de un foodtruck un producto de otro. Se puede reforzar con claves foráneas compuestas o un trigger. |
| Calcular o validar `orders.total` | En los CSV, el total puede no coincidir con `price x quantity`. Se debe definir si incluye impuestos, descuentos o costos adicionales. |
| Crear `stock_movements` | Un único campo `stock` no deja trazabilidad de ingresos, ventas, ajustes ni devoluciones. |
| Ampliar `locations` con horarios o coordenadas | `zone` y fecha identifican una ubicación general, pero no distinguen turnos ni posiciones precisas. |
| Normalizar estados si crecen | Un `CHECK` es apropiado para pocos estados estables. Una tabla `order_statuses` facilita configuraciones, descripciones y auditoría si el flujo se vuelve más complejo. |

## Alcance de las cardinalidades

El diagrama usa `0..N` en el lado hijo porque las claves foráneas obligan a que cada hijo tenga un padre, pero no obligan a que todo padre ya tenga hijos. Por ejemplo, una orden puede existir antes de que se creen sus ítems; si la regla de negocio exige al menos un ítem para confirmar un pedido, esa condición requiere lógica adicional de aplicación, procedimiento o trigger.
