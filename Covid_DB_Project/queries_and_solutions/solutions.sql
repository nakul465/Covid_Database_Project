-- Joins
-- UC1 :
-- Which country has the highest number of confirmed cases on a specific date?

SELECT
    c.name AS country,
    g.confirmed AS total_confirmed_cases
FROM global_covid_stats g
JOIN country c
    ON g.country_id = c.country_id
WHERE g.report_date = '2021-03-31'
ORDER BY g.confirmed DESC
LIMIT 1;

-- UC2 : 
-- Show the total number of deaths in each country, including provinces/states, for a given date.

SELECT c.name,s.name,SUM(cs.deaths)
FROM country as c
JOIN covid_case_stats as cs
	on c.country_id=cs.country_id
JOIN state as s
	on cs.state_id=s.state_id
WHERE cs.report_date='2021-03-31'
GROUP BY c.name,s.name
ORDER BY SUM(cs.deaths) DESC;

-- UC3 :
-- List the continents along with the total number of confirmed cases, deaths, and recoveries.

SELECT c.continent,SUM(gc.confirmed),SUM(gc.deaths),SUM(gc.recovered)
FROM country c
JOIN global_covid_stats gc
    on c.country_id=gc.country_id
GROUP BY c.continent;

-- UC4 :
-- Calculate the average number of new deaths per day across all countries.

SELECT gc.report_date,ROUND(AVG(gc.new_deaths),2)
FROM country c
JOIN global_covid_stats gc
    on c.country_id=gc.country_id
GROUP BY gc.report_date;

-- UC5 :
-- Find the maximum number of active cases recorded in any country on a specific date.

SELECT c.name , gc.report_date , gc.active_cases
FROM country c 
JOIN global_covid_stats gc
    on c.country_id=gc.country_id
WHERE gc.report_date='2020-09-30'
ORDER BY gc.active_cases DESC
LIMIT 1;

-- Stored Procedure:
-- UC6 :
-- Create a stored procedure that returns the total number of recovered cases for a given country and date.

CREATE PROCEDURE recovered_cases(
    INOUT p_date date,
    INOUT p_name text,
	OUT p_recovered INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    SELECT gc.recovered INTO p_recovered
    FROM country as c
    JOIN global_covid_stats as gc
        ON c.country_id=gc.country_id
    WHERE gc.report_date=p_date AND c.name=p_name;

END;
$$

-- UC7 :
-- Design a stored procedure to update the number of deaths for a specific country and date.

CREATE PROCEDURE recovered_cases(
    IN p_date date,
    IN p_country_id INT,
	IN p_updated_deaths INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE global_covid_stats 
    SET deaths=p_updated_deaths
    WHERE country_id=p_country_id AND report_date=p_date;

END;
$$

-- Views:

-- UC8 :
-- Create a view that displays the total number of cases (confirmed, deaths, and recovered) for each country on a specific date.

CREATE VIEW total_cases_view AS
SELECT c.name , gc.confirmed,gc.deaths,gc.recovered
FROM country c
JOIN global_covid_stats gc
    ON c.country_id=gc.country_id
WHERE gc.report_date='2020-09-30';

-- UC9 :
-- Implement a view to show the latest data (confirmed, deaths, recovered) for each country.

CREATE VIEW latest_data_view AS
SELECT c.name , gc.confirmed,gc.deaths,gc.recovered
FROM country c
JOIN global_covid_stats gc
    ON c.country_id=gc.country_id
WHERE gc.report_date =
(
SELECT MAX(report_date) 
FROM global_covid_stats
)

-- CTE (Common Table Expressions):

-- UC12 :
-- Create a CTE to calculate the percentage increase in confirmed cases for each country over the past week.
-- as the difference between the date in data was not in gaps of a week i took 2 dates that existed in data

WITH Initial_Dates as(
    SELECT c.name as cont_name,gc.confirmed as confirmed_cases
    FROM country as c
    JOIN global_covid_stats as gc
        ON gc.country_id = c.country_id
    WHERE gc.report_date='2020-06-30'
),
Final_Dates as(
    SELECT c.name as cont_name,gc.confirmed as confirmed_cases
    FROM country as c
    JOIN global_covid_stats as gc
        ON gc.country_id = c.country_id
    WHERE gc.report_date='2020-09-30'
)
SELECT 
    Initial_Dates.cont_name,
    (Final_Dates.confirmed_cases-Initial_Dates.confirmed_cases)*100/Initial_Dates.confirmed_cases
    FROM Initial_Dates
    JOIN Final_Dates
        ON Initial_Dates.cont_name=Final_Dates.cont_name;

-- UC13 :
-- Use a CTE to find the country with the highest number of active cases at the moment.

WITH active AS (
    SELECT 
    c.name AS cont_name,
    gc.active_cases as ac,
    gc.report_date as rp
    FROM country AS c
    JOIN global_covid_stats as gc
        on c.country_id=gc.country_id
)
select cont_name,MAX(ac) from active
order by ac desc limit 1; 

-- Indexes

-- UC14 :
-- Explain the importance of indexes in optimizing queries for this dataset.

-- Indexes improve query performance by allowing the database to locate required records 
-- quickly instead of scanning the entire table. In the COVID-19 dataset, indexes on frequently 
-- searched and joined columns such as country_id and report_date can significantly improve the
-- performance of queries, joins, and updates. However, indexes also require additional storage 
-- and can slightly slow down INSERT, UPDATE, and DELETE operations, so they should be created 
-- on columns that are frequently used in queries.

-- UC15 :
-- Implement an index on the "Country/Region" column to speed up search operations.

CREATE INDEX country_index
ON global_covid_stats (country_id);


-- User-Defined Functions (UDF):

-- UC16 :
-- Develop a UDF to calculate the mortality rate (deaths / confirmed cases * 100) for a given country.

CREATE FUNCTION martality_rate(
    f_name text
)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE 
    mortality numeric;
BEGIN 
    SELECT SUM(gc.new_deaths)*100.0/SUM(gc.new_confirmed) INTO mortality
    FROM country c
    JOIN global_covid_stats gc
        ON gc.country_id=c.country_id
    WHERE c.name=f_name;

    RETURN mortality;
END;
$$

-- UC17 :
-- Create a UDF to determine the recovery rate (recovered / confirmed cases * 100) for a specific date.

CREATE FUNCTION recovery_rate(
    f_name text,
    f_date date
)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
    recovery numeric;
BEGIN

    SELECT gc.recovered * 100.0 / gc.confirmed
    INTO recovery
    FROM country c
    JOIN global_covid_stats gc
        ON gc.country_id = c.country_id
    WHERE c.name = f_name
      AND gc.report_date = f_date;

    RETURN recovery;

END;
$$;


-- GROUP BY

-- UC18 :
-- Group the data by continent and calculate the total number of confirmed cases for each continent.

SELECT c.continent,SUM(gc.confirmed)
FROM country c
JOIN global_covid_stats gc
    on c.country_id=gc.country_id
GROUP BY  c.continent;

-- UC19 :
-- Group the data by date and compute the total number of deaths and recoveries for each date.

SELECT report_date,SUM(deaths),SUM(recovered)
FROM global_covid_stats 
GROUP BY  report_date;

-- UC20 :
-- Group the data by country and calculate the average number of new cases reported daily for each country.

SELECT c.name,ROUND(AVG(gc.new_confirmed), 2) 
FROM country c
JOIN global_covid_stats gc
    on c.country_id=gc.country_id
GROUP BY c.name;


-- Covid-Data-Global :

-- To find out the death percentage locally and globally
-- globally :

SELECT SUM(new_deaths)*100/SUM(new_confirmed)
FROM global_covid_stats;

-- locally :
SELECT SUM(gc.new_deaths)*100/SUM(gc.new_confirmed)
FROM country c
JOIN global_covid_stats gc 
    ON c.country_id=gc.country_id
GROUP BY c.name;

-- To find out the infected population percentage locally and globally
-- globally

WITH infected_population AS (
    SELECT c.country_id,SUM(gc.new_confirmed) as total
    FROM country as c
    JOIN global_covid_stats gc
        ON c.country_id=gc.country_id
    GROUP BY c.country_id
)
SELECT SUM(infected_population.total)*100/SUM(c.population)
FROM country c
JOIN infected_population 
    ON c.country_id=infected_population.country_id;

-- Locally

WITH infected_population AS (
    SELECT c.country_id,SUM(gc.new_confirmed) as total
    FROM country as c
    JOIN global_covid_stats gc
        ON c.country_id=gc.country_id
    GROUP BY c.country_id
)
SELECT c.name,infected_population.total*100/c.population
FROM country c
JOIN infected_population 
    ON c.country_id=infected_population.country_id;

-- To find out the countries with the highest infection rates

WITH infected_population AS (
    SELECT c.country_id,SUM(gc.new_confirmed) as total
    FROM country as c
    JOIN global_covid_stats gc
        ON c.country_id=gc.country_id
    GROUP BY c.country_id
)
SELECT c.name,infected_population.total*100/c.population as infection_rate
FROM country c
JOIN infected_population 
    ON c.country_id=infected_population.country_id
ORDER BY infection_rate DESC;

-- To find out the countries and continents with the highest death counts
-- countries

SELECT country_id,MAX(deaths)
FROM global_covid_stats
GROUP BY country_id
ORDER BY MAX(deaths) DESC;

-- continents

WITH death_country AS(
    SELECT country_id,MAX(deaths) as dt
    FROM global_covid_stats
    GROUP BY country_id
)
SELECT c.continent,SUM(death_country.dt)
FROM country as c
JOIN death_country
    ON c.country_id=death_country.country_id
GROUP BY c.continent
ORDER BY SUM(death_country.dt) DESC;


-- Queries on Vaccination:
-- Total vaccinated with at least 1 dose over time (All countries)

SELECT SUM(mx)
from (SELECT MAX(first_dose) AS mx
FROM vaccination
GROUP BY state_id) as ab;

-- Percentage of the population vaccinated with at least the first dose until 30/9/2021 

WITH total_vaccinated as (
	SELECT MAX(v.first_dose) AS mx, v.state_id as st_id,s.population as pop
	FROM vaccination as v
	JOIN state as s
		ON s.state_id=v.state_id
	WHERE v.date<='2021/09/30'
	GROUP BY v.state_id,s.population
)
select SUM(total_vaccinated.mx)*100/SUM(total_vaccinated.pop)
from total_vaccinated;


-- Using JOINS to combine the covid_deaths and covid_vaccine tables :

-- To find out the population vs the number of people vaccinated

WITH total_vaccinated as (
	SELECT MAX(v.first_dose) AS mx, v.state_id as st_id,s.population as pop
	FROM vaccination as v
	JOIN state as s
		ON s.state_id=v.state_id
	WHERE v.date<='2021/09/30'
	GROUP BY v.state_id,s.population
)
select SUM(total_vaccinated.mx) as Total_Person_Vaccinated,SUM(total_vaccinated.pop) as Total_Population
from total_vaccinated;

-- To find out the percentage of different vaccine taken by people in a country

WITH total_vaccinated as (
	SELECT MAX(v.covaxin) AS covax,
           MAX(v.covishield) as covi, 
           MAX(sputnik_v) as sput,
           v.state_id as st_id,
           s.population as pop
	FROM vaccination as v
	JOIN state as s
		ON s.state_id=v.state_id
	GROUP BY v.state_id,s.population
)
select  SUM(total_vaccinated.covax)*100/SUM(total_vaccinated.pop) as Covaxin_Vaccinated,
		SUM(total_vaccinated.covi)*100/SUM(total_vaccinated.pop)  as Covishield_Vaccinated,
		SUM(total_vaccinated.sput)*100/SUM(total_vaccinated.pop)  as Sputnik_Vaccinated
from total_vaccinated;

-- To find out percentage of people who took both the doses

WITH total_vaccinated as (
	SELECT MAX(v.second_dose) AS mx, v.state_id as st_id,s.population as pop
	FROM vaccination as v
	JOIN state as s
		ON s.state_id=v.state_id
	GROUP BY v.state_id,s.population
)
select SUM(total_vaccinated.mx)*100/SUM(total_vaccinated.pop)
from total_vaccinated;


-- Indian State Wise Analysis:

-- 1. Total State-wise Confirmed Cases

SELECT s.name , MAX(cs.confirmed)
FROM state AS s
JOIN covid_case_stats cs
    ON cs.state_id=s.state_id
GROUP BY s.name;

-- 2. Maximum Active cases State-wise till date

SELECT s.name , MAX(cs.active_cases)
FROM state AS s
JOIN covid_case_stats cs
    ON cs.state_id=s.state_id
WHERE cs.report_date <= '2020-10-16'
GROUP BY s.name;

-- 3. Max Per Day Confirmed cases in States

SELECT cs.report_date, MAX(cs.confirmed) 
FROM covid_case_stats AS cs
GROUP BY cs.report_date
ORDER BY cs.report_date;

-- 4. Max Per Day Death cases in States

SELECT cs.report_date, MAX(cs.deaths) 
FROM covid_case_stats AS cs
GROUP BY cs.report_date
ORDER BY cs.report_date;

-- 5. State-wise Mortality Rate

SELECT s.name ,SUM(cs.new_deaths)*100.0/SUM(cs.new_confirmed)
FROM state AS s
JOIN covid_case_stats cs
    ON cs.state_id=s.state_id
GROUP BY s.name,s.population;


