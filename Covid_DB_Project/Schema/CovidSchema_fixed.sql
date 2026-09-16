CREATE DATABASE covid_db;

CREATE TABLE country (
  country_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  continent VARCHAR(50) NOT NULL,
  population BIGINT NOT NULL
);

CREATE TABLE state (
  state_id INT PRIMARY KEY,
  country_id INT NOT NULL REFERENCES country(country_id),
  name VARCHAR(100) NOT NULL,
  population BIGINT NOT NULL,
  UNIQUE (country_id, name)
);

CREATE TABLE district (
  district_id INT PRIMARY KEY,
  state_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  CONSTRAINT fk_district_state FOREIGN KEY (state_id) REFERENCES state (state_id),
  CONSTRAINT uq_district_state_name UNIQUE (state_id, name)
);

CREATE TABLE covid_case_stats (
  case_id INT PRIMARY KEY,
  country_id INT NOT NULL,
  state_id INT NOT NULL,
  district_id INT NULL,
  report_date DATE NOT NULL,
  report_time TIME NOT NULL DEFAULT '08:00:00',
  confirmed INT NOT NULL DEFAULT 0,
  deaths INT NOT NULL DEFAULT 0,
  recovered INT NOT NULL DEFAULT 0,
  new_confirmed INT NOT NULL DEFAULT 0,
  new_deaths INT NOT NULL DEFAULT 0,
  active_cases INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_cases_country FOREIGN KEY (country_id) REFERENCES country (country_id),
  CONSTRAINT fk_cases_state FOREIGN KEY (state_id) REFERENCES state (state_id),
  CONSTRAINT fk_cases_district FOREIGN KEY (district_id) REFERENCES district (district_id),
  CONSTRAINT uq_case_scope_date UNIQUE (country_id, state_id, district_id, report_date)
);

CREATE TABLE vaccination (
  vaccine_id INT PRIMARY KEY,
  state_id INT NOT NULL,
  date DATE NOT NULL,
  total_doses BIGINT NOT NULL DEFAULT 0,
  first_dose BIGINT NOT NULL DEFAULT 0,
  second_dose BIGINT NOT NULL DEFAULT 0,
  covaxin BIGINT NOT NULL DEFAULT 0,
  covishield BIGINT NOT NULL DEFAULT 0,
  sputnik_v BIGINT NOT NULL DEFAULT 0,
  precaution_dose BIGINT NOT NULL DEFAULT 0,
  CONSTRAINT fk_vaccine_state FOREIGN KEY (state_id) REFERENCES state (state_id),
  CONSTRAINT uq_vaccine_state_date UNIQUE (state_id, date)
);

CREATE TABLE testing (
  testing_id INT PRIMARY KEY,
  state_id INT NOT NULL,
  date DATE NOT NULL,
  total_samples BIGINT NOT NULL DEFAULT 0,
  positive_cases BIGINT NULL,
  negative_cases BIGINT NULL,
  CONSTRAINT fk_testing_state FOREIGN KEY (state_id) REFERENCES state (state_id),
  CONSTRAINT uq_testing_state_date UNIQUE (state_id, date)
);

ALTER TABLE testing
ALTER COLUMN positive_cases TYPE NUMERIC
USING positive_cases::NUMERIC,
ALTER COLUMN negative_cases TYPE NUMERIC
USING negative_cases::NUMERIC;

CREATE TABLE global_covid_stats (
  global_stat_id INT PRIMARY KEY,
  country_id INT NOT NULL,
  report_date DATE NOT NULL,
  confirmed BIGINT NOT NULL DEFAULT 0,
  deaths BIGINT NOT NULL DEFAULT 0,
  recovered BIGINT NOT NULL DEFAULT 0,
  new_confirmed BIGINT NOT NULL DEFAULT 0,
  new_deaths BIGINT NOT NULL DEFAULT 0,
  active_cases BIGINT NOT NULL DEFAULT 0,
  people_vaccinated_1dose BIGINT NOT NULL DEFAULT 0,
  people_fully_vaccinated BIGINT NOT NULL DEFAULT 0,
  CONSTRAINT fk_global_country FOREIGN KEY (country_id) REFERENCES country (country_id),
  CONSTRAINT uq_global_country_date UNIQUE (country_id, report_date)
);

