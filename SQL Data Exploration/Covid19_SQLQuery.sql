--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order By 3,4

--Data Selections
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order By 1,2

--Total Cases Vs Total Deaths
--Objective: To check the percentage likelihood of death if a person is infected with COVID-19
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%malay%'
Order By 1,2

--Total Cases Vs Population
--Objective: To check the percentage if population that got covid
Select location, date, population, total_cases, (total_cases/population) * 100 as CasesPercentage
From PortfolioProject..CovidDeaths
Where location like '%malay%'
Order By 1,2

--Objective: To check Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%malay%'
where continent is not null
Group By location, population
Order By 4 desc

--Objective: To check countries with highest death count
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group By location
Order By TotalDeathCount desc

--Objective: To check continents with highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group By continent
Order By TotalDeathCount desc

--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order By 1

--Objective: To look at population vs vaccination
--Method 1: Use CTE for the query (act like sticky note)

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated --add total people vaccinated day by day, in date order
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Method 2: Use Temp Table for the query (act like whiteboard)

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated --add total people vaccinated day by day, in date order
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Objective: Create View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated --add total people vaccinated day by day, in date order
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null