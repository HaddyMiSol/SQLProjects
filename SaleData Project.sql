---Opening Sales_Data
SELECT * FROM Sales_Data..sales_data_sample 

select distinct status FROM Sales_Data..sales_data_sample
select distinct year_id FROM Sales_Data..sales_data_sample
select distinct productline FROM Sales_Data..sales_data_sample
select distinct country FROM Sales_Data..sales_data_sample
select distinct dealsize FROM Sales_Data..sales_data_sample
select distinct territory FROM Sales_Data..sales_data_sample


---ANALYSIS
---Grouping sales by productline

select PRODUCTLINE, sum(sales) Revenue
from Sales_Data..sales_data_sample
group by PRODUCTLINE
order by 2 desc

--Grouping sales by year_id
select year_id, sum(sales) Revenue
from Sales_Data..sales_data_sample
group by year_id
order by 2 desc

---Investigating the low Revenue in 2005
select distinct month_id from Sales_Data..sales_data_sample
where year_id= 2005
---The revenue in 2005 is low because they only operated for 5 months in the year 2005


---what was the best month for sales in a specific year? How much was earned that month?
select month_id, sum(sales) Revenue  --, count(ORDERNUMBER) Frequency
from Sales_Data..sales_data_sample
where year_id= 2004
group by month_id
order by 2 desc
---observation; the highest sales were made in the 11th month in the year 2003 and 2004.

--November seems to be the month with highest sales, what product do they sell in November, Classic cars I believe
select month_id, productline, sum(sales) Revenue  --, count(ORDERNUMBER) Frequency
from Sales_Data..sales_data_sample
where year_id= 2004 and month_id= 11
group by month_id, productline
order by 3 desc

--What city has the highest number of sales in a specific country
select city, productline, sum(sales) Revenue  --, count(ORDERNUMBER) Frequency
from Sales_Data..sales_data_sample
where year_id= 2004
group by city, productline
order by 3 desc


---What is the best product in United States?
select country,year_id,  productline, sum(sales) Revenue  --, count(ORDERNUMBER) Frequency
from Sales_Data..sales_data_sample
where country= 'USA'
group by country,year_id,  productline
order by 4 desc


---what is the most expensive product
select productline, max(priceeach) Most_Expensive_Product  --, count(ORDERNUMBER) Frequency
from Sales_Data..sales_data_sample
group by productline
order by 2 desc


----Who is our best customer (this could be best answered with RFM)
DROP TABLE IF EXISTS #rfm
;with rfm as 
(
	select 
		CUSTOMERNAME, 
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from Sales_Data..sales_data_sample) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from Sales_Data..sales_data_sample)) Recency
	from Sales_Data..sales_data_sample
	group by CUSTOMERNAME
),
rfm_calc as
(

	select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar)rfm_cell_string
into #rfm
from rfm_calc c
select * from #rfm

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm

--What products are most often sold together? 
--select * from Sales_Data..sales_data_sample where ORDERNUMBER =  10411
select distinct OrderNumber, stuff(

	(select ',' + PRODUCTCODE
	from Sales_Data..sales_data_sample p
	where ORDERNUMBER in 
		(

			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) rn
				FROM Sales_Data..sales_data_sample
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

from Sales_Data..sales_data_sample s
order by 2 desc


