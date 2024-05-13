SELECT * FROM portfolio_covid.coviddeaths 
	WHERE continent IS NOT NULL
    ORDER BY 3,4;

-- SELECT * FROM portfolio_covid.covidvaccinations ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population 
	FROM portfolio_covid.coviddeaths 
    WHERE continent IS NOT NULL
    ORDER BY 1, 2;
    
-- looking at total cases versus total deaths
-- shows likelihood of dying if you contract covid in a specific country
SELECT location, date, total_cases, total_deaths, 
	(total_deaths / total_cases) * 100 AS DeathPercentage
	FROM portfolio_covid.coviddeaths
    WHERE location like "%Turkey%" AND continent IS NOT NULL
    ORDER BY DeathPercentage DESC;
    
-- total cases versus population
-- shows what percentage of population got covid
SELECT location, date, population, total_cases, 
	(total_cases / population) * 100 AS CasePercentage
	FROM portfolio_covid.coviddeaths
    WHERE location like "%Turkey%" AND continent IS NOT NULL
    ORDER BY 1, 2;
    
SELECT location, date, population, total_cases, 
	(total_cases / population) * 100 AS CasePercentage
	FROM portfolio_covid.coviddeaths
    WHERE continent IS NOT NULL
    ORDER BY 1, 2;

-- Looking at the countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases / population)) * 100 AS CasePercentage
	FROM portfolio_covid.coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY location, population
    ORDER BY CasePercentage DESC;
    
-- Breaking down by the continent     
-- Continents with the highest death counts
SELECT continent, MAX(CAST(total_deaths as float)) AS TotalDeathCount
	FROM portfolio_covid.coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY continent
    ORDER BY TotalDeathCount DESC;

-- Global numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) AS TotalDeaths, 
	SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
	FROM portfolio_covid.coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY date
    ORDER BY 1,2;

-- Joining Covid Deaths and Covid Vaccinations table
SELECT * FROM portfolio_covid.coviddeaths dea
	JOIN portfolio_covid.covidvaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date;
        
-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
	FROM portfolio_covid.coviddeaths dea
	JOIN portfolio_covid.covidvaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3;

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingTotalVaccinations) AS
	(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
	FROM portfolio_covid.coviddeaths dea
	JOIN portfolio_covid.covidvaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	)

SELECT *, (RollingTotalVaccinations / Population) * 100 FROM PopvsVac;

-- Creating view for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
FROM portfolio_covid.coviddeaths dea
JOIN portfolio_covid.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


SELECT * FROM PercentPopulationVaccinated; 

