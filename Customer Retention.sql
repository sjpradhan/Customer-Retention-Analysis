-- Data Exploration

-- Total Recoreds = 541909
select count(*)
from online_retailer;
-- Checking Null values for quantitative column or invalid data
-- 135080 customer_id is not available

select count(*)
from online_retailer
where customer_id is null;

select count(*)
from online_retailer
where unit_price is null or quantity is null;

-- 406829 customers have customer_id

create temp table cleaned_online_retailer AS
select *
from online_retailer
where customer_id is not null

-- Beginning Of Cohort Analysis
select * 
from cleaned_online_retailer
-- Unique Identifier (Customer_id)
-- Initial Start Date (First Invoice_date)
-- Renvenue Data (unit_price)

create temp table cohort as 
SELECT
    customer_id,
    MIN(invoice_date) AS first_purchase,
    make_date(EXTRACT(year FROM MIN(invoice_date))::int, 
			  EXTRACT(month FROM MIN(invoice_date))::int, 1) AS cohort_date
FROM
    cleaned_online_retailer
GROUP BY
    customer_id;
	
-- Cohort Table

create temp table cohort_retention as
SELECT xy.*,
       (year_diff * 12) + month_diff + 1 AS cohort_index
FROM (
    SELECT x.*,
           invoice_year - cohort_year AS year_diff,
           invoice_month - cohort_month AS month_diff
    FROM (
        SELECT cr.*,
               ch.cohort_date,
               EXTRACT(year FROM cr.invoice_date)::int AS invoice_year,
               EXTRACT(month FROM cr.invoice_date)::int AS invoice_month,
               EXTRACT(year FROM ch.cohort_date)::int AS cohort_year,
               EXTRACT(month FROM ch.cohort_date)::int AS cohort_month
        FROM cleaned_online_retailer cr
        LEFT JOIN cohort ch USING (customer_id)
    ) x
) xy;

-- Retention Index

create temp table cohort_pivot_table as
SELECT cohort_date,
       COUNT(DISTINCT CASE WHEN cohort_index = 1 THEN customer_id END) AS "1",
       COUNT(DISTINCT CASE WHEN cohort_index = 2 THEN customer_id END) AS "2",
	   COUNT(DISTINCT CASE WHEN cohort_index = 3 THEN customer_id END) AS "3",
       COUNT(DISTINCT CASE WHEN cohort_index = 4 THEN customer_id END) AS "4",
	   COUNT(DISTINCT CASE WHEN cohort_index = 5 THEN customer_id END) AS "5",
       COUNT(DISTINCT CASE WHEN cohort_index = 6 THEN customer_id END) AS "6",
	   COUNT(DISTINCT CASE WHEN cohort_index = 7 THEN customer_id END) AS "7",
       COUNT(DISTINCT CASE WHEN cohort_index = 8 THEN customer_id END) AS "8",
	   COUNT(DISTINCT CASE WHEN cohort_index = 9 THEN customer_id END) AS "9",
       COUNT(DISTINCT CASE WHEN cohort_index = 10 THEN customer_id END) AS "10",
	   COUNT(DISTINCT CASE WHEN cohort_index = 11 THEN customer_id END) AS "11",
       COUNT(DISTINCT CASE WHEN cohort_index = 12 THEN customer_id END) AS "12",
	   COUNT(DISTINCT CASE WHEN cohort_index = 13 THEN customer_id END) AS "13"
FROM cohort_retention
GROUP BY cohort_date;

-- Retention Rate

WITH TotalCounts AS 
(
    SELECT cohort_date,
           COUNT(DISTINCT customer_id) AS total_count
    FROM cohort_retention
    GROUP BY cohort_date
)
SELECT tc.cohort_date,
      concat( ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 1 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "1",
      concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 2 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "2",
	  concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 3 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "3",
      concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 4 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "4",
	  concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 5 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "5",
      concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 6
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "6",
	  concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 7
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "7",
      concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 8 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "8",
	  concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 9 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "9",
      concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 10 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "10",
	  concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 11 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "11",
      concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 12 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "12",
	  concat(ROUND(COUNT(DISTINCT CASE WHEN cohort_index = 13 
				   THEN customer_id END) * 100.0 / tc.total_count, 2),'%') AS "13"
FROM cohort_retention cr
JOIN TotalCounts tc ON cr.cohort_date = tc.cohort_date
GROUP BY tc.cohort_date, tc.total_count
ORDER BY tc.cohort_date;
