CREATE DATABASE informatika_rk_4;

CREATE TABLE products (
id SERIAL PRIMARY KEY,
name VARCHAR(50),
quantity INT);

CREATE TABLE operations_log (
id SERIAL PRIMARY KEY,
product_id INT REFERENCES products(id),
operation VARCHAR(10) CHECK (operation IN ('ADD', 'REMOVE')),
quantity INT);

CREATE OR REPLACE PROCEDURE update_stock(
product_id INT,
operation VARCHAR,
add_quantity INT
)
LANGUAGE plpgsql
AS $$
BEGIN
IF operation = 'ADD' THEN
UPDATE products
SET quantity = add_quantity + quantity
WHERE id = product_id;

ELSIF operation = 'REMOVE' THEN
IF (SELECT quantity FROM products WHERE id = product_id) >= add_quantity THEN
UPDATE products
SET quantity = quantity - add_quantity
WHERE id = product_id;
ELSE
RAISE EXCEPTION 'Количество товаров на складе меньше указанного числа';
END IF;

ELSE
RAISE EXCEPTION 'Доступны только операции "ADD" и "REMOVE"';
END IF;

INSERT INTO operations_log (product_id, operation, quantity)
VALUES (product_id, operation, add_quantity);
END;
$$;

INSERT INTO products (name, quantity)
VALUES
('Конфеты', 100),
('Шоколад', 50);


CALL update_stock(1, 'ADD', 50);
CALL update_stock(2,'REMOVE', 10);

SELECT * FROM products;
SELECT * FROM operations_log;
