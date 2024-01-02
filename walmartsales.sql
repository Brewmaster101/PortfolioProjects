-- CREATING THE DATABASE AND IMPORTING DATA

create database if not exists walmartsales;

create table if not exists sales(
	invoice_id varchar(30) not null primary key,
    branch varchar(10) not null,
    city varchar(40) not null,
    customer_type varchar(30) not null,
    gender varchar(10) not null,
    product_line varchar(100) not null,
    unit_price decimal(10,2) not null,
    quantity int not null,
    tax float(6,4) not null,
    total decimal(10,2) not null,
    date date not null,
    time time not null,
    payment_method varchar(30) not null,
    cogs decimal(10,2) not null,
    gross_margin_percentage float(11,9) not null,
    gross_income decimal(10,2) not null,
    rating float(2,1) not null
    );
    
    
    
    
    
    -- FEATURE ENGINEERING 
    
    -- Adding the time of day column to the sales table 
    
    select time,
		(case
			when time between '00:00:00' and '12:00:00' then 'Morning'
            when time between '12:01:00' and '16:00:00' then 'Afternoon'
            else 'Evening'
            end
		) as time_of_day
	from sales;
    
-- Here I am adding the column itself to the sales table 

    
alter table sales 
add column time_of_day varchar(20);
    
    
    
    -- Uisng the update command lets me add the data into the time of day column
    
update sales
set time_of_day = (case
	when time between '00:00:00' and '12:00:00' then 'Morning'
	when time between '12:01:00' and '16:00:00' then 'Afternoon'
	else 'Evening'
	end); 
		
        

-- Now I will add day type to the sales table 

select date, dayname(date)
from sales;
        
        
alter table sales add column day_name varchar(15);


update sales
set day_name = dayname(date);

-- Now I will get the month name from the date data

select date, monthname(date)
from sales;

alter table sales add column month_name varchar(15);

update sales
set month_name = monthname(date);





-- General business questions

-- how many unique cities does the data have?

select distinct city
from sales;


-- In which city is each branch?

select distinct city, branch
from sales;
    
    
   
   
-- Product questions
   
-- How many unique product lines does the data have?

select distinct product_line
from sales; 


-- What is the most common payment method?

select payment_method, count(payment_method) as total_count
from sales
group by payment_method
order by total_count desc
limit 1; 


-- What is the most selling product line?

select product_line, sum(quantity) as quantity
from sales
group by product_line
order by quantity desc
limit 1;



-- What is the total revenue by month?

select month_name as month, sum(total) as total_revenue
from sales
group by month;


-- What month had the largest COGS?

select month_name as month, sum(cogs) as cogs
from sales
group by month
order by cogs desc
limit 1;




-- What product line had the largest revenue?

select product_line, sum(total) as total_revenue 
from sales
group by product_line
order by total_revenue desc
limit 1; 


-- What is the city with the largest revenue?

select branch, city, sum(total) as total_revenue
from sales
group by city, branch
order by total_revenue desc;


-- What product line had the largest VAT?

select product_line, avg(tax) as avg_tax
from sales
group by product_line
order by sum(tax) desc
limit 1;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;


-- Which branch sold more products than average product sold?

SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);



-- What is the most common product line by gender?

select product_line, gender, count(gender) as total_count
from sales
group by gender, product_line
order by total_count desc; 



-- What is the average rating of each product line?

select round(avg(rating), 2) as avg_rating, product_line
from sales
group by product_line
order by avg_rating desc;

    