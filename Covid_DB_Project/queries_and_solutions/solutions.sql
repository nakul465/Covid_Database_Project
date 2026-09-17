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
