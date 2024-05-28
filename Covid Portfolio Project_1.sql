Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--Order by 3,4

--Select data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
From [Portfolio Project]..CovidDeaths
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..CovidDeaths
Where location like '%India%'
Order by 1,2


--Looking at Total cases vs Population
--Percentage of Covid_Affected
  Select location,date,population,total_cases,(total_cases/population)*100 as Affected_Percentage
From [Portfolio Project]..CovidDeaths
--Where location like '%India%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
Select location,population,Max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%India%'
Group by location,population
Order by PercentPopulationInfected desc

--Let's break things down by Continent
Select continent,Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc




Select location,Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%India%'
Where continent is null
Group by location
Order by TotalDeathCount desc


--Showing Countries with Highest Death count per Population
--Since the dtpye of total deaths is nvarchar we will not get accurate count just by using MAX
Select location,Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


--Global Numbers
Select date,sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From [Portfolio Project]..CovidDeaths
--Where location like '%India%'
where continent is not null
group by date
Order by 1,2

Select sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From [Portfolio Project]..CovidDeaths
--Where location like '%India%'
where continent is not null
--group by date
Order by 1,2

Select *
From [Portfolio Project]..CovidVaccinations

Select *
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE
With PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization
DROP VIEW if exists PercentPopulationVaccinated 
USE [Portfolio Project]
GO
Create View dbo.PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated