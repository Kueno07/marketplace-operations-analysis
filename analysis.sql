-- PostgreSQL reference queries. Use a fixed, closed reporting period.
-- orders: one row per order. order_items: one row per requested product line.

-- Cancellation rate for terminal orders by store and order month.
WITH terminal_orders AS (
    SELECT
        order_id,
        store_id,
        date_trunc('month', created_at)::date AS order_month,
        upper(trim(status)) AS normalized_status
    FROM orders
    WHERE upper(trim(status)) IN ('DELIVERED', 'CANCELED', 'CANCELLED')
)
SELECT
    store_id,
    order_month,
    COUNT(*) AS terminal_orders,
    COUNT(*) FILTER (
        WHERE normalized_status IN ('CANCELED', 'CANCELLED')
    ) AS canceled_orders,
    COUNT(*) FILTER (
        WHERE normalized_status IN ('CANCELED', 'CANCELLED')
    )::numeric / NULLIF(COUNT(*), 0) AS cancellation_rate
FROM terminal_orders
GROUP BY store_id, order_month
ORDER BY order_month, cancellation_rate DESC NULLS LAST;

-- Unit fill and line availability use delivered orders and positive requested quantities.
-- Null found quantity is treated as zero. Overfills are capped in the fill-rate numerator
-- and counted separately so data-quality issues remain visible.
WITH delivered_lines AS (
    SELECT
        o.store_id,
        date_trunc('month', o.created_at)::date AS order_month,
        i.quantity_requested::numeric AS quantity_requested,
        i.quantity_found::numeric AS quantity_found
    FROM orders AS o
    JOIN order_items AS i
        ON i.order_id = o.order_id
    WHERE upper(trim(o.status)) = 'DELIVERED'
      AND i.quantity_requested > 0
)
SELECT
    store_id,
    order_month,
    SUM(LEAST(GREATEST(COALESCE(quantity_found, 0), 0), quantity_requested))
        / NULLIF(SUM(quantity_requested), 0) AS unit_fill_rate,
    COUNT(*) FILTER (
        WHERE COALESCE(quantity_found, 0) > quantity_requested
    ) AS overfilled_lines,
    COUNT(*) FILTER (WHERE quantity_found IS NULL) AS missing_found_quantity_lines,
    COUNT(*) FILTER (WHERE quantity_found < 0) AS negative_found_quantity_lines,
    COUNT(*) FILTER (
        WHERE COALESCE(quantity_found, 0) > 0
    )::numeric / NULLIF(COUNT(*), 0) AS line_availability_rate,
    COUNT(*) AS requested_lines,
    SUM(quantity_requested) AS requested_units,
    SUM(LEAST(GREATEST(COALESCE(quantity_found, 0), 0), quantity_requested)) AS found_units
FROM delivered_lines
GROUP BY store_id, order_month
ORDER BY order_month, store_id;
