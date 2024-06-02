-- Создаем таблицу покупаталей
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(255)
);

-- Создаем таблицу категорий товаров
CREATE TABLE IF NOT EXISTS product_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE
);

-- Создаем таблицу товаров
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    description TEXT,
    price NUMERIC (18, 2),
    stock INT,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES product_categories
    (category_id) ON DELETE CASCADE
);

-- Создаем таблицу заказов
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    shipping_address VARCHAR(255),
    order_status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Создаем таблицу детализации заказов
CREATE TABLE IF NOT EXISTS order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price NUMERIC(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- Заполняем покупателей
INSERT INTO customers (first_name, last_name, email, phone, address)
VALUES
('John', 'Doe', 'john.doe@example.com', '123-456-7890', '123 Elm St'),
('Jane', 'Doe', 'jane.doe@example.com', '987-654-3210', '456 Oak St'),
('Alice', 'Johnson', 'alice.johnson@example.com', '555-678-1234', '789 Pine St'),
('Bob', 'Smith', 'bob.smith@example.com', '555-123-4567', '789 Maple St'),
('Charlie', 'Brown', 'charlie.brown@example.com', '555-987-6543', '321 Chestnut St'),
('David', 'Jones', 'david.jones@example.com', '555-321-9876', '654 Willow St'),
('Eve', 'Taylor', 'eve.taylor@example.com', '555-654-3219', '987 Birch St'),
('Frank', 'Miller', 'frank.miller@example.com', '555-321-6540', '321 Ash St'),
('Grace', 'Davis', 'grace.davis@example.com', '555-654-3211', '654 Cedar St'),
('Helen', 'Wilson', 'helen.wilson@example.com', '555-321-6542', '987 Elm St');

-- Заполняем заказы
INSERT INTO orders (customer_id, order_date, shipping_address, order_status)
VALUES
(1, '2023-01-01', '123 Elm St', 'Shipped'),
(2, '2023-01-02', '456 Oak St', 'Pending'),
(3, '2023-01-03', '789 Pine St', 'Delivered'),
(4, '2023-01-04', '789 Maple St', 'Cancelled'),
(5, '2023-01-05', '321 Chestnut St', 'Shipped')
(2, '2023-01-01', '123 Elm St', 'Shipped'),
(2, '2023-01-02', '123 Elm St', 'Pending'),
(5, '2023-02-03', '789 Pine St', 'Delivered');

-- Заполняем категории товаров
INSERT INTO product_categories (category_name)
VALUES
('Phones'),
('Computers'),
('Audio'),
('Video'),
('Home appliances');

-- Заполняем товары
INSERT INTO products (product_name, description, price, stock, category_id)
VALUES
('Honor 20 Pro', ' При этом Honor 20 Lite для российского рынка — это, по всей видимости, то же самое, что и уже протестированная нами ранее модель Honor 10i.', '24850', 10, 1),
('Mac mini m2 24 GB', 'Модель оснащена восьмиядерным процессором и десятиядерным графическим процессором и до 24 ГБ ОЗУ с пропускной способностью 100 ГБ/с.', '138501', 5, 2),
('Realme Buds Аir 2', 'Buds Аir 2 поддерживают активное шумоподавление до 25 дБ и могут отфильтровывать большинство низкочастотных шумов, включая шум самолета, метро и тд.','4405', 15, 3),
('The projector LED YG-300', 'Мини-проектор LED YG-300 Это мультимедиа-плеер с собственным разрешением 320 х 240 px, который поддерживает воспроизведение Full Hd видео и обладает множеством интерфейсов для проигрывания различных файлов.', '2074', 20, 4),
('Indesit IWUC 4105', 'Выполненная в классическом белом корпусе и оснащенная интеллектуальной системой управления стиральная машина INDESIT IWUC 4105 станет для вас надежным подспорьем на долгие годы.', '16990', 10, 5);

-- Заполняет детализацию заказов
INSERT INTO order_details (order_id, product_id, quantity, unit_price)
VALUES
(1, 3, 3, 13215),
(2, 1, 2, 49700),
(3, 2, 1, 138501),
(4, 5, 1, 16990),
(5, 4, 1, 2074),
(6, 3, 3, 13215),
(7, 1, 2, 49700),
(8, 2, 1, 138501);

-- Функция для получения общей суммы продаж по категориям товаров за определенный период. На вход подается дата начала и конца периода. На выход должна выходить таблица с колонками: название категории, и общая сумма продаж.
CREATE FUNCTION get_sales_total(date_from date, date_to date)
RETURNS TABLE (
  name VARCHAR(100),
  total NUMERIC(10, 2)
)
AS $$
BEGIN
  RETURN QUERY
    SELECT prd_ctg.category_name, sum(dtl.unit_price) FROM orders ord
    LEFT JOIN order_details dtl ON ord.order_id = dtl.order_id
    LEFT JOIN products prd ON dtl.product_id = prd.product_id
    LEFT JOIN product_categories prd_ctg ON prd.category_id = prd_ctg.category_id
    WHERE ord.order_date > get_sales_total.date_from AND ord.order_date < get_sales_total.date_to
    GROUP BY prd_ctg.category_name;
END;
$$ LANGUAGE plpgsql;

-- Функция по получению количества товара по id заказа
CREATE FUNCTION get_product_new_count(order_id int)
RETURNS TABLE (
  product_id INT,
  stock INT
)
AS $$
BEGIN
  RETURN QUERY
    SELECT prd.product_id, (prd.stock - dtl.quantity) FROM order_details dtl
    LEFT JOIN products prd on dtl.product_id = prd.product_id
    WHERE dtl.order_id = get_product_new_count.order_id;
END;
$$ LANGUAGE plpgsql;

-- Процедура по обновлению количества товара по id заказа
CREATE OR REPLACE PROCEDURE update_products_count(
  order_id INT
)
AS $$
BEGIN
  UPDATE products
  SET stock = (SELECT stock FROM get_product_new_count(update_products_count.order_id))
  WHERE products.product_id = (SELECT product_id FROM get_product_new_count(update_products_count.order_id));

  IF NOT FOUND THEN
       RAISE EXCEPTION 'product_id not found';
  END IF;
END;
$$ LANGUAGE plpgsql;



-- Вызов функуции
SELECT * FROM get_sales_total('2023-01-01', '2023-01-04');

-- Вызов процедуры
CALL update_products_count(6);

-- Вызов процедуры с исключением
CALL update_products_count(20);


