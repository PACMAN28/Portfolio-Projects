

--SELECT *
--FROM CovidPortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 3,4

--SELECT *
--FROM CovidPortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Raw data 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at chance of dying if you have covid in each country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%united kingdom%'
ORDER BY 1,2

--Looking at Total Cases Vs Population
--shows what percentage of population have caught covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS "Chance Of Catching Covid"
FROM CovidPortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%united kingdom%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS "Highest Infection Count",  MAX((total_cases/population))*100 AS "Highest infection rate of countries"
FROM CovidPortfolioProject..CovidDeaths
--WHERE location LIKE '%united kingdom%'
GROUP BY location, population
ORDER BY [Highest infection rate of countries] DESC

--Showing Countries with Highest Death Count per Population

SELECT location, population, MAX(cast(total_deaths as int)) AS "Total Death Count", MAX((total_deaths/population))*100 AS "Highest death rate of countries"
FROM CovidPortfolioProject..CovidDeaths
--WHERE location LIKE '%united kingdom%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY"Total Death Count" DESC

--Continent break down showing the continents with the highest death rate per population

SELECT location, MAX(cast(total_deaths as int)) AS "Total Death Count", MAX((total_deaths/population))*100 AS "Highest death rate of countries"
FROM CovidPortfolioProject..CovidDeaths
--WHERE location LIKE '%united kingdom%'
WHERE continent IS NULL
GROUP BY location
ORDER BY "Total Death Count" DESC

--Global Numbers for cases and deaths

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as "Total Deaths", SUM(cast(new_deaths as int))/SUM(new_cases)*100 as "Death Percentage"
FROM CovidPortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%united kingdom%'
where continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Toal population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated, 
--(RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- max number of pop vaccinated in temp table 

DROP Table if exists #NumberOfPopVaccinated
Create Table #MaxNumberOfPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPoepleVaccinated numeric,
)

INSERT INTO #NumberOfPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPoepleVaccinated/Population)*100
FROM #NumberOfPopVaccinated


-- View of the above

CREATE View NumberOfPopVaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM NumberOfPopVaccinated


