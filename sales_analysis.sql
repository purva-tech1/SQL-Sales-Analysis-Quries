-- Retail Sales & Customer Analysis Queries

-- 1. Total revenue and total orders across all sales
SELECT 
    COUNT(order_id) AS total_orders,
    SUM(sales_amount) AS total_revenue,
    ROUND(AVG(sales_amount), 2) AS avg_order_value
FROM sales_data;

-- 2. Total sales by product category (highest to lowest)
SELECT 
    category,
    SUM(quantity) AS total_units_sold,
    SUM(sales_amount) AS category_revenue
FROM sales_data
GROUP BY category
ORDER BY category_revenue DESC;

-- 3. Categories generating more than 50,000 in revenue
SELECT 
    category,
    SUM(sales_amount) AS total_revenue
FROM sales_data
GROUP BY category
HAVING SUM(sales_amount) > 50000;

-- 4. Join customers and orders to find top 5 spending customers
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(s.order_id) AS order_count,
    SUM(s.sales_amount) AS total_spent
FROM customers c
INNER JOIN sales_data s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY total_spent DESC
LIMIT 5;

-- 5. Find customers who have not placed any orders yet
SELECT 
    c.customer_id,
    c.customer_name,
    c.city
FROM customers c
LEFT JOIN sales_data s ON c.customer_id = s.customer_id
WHERE s.order_id IS NULL;

-- 6. Products priced above the overall average product price
SELECT 
    product_name,
    category,
    price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

import pandas as pd

# 1. Load raw retail dataset
df = pd.read_csv("retail_sales_raw.csv")

# 2. Inspect dataset structure and missing values
print("Dataset Shape:", df.shape)
print("Missing Values:\n", df.isnull().sum())

# 3. Remove duplicate rows
df = df.drop_duplicates()

# 4. Handle missing values safely
df["sales_amount"] = df["sales_amount"].fillna(df["sales_amount"].median())
df["city"] = df["city"].fillna("Unknown")
df = df.dropna(subset=["order_id", "order_date"])

# 5. Standardize text formatting and date column
df["category"] = df["category"].str.strip().str.title()
df["order_date"] = pd.to_datetime(df["order_date"])

# 6. Summarize total revenue and average order value by category
category_summary = (
    df.groupby("category")["sales_amount"]
    .agg(total_revenue="sum", avg_order_value="mean", order_count="count")
    .reset_index()
    .sort_values(by="total_revenue", ascending=False)
)

print("\nCategory Performance Summary:\n", category_summary)

# 7. Export cleaned dataset
df.to_csv("retail_sales_cleaned.csv", index=False)
