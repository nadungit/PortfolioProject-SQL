Select * 
From [Portfolio Project]..CovidDeaths
Order by 3,4

Select * 
From [Portfolio Project]..CovidVaccinations
Order by 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases,total_deaths, population 
From [Portfolio Project]..CovidDeaths
Order by 1,2


-- Looking at Total Cases Vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as Deathpercentage
From [Portfolio Project]..CovidDeaths
Where Location like '%state%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, total_cases, Population, (total_cases/population) *100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where Location like '%state%'			-- You can change the location as you want
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where Location like '%state%'
Group by Location,population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count Per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount  -- Converted the data type as "int"
From [Portfolio Project]..CovidDeaths
--Where Location like '%state%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Let's Break things down by Continent
-- Showing the continent with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Portfolio Project]..CovidDeaths
--Where Location like '%state%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Total Cases

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated  -- SUM(cast (vac.new_vaccinations as int)) = SUM(CONVERT(int,vac.new_vaccinations))
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
	on dea.location	= vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE - ****
With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated  -- SUM(cast (vac.new_vaccinations as int)) = SUM(CONVERT(int,vac.new_vaccinations))
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
	on dea.location	= vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac 


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated  
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
	on dea.location	= vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated


-- Creating view to store data fro later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated  
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
	on dea.location	= vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated