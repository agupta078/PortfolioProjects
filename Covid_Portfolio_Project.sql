Select *
From CovidDeaths
Order By 3,4

Select *
From CovidVaccinations
Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2

--- Total Cases vs Total Deaths
Select location, date, total_cases,total_deaths,(total_deaths/total_cases) * 100 AS DeathPercent
From CovidDeaths
Where location like '%austria%'
Order by 1,2

------Total_Cases Vs Population
------ % of popuation got Covid

Select location, date, population, total_cases, (total_cases/population) * 100 AS DeathPercent
From CovidDeaths
Where location like '%austria%'
Order by 1,2

------Countries with highest infection count

Select location, population, MAX(total_cases) AS HighestInfCount, MAX(total_cases/population) * 100 AS PercentPopInf
From CovidDeaths
----Where location like '%austria%'
Group by location, population
Order by PercentPopInf desc

------Countries with highest death count per population
Select location, MAX(total_deaths) AS TotalDeathCount
From CovidDeaths
----Where location like '%austria%'
Where continent is not NULL
Group by location
Order by TotalDeathCount desc

----- Break things down by continent
Select continent, MAX(total_deaths) AS TotalDeathCount
From CovidDeaths
----Where location like '%austria%'
Where continent is NOT NULL
Group by continent
Order by TotalDeathCount desc

----Global Numbers
Select date,continent, SUM(new_cases) , SUM(new_deaths)  ----sum(new_deaths)/population) * 100 AS DeathPercentage
From CovidDeaths
Where continent is NOT NULL
Group By Date, continent
Order by 1,2

---- Total_Population Vs Vaccinations
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
dea.Date) AS RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
----order by 2,3
)

---- USE CTE
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


----TEMP TABLE
Drop Table if exists	#PercentPopulationVaccinated1
Create Table #PercentPopulationVaccinated1
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated1
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
dea.Date) AS RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date


Select *
From #PercentPopulationVaccinated1

Select *, (RollingPeopleVaccinated /Population)*100
From #PercentPopulationVaccinated1

----- Create View 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
dea.Date) AS RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated
