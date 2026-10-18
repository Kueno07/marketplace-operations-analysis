# Marketplace Operations Metrics

A sanitized SQL reference for marketplace operations. It separates order cancellation, unit fill rate, and product-line availability so each metric has an explicit numerator and denominator.

## Data contract

`orders` has one row per order with `order_id`, `store_id`, and `status`. `order_items` has one row per order and requested product with `order_id`, `quantity`, and `quantity_found`. Adapt names and statuses to the source system.

The sample uses PostgreSQL syntax. It contains no company names, source prompt, dashboard, or case data. A unit fill rate and a line availability rate answer different questions; choose the one the business definition requires.
