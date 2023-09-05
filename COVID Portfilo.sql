SELECT * FROM PortfolioProject..covidDeaths$
where continent is not null
ORDER BY 3,4

--SELECT * FROM PortfolioProject..covidVaccinations$
--ORDER BY 3,4

-- select data that we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths, population
FROM PortfolioProject..covidDeaths$
where continent is not null
ORDER BY 1,2

-- looking at Total Caases vs Total Deaths
-- shows the linklihood of dying if you contract the covid in youe country
SELECT location,date,total_cases,total_deaths,(CONVERT(float, total_deaths)/CONVERT(float, total_cases))*100 as DeathPercentage
FROM PortfolioProject..covidDeaths$
where continent is not null
WHERE location like '%China'
ORDER BY 1,2

-- looking at Total Cases vs Population
-- shows what percentage of population got covid
SELECT location, date, population, total_cases, (CONVERT(float, total_cases)/CONVERT(float, population))*100 as PopulationPercentage
FROM PortfolioProject..covidDeaths$
where continent is not null
WHERE location like '%Cyprus'
ORDER BY 1,2

--looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(CONVERT(float, total_cases)) as HighestInfectionCount, MAX((CONVERT(float, total_cases)/CONVERT(float, population))*100) as percentPopulationInfected
FROM PortfolioProject..covidDeaths$
where continent is not null
GROUP BY Location, population
ORDER BY percentPopulationInfected desc


--showing countries with highest death count per population		
SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths$
where continent is not null
GROUP BY Location, population
ORDER BY TotalDeathCount desc

-- Lets break things down by continent 
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths$
where continent is  null
and location not like '%income'
GROUP BY location 
ORDER BY TotalDeathCount desc

	
--GLOBAL numbers
select SUM(CAST(new_cases as int)) as total_cases, sum(CAST(new_deaths as int)) as total_death--,sum(CAST(new_deaths as int))/SUM(CAST(new_cases as int))*100 as DeathPercentage -- CAST(total_deaths as int), cast(total_deaths as int)/CAST(total_cases as int)*100 as DeathPercentage
FROM PortfolioProject..covidDeaths$
where continent is not null
--and (location not like '%income' or location not like '%world')
order by 1,2


-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
,(rollingpeoplevaccination/population)*100
from PortfolioProject..covidDeaths$ dea
join PortfolioProject..covidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.location like 'Australia'
order by 2,3
-- this has problem because we cant just use the column we just created
-- 2 ways to solve

--CTE

with popvsvac (continent, location, date, population, new_vaccinations,  rollingpeoplevaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccination
from PortfolioProject..covidDeaths$ dea
join PortfolioProject..covidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.location like 'Australia'
--order by 2,3
)
select * ,(rollingpeoplevaccination/population)*100
from popvsvac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths$ dea
join PortfolioProject..covidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.location like 'Australia'
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating View to store data for later visualisation

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths$ dea
join PortfolioProject..covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location like 'Australia' 
--order by 2,3

Select * From PercentPopulationVaccinated	