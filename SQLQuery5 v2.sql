Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4


Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2 


-- Let's compare Total Cases vs Total Deaths  on each country
-- Shows possibility of dying if you contact with covi in your country


Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
from PortfolioProject..covidDeaths
Where location like '%Finland%'
order by 1,2


-- Let's look at Total Cases vs Population
-- Percentage of population got covid


Select location, date, total_cases,population, ((total_cases / population) * 100) AS TotalPercentage
from PortfolioProject..covidDeaths
Where location like '%Finland%'
order by 1,2


-- Let's look at highest infection rates on different countries population

Select location, population, MAX(total_cases) AS MaxInfectionCount, MAX ((total_cases / population) * 100) AS PercentageInfectedPopulation
from PortfolioProject..covidDeaths
Group by location,population
order by PercentageInfectedPopulation desc


--Let's look at Countries with Highest Death Count per Population

Select location,Max(CONVERT(int, total_deaths)) AS MaxTotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by MaxTotalDeathCount desc



-- Let's look things by continent.continents with the highest death count / population



--right one 

Select location,Max(CONVERT(int, total_deaths)) AS MaxTotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is  null
AND location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by MaxTotalDeathCount desc


--error one


--Select continent,Max(CONVERT(int, total_deaths)) AS MaxTotalDeathCount
--FROM PortfolioProject..CovidDeaths
--Where continent is not  null
--Group by continent
--order by MaxTotalDeathCount desc


-- GLOBAL NUMBERS



--SELECT
--    date,SUM(new_cases) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int)) / NULLIF(SUM(New_Cases), 0) * 100 AS DeathPercentage
--FROM
--    PortfolioProject..CovidDeaths
---- WHERE location LIKE '%states%'
--WHERE continent IS NOT NULL
--GROUP BY date
--HAVING
--    SUM(new_cases) IS NOT NULL
--    AND SUM(cast(new_deaths as int)) IS NOT NULL
--    AND SUM(cast(new_deaths as int)) / NULLIF(SUM(New_Cases), 0) * 100 IS NOT NULL
--ORDER BY
--    1, 2;



SELECT
    SUM(new_cases) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int)) / NULLIF(SUM(New_Cases), 0) * 100 AS DeathPercentage
FROM
    PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
HAVING
    SUM(new_cases) IS NOT NULL
    AND SUM(cast(new_deaths as int)) IS NOT NULL
    AND SUM(cast(new_deaths as int)) / NULLIF(SUM(New_Cases), 0) * 100 IS NOT NULL
ORDER BY
    1, 2;

--  Lets look at the Total Population and total vaccination
--  Lets also make a CTE

With Populationandvaccination(continent,location,date,population,new_vaccinations,PeopleVaccinated)
as
(

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY LEFT(dea.location, 50), dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *,(PeopleVaccinated/population)*100 as CovidTotalPercentage
FROM
    Populationandvaccination





-- Temp Table version


DROP Table if exists #TotalPopulationVaccinated
Create Table #TotalPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
PeopleVaccinated numeric
)

Insert into #TotalPopulationVaccinated
	Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY LEFT(dea.location, 50), dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


SELECT *,(PeopleVaccinated/population)*100 as CovidTotalPercentage
FROM #TotalPopulationVaccinated
    


-- Storing the data for data visualitions, creating view

Create view TotalPopulationVaccinated as 

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY LEFT(dea.location, 50), dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select *
From TotalPopulationVaccinated