SELECT * 
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
Order by 3,4


--SELECT * 
--FROM [Portfolio Project].dbo.CovidVaccinations$
--Order by 3,4

--Select Data that we are going to be using


SELECT location, date, total_cases, new_cases, total_deaths, population  
FROM [Portfolio Project].dbo.CovidDeaths$
Order By 1,2


-- Looking at Total Cases vs Total Daeths


SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE location like '%states&'
Order By 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid


SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE location like '%United States%'
Order By 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths$
--WHERE location like '%States%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
--WHERE location like '%States%
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount desc



--Let's Break Things Down by Continet


SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
--WHERE location like '%States%
WHERE continent is null
GROUP BY continent
ORDER BY TotalDeathCount desc


--SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
--FROM [Portfolio Project].dbo.CovidDeaths$
----WHERE location like '%States%
--WHERE continent is null
--GROUP BY location
--ORDER BY TotalDeathCount desc


-- Showing the Continets with the highest death count per population


SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
--WHERE location like '%States%
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- Global Numbers

SELECT date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) ,SUM(cast(new_deaths as int))as total_deaths, SUM (new_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
--WHERE location like '%states&'
WHERE continent is not null
Group By date
Order By 1,2

--The other Query for to find Global Numbers without the date (below). Remember to reomove date and block out Group by date to get the total cases, total deaths, and death percentage.

SELECT SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) ,SUM(cast(new_deaths as int))as total_deaths, SUM (new_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
--WHERE location like '%states&'
WHERE continent is not null
--Group By date
Order By 1,2


--Using the Covid Vaccination Table Next.

SELECT * 
FROM [Portfolio Project].dbo.CovidVaccinations$


--Next Goint to Join both the Covid Deaths and Vaccination table together.


SELECT * 
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date

	-- Looking at the Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea. location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	Order By 1,2,3

	--Using a CTE

	With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
	as
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea. location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--Order By 1,2,3
	)
Select *, (RollingPeopleVaccinated/Population)*100               -- Note* If you wanted to look at the MAX # of Vaccinated people you can, but, you have to get rid of date and keep the rest, because the date category will throw your numbers off.
From PopvsVac




-- Temp Table


Create Table #PercentPopulationVaccinated    -- If you plan to make changes, it would be wise to put (DROP Table if exists #PercentagePopulationVaccinated)
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
 
Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea. location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--Order By 1,2,3

	Select *, (RollingPeopleVaccinated/Population) *100
	FROM #PercentPopulationVaccinated



	-- Creating View to store data for later visualization

	Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea. location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--Order By 2,3

	Select *
	From PercentPopulationVaccinated