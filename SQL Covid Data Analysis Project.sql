SELECT * 
FROM [Covid Data Analysis]..CovidDeaths
ORDER BY 3,4;


--SELECT * 
--FROM covid_data..CovidVaccinations
--ORDER BY 3,4;

--selecting the data that I am going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Data Analysis]..CovidDeaths
WHERE location = 'South Africa'
ORDER BY 1,2;

--total cases vs total deaths
--death_percentage shows the chances of dying if you contract covid in South Africa
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM [Covid Data Analysis]..CovidDeaths
WHERE location = 'South Africa'
ORDER BY 1,2;

--looking at the total case vs population
--shows the percentage of the population that got covid
SELECT location, date, population, total_cases, (total_cases / population) * 100 AS covid_population_percentage
FROM [Covid Data Analysis]..CovidDeaths
WHERE location = 'South Africa'
ORDER BY 1,2;

--what country has the highest covid cases compared to population
SELECT location, population, MAX(total_cases) AS highest_covid_cases, MAX((total_cases / population)) * 100 AS highest_population_cases
FROM [Covid Data Analysis]..CovidDeaths
GROUP BY location, population
ORDER BY highest_population_cases DESC;

--showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM [Covid Data Analysis]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


--showing location with the highest death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM [Covid Data Analysis]..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;


--showing continents with the highest death count
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM [Covid Data Analysis]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


--GLOBAL NUMBERS

--total number of new cases across the world by date
SELECT date, sum(new_cases) AS total_cases
FROM [Covid Data Analysis]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


--looking at the death percentage across the world
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) /  sum(new_cases) * 100 AS 
death_percentage
FROM [Covid Data Analysis]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


--looking at total cases, total deaths and death perecentage across the world
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) /  sum(new_cases) * 100 AS 
death_percentage
FROM [Covid Data Analysis]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;



--joining both tables
SELECT *
FROM [Covid Data Analysis]..CovidDeaths dea
JOIN [Covid Data Analysis]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;


--looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Covid Data Analysis]..CovidDeaths dea
JOIN [Covid Data Analysis]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--rolling the number of people vaccinatd
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY 
dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Covid Data Analysis]..CovidDeaths dea
JOIN [Covid Data Analysis]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--get perecentage of vaccinated people from the rolling number
--using cte
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER 
(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Covid Data Analysis]..CovidDeaths dea
JOIN [Covid Data Analysis]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (rolling_people_vaccinated / population) * 100 AS vaccinated_population_population
FROM pop_vs_vac;


--temp table
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER 
(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Covid Data Analysis]..CovidDeaths dea
JOIN [Covid Data Analysis]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * , (rolling_people_vaccinated / population) * 100 AS vaccinated_population_population
FROM #percent_population_vaccinated;


--creating view to store data for later visualizations
CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER 
(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Covid Data Analysis]..CovidDeaths dea
JOIN [Covid Data Analysis]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


SELECT *
FROM percent_population_vaccinated;