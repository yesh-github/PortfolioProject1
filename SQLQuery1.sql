-- The SARS-CoV-2 virus causes Coronavirus Illness (COVID-19), an infectious disease. The majority of those infected with the virus 
-- will have mild to moderate respiratory symptoms and will recover without the need for medical attention. Some, on the other hand, 
-- will get critically unwell and require medical assistance. Serious sickness is more likely to strike the elderly and those with 
-- underlying medical disorders such as cardiovascular disease, diabetes, chronic respiratory disease, or cancer. COVID-19 may make 
-- anyone sick and cause them to get very ill or die at any age.

-- The dataset used here is from https://ourworldindata.org/covid-deaths
  
  
  --Selecting the data that is going to be used

  SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM PortfolioProject..CovidDeaths
  ORDER BY 1,2

  --Looking at Total Cases vs Total Deaths with Death Perecentage

  SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
  FROM PortfolioProject..CovidDeaths
  WHERE LOCATION = 'Canada'
  ORDER BY 1,2

  --Looking at Total Cases vs Population
  --Shows percentage of population got Covid

  SELECT location, date, total_cases, population, (total_cases/population) * 100 as CovidGotPercentage
  FROM PortfolioProject..CovidDeaths
  WHERE LOCATION = 'United States'
  ORDER BY 1,2

  -- Showing Countries with highest death count per population

  SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
  FROM PortfolioProject..CovidDeaths 
  where continent is not null
  group by location
  ORDER BY TotalDeathCount desc

  --By Continent

  SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
  FROM PortfolioProject..CovidDeaths
  where continent is null
  group by location
  ORDER BY TotalDeathCount desc

-- Total Covid Deaths Internationally

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

--Cross check with different location parameter

 SELECT MAX(CAST(total_cases AS INT)), MAX(CAST(total_deaths AS INT)), MAX(cast(total_deaths as int))/MAX(total_Cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths
 WHERE location = 'World'
 ORDER BY 1,2

--Result almost same

--By continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--Percentage of Population Infected based on the location.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Rolling People Vaccinated that counts vaccinatin based on date and location
-- Using Partition by instead of group by

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	        On dea.location = vac.location
	        and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

-- Using CTE to use RollingPeopleVaccinated in te same Query

WITH PopulationvsVaccinations ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
		SUM(CONVERT(BIGINT,vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vaccinations
	ON deaths.location = vaccinations.location
	AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinatedPercentage
FROM PopulationvsVaccinations 
