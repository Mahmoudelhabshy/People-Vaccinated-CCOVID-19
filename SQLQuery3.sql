SELECT Location, date, total_cases,new_cases, total_deaths, population
FROM [portfoli-project]..CovidDeaths$
ORDER BY 1, 2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DEATHPercentage
FROM [portfoli-project]..CovidDeaths$
ORDER BY 1, 2

--LOOKING AT TOTAL CASES VS POPULATION 
-- SHOW WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT Location, date, total_cases, Population, (total_cases/population)*100 ASpercent
FROM [portfoli-project]..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1, 2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTIO RATE COMPARED TO POPULATION 
SELECT Location,  Population,MAX(total_cases) AS Hieghestinfectioncount, MAX(total_cases/population)*100 AS DeathPercentage
FROM [portfoli-project]..CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY DeathPercentage DESC


--showing countries with hieghest death
SELECT Location,MAX(cast(total_deaths as int)) AS total_death_count
FROM [portfoli-project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC

-- sum continent 
SELECT continent, MAX(cast(total_deaths as int )) as TotalDeathCount
FROM [portfoli-project]..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [portfoli-project]..CovidDeaths$
WHERE  continent is not null
order by 1, 2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccination
FROM [portfoli-project]..CovidDeaths$ dea
JOIN [portfoli-project]..CovidDeaths$_xlnm#_FilterDatabase vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE 
with PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [portfoli-project]..CovidDeaths$ dea
JOIN [portfoli-project]..CovidDeaths$_xlnm#_FilterDatabase vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

Drop Table if exists #PercetPeoplattionVaccinated
Create Table #PercetPeoplattionVaccinated
(
continent nvarchar(225),
Locatoin nvarchar(225),
Date datetime,
Population numeric,
New_Vaccainations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercetPeoplattionVaccinated
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [portfoli-project]..CovidDeaths$ dea
JOIN [portfoli-project]..CovidDeaths$_xlnm#_FilterDatabase vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercetPeoplattionVaccinated


-- creating view to store data for later visualizations

create  view PercentPeoplationVaccinated as 
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [portfoli-project]..CovidDeaths$ dea
JOIN [portfoli-project]..CovidDeaths$_xlnm#_FilterDatabase vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3