-- ============================================================
-- Pizza Hut Sales Analysis — Queries
-- ============================================================
-- Run schema/create_tables.sql and schema/load_data.sql first.
-- Queries progress from basic KPIs to advanced window functions.
-- ============================================================

USE pizza_hut;

-- 1. Total number of orders placed
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- 2. Total revenue generated from pizza sales
SELECT
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- 3. Highest-priced pizza
SELECT
    pizza_types.name,
    pizzas.price
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Most common pizza size ordered
SELECT
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 5. Top 5 most ordered pizza types by quantity
SELECT
    pizza_types.name,
    SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- 6. Total quantity ordered per pizza category
SELECT
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 7. Distribution of orders by hour of the day
SELECT
    HOUR(order_time) AS order_hour,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);

-- 8. Category-wise distribution of pizza types
SELECT
    category,
    COUNT(name) AS pizza_count
FROM pizza_types
GROUP BY category;

-- 9. Average number of pizzas ordered per day
SELECT
    ROUND(AVG(quantity), 0) AS avg_pizzas_per_day
FROM (
    SELECT
        orders.order_date,
        SUM(order_details.quantity) AS quantity
    FROM orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS order_quantity;

-- 10. Top 3 pizza types by revenue
SELECT
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- 11. Percentage contribution of each pizza category to total revenue
SELECT
    pizza_types.category,
    ROUND(
        SUM(order_details.quantity * pizzas.price) /
        (
            SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2)
            FROM order_details
            JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
        ) * 100,
    2) AS revenue_pct
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_pct DESC;

-- 12. Cumulative revenue generated over time
SELECT
    order_date,
    ROUND(SUM(revenue) OVER (ORDER BY order_date), 2) AS cumulative_revenue
FROM (
    SELECT
        orders.order_date,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS daily_sales;

-- 13. Top 3 pizza types by revenue, within each category
SELECT name, revenue
FROM (
    SELECT
        category,
        name,
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM (
        SELECT
            pizza_types.category,
            pizza_types.name,
            ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue
        FROM pizza_types
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS category_revenue
) AS ranked
WHERE rnk <= 3;
