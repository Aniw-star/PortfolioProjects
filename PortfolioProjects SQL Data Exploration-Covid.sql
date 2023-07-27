SELECT *
FROM PortfolioProjects..Coviddeaths$
ORDER BY 3,4

SELECT *
FROM PortfolioProjects..CovidVaccinations
ORDER BY 3,4

---Now let us  Select Data we will use in our query

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..Coviddeaths$
ORDER BY 1,2

---We are looking at the total cases vs total deaths

---- We will also see the  likelihood of death if you contracted COVID in your country AT ANY TIME

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProjects..Coviddeaths$
WHERE location like '%states%'
ORDER BY 1,2


---- Looking at the Total Cases vs Population

---- Shows what % of population tested positive for COVID AT ANY TIME

SELECT Location, date, population, total_cases, (total_cases/population)*100 as Sick_Percentage
FROM PortfolioProjects..Coviddeaths$
WHERE location like '%states%'
ORDER BY 1,2

---- Looking at countries with highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as Sick_Percentage
FROM PortfolioProjects..Coviddeaths$
-- WHERE location like '%states%'
GROUP BY Location, population
ORDER BY Sick_Percentage DESC

---- Showing Countries with Highest Death Count


SELECT Location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProjects..Coviddeaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

---- Break data down by Continent

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProjects..Coviddeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

---- Showing Continents with highest death count

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProjects..Coviddeaths$
WHERE continent IS NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


---- Global Numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as INT)) AS Total_Deaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as Death_Percentage
FROM PortfolioProjects..Coviddeaths$
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2



---- Exploring other table

SELECT *
FROM PortfolioProjects..CovidVaccinations

---- Joining Tables!

SELECT * 
FROM PortfolioProjects..Coviddeaths$ dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

---- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	FROM PortfolioProjects..Coviddeaths$ dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT))OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..Coviddeaths$ dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
 
---- Use CTE Option

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..Coviddeaths$ dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


---- The Temp Table Method

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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..Coviddeaths$ dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


---- Create View to store data for later visualiazation

Create View #PercentPopulationVaccinated AS
SELECT dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [PortfolioProjects]..Coviddeaths$ dea
JOIN [PortfolioProjects]..Covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3


Select *
FROM PercentPopulationVaccinated


---- Queries used for Tableau Portion 2/4

---- Table 1

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as INT)) AS Total_Deaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as Death_Percentage
FROM PortfolioProjects..CovidVaccinations
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2


---- Table 2

SELECT location, SUM(cast(new_deaths AS int)) as TotalDeathCount
FROM PortfolioProjects..Coviddeaths$
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

---- Table 3

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProjects..Coviddeaths$
-- WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

---- Table 4

SELECT Location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProjects..Coviddeaths$
-- WHERE location like '%states%'
GROUP BY Location, population, date
ORDER BY PercentPopulationInfected DESC
