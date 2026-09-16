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

