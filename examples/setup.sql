CREATE TEMP TABLE orders (
    order_id text PRIMARY KEY,
    store_id text NOT NULL,
    created_at timestamptz NOT NULL,
    status text NOT NULL
);

CREATE TEMP TABLE order_items (
    order_id text NOT NULL,
    line_id integer NOT NULL,
    quantity_requested numeric NOT NULL,
    quantity_found numeric,
    PRIMARY KEY (order_id, line_id)
);

INSERT INTO orders VALUES
('A1', 'Store A', '2026-01-05 12:00:00+00', 'DELIVERED'),
('A2', 'Store A', '2026-01-06 12:00:00+00', 'DELIVERED'),
('A3', 'Store A', '2026-01-07 12:00:00+00', 'DELIVERED'),
('A4', 'Store A', '2026-01-08 12:00:00+00', 'DELIVERED'),
('A5', 'Store A', '2026-01-09 12:00:00+00', 'CANCELED'),
('B1', 'Store B', '2026-01-05 12:00:00+00', 'DELIVERED'),
('B2', 'Store B', '2026-01-06 12:00:00+00', 'DELIVERED'),
('B3', 'Store B', '2026-01-07 12:00:00+00', 'DELIVERED'),
('B4', 'Store B', '2026-01-08 12:00:00+00', 'CANCELLED'),
('B5', 'Store B', '2026-01-09 12:00:00+00', 'CANCELED');

INSERT INTO order_items VALUES
('A1', 1, 20, 18), ('A1', 2, 10, 0),
('A2', 1, 1, 1), ('A2', 2, 1, 2),
('B1', 1, 5, 3), ('B1', 2, 3, 3), ('B2', 1, 2, NULL);
