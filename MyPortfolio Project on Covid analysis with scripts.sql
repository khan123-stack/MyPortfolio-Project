 Select * from [Portfolio Project]..CovidDeath
order by 3,4


Select location, date, total_cases,new_cases, total_deaths,population
from [Portfolio Project]..CovidDeath
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases,new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercenatge
from [Portfolio Project]..CovidDeath
where location like '%India%' and continent is not null
order by 1,2

--- looking at total cases vs population
--shows what perctange of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercenatge
from [Portfolio Project]..CovidDeath
where location like '%India%' and continent is not null
order by 1,2


-- - looking at countires with highest infection rate compared to population
Select location, population, MAX(total_cases) as highestInfectionrate, MAX(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeath
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- countries with the highest death count for population
Select location, population, MAX(cast(total_deaths as int)) as totaldeaths
from [Portfolio Project]..CovidDeath
where continent is not null
group by location, population
order by totaldeaths desc

----- Lets breakdown by continent
Select location, MAX(cast(total_deaths as int)) as totaldeaths
from [Portfolio Project]..CovidDeath
where continent is null
group by location
order by totaldeaths desc

Select continent, MAX(cast(total_deaths as int)) as totaldeaths
from [Portfolio Project]..CovidDeath
where continent is null
group by continent
order by totaldeaths desc

Select continent, MAX(cast(total_deaths as int)) as totaldeaths
from [Portfolio Project]..CovidDeath
where continent is not null
group by continent
order by totaldeaths desc

----- Global Numbers
Select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as Deathpercentage
from [Portfolio Project]..CovidDeath
--where location like '%India%' 
where continent is not null
order by 1,2

----------------------------------------------------------------------------------------------
=----looking at total population vs vaccination
------ USE CTE or TEMP TABLE
With PopvsVac (Continent,location, date, Population,new_vaccinations,rollingpeoplevaccinated)
as 
(
Select Dea.continent,Dea.location,Dea.date,Dea.population,Vacc.new_vaccinations,
SUM(convert(int,Vacc.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location,Dea.Date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeath Dea
JOIN [Portfolio Project]..CovidVaccin Vacc
ON Dea.location=Vacc.location
and Dea.date=Vacc.date
where dea.continent is not null
--and new_vaccinations is not null
--order by 2,3
)

Select *,(rollingpeoplevaccinated/Population)*100
 from PopvsVac

------------------------------------------- TEMP TABLE

DROP Table  #Percentpopulationvaccinated
create table #Percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)

Insert into #Percentpopulationvaccinated
Select Dea.continent,Dea.location,Dea.date,Dea.population,Vacc.new_vaccinations,
SUM(convert(int,Vacc.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location,Dea.Date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeath Dea
JOIN [Portfolio Project]..CovidVaccin Vacc
ON Dea.location=Vacc.location
and Dea.date=Vacc.date
--where dea.continent is not null
--and new_vaccinations is not null
--order by 2,3
Select *,(rollingpeoplevaccinated/Population)*100
 from #Percentpopulationvaccinated

 ----------------- Creating view to store data for later visulization
Create View Percentpopulationvaccinated as
Select Dea.continent,Dea.location,Dea.date,Dea.population,Vacc.new_vaccinations,
SUM(convert(int,Vacc.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location,Dea.Date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeath Dea
JOIN [Portfolio Project]..CovidVaccin Vacc
ON Dea.location=Vacc.location
and Dea.date=Vacc.date
where dea.continent is not null
--order by 2,3

Select * from Percentpopulationvaccinated
