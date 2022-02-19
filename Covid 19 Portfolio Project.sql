/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Looking at all data ordered by location and date
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null  /* This is because location column includes continents itself and when location column has a continet,
								the continent column is null	*/
ORDER BY 3,4

-- Data that I will start with
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths
-- What is the probability of dying in each country?
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases VS Population
-- What is the percentage of population infected with Covid-19?
Select Location, date,population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

-- What country has the highest infection rate Compared to Population?
SELECT Location,population, MAX(total_cases) AS HighestInfection, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location,population 
ORDER BY PercentPopulationInfected DESC

-- What Countries with Highest Death Count per Population?
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- What Continents with Highest Death Count per Population?
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Looking at Global Numbers
-- viewing overall total cases
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Population VS Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location  ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3

-- CTE

WITH Population_VS_Vaccination (continent,location,date,population,new_vaccination, RollingPeopleVaccinated)
AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location  ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/population)*100 AS Vac_percent
FROM Population_VS_Vaccination


-- Using Temp Table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location  ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 AS Vac_percent
FROM #PercentPopulationVaccinated

-- Create View for Percent people vaccinated
USE PortfolioProject
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW PercentPeopleVaccinated AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location  ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
)
GO

SELECT *
FROM PercentPeopleVaccinated