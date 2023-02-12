-- Checkinig that the table is correct
SELECT *
FROM covidData


-- Selecting relevant data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covidData
ORDER BY location, date ASC


-- Death persentage of people with covid dying in Norway, for each day since start 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_persentage
FROM covidData
WHERE location = 'Norway'
ORDER BY location, date DESC

-- Persentage of Norwegians that has gotten Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infected_persentage
FROM covidData
WHERE location = 'Norway'
ORDER BY location, date DESC

-- Ranking of countries with highest death persentage (per 08.11.2022)
-- As seen in the result, the North Korean data must be faulty
SELECT location, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_persentage
FROM covidData
WHERE date = '2022-11-08'
ORDER BY death_persentage DESC

-- Ranking of countries with highes infected persentage of the population
SELECT location, total_cases, population, (total_cases/population)*100 AS infected_persentage
FROM covidData
WHERE date = '2022-11-08'
ORDER BY infected_persentage DESC

-- Other formulation, with same result as above
SELECT location, population, MAX((total_cases/population)*100) AS infected_persentage
FROM covidData
GROUP BY location, population
ORDER BY infected_persentage DESC

-- Countries with highest total deaths ranked
SELECT location, total_deaths
FROM covidData
WHERE date = '2022-11-08' AND (continent IS NOT NULL) 
GROUP BY location, total_deaths
ORDER BY cast(total_deaths as INT) DESC

-- Lookinig at key factors for continitents and other bigger groups of countries
SELECT location, total_deaths, (total_deaths/total_cases)*100 AS death_persentage, (total_cases/population)*100 AS infected_persentage
FROM covidData
WHERE date = '2022-11-08' AND continent IS NULL
GROUP BY location, total_deaths, (total_deaths/total_cases)*100, (total_cases/population)*100
ORDER BY total_deaths DESC

-- Fully vaccinated persentage of population ranking
SELECT location, (people_fully_vaccinated/population)*100 AS fully_vaccinates_persentage
FROM covidData
WHERE date = '2022-11-08'
ORDER BY fully_vaccinates_persentage DESC

-- Vaccinated persentage of population ranking
SELECT location, (people_vaccinated/population)*100 AS vaccinated_persentage
FROM covidData
WHERE date = '2022-11-08' AND continent IS NOT NULL
ORDER BY vaccinated_persentage DESC

-- New vaccinated on a rolling basis for each country per day
SELECT continent, location, date, population, new_vaccinations
, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY location, date ROWS UNBOUNDED PRECEDING) AS people_vaccinated_rolling
, 100*SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY location, date ROWS UNBOUNDED PRECEDING)/population
FROM covidData
WHERE continent IS NOT NULL AND people_vaccinated IS NOT NULL
ORDER BY location, date