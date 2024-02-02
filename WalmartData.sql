-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;


-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);


-- -----------------------------------------------------------------------------
-- -------------------------- Feature Enginerring ------------------------------

-- time_of_day

select 
	time,
    (case 
		when time between '00:00:00' and '12:00:00' then 'Morning'
        when time between '12:01:00' and '16:00:00' then 'Afternoon'
        else 'Evening'
	end) as time_of_day
from sales;

alter table sales add column time_of_day varchar(20);

update sales
set time_of_day = (case 
		when time between '00:00:00' and '12:00:00' then 'Morning'
        when time between '12:01:00' and '16:00:00' then 'Afternoon'
        else 'Evening'
	end
	);
    
-- day_name
select 
	date,
    dayname(date) as day_name
from sales;

alter table sales add column day_name varchar(10);

update sales
set day_name = (dayname(date));

-- month_name
select
	date,
    monthname(date) as month_name
from sales;

alter table sales add column month_name varchar(10);

update sales
set month_name = monthname(date);

-- -----------------------------------------------------------------------------



-- -------------------------Business Questions To Answer------------------------
-- ------------------------------Generic Question-------------------------------
-- 1. How many unique cities does the data have?
select
	count(distinct city) 
from sales;
	
-- 2. In which city is each branch?
select
	distinct city,
    branch
from sales;

-- ---------------------------------Product------------------------------------
-- How many unique product lines does the data have?
select
	count(distinct product_line)
from sales;

-- What is the most common payment method?
select
	payment_method,
    count(payment_method) as count
from sales
group by payment_method
order by count desc
limit 1;

-- What is the most selling product line?
select
	product_line,
    count(product_line) as count
from sales
group by product_line
order by count desc
limit 1;

-- What is the total revenue by month?
select
	month_name as month,
	sum(total) as total_revenue
from sales
group by month_name;

-- What month had the largest COGS?
select 
	month_name as month,
    sum(cogs) as COGS
from sales
group by month_name
order by COGS desc
limit 1;

-- What product line had the largest revenue?
select
	product_line,
    sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc
limit 1;

-- What is the city with the largest revenue?
select
	city,
    sum(total) as total_revenue
from sales
group by city
order by total_revenue desc
limit 1;

-- What product line had the largest VAT?
select 
	product_line,
    avg(vat) as avg_vat
from sales
group by product_line
order by avg_vat desc
limit 1;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
select 
	product_line,
    round(avg(total),2) as avg_sales,
    (case
		when avg(total) > (select avg(total) from sales) then 'Good'
        else 'Bad'
	end) as mark
from sales
group by product_line;

-- Which branch sold more products than average product sold?
select
	branch,
    sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- What is the most common product line by gender?
select
	gender,
    product_line,
    count(product_line) as qty
from sales
group by gender, product_line
order by qty desc;

-- What is the average rating of each product line?
select 
	product_line,
    round(avg(rating),2) as avg_rating
from sales
group by product_line;


-- -------------------------------Sales-------------------------------------
-- Number of sales made in each time of the day per weekday
select 
	day_name,
    time_of_day,
    count(quantity) as sales
from sales
group by day_name, time_of_day
order by sales;

-- Which of the customer types brings the most revenue?
select
	customer_type,
    sum(total) as total_revenue
from sales
group by customer_type
order by total_revenue desc;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
select
	city,
    avg(vat) as avg_vat
from sales
group by city
order by avg_vat desc;

-- Which customer type pays the most in VAT?
select
	customer_type,
    avg(vat) as avg_vat
from sales
group by customer_type
order by avg_vat desc;


-- ---------------------------------Sales-------------------------------------
-- How many unique customer types does the data have?
select
	count(distinct customer_type) as num_customer_type
from sales;

-- How many unique payment methods does the data have?
select
	count(distinct payment_method) as num_payment_method
from sales;

-- What is the most common customer type?
select
	customer_type,
	count(customer_type) as num_customer_type
from sales
group by customer_type
order by num_customer_type desc; 
	
-- Which customer type buys the most?
select 
	customer_type,
    count(*) as qty
from sales
group by customer_type
order by qty desc;

-- What is the gender of most of the customers?
select
	gender,
    count(*) as ct
from sales
group by gender
order by ct desc;
    
-- What is the gender distribution per branch?
select
	branch,
    gender,
    count(*) as ct
from sales
group by gender, branch
order by branch;

-- Which time of the day do customers give most ratings?
select 
	time_of_day,
    count(*) as ct
from sales
group by time_of_day
order by ct desc;

-- Which time of the day do customers give most ratings per branch?
select 
	time_of_day,
    branch,
    count(*) as ct
from sales
group by time_of_day, branch
order by ct desc;

-- Which day of the week has the best avg ratings?
select 
	day_name,
    avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc;

-- Which day of the week has the best average ratings per branch?
select 
	day_name,
    avg(rating) as avg_rating
from sales
where branch = 'A'
group by day_name
order by avg_rating desc;
