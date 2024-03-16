SELECT * 
FROM PortforlioProject..CovidDeaths
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, population
FROM PortforlioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelyhood of dying if you contract cvid in USA

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 
AS DeathPercentage
FROM PortforlioProject..CovidDeaths
WHERE location LIKE '%States%' 
ORDER BY 1,2

--Looking at Total cases vs Population

SELECT Location, date, population, total_cases,(total_cases/population) * 100 
AS PercentPopulation
FROM PortforlioProject..CovidDeaths
WHERE location LIKE '%States%' 
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 
AS PercentPopulationInfected
FROM PortforlioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing the countries with the highest death count per population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathcount
FROM PortforlioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathcount desc



--Showing the continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathcount
FROM PortforlioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathcount desc


--Global Numbers

SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths , SUM(cast(new_deaths as int))/ SUM(new_cases)* 100 
AS Deathpercentage
FROM PortforlioProject..CovidDeaths
WHERE continent is not Null
GROUP BY date
ORDER BY 1,2


SELECT  SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths , SUM(cast(new_deaths as int))/ SUM(new_cases)* 100 
AS Deathpercentage
FROM PortforlioProject..CovidDeaths
WHERE continent is not Null
ORDER BY 1,2

-- VACCINATION TABLE
SELECT * FROM
PortforlioProject..CovidVaccinations

--Total population vs vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dea JOIN
PortforlioProject..CovidVaccinations vac
ON dea.location=vac.location AND 
dea.date= vac.date
WHERE dea.continent is not Null
ORDER BY 2,3



--Using CTE

WITH PopvsVac(continent, location, date , population, new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dea 
JOIN PortforlioProject..CovidVaccinations vac
	ON dea.location=vac.location 
	AND 
	dea.date= vac.date
WHERE dea.continent is not Null
--ORDER BY 2,3
)
 
SELECT * , (RollingPeopleVaccinated / population) * 100 
FROM PopvsVac


--TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dea 
JOIN PortforlioProject..CovidVaccinations vac
	ON dea.location=vac.location 
	AND 
	dea.date= vac.date
WHERE dea.continent is not Null


SELECT * , (RollingPeopleVaccinated / Population) * 100 
FROM #PercentPopulationVaccinated 



--Creating view  to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dea 
JOIN PortforlioProject..CovidVaccinations vac
	ON dea.location=vac.location 
	AND 
	dea.date= vac.date
WHERE dea.continent is not Null

SELECT * FROM PercentPopulationVaccinated