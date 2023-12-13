SELECT *
FROM dbo.covid_deaths
WHERE continent IS NOT NULL;


--Select the data that I want to use

SELECT location , date , total_cases , new_cases , total_deaths , population 
FROM dbo.covid_deaths
ORDER BY 1 , 2; 

--Fixing the date column

UPDATE covid_deaths
SET date = FORMAT(date, 'yyyy-MM-dd');

--Looking at total cases vs total deaths 
--Shows the likelyhood of dying when contracting Covid-19

SELECT location , date , total_cases , total_deaths , (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPercentage
FROM dbo.covid_deaths
WHERE location like '%states%'
ORDER BY 1 , 2 DESC;


--Looking at total cases vs population
--Shows what percentage of population has contracted covid-19

SELECT location , date , population , total_cases , (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 AS Percent_population_infected
FROM dbo.covid_deaths
ORDER BY 1 , 2;


--Looking at countries with highest infection rate compared to population 

SELECT location , population , MAX(total_cases) AS highest_infection_count , (CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0))*100 AS percent_population_infected
FROM dbo.covid_deaths
--WHERE location like '%states%'
GROUP BY location , population 
ORDER BY percent_population_infected DESC;


--Countries with the higheset death count per population

SELECT location , MAX(CAST(total_deaths AS int)) AS total_death_count
FROM dbo.covid_deaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY total_death_count DESC; 


--Continents with the highest death cound per population

SELECT continent , MAX(cast(total_deaths AS int)) AS total_death_count
FROM dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC; 


--Global Numbers

SELECT 
    date,
    SUM(new_cases) AS total_new_cases,
    SUM(CAST(new_deaths AS int)) AS total_new_deaths,
    SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) * 100 AS death_percentage
FROM 
    dbo.covid_deaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    date, total_new_cases;


--World Totals

SELECT 
    SUM(new_cases) AS total_new_cases,
    SUM(CAST(new_deaths AS int)) AS total_new_deaths,
    SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) * 100 AS death_percentage
FROM 
    dbo.covid_deaths
WHERE 
    continent IS NOT NULL
ORDER BY 
	1 , 2;


--Table Joins- Looking at total population vs vaccinations 

SELECT a.continent ,a.location , a.date , a.population , b.new_vaccinations , SUM(CONVERT(bigint, b.new_vaccinations, 0))
	OVER (PARTITION BY a.location ORDER BY a.location , a.date) AS total_vaccinations , (total_vaccinations/population)*100
FROM dbo.covid_deaths AS a
JOIN dbo.covid_vac AS b 
	ON a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL
ORDER BY 2 , 3;


--Use CTE

WITH popvsvac (continent , location , date , population , new_vaccinations , rollingpeople_vaccinated)
AS
(
SELECT a.continent ,a.location , a.date , a.population , b.new_vaccinations , SUM(CONVERT(bigint, b.new_vaccinations, 0))
	OVER (PARTITION BY a.location ORDER BY a.location , a.date) AS rollingpeople_vaccinated
FROM dbo.covid_deaths AS a
JOIN dbo.covid_vac AS b 
	ON a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL
)
SELECT * , (rollingpeople_vaccinated/population) *100
FROM popvsvac


-- Temp Table
	
CREATE TABLE #percentpopulationvaccinated 
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
	new_vaccinations NUMERIC ,
    rollingpeople_vaccinated NUMERIC
)

INSERT INTO #percentpopulationvaccinated (continent, location, date, population, new_vaccinations , rollingpeople_vaccinated)
SELECT
    a.continent,
    a.location,
    a.date,
    a.population,
	b.new_vaccinations,
    SUM(CONVERT(BIGINT, b.new_vaccinations)) 
        OVER (PARTITION BY a.location ORDER BY a.date) AS rollingpeople_vaccinated
FROM
    dbo.covid_deaths AS a
JOIN
    dbo.covid_vac AS b ON a.location = b.location AND a.date = b.date
WHERE
    a.continent IS NOT NULL;


-- Calculate the percentage

SELECT 
    continent,
    location,
    date,
	population,
	new_vaccinations,
    (rollingpeople_vaccinated / population) * 100 AS percentage_vaccinated
FROM 
    #percentpopulationvaccinated;


--Creating view to store data for later visualizations

CREATE VIEW percentpopulationvacc AS
SELECT
    a.continent,
    a.location,
    a.date,
    a.population,
	b.new_vaccinations,
    SUM(CONVERT(BIGINT, b.new_vaccinations)) 
        OVER (PARTITION BY a.location ORDER BY a.date) AS rollingpeople_vaccinated
FROM
    dbo.covid_deaths AS a
JOIN
    dbo.covid_vac AS b ON a.location = b.location AND a.date = b.date
WHERE
    a.continent IS NOT NULL


--Continents with the highest death count per population
	
CREATE VIEW continent_total_death AS
SELECT continent , MAX(cast(total_deaths AS int)) AS total_death_count
FROM dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent

	
-------Countries with the higheset death count per population
CREATE VIEW countries_death_total AS
SELECT location , MAX(CAST(total_deaths AS int)) AS total_death_count
FROM dbo.covid_deaths
WHERE continent IS NOT NULL 
GROUP BY location
