# 🛒 Brazilian E-Commerce Dataset SQL Analysis
This project involves analysis of a Brazilian E-commerce dataset using **POSTGRESQL**. The analysis includes data modeling, ETL design, query optimization, and insight extraction from key datasets such as customers, orders, payments, reviews, and more.

---

##  Dataset Overview

The project utilizes structured relational data from a Brazilian E-commerce platform.

### Core Tables:

- `customers_dataset`
- `geolocation_dataset`
- `order_items_dataset`
- `orders_dataset`
- `payments_dataset`
- `products_dataset`
- `reviews_dataset`
- `sellers_dataset`
- `product_translation`

---

##  Schema Design

###  Fact Tables

- **`order_items_dataset`**: Granular level transactional data (one row per item in an order).
- **`payments_dataset`**: Payment transaction records per order.


### 🔹 Dimension Tables

- **`orders_dataset`**: Order status and timeline data.
- **`customers_dataset`**: Information about each customer.
- **`products_dataset`**: Product characteristics and dimensions.
- **`sellers_dataset`**: Seller location and details.
- **`geolocation_dataset`**: Mapping of zip codes to geographical data.
- **`product_translation`**: English translations for product categories.
- **`reviews_dataset`**: Customer reviews for each order.
---

##  Constraints and Keys

### 🔹 Primary Keys

- `customer_id` in `customers_dataset`
- `order_id` in `orders_dataset`
- `product_id` in `products_dataset`
- `seller_id` in `sellers_dataset`
- Composite key: (`order_id`, `order_item_id`) in `order_items_dataset`

### 🔹 Foreign Keys

- `orders_dataset.customer_id` → `customers_dataset.customer_id`
- `order_items_dataset.order_id` → `orders_dataset.order_id`
- `order_items_dataset.product_id` → `products_dataset.product_id`
- `order_items_dataset.seller_id` → `sellers_dataset.seller_id`
- `orders_dataset.order_id` → `order_payment_summary.order_id`
- `orders_dataset.order_id` → `reviews_dataset.order_id`

---

## 📊 Analysis Summary

# Here are the key business questions and SQL queries implemented:


1. Total Orders

2. Check status of orders

3. Total Revenue of all orders and delivered orders

4. Total Revenue per order status and number of payment types

5. Total Unique Customers

6. Average Items per Order

7. Average Review Score

8. Average Delivery Time (in days)

9. Top 10 Cities by Number of Orders

10. Products Category by Quantity Sold

11. Top Sellers by Revenue

12. On-Time Delivery Rate using subquery and CTE

13. Return/Cancellation Rate

14. Top Selling Product by Month

## 📄 SQL Analysis Documentation

For a detailed overview of the SQL analysis, please refer to the [OLIST_SQL.pdf](https://github.com/sufrimo/OLIST-ECOMMERCE-SQL-ANALYSIS-/blob/main/OLIST_SQL.pdf).



