create database airport_db;
use airport_db;
Select * from airports2 limit 5;


## Problem Statement 1 : 

-- The objective is to calculate the total number of passengers for each pair of origin and destination airports.
Select 
	origin_airport ,
    Destination_airport,
    SUM(Passengers) as total_passengers
from
	airports2
group by 
	origin_airport,
    destination_airport
order by total_passengers desc;
-- This analysis will provide insights into travel patterns between specific airport pairs,
-- helping to identify the most frequented routes and enhance strategic planning for airline operations.


## Problem Statement 2 : 

-- Here the goal is to calculate the average seat utilization for each flight by dividing the  number of passengers by the total number of seats available.
Select 
	Origin_airport ,
    Destination_airport,
    avg(CAST(Passengers as FLOAT) / NULLIF(Seats, 0))*100 as average_seat_utilization
from
	airports2
group by 
	Origin_airport,
    Destination_airport
order by  average_seat_utilization desc;
-- The results will be sorted in descending order based on utilization percentage.
-- This analysis will help identify flights with the highest and lowest seat occupancy, 
-- providing valuable insights for optimizing flight capacity and enhancing operational efficiency.

## Problem Statement 3 :
 
-- The aim is to determine the top 5 origin and destination airport pairs that have the highest total passenger volume. 

Select 
	Origin_airport ,
    Destination_airport,
    SUM(Passengers) as total_passengers
from
	airports2
group by 
	Origin_airport,
    Destination_airport
order by  total_passengers desc
limit 3;

-- This analysis will reveal the most frequented travel routes, allowing airlines to optimize resource allocation 
-- and enhance service offerings based on passenger demand trends

## Problem Statement 4 :

-- The objective is to calculate the total number of flights and passengers departing from each origin city.
Select 
	Origin_city ,
    count(Flights) total_flights,
    SUM(Passengers)  total_passengers
from
	airports2
group by 
	origin_city
order by  total_passengers desc;

-- This analysis will provide insights into the activity levels at various origin cities, 
-- helping to identify key hubs and inform strategic decisions regarding flight operations and capacity management.


## Problem Statement 5 : 

-- The aim is to calculate the total distance flown by flights originating from each airport.

Select 
	Origin_airport,
    SUM(Distance) total_distance
from
	airports2
group by 
	Origin_airport
order by  total_distance desc;
-- This analysis will offer insights into the overall travel patterns and operational reach of each airport, 
-- helping to evaluate their significance in the network and inform future route planning decisions.


## Problem Statement 6 :

-- The objective is to group flights by month and year using the Fly_date column to calculate the number of flights,
-- total passengers, and average distance traveled per month.

Select 
    year(fly_date) as Year,
    month(fly_date) as Month,
    count(flights) total_flights,
    SUM(passengers) total_passengers,
    avg(distance) as avg_distance
from
	airports2
group by 
	Year, Month
order by  Year desc, Month desc;

-- This analysis will provide a clearer understanding of seasonal trends and operational performance over time, 
-- enabling better strategic planning for airline operations.


## Problem Statement 7 : 

-- The goal is to calculate the passenger-to-seats ratio for each origin and destination route
-- and filter the results to display only those routes where this ratio is less than 0.5.

Select 
	origin_airport ,
    Destination_airport,
    Sum(Passengers) total_passengers,
    Sum(Seats) total_seats,
    (Sum(Passengers)*1.0/ Nullif(Sum(Seats), 0)) Passengers_to_seats_ratio
from
	airports2
group by 
	origin_airport,
    destination_airport
having 
	Passengers_to_seats_ratio < 0.5
order by Passengers_to_seats_ratio;

-- This analysis will help identify underutilized routes, enabling airlines to make informed decisions about capacity management and potential route adjustments.

## Problem Statement 8 : 

-- The aim is to determine the top 3 origin airports with the highest frequency of flights. 

Select 
	Origin_airport,
    count(Flights) as total_flights
from
	airports2
group by 
	Origin_airport
order by  total_flights desc
Limit 3;

-- This analysis will highlight the most active airports in terms of flight operations, 
-- providing valuable insights for airlines and stakeholders to optimize scheduling and improve service offerings at these critical locations.


## Problem Statement 9 :
-- The objective is to identify the cities (excluding Bend, OR) that sends the most flights and passengers to Bend, OR.

Select 
	Origin_city,
    count(Flights) as total_flights,
    Sum(Passengers) as total_passengers
from
	airports2
where 
	destination_city = "Bend, OR" and 
    origin_city <> "Bend, OR"
group by 
	Origin_city

order by  total_flights desc
Limit 3;

-- This analysis will reveal key contributors to passenger traffic at Bend, OR, 
-- helping airlines and travel authorities understand demand patterns and enhance connectivity from popular originating cities.


## Problem Statement 10 : 
-- The aim is to identify the longest flight route in terms of distance traveled, including both the origin and destination airports.

Select 
	Origin_airport,
    Destination_airport,
    max(distance) long_distance
from
	airports2
group by 
	Origin_airport,
    destination_airport
order by  long_distance desc
Limit 1;

-- This analysis will provide insights into the most extensive travel connections,
-- helping airlines assess operational challenges and opportunities for long-haul service planning.

## Probleem Statement 11 : 

-- The objective is to determine the most and least busy months by flight count across multiple years. 
SELECT 
    YEAR(Fly_date) AS Year,
    MONTH(Fly_date) AS Month,
    COUNT(Flights) AS Total_Flights
FROM
    airports2
GROUP BY MONTH(Fly_date) , YEAR(Fly_date)
ORDER BY Total_Flights DESC;

-- To get both the most and least busy months as per the year, you can run the above query 

-- below query will give you the "Most Busy" & "Least Busy" Month at Once in result
with Monthly_flights as
(Select 
	month(Fly_date) as Month,
    count(flights) as Total_flights
from
	airports2
group by 
	month(Fly_date)
	) 
select 
		month,
        Total_flights,
        case
			when Total_flights = (select Max(Total_flights) from Monthly_flights) then 'MOST Busy'
            when Total_flights = (select Min(Total_flights) from Monthly_flights) then 'LEAST Busy'
            Else NULL
		End as status
from
	Monthly_flights
where 
	Total_flights = (select Max(Total_flights) from Monthly_flights) OR
    Total_flights = (select Min(Total_flights) from Monthly_flights);
    
    -- This analysis will provide insights into seasonal trends in air travel,
-- helping airlines and stakeholders understand peak and off-peak periods for better operational planning and resource allocation.

## Problem Statement 12 : 

-- The aim is to calculate the year-over-year percentage growth in the total number of passengers for each origin and destination airport pair.
With passenger_summary as
(select
	origin_airport,
    destination_airport,
    Year(fly_date) as Year,
    Sum(passengers) as total_passengers
from 
	airports2
group by 
	origin_airport,
    destination_airport,
    Year),
passenger_growth as
(select
	origin_airport,
    destination_airport,
    Year,
    total_passengers,
    Lag(total_passengers) over 
    (partition by origin_airport, destination_airport order by Year) as Previous_year_passenger
from
	passenger_summary)
select 
	origin_airport,
    destination_airport,
    Year,
	total_passengers,
    CASE
		WHEN Previous_year_passenger is not null then
        ((total_passengers - Previous_year_passenger)* 100.0 / nullif(Previous_year_passenger, 0))
        End as Growth_percentage

from 
	passenger_growth
order by
	origin_airport,
    destination_airport,
    Year;
    
-- This analysis will help identify trends in passenger traffic over time,
-- providing valuable insights for airlines to make informed decisions about route development 
-- and capacity management based on demand fluctuations.
    
## Problem Statement 13 : 

-- The objective is to identify routes (from origin to destination) that have demonstrated consistent year-over-year growth in the number of flights.
With Flight_summary as
(select
	origin_airport,
    destination_airport,
    Year(fly_date) as Year,
    Count(flights) as Total_flights
from 
	 airports2
group by 
	origin_airport,
    destination_airport,
    Year),
Flight_growth as
(select
	origin_airport,
    destination_airport,
	Year,
    Total_flights,
    lag(Total_flights) over (partition by origin_airport, destination_airport order by Year) as previous_year_flights
from 
	Flight_summary),
Growth_rate as (select
	origin_airport,
    destination_airport,
	Year,
    Total_flights,
    CASE
		WHEN previous_year_flights is not null AND previous_year_flights>0 then
        (Total_flights - previous_year_flights)*100.0/nullif(previous_year_flights,0)
        ELSE null
	END as Growth_Rate,
    CASE
		WHEN previous_year_flights is not null AND Total_flights>Previous_year_flights   then
        1
        ELSE 0
	END as Growth_indicator
from 
	flight_growth)
 select 
	origin_airport,
    destination_airport,
    Min(Growth_rate) as Minimum_growth_rate,
    Max(Growth_rate) as Maximum_growth_rate
 from 
	Growth_rate
where 
	Growth_indicator=1
group by
	origin_airport,
    destination_airport
having 
	Min(Growth_indicator)=1
order by
	origin_airport,
    destination_airport;
-- This analysis will help airlines understand which routes have not only grown consistently but also the magnitude of that growth in terms of percentage.
-- This analysis will highlight successful routes, providing insights for airlines to strengthen their operational strategies 
-- and consider potential expansions based on sustained demand trends.
    
## Problem Statement 14 :

 -- The aim is to determine the top 3 origin airports with the highest weighted passenger-to-seats utilization ratio, 
 -- sidering the total number of flights for weighting.
with utilization_ratio as (select 
	origin_airport,
    sum(passengers) total_passengers,
    sum(seats) total_seats,
    count(flights) total_flights,
    sum(passengers)*1.0 / sum(seats) passengers_seats_ratio
from 
	airports2
group by
	origin_airport),
    
Weighted_utilization as (select 
	origin_airport,
    total_passengers,
    total_seats,
    total_flights,
	passengers_seats_ratio,
    (passengers_seats_ratio * total_flights) / sum(total_flights) 
    over () as Weighted_utilization
from 
	utilization_ratio)
select 
	origin_airport,
    total_passengers,
    total_seats,
    total_flights,
    Weighted_utilization
from Weighted_utilization
order by Weighted_utilization desc
limit 3;

-- analysis will highlight the top 3 origin airports that not only have good passenger-to-seat ratios 
-- but also perform well when the total number of flights is considered. It gives a more balanced view of operational efficiency by considering both the ratio and flight volume.

## Problem Statement 15 : 

-- The objective is to identify the peak traffic month for each origin city based on the highest number of passengers, 
-- including any ties where multiple months have the same passenger count.
With Monthly_passenger_count as (select 
	Origin_city,
    sum(passengers) total_passengers,
    year(fly_date) Year,
	month(fly_date) Month

from airports2
group by origin_city, Year, Month),

Max_passengers_per_city as (select	
	origin_city,
    max(total_passengers) as peak_passengers
from
	 Monthly_passenger_count
group by origin_city)

select 
	mpc.origin_city,
    mpc.Year,
    mpc.Month,
    mpc.total_passengers
from 
	 Monthly_passenger_count mpc
join 
	Max_passengers_per_city mp
on mpc.origin_city = mp.origin_city and
	mpc.total_passengers = mp.peak_passengers
order by 
	mpc.origin_city,
    mpc.Year,
    mpc.Month;
    
-- This analysis will help reveal seasonal travel patterns specific to each city,
-- enabling airlines to tailor their services and marketing strategies to meet demand effectively.
    
## Problem Statement 16 : 

-- The aim is to identify the routes (origin-destination pairs) that have experienced the largest decline in passenger numbers year-over-year.
With Yearly_passenger_count as (select
	origin_airport,
    destination_airport,
    Year(fly_date) as Year,
    Sum(Passengers) as Total_passengers
from 
	airports2
group by 
	origin_airport,
    destination_airport,
    Year),
Yearly_decline as (select 
	y1.origin_airport,
    y1.destination_airport,
    y1.Year Year1,
    y1.total_passengers passengers_year1,
    y2.Year year2,
    y2.total_passengers passengers_year2,
    ((y2.total_passengers - y1.total_passengers) / Nullif(y1.total_passengers, 0))*100 percentage_change
from 
	Yearly_passenger_count y1
join 
	Yearly_passenger_count y2
on y1.origin_airport = y2.origin_airport 
and y1.destination_airport = y2.destination_airport 
and y1.Year = y2.year+1)

select 
	origin_airport,
    destination_airport,
    Year1,
    passengers_year1,
    year2,
	passengers_year2,
    percentage_change
from 
	Yearly_decline 
where percentage_change < 0 -- declining routes
order by percentage_change
limit 5;

-- This analysis will help airlines pinpoint routes facing reduced demand,
-- allowing for strategic adjustments in operations, marketing, and service offerings to address the decline effectively.

## Problem Statement 17 : 

-- The objective is to list all origin and destination airports that had at least 10 flights
-- but maintained an average seat utilization (passengers/seats) of less than 50%.
With Flights_stat as (Select 
	Origin_airport,
    destination_airport,
    sum(passengers) total_passengers,
    count(flights) total_flights,
    sum(seats) total_seats,
    (sum(passengers)/Nullif(sum(seats),0)) avg_seat_utilization
from 
	airports2
group by 
	Origin_airport,
    destination_airport)

select 
	Origin_airport,
    destination_airport,
    total_passengers,
    total_flights,
    total_seats,
    round((avg_seat_utilization * 100), 2) avg_seat_utilization_percentage
from 
	Flights_stat
where 
	total_flights >= 10 and 
   round((avg_seat_utilization * 100), 2) < 50
order by 
	avg_seat_utilization_percentage;
    
-- This analysis will highlight underperforming routes, allowing airlines to reassess their capacity management strategies
-- and make informed decisions regarding potential service adjustments to optimize seat utilization and improve profitability
    
    
## Problem Statement 18 : 

-- The aim is to calculate the average flight distance for each unique city-to-city pair (origin and destination) 
-- and identify the routes with the longest average distance.
With Distance_stats as (select
	Origin_city, 
    destination_city,
    avg(distance) avg_flight_distance
from 
	airports2
group by
	Origin_city, 
    destination_city)
    
select 
	Origin_city, 
    destination_city,
    round(avg_flight_distance,2) avg_flight_distance
from
	Distance_stats
order by
	avg_flight_distance desc;
    
-- This analysis will provide insights into long-haul travel patterns,
-- helping airlines assess operational considerations
-- and potential market opportunities for extended routes.
    
## Problem Statement 19 : 

-- The objective is to calculate the total number of flights and passengers for each year, 
-- along with the percentage growth in both flights and passengers compared to the previous year.
With Year_stats as (select
	year(fly_date) Year,
    sum(passengers) total_passengers,
    Count(flights) total_flights
from
	airports2
group by
	Year),

Yearly_growth as (select 
	Year,
    total_flights,
    total_passengers,
    lag(total_flights) over (order by Year) as Prev_flights,
    lag(total_passengers) over (order by Year) as Prev_passengers
from
	Year_stats)
select 
	Year,
    total_flights,
    total_passengers,
    round(((total_passengers - Prev_passengers) / Nullif(Prev_passengers, 0) * 100),2) passenger_growth_percentage,
    round(((total_flights - Prev_flights) / Nullif(Prev_flights, 0) * 100),2) flight_growth_percentage
from 
	Yearly_growth
order by Year;

-- This analysis will provide a comprehensive overview of annual trends in air travel,
-- enabling airlines and stakeholders to assess growth patterns and 
-- make informed strategic decisions for future operations.
    
## Problem Statement 20 : 

-- The aim is to identify the top 3 busiest routes (origin-destination pairs) based on the total distance flown,
--  weighted by the number of flights.
With Distance_summary as (select
	origin_airport,
    destination_airport,
    sum(distance) total_distance,
    sum(flights) total_flights
from
	airports2
group by 
	origin_airport,
    destination_airport),
Weighted_summary as (select 
	origin_airport,
    destination_airport,
    total_distance,
    total_flights,
    (total_flights * total_distance) as Weighted_distance
from 
	Distance_summary)
select 
	origin_airport,
    destination_airport,
    total_distance,
    total_flights,
    Weighted_distance
from 
	Weighted_summary
order by 
	Weighted_distance desc
limit 3;

-- This analysis will highlight the most significant routes in terms of distance and operational activity, 
-- providing valuable insights for airlines to optimize their scheduling and resource allocation strategies.