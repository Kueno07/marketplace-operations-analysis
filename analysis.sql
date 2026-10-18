-- Cancellation rate: canceled orders divided by all orders, by store.
SELECT
    store_id,
    COUNT(*) AS order_count,
    COUNT(*) FILTER (WHERE UPPER(status) = 'CANCELED') AS canceled_orders,
    COUNT(*) FILTER (WHERE UPPER(status) = 'CANCELED')::numeric
        / NULLIF(COUNT(*), 0) AS cancellation_rate
FROM orders
GROUP BY store_id
ORDER BY cancellation_rate DESC NULLS LAST;

-- Unit fill rate: found units divided by requested units, by store.
-- LEAST caps found quantity at the amount requested for each line.
SELECT
    o.store_id,
    SUM(LEAST(COALESCE(i.quantity_found, 0), i.quantity))::numeric
        / NULLIF(SUM(i.quantity), 0) AS unit_fill_rate,
    SUM(i.quantity) AS requested_units,
    SUM(LEAST(COALESCE(i.quantity_found, 0), i.quantity)) AS found_units
FROM orders AS o
JOIN order_items AS i
    ON i.order_id = o.order_id
WHERE UPPER(o.status) = 'DELIVERED'
GROUP BY o.store_id
ORDER BY o.store_id;

-- Product-line availability: delivered order-item lines with any units found.
SELECT
    o.store_id,
    COUNT(*) FILTER (WHERE COALESCE(i.quantity_found, 0) > 0)::numeric
        / NULLIF(COUNT(*), 0) AS line_availability_rate,
    COUNT(*) AS requested_lines,
    COUNT(*) FILTER (WHERE COALESCE(i.quantity_found, 0) > 0) AS lines_with_any_units
FROM orders AS o
JOIN order_items AS i
    ON i.order_id = o.order_id
WHERE UPPER(o.status) = 'DELIVERED'
GROUP BY o.store_id
ORDER BY o.store_id;
