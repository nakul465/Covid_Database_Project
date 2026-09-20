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

