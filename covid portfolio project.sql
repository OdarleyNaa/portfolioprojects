SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

--SELECTING THE DATA TO BE USED

SELECT location,date,total_cases,new_cases,total_deaths, population
FROM CovidDeaths
order by 1,2
---ANALYSIS OF DATA BY LOCATION

--TOTAL CASES VS TOTAL DEATH

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE continent is not null
order by 1,2


--total cases vs death BY LOCATION

SELECT location,MAX(total_deaths) as highestdeath,population
FROM CovidDeaths
WHERE continent is not null
GROUP BY location,population
order by 2 desc

--total cases vs death in ghana

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE location ='Ghana'
order by 1,2

--Total cases vs poplation
--showing the percentage of the population that contracted covid various locations around the world

SELECT location,date,total_cases,population, (total_cases/population)*100 AS totalcasesvspop
FROM CovidDeaths
order by 1,2

--Total cases vs poplation 
--showing the percentage of the population that contracted covid in Ghana

SELECT location,date,total_cases,population, (total_cases/population)*100 AS totalcasesvspop
FROM CovidDeaths
WHERE location ='Ghana' 
order by 1,2
 
 --highest infested country as compared to thier population

 SELECT location,MAX(total_cases) as highesttotalcases,population, MAX((total_cases/population))*100 AS Highestinfectedpop
FROM CovidDeaths
Group by location,population
order by 4 desc

---looking at the location with the highest total cases

SELECT location,MAX(total_cases) as highesttotalcases,population
FROM CovidDeaths
WHERE continent is not null
Group by location,population
order by 2 desc


---ANALYSIS BY CONTINENTS

--looking at the continent with the highest total deaths 

SELECT location,MAX(total_deaths) as highestdeath
FROM CovidDeaths
WHERE continent is null
GROUP BY location
order by 2 desc

---looking at the continents with the highest recorded cases

SELECT location,MAX(total_cases) as highesttotalcases
FROM CovidDeaths
WHERE continent is null
Group by location
order by 2 desc

---GLOBAL	
---SHOW THE TOTAL NEW CASES AS OPPOSE NEW DEATHS GLOBALLY

SELECT date, SUM(new_cases) as totalnewcases,SUM(new_deaths) as totalnewdeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM CovidDeaths
--WHERE location ='Ghana'
WHERE continent is not null
GROUP BY DATE	
order by 2,3 DESC

--SHOWING THE TOTAL CASES VS TOTAL DEATHS GLOBALLY

SELECT date, SUM(total_cases) as totalcases,SUM(total_deaths) as totaldeaths, (SUM(total_deaths)/SUM(total_cases))*100 AS death_percentage
FROM CovidDeaths
--WHERE location ='Ghana'
WHERE continent is not null
GROUP BY DATE	
order by 2,3 DESC


---VACCINATION ANALYSIS

---JOINING THE COVID DEATH DATA TO THE COVID VANICITIONS

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location 
	and dea.date = vac.date

	---showing how many people got vaccinated in each location vs their population USING two different approaches

	---USING CTE
	SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations
	,SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollovervaccount 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

	WITH VACVSPOP (continent , location, date,population,new_vaccination , rollovervaccount )
	as
	(
	SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations
	,SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollovervaccount 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	)
	SELECT *, (rollovervaccount/population)*100 as percentageofpeoplevaccinated
	FROM VACVSPOP

	---showing how many people got vaccinated in each location vs their population
	---USING TEMP TABLE
	DROP TABLE if exists #PERCENTAGEVACCINATED
	CREATE TABLE #PERCENTAGEVACCINATED
	(
	Continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	rollerovercount numeric
	)

	insert into #PERCENTAGEVACCINATED
	SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations
	,SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollovervaccount 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL

	SELECT *, (rollerovercount/population)*100 as percentageofpeoplevaccinated
	FROM #PERCENTAGEVACCINATED

	---creating view for further visualizations

	create view PERCENTAGEVACCINATED as
	SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations
	,SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollovervaccount 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL

	create view totaldeathpercontinents as
	SELECT location,MAX(total_deaths) as highestdeath
FROM CovidDeaths
WHERE continent is null
GROUP BY location

create view totalcasespercontinents as
SELECT location,MAX(total_cases) as highesttotalcases
FROM CovidDeaths
WHERE continent is null
Group by location

create view percentageoftotalcasesvspopperlocation as
SELECT location,date,total_cases,population, (total_cases/population)*100 AS totalcasesvspop
FROM CovidDeaths

create view highestinfectedlocation as 
SELECT location,MAX(total_cases) as highesttotalcases,population
FROM CovidDeaths
WHERE continent is not null
Group by location,population
