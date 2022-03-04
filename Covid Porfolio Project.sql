SELECT *
FROM PortfolioProject..['CovidDeaths]
WHERE continent is not null
ORDER BY 3,4;

/*
SELECT *
FROM PortfolioProject..['CovidVaccinations]
WHERE continent is not null
ORDER BY 3,4;
*/


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['CovidDeaths]
WHERE continent is not null
ORDER BY 1,2;


--Look at total cases vs total deaths
--Shows liklihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
FROM PortfolioProject..['CovidDeaths]
Where location like '%states%'
ORDER BY 1,2;

--Look at total cases Vs population
--Shows what percentage of population who got Covid
SELECT location, date, total_cases, population, (total_cases / population) * 100 as TotalCovidPositive
FROM PortfolioProject..['CovidDeaths]
Where location like '%states%'
ORDER BY 1,2;

--Look at countries with highest infection rate compared to population
SELECT location, population, max(total_cases) as highestInfectionCount, max(total_cases / population) * 100 as percentOfPopulationInfected
FROM PortfolioProject..['CovidDeaths]
--Where location like '%states%'
GROUP BY location, population
ORDER BY percentOfPopulationInfected DESC;

--Look at countries with hightes death count per population
SELECT location, max(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject..['CovidDeaths]
--Where location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY totalDeathCount DESC;


--Look at breakdown By continent
SELECT continent, max(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject..['CovidDeaths]
--Where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount DESC;
	--this looks like better numbers
SELECT location, max(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject..['CovidDeaths]
--Where location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY totalDeathCount DESC;


-- Showing continents with highest death count
SELECT continent, max(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject..['CovidDeaths]
--Where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount DESC;



--GLOBAL NUMBERS
--info by day
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..['CovidDeaths]
--Where location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- total cases of all time across the world
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..['CovidDeaths]
--Where location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;



--Looking at Total Population vs Vaccinations

with PopvsVac(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations )) OVER(Partition by dea.location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['CovidDeaths] as dea
JOIN PortfolioProject..['CovidVaccinations] as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3
)
SELECT *, (RollingPeopleVaccinated / population)*100
FROM PopvsVac

--USE CTE  (columns in CTE need to be the same as in the select statement)



--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations )) OVER(Partition by dea.location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['CovidDeaths] as dea
JOIN PortfolioProject..['CovidVaccinations] as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3

SELECT *, (RollingPeopleVaccinated / population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations )) OVER(Partition by dea.location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['CovidDeaths] as dea
JOIN PortfolioProject..['CovidVaccinations] as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3

SELECT *
FROM PercentPopulationVaccinated