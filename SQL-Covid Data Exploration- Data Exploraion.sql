
/*

Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From CovidProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Total Deaths
--Shows chances of dying if you contract covid in the USA
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


--Looking at Total Cases vs Population in USA

Select location, date, population, total_cases, (total_cases/population)*100 as Percent_Pop_Infected
From CovidProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


--Looking at peak total cases vs population across countries.  

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) *100 as Percent_Pop_Infected
From CovidProject..CovidDeaths
Where continent is not null
Group by location, population
Order by Percent_Pop_Infected desc


-- Showing countries with highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Percent of population that has died from covid
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount, MAX(cast(Total_deaths as int)/population) *100 as PercentDead
From CovidProject..CovidDeaths
Where continent is not null
Group by location
Order by PercentDead desc



-- Looking at numbers by continent


-- Continents with Highest death count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Global numbers total

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Order by 1,2


---

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated

--Creating View to store data for visualization

Create View PercentPopulatuionVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


-- Queries for vizualization
