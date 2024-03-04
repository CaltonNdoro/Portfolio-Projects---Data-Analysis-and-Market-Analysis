Select * 
From PortfolioProject . .CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases,new_cases,total_deaths,population
From PortfolioProject . .CovidDeaths
order by 1,2


---Look at the Total Cases vs Total Deaths 
--Shows the likelihood of dying if you contract covid in your country


--Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
--From PortfolioProject . .CovidDeaths
--order by 1,2

--As compared to the USA 

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject . .CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at the total cases vs population 
--Shows what percentage of population got Covid

Select Location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage 
From PortfolioProject. .CovidDeaths
--Where location like '%states%'
order by 1,2


--Countries with Highest Infection Rate compared to Population 

Select Location,population,Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 PercentPopolutionInfected
From PortfolioProject. .CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopolutionInfected desc


--Countries with the Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount  
From PortfolioProject . .CovidDeaths
where continent is null 
Group by location
order by TotalDeathCount desc

--- LETS BREAK IT DOWN BY CONTINET 
--showing continents with the highest death count per population 

Select continent, max(cast(total_deaths as int)) as TotalDeathCount  
From PortfolioProject . .CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathCount desc




---GLOBAL STATS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
