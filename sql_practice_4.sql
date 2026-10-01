/*
### SQL Practice Questions 22–26

**22. Find the highest-selling product in each category**
Find the product that generated the highest total revenue within each category.

**23. Calculate running total sales**
For each order date, calculate the cumulative sales amount up to that date.

**24. Find customers with consecutive orders**
Identify customers who placed orders on more than one different date.

**25. Calculate category sales percentage**
For each category, calculate total sales and its percentage contribution to overall sales.

**26. Find the top 2 customers in each category**
For every category, identify the two customers who generated the highest total spending.

*/

# 22. Highest-selling product in each category
WITH product_sales AS (
    SELECT
        category,
        product,
        SUM(amount) AS total_revenue
    FROM orders
    GROUP BY category, product
),
ranked_products AS (
    SELECT
        category,
        product,
        total_revenue,
        RANK() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS product_rank
    FROM product_sales
)
SELECT
    category,
    product,
    total_revenue
FROM ranked_products
WHERE product_rank = 1
ORDER BY category;

# 23. Calculate running total sales

WITH daily_sales AS (
    SELECT
        order_date,
        SUM(amount) AS daily_sales
    FROM orders
    GROUP BY order_date
)
SELECT
    order_date,
    daily_sales,
    SUM(daily_sales) OVER (
        ORDER BY order_date
    ) AS running_total_sales
FROM daily_sales
ORDER BY order_date;

# 24. Find customers with multiple order dates
SELECT
    customer_name,
    COUNT(DISTINCT order_date) AS order_days
FROM orders
GROUP BY customer_name
HAVING COUNT(DISTINCT order_date) > 1
ORDER BY order_days DESC;

# 25. Calculate category sales percentage

WITH category_sales AS (
    SELECT
        category,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY category
)
SELECT
    category,
    total_sales,
    ROUND(
        total_sales * 100.0 /
        SUM(total_sales) OVER (),
        2
    ) AS sales_percentage
FROM category_sales
ORDER BY total_sales DESC;

# 26. Top 2 customers in each category

WITH customer_category_sales AS (
    SELECT
        category,
        customer_name,
        SUM(amount) AS total_spending
    FROM orders
    GROUP BY category, customer_name
),
ranked_customers AS (
    SELECT
        category,
        customer_name,
        total_spending,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_spending DESC
        ) AS customer_rank
    FROM customer_category_sales
)
SELECT
    category,
    customer_name,
    total_spending,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 2
ORDER BY category, customer_rank;