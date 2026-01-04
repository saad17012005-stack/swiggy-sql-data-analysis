# Swiggy SQL Data Analysis Project

## 📌 Project Description
This project involves analyzing Swiggy food delivery data using SQL. The goal is to clean raw data, handle missing values, create dimension tables, and perform analytical queries to extract meaningful insights related to food categories, cities, states, and restaurants.

The project demonstrates practical SQL skills used in real-world data analysis and reporting.

---

## 🎯 Objectives
- Clean and preprocess raw Swiggy dataset
- Handle NULL values using SQL CASE statements
- Create dimension tables for better data organization
- Perform data analysis using GROUP BY, JOIN, and aggregate functions
- Generate category-wise and location-based insights

---

## 🛠️ Tools & Technologies
- Database: Microsoft SQL Server  
- Tool: SQL Server Management Studio (SSMS)  
- Language: SQL  
- Dataset Source: Kaggle  

---

## 🗂️ Database Tables

### Main Table
- `swiggy_data23`

### Dimension Tables
- `dim_category`
- `dim_city`
- `dim_state`

---

## 🔑 Key SQL Operations
- Data cleaning and NULL handling
- DISTINCT and GROUP BY analysis
- Aggregate functions (COUNT, SUM)
- Dimension table creation
- Business insight generation

---

## 📊 Sample Queries

```sql
-- Count total restaurants by category
SELECT Category, COUNT(*) AS Total_Restaurants
FROM swiggy_data23
GROUP BY Category
ORDER BY Total_Restaurants DESC;

-- Check NULL values in state column
SELECT 
SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS Null_State_Count
FROM swiggy_data23;
