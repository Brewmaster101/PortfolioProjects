-- These are the queries I used to create a tableau visual.

*/



-- Visual 1- Here I will be getting the sum of total cases, total deaths, and a percentage of the infected that die from Covid-19. This is based on the total poplation.

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS deathpercentage
FROM dbo.covid_deaths
WHERE continent is not null 
ORDER BY 1,2

-- Visual 2- Here I will be able to get the total deathcout of each continent. There were some columns that needed to be removed based on the locations listed below. 
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths as int)) AS total_deathcount
FROM dbo.covid_deaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International' , 'High income' , 'Upper middle income' , 'Lower middle income' , 'Low income')
GROUP BY location
ORDER BY total_deathcount DESC


-- Visual 3 Here I will be getting the total population of each country that has tested positve from Covid-19.

SELECT location, population, MAX(total_cases) as highest_infectioncount,  Max((total_cases/population))*100 as percent_populationinfected
FROM dbo.covid_deaths
GROUP BY location, population
ORDER BY percent_populationinfected DESC


-- Visual 4 Here I will be getting the infection rate over time of each country. For visual purposes not every country will be in the grapgh. 


SELECT location, population,date, MAX(total_cases) as highest_infectioncount,  Max((total_cases/population))*100 as percent_populationinfected
FROM dbo.covid_deaths
GROUP BY location, population, date
ORDER BY percent_populationinfected DESC