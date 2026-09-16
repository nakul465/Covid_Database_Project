-- Loading data into the table country

COPY country (country_id, name, continent, population)
FROM '/Users/nakularora/Documents/PostgresProjects/Covid_DB_Project/Data/countries.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

COPY state (state_id, name, population,country_id)
FROM '/Users/nakularora/Documents/PostgresProjects/Covid_DB_Project/Data/states.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

COPY district (district_id, state_id, name)
FROM '/Users/nakularora/Documents/PostgresProjects/Covid_DB_Project/Data/districts.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

COPY covid_case_stats (case_id, country_id, state_id,report_date,report_time,confirmed,deaths,recovered,new_confirmed,new_deaths,active_cases)
FROM '/Users/nakularora/Documents/PostgresProjects/Covid_DB_Project/Data/covid_case_stats.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

COPY vaccination (vaccine_id, state_id, date,total_doses,first_dose,second_dose,covaxin,covishield,sputnik_v,precaution_dose)
FROM '/Users/nakularora/Documents/PostgresProjects/Covid_DB_Project/Data/vaccination.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

COPY testing (testing_id, state_id, date,total_samples,positive_cases,negative_cases)
FROM '/Users/nakularora/Documents/PostgresProjects/Covid_DB_Project/Data/testing.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

COPY global_covid_stats (global_stat_id, country_id, report_date,confirmed,deaths,recovered,new_confirmed,new_deaths,active_cases,people_vaccinated_1dose,people_fully_vaccinated)
FROM '/Users/nakularora/Documents/PostgresProjects/Covid_DB_Project/Data/global_covid_stats.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);