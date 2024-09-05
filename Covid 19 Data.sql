select * 
from CovidDeaths
where continent is not null



-- Select Data that we are going to be starting with
select location,date, total_cases, new_cases, total_deaths, population
from CovidDeaths
Where continent is not null
order by location,date

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from CovidDeaths
where location like 'Egypt'
and total_deaths is not null
Order by location,date


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like 'Egypt'
Order by location,date


-- Countries with Highest Infection Rate compared to Population
select location,population,MAX(total_cases) as Highest_Infection_Count,
MAX((total_cases/population))*100 as Precent_Population_Infection
from CovidDeaths
Group by location,population
order by Precent_Population_Infection DESC


-- Countries with Highest Death Count per Population
select location,MAX(CAST(total_deaths as int)) as Total_Death_Count
from CovidDeaths
where continent is not null
Group by location
order by Total_Death_Count DESC

-- Break Down by Continent
select location,MAX(CAST(total_deaths as int)) as Total_Death_Count
from CovidDeaths
where continent is not null
Group by location
order by Total_Death_Count DESC


-- Showing contintents with the highest death count per population
select continent,MAX(CAST(total_deaths as int)) as Total_Death_Count
from CovidDeaths
where continent is not null
Group by continent
order by Total_Death_Count DESC



-- GLOBAL NUMBERS
Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
Group by date
Order by date
--Total
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1


--Join CovidDeath and CovidVaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location
Order by dea.location,dea.date) AS Taken_Vacci
from CovidDeaths dea
join CovidVaccinations vac
     on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by location,date



-- Total Population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location
Order by dea.location,dea.date) AS Taken_Vacci
from CovidDeaths dea
join CovidVaccinations vac
     on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by location,date


--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Taken_Vacci)
as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location
Order by dea.location,dea.date) AS Taken_Vacci
from CovidDeaths dea
join CovidVaccinations vac
     on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
)
select * ,(Taken_Vacci/Population) * 100 
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Taken_Vacci numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location
Order by dea.location,dea.date) AS Taken_Vacci
from CovidDeaths dea
join CovidVaccinations vac
     on dea.location = vac.location
   and dea.date = vac.date

select * ,(Taken_Vacci/Population) * 100 AS percentage
from #PercentPopulationVaccinated
where continent is not null
order by location,date



-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location
Order by dea.location,dea.date) AS Taken_Vacci
from CovidDeaths dea
join CovidVaccinations vac
     on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null