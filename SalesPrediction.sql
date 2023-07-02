CREATE SCHEMA `SalesPrediction` ;

use SalesPrediction;

-- The data was imported to the table, "walmart_sales_data", using Table Data Import Wizard. 

show tables;

select * from walmart_sales_data;

select count(*) as count
from walmart_sales_data;

select Store, count(*) as value_count
from walmart_sales_data
group by Store;

-- There are 143 records for each store (n=46)


-- Total Sales for each 
create view weekly_sales_view as
select Store, week(Date) as week, sum(Weekly_Sales) as total_weekly_sales
from walmart_sales_data
group by Store, week(Date);


select * from weekly_sales_view;


-- Finding Averages of store parameters
create view economic_data_view as
select Store, week(Date) as week, round(avg(CPI), 2) as avg_cpi, round(avg(Unemployment), 2) as avg_unemployment_rate, round(avg(Fuel_Price), 2) as avg_fuel_price
from walmart_sales_data 
group by Store, week(Date);

select * from economic_data_view;

-- Finding the moving average for the Sequential Data
select Store, Date, Weekly_Sales,
	avg(Weekly_Sales) over (partition by Store order by Date rows between 2 preceding and current row) as Moving_Average
from walmart_sales_data
order by Store, Date;    

-- Identifying peaks in the Sequential Data
select Store, Date, Weekly_Sales
from (
	select Store, Date, Weekly_Sales,
		lag(Weekly_Sales) over (partition by Store order by Date) as Previous_Sales,
        lead(Weekly_Sales) over (partition by Store order by Date) as Next_Sales
	from walmart_sales_data
) as subquery
where Weekly_Sales > Previous_Sales and Weekly_Sales > Next_Sales
order by Store, Date;


-- Ranking Weekly Store Perfromances
select Store, Date, Weekly_Sales,
	rank() over (partition by Store order by Weekly_Sales desc) as Sales_Rank
from walmart_sales_data;

-- Selecting Weekly Performance Rank for Stores
select Store, Date, Weekly_Sales, Sales_Rank
from(
	select Store, Date, Weekly_Sales,
		rank() over (partition by Store order by Weekly_Sales desc) as Sales_Rank
	from walmart_sales_data
) as subquery
where Sales_Rank = 1;    





