SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date,  total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--shows likelihood of dying if you contract covid in your country
SELECT location, date,  total_cases, total_deaths, (total_deaths / total_cases) *100 AS  DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
SELECT location, date,  total_cases, population, (total_cases / population) *100 AS  CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2


--WHAT COUNTRY HAS THE HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases) / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths AS INT)) AS HighestTotalDeath
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestTotalDeath DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths AS INT)) AS HighestTotalDeath
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestTotalDeath DESC

--showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestTotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2

--looking total population vs vaccinations 


WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,		
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,		
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,		
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

select *
from PercentPopulationVaccinated