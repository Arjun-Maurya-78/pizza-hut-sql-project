# 🍕 Pizza Hut Sales Analysis (SQL Project)

An end-to-end SQL analysis of a full year of Pizza Hut order data using **MySQL**. This project covers database design, data loading, and 13 progressively advanced queries — from basic KPIs to window functions — to uncover business insights around revenue, product performance, and customer ordering behavior.

## 📊 Dataset

- **Source:** Public Pizza Place sales dataset (Maven Analytics)
- **Period covered:** Jan 1, 2015 – Dec 31, 2015
- **Scale:** 21,350 orders · 48,620 order line items · 32 pizza types · 91 pizza size variants
- **Tables:** `orders`, `order_details`, `pizzas`, `pizza_types`

### Entity Relationship Diagram

![ER Diagram](er_diagram.svg))

- `pizza_types` → `pizzas` (one type has multiple sizes, each with its own price)
- `pizzas` → `order_details` (each line item references one pizza/size)
- `orders` → `order_details` (each order can contain multiple line items)

## 🛠️ Tech Stack

- **Database:** MySQL 8+
- **Tools:** MySQL Workbench / CLI

## 📁 Project Structure

```
pizza-hut-sql-project/
├── README.md
├── schema/
│   ├── create_tables.sql     # database + table definitions
│   └── load_data.sql         # LOAD DATA statements for the CSVs
├── queries/
│   └── pizza_sales_analysis.sql   # all 13 analysis queries
├── data/
│   ├── orders.csv
│   ├── order_details.csv
│   ├── pizzas.csv
│   └── pizza_types.csv
└── docs/
    └── er_diagram.svg
```

## 🔍 Key Insights

| Metric | Result |
|---|---|
| Total orders | **21,350** |
| Total revenue | **$817,860.05** |
| Highest-priced pizza | The Greek Pizza — **$35.95** |
| Most common size ordered | **Large (L)** — 18,526 line items |
| Top pizza by quantity sold | The Classic Deluxe Pizza — 2,453 units |
| Top pizza by revenue | The Thai Chicken Pizza — $43,434.25 |


**Takeaways:**
- Revenue is fairly evenly split across all four pizza categories (~24–27% each), suggesting a well-balanced, diversified menu rather than reliance on one category.
- `L` size is the most popular by far, followed by `M` and `S` — `XL`/`XXL` are niche (under 3% of orders combined), which could inform inventory and pricing decisions.
- Interestingly, the **top-selling pizza by quantity** (Classic Deluxe) is *not* the top earner by revenue — that title goes to Thai Chicken, a pricier specialty pizza. This kind of gap is exactly what a quantity-vs-revenue comparison is meant to catch.

## 📝 Example Queries

A sample of the analysis, ranging from simple joins to advanced window functions — full set of 13 queries is in [`queries/pizza_sales_analysis.sql`](pizza_sales_analysis.sql).

### 1. Top 5 best-selling pizzas by quantity
```sql
SELECT
    pizza_types.name,
    SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;
```

### 2. Revenue contribution of each category (%)
Uses a correlated subquery to express each category's revenue as a share of total revenue.
```sql
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
```

### 3. Cumulative revenue over time (running total)
Uses a window function to track how revenue accumulates day by day across the year.
```sql
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
```

### 4. Top 3 pizzas by revenue — within each category
Uses `RANK() OVER (PARTITION BY ...)` to find category leaders instead of just overall leaders.
```sql
SELECT name, revenue
FROM (
    SELECT
        category, name, revenue,
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
```

### 5. Order distribution by hour of day
Useful for staffing decisions — reveals peak lunch/dinner rush hours.
```sql
SELECT
    HOUR(order_time) AS order_hour,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time)
ORDER BY order_hour;
```

## 📌 What This Project Demonstrates

- Relational schema design with primary/foreign keys
- Multi-table `JOIN`s across 3–4 tables
- Aggregate functions (`SUM`, `COUNT`, `AVG`) with `GROUP BY`
- Subqueries and derived tables
- Window functions (`RANK() OVER (PARTITION BY ...)`, running totals with `SUM() OVER`)
- Translating business questions into SQL and business insights back out

## 🤝 Connect With Me

If you found this project useful, please consider giving it a ⭐

[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/arjun-maurya78)
[![Gmail](https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:youremail@gmail.com)


> 💬 Open to feedback, collaboration, and data analytics discussions!
