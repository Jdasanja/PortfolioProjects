--ENTIRE TABLE
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--DATA BEING ANALYZED
SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
ORDER BY 1,2

--TOTAL CASES VS. TOTAL DEATHS
--LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--TOTAL CASES VS. POPULATION
--WHAT PERCENTAGE OF THE POPULATION GOT COVID
SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
GROUP  BY Location, Population
ORDER BY PercentPopulationInfected DESC

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP  BY Location
ORDER BY TotalDeathCount DESC

--DeathCountperPopulation BASED ON CONTINENT
--Script was changed. Select was changed to location from continent
--Where continent is not null was changed to WHERE continent is null
SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP  BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as Totalcases, SUM(new_deaths) as Total_deaths, SUM(New_deaths)/SUM(New_Cases)*100 as DeathPercentage --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not NULL
GROUP BY date 
ORDER BY 1,2
--TOTAL DEATH PERCENTAGE
SELECT SUM(new_cases) as Totalcases, SUM(new_deaths) as Total_deaths, SUM(New_deaths)/SUM(New_Cases)*100 as DeathPercentage --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..[CovidDeaths]
--WHERE location LIKE '%states%'
where continent is not NULL
--GROUP BY date 
ORDER BY 1,2

--TOTAL POPULATION VS. VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..[CovidDeaths]  dea 
JOIN PortfolioProject..[CovidVaccinations] vac 
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not NULL
ORDER BY 2,3

--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..[CovidDeaths]  dea 
JOIN PortfolioProject..[CovidVaccinations] vac 
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not NULL
--ORDER BY 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    CONTINENT NVARCHAR(255),
    LOCATION NVARCHAR(255),
    DATE DATETIME,
    POPULATION NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated numeric

)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..[CovidDeaths]  dea 
JOIN PortfolioProject..[CovidVaccinations] vac 
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not NULL
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..[CovidDeaths]  dea 
JOIN PortfolioProject..[CovidVaccinations] vac 
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not NULL
--ORDER BY 2,3

Select *
FROM PercentPopulationVaccinated