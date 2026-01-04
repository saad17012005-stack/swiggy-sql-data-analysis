SELECT*FROM swiggy_data23
SELECT
SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_State,
SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) null_City,
SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) null_Order_Date,
SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) null_Restaurant_Name,
SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) null_Location,
SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) null_Category,
SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) null_Dish_Name,
SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) null_Price_INR,
SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) null_Rating,
SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) null_Rating_Count
FROM swiggy_data23;

SELECT*FROM swiggy_data23
WHERE State='' OR City='' OR Restaurant_Name='' OR Location='' OR Category='' OR Dish_Name='';
SELECT State , City ,Order_Date, Restaurant_Name , Location , Category ,  Dish_Name , Price_INR , Rating , Rating_Count , count(*) as DUPLICATE
FROM swiggy_data23
GROUP BY 
State , City ,Order_Date, Restaurant_Name , Location , Category ,  Dish_Name , Price_INR , Rating , Rating_Count  Having  count(*)>1

WITH CTE AS (
SELECT*, ROW_NUMBER() OVER(
PARTITION BY State , City ,Order_Date, Restaurant_Name , Location , Category ,  Dish_Name , Price_INR , Rating , Rating_Count ORDER BY(SELECT NULL)
) AS ABC FROM swiggy_data23)
DELETE FROM CTE WHERE ABC>1

CREATE TABLE dim_date (
date_id INT IDENTITY(1,1) PRIMARY KEY ,
FULL_DATE DATE,
YEAR INT,
MONTH INT, 
Month_name varchar(20),
Quarter INT,
DAY INT,
WEEK INT
)
SELECT*FROM dim_date;

CREATE TABLE dim_location (
location_id INT IDENTITY(1,1) PRIMARY KEY,
State VARCHAR(100),
City Varchar(100),
Location VARCHAR(200)
);
select*from dim_location; 

CREATE TABLE dim_restaurant (
restaurant_id INT IDENTITY(1,1)  PRIMARY KEY,
Restaurant_Name VARCHAR(200)
);
SELECT*FROM dim_restaurant;

CREATE TABLE dim_category (
category_id INT IDENTITY(1,1)  PRIMARY KEY,
Category VARCHAR(200)
);
SELECT*FROM dim_category;


CREATE TABLE dim_dish (
dish_id INT IDENTITY(1,1)  PRIMARY KEY,
Dish_Name VARCHAR(200)
);
SELECT*FROM dim_dish;

SELECT*FROM swiggy_data23

CREATE TABLE fact_swiggy_orders (
order_id INT IDENTITY(1,1) PRIMARY KEY ,

date_id INT,
Price_INR DECIMAL(10,2),
Rating DECIMAL(4,2),
Rating_Count INT,

location_id INT,
restaurant_id INT,
category_id INT,
dish_id INT,

FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);
select*from fact_swiggy_orders

INSERT INTO dim_date(FULL_DATE , YEAR , MONTH , Month_Name , Quarter,DAY,WEEK)
SELECT DISTINCT
    Order_Date,
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH,Order_Date),
    DATEPART(QUARTER,Order_Date),
    DAY(Order_Date),
    DATEPART(WEEK, Order_Date)
    FROM swiggy_data23
    WHERE Order_Date IS NOT NULL;

    SELECT*FROM dim_date
    
    INSERT INTO dim_location(State,City,Location)
    SELECT DISTINCT
    State,
    City,
    Location
    FROM swiggy_data23

    INSERT INTO dim_restaurant (Restaurant_Name)
    SELECT DISTINCT
    Restaurant_Name
    FROM swiggy_data23

    INSERT INTO dim_category (Category)
    SELECT DISTINCT 
    Category
    FROM swiggy_data23

    INSERT INTO dim_dish (Dish_Name)
    SELECT DISTINCT
    Dish_Name
    FROM swiggy_data23



    INSERT INTO fact_swiggy_orders
    (
    date_id,
    Price_INR,
    Rating,
    Rating_Count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)
SELECT
    dd.date_id,
    s.Price_INR,
    s.Rating,
    s.Rating_Count,

    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
FROM swiggy_data23 as s

JOIN dim_date as dd
ON dd.FULL_DATE = s.Order_Date

JOIN dim_location as dl
ON dl.State = s.State
AND dl.City = s.City

JOIN dim_restaurant as dr
ON  dr.Restaurant_Name = s.Restaurant_Name

JOIN dim_category as dc
ON dc.Category = s.Category

JOIN dim_dish as dsh
ON dsh.Dish_Name = s.Dish_Name;
SELECT*FROM fact_swiggy_orders

SELECT*FROM fact_swiggy_orders f
JOIN dim_date as d ON f.date_id = d.date_id
JOIN dim_location as l ON f.location_id = l.location_id
JOIN dim_restaurant as r ON  f.restaurant_id = r.restaurant_id
JOIN dim_category as c ON f.category_id = c.category_id
JOIN dim_dish as di ON f.dish_id = di.dish_id;

SELECT COUNT(*) AS Total_Orders
FROM fact_swiggy_orders

SELECT
FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000, 'N2') + 'INR Million'  
AS Total_Revenue
FROM fact_swiggy_orders

SELECT
FORMAT(AVG(CONVERT(FLOAT,price_INR)), 'N2') + 'INR Million'  
AS Total_Revenue
FROM fact_swiggy_orders

SELECT
AVG(RATING) AS Avg_Rating
FROM fact_swiggy_orders

--DEEP DIVE BUSSINESS ANALYSIS
-- MONTHLY ORDER TRENDS
SELECT 
d.year,
d.month,
d.month_name,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders AS f
JOIN dim_date as d ON f.date_id = d.date_id
GROUP BY d.year,
d.month,
d.month_name
ORDER BY Count(*) DESC

--QUARTERLY TRENDS--
SELECT 
d.year,
d.quarter,
count(*) AS Total_Orders
FROM fact_swiggy_orders AS f
JOIN dim_date as d  ON f.date_id = d.date_id
GROUP BY d.year,
d.quarter
ORDER BY COUNT(*) DESC 

--YEARLY TREND 
SELECT
d.year,
count(*) as Total_Orders
FROM fact_swiggy_orders AS f
JOIN dim_date as d ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY count(*) DESC

--ORDER BY DAY OF WEEK (MON-SUN)
SELECT 
  DATENAME(WEEKDAY, d.full_date) AS day_name,
  COUNT(*) AS total_orders 
FROM fact_swiggy_orders as f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY DATENAME(WEEKDAY, d.full_date), DATEPART(WEEKDAY, d.full_date)
ORDER BY DATEPART(WEEKDAY, d.full_date);

-- TOP 10 CITIES BY VOLUME
SELECT TOP 10
l.city,
COUNT(*) AS Total_Orders FROM fact_swiggy_orders AS f
JOIN dim_location l
ON l.location_id = f.location_id
GROUP BY l.city
ORDER BY COUNT(*) ASC

--  REVENUE CONTRIBUTION BY STATE
SELECT 
l.State,
SUM(f.price_INR) AS Total_Orders FROM fact_swiggy_orders AS f
JOIN dim_location l
ON l.location_id = f.location_id
GROUP BY l.State
ORDER BY SUM(f.price_INR) DESC

-- TOP 10 RESTAURANT BY ORDERS
SELECT TOP 10
r.Restaurant_Name,
SUM(f.price_INR) AS Total_Revenue  FROM fact_swiggy_orders AS f
JOIN dim_restaurant r
ON r.restaurant_id = f.restaurant_id
GROUP BY r.Restaurant_Name
ORDER BY SUM(f.price_INR) DESC

-- TOP CATEGORIES BY ORDER VOLUME 
SELECT 
     c.category,
     COUNT(*) AS total_orders
FROM fact_swiggy_orders AS f
JOIN dim_category AS c ON f.category_id = c.category_id
GROUP BY c.category
ORDER BY total_orders DESC;

-- MOST ORDERED DISHES
SELECT TOP 10
     d.dish_name,
     COUNT(*) AS order_count
FROM fact_swiggy_orders AS f
JOIN dim_dish AS d ON f.dish_id = d.dish_id
GROUP BY d.Dish_Name
ORDER BY order_count  DESC;

-- CUISINE PERFORMANCE ( ORDERS + AVG RATING)
SELECT c.category,
count(*) as total_orders,
avg (f.rating) as avg_rating
from fact_swiggy_orders as f
join dim_category as c on f.category_id = c.category_id
group by c.Category
order by total_orders desc

-- TOTAL ORDERS BY PRICE RANGE
select 
case
    when convert(float,price_inr) <100 then 'under 100'
    when convert(float,price_inr) between 100 and 199 then '100 - 199'
    when convert(float,price_inr) between 200 and 299  then '200 - 299'
    when convert(float,price_inr) between 300 and 499 then '300 - 499'
    else '500+'
  end as price_range,
  count(*) as total_orders
from fact_swiggy_orders
group by 
      case 
          when convert(float,price_inr) <100 then 'under 100'
    when convert(float,price_inr) between 100 and 199 then '100 - 199'
    when convert(float,price_inr) between 200 and 299  then '200 - 299'
    when convert(float,price_inr) between 300 and 499 then '300 - 499'
    else '500+'
  end 
order by total_orders desc;
-- rating count distribution(1 - 5)
select 
      rating,
      count(*) as rating_count
from fact_swiggy_orders
group by rating
order by count(*) desc;

          
