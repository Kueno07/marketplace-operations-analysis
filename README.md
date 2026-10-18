# Marketplace Operations Metrics

This PostgreSQL reference defines three operational measures at store and order-month level. It contains no case prompt, source dashboard, source catalog, or computed company findings.

## Measures

| Measure | Numerator | Denominator |
|---|---|---|
| Cancellation rate | Orders with a canceled terminal status | Delivered and canceled terminal orders |
| Unit fill rate | Found units, capped at requested units per line | Requested units on delivered order lines |
| Line availability rate | Delivered order lines with at least one unit found | Delivered order lines with positive requested quantity |

## Data contract

- `orders` has one row per order and includes `order_id`, `store_id`, `created_at`, and `status`.
- `order_items` has one row per requested product line and includes `order_id`, `quantity_requested`, and `quantity_found`.
- The cancellation query counts only delivered and canceled orders, so in-progress orders do not dilute the rate. Both `CANCELED` and `CANCELLED` spellings are accepted.
- The fill-rate query treats a null or negative `quantity_found` as zero, caps overfills in the numerator, and reports missing, negative, and overfilled lines separately. Review these counts as data-quality signals.
- The queries group by the order creation month. Add a fixed lower-inclusive and upper-exclusive date filter to compare complete, equivalent reporting periods.

## Interpretation

Unit fill weights each line by requested units. Line availability weights each line once. They answer different questions and can move in opposite directions. Compare stores only after checking reporting windows, order eligibility, item-line grain, and missing quantities.

Adapt status values and field names to an authorized source system before use. No source data ships with this repository.

## Entrega original (resumo sanitizado)

A submissão da época reuniu apresentações e um dashboard de BI. Este repositório reconstrói métricas operacionais com dados sintéticos; não reproduz os materiais, dados ou conclusões do processo seletivo.

## Exemplo sintético

`examples/setup.sql` cria tabelas temporárias e dados de janeiro de 2026. Na mesma sessão PostgreSQL, execute o setup e as consultas de `analysis.sql`.

| Loja fictícia | Cancelamento | Unit fill | Disponibilidade de linha |
|---|---:|---:|---:|
| Store A | 20% | 62,5% | 75% |
| Store B | 40% | 60% | 66,7% |

Os valores são sintéticos e não representam o case original. O exemplo inclui uma linha acima da quantidade solicitada e uma quantidade encontrada ausente para ilustrar os controles de qualidade.
