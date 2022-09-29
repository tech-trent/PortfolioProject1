

SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject1..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

--Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths to observe fatality probability from Covid contraction in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at Total Cases vs Population to observe percentage of population that contracted Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfection
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfection
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY continent, population
ORDER BY PercentPopulationInfection DESC


--Looking at countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Looking at continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Looking at global count
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Looking at global count excluding dated progression
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS


(
--Looking at Total Population vs Vaccinations
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dth.location
ORDER BY dth.location, dth.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dth
JOIN PortfolioProject1..CovidVaccinations vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF exists PercentPopulationVaccination
CREATE TABLE PercentPopulationVaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccination
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dth.location
ORDER BY dth.location, dth.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dth
JOIN PortfolioProject1..CovidVaccinations vac
	ON dth.location = vac.location
	AND dth.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccination


--Creating view to store for later visualizations
CREATE VIEW PercentPopulationVaccination as
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dth.location
ORDER BY dth.location, dth.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dth
JOIN PortfolioProject1..CovidVaccinations vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent is not null

SELECT *
FROM PercentPopulationVaccination
