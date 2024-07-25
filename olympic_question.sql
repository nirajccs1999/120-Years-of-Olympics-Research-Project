create database olympic;

select * from olympic;
select count(*) from olympic;

describe olympic;
use olympic;





CREATE TABLE olympic (
    ID INT,
    Name VARCHAR(255),
    Sex CHAR(1),
    Age INT,
    Height INT,
    Weight INT,
    Team VARCHAR(255),
    COUNTRY VARCHAR(255),
    Games VARCHAR(255),
    Year INT,
    Season VARCHAR(255),
    City VARCHAR(255),
    Sport VARCHAR(255),
    Event VARCHAR(255),
    Medal VARCHAR(255)
);



-- 1. Retrieve the number of athletes who participated in each Olympic game.

SELECT Games, COUNT(DISTINCT Name) AS AthleteCount, MIN(Year) AS Year
FROM olympic
GROUP BY Games
ORDER BY Year;

-- 2. Find the top 5 countries with the most medals in the history of the Olympics.

SELECT COUNTRY, COUNT(Medal) AS MedalCount
FROM olympic
WHERE Medal IS NOT NULL
GROUP BY COUNTRY
ORDER BY MedalCount DESC
LIMIT 5;


-- 3. Determine the average age of gold medalists over the decades.

SELECT (Year DIV 10) * 10 AS Decade, AVG(Age) AS AvgAge
FROM olympic
WHERE Medal = 'Gold'
GROUP BY Decade
ORDER BY Decade;


-- 4. List the sports which had female athletes only.

SELECT DISTINCT Sport
FROM olympic
WHERE Sport NOT IN (
    SELECT DISTINCT Sport
    FROM olympic
    WHERE Sex = 'M'
);


-- 5. Find the athletes who have won medals in more than one sport.

SELECT Name, COUNT(DISTINCT Sport) AS SportCount
FROM olympic
WHERE Medal IS NOT NULL
GROUP BY Name
HAVING SportCount > 1;


-- 6. Calculate the average height and weight of athletes over different seasons (Summer/Winter).

SELECT Season, AVG(Height) AS AvgHeight, AVG(Weight) AS AvgWeight
FROM olympic
GROUP BY Season;


-- 7. Identify the top 5 city which has hosted the Olympics the most number of times.

SELECT City, COUNT(DISTINCT Games) AS HostCount
FROM olympic
GROUP BY City
ORDER BY HostCount DESC
LIMIT 5;

-- 8.Find the most common age of athletes who have Won medal in the Olympics.

SELECT Age, COUNT(*) AS AthleteCount
FROM olympic
GROUP BY Age
ORDER BY AthleteCount DESC
LIMIT 10;

--  9. Determine the top 10 sports with the highest average number of medals won per event.

SELECT Sport, AVG(MedalCount) AS AvgMedals
FROM (
    SELECT Sport, Event, COUNT(Medal) AS MedalCount
    FROM olympic
    WHERE Medal IS NOT NULL
    GROUP BY Sport, Event
) AS EventMedals
GROUP BY Sport
ORDER BY AvgMedals DESC
LIMIT 10;


-- 10. Calculate the total number of medals won by athletes under the age of 20.

SELECT COUNT(Medal) AS MedalsWon
FROM olympic
WHERE Age < 20 AND Medal IS NOT NULL;

-- 11.Calculate the proportion of medals won by male vs. female athletes.
SELECT Sex, COUNT(Medal) AS MedalCount, 
		(COUNT(Medal) * 100.0 / (SELECT COUNT(Medal) 
FROM olympic 
WHERE Medal IS NOT NULL)) AS MedalProportion
FROM olympic
WHERE Medal IS NOT NULL
GROUP BY Sex;


-- 12. Determine the top 10 athletes with the most Olympic participations.

SELECT Name, COUNT(DISTINCT Games) AS ParticipationCount
FROM olympic
GROUP BY Name
ORDER BY ParticipationCount DESC
LIMIT 10;

-- 13. List the events that have been introduced in the last 30 years.

SELECT DISTINCT Event
FROM olympic
WHERE Year >= (SELECT MAX(Year) - 30 FROM olympic);


-- 14.  Identify the correlation between the age of athletes and the number of medals won.

SELECT Age, COUNT(Medal) AS MedalCount
FROM olympic
WHERE Medal IS NOT NULL
GROUP BY Age
ORDER BY Age;


-- 15. Determine the change in medal distribution before and after major historical events (e.g., World Wars).

SELECT 
    COUNTRY, 
    AVG(CASE WHEN Year < 1945 THEN 1 ELSE 0 END) AS pre_WWII_medals,
    AVG(CASE WHEN Year >= 1945 THEN 1 ELSE 0 END) AS post_WWII_medals
FROM olympic
GROUP BY COUNTRY;


--  16 show top 5  countries has the most improvement in medal counts from one Olympic Games to the next?

SELECT COUNTRY, AVG(improvement) AS avg_improvement
FROM (SELECT COUNTRY, 
	(medal_count - LAG(medal_count, 1) OVER (PARTITION BY COUNTRY ORDER BY Year)) AS improvement
    FROM (SELECT COUNTRY, Year, COUNT(*) AS medal_count FROM olympic GROUP BY COUNTRY, Year
    ) AS yearly_medals
) AS improvements
WHERE improvement IS NOT NULL
GROUP BY COUNTRY
ORDER BY avg_improvement DESC
LIMIT 5;


-- 17 . top 10  city has hosted the most diverse set of events (different sports)?

SELECT 
    City, 
    COUNT(DISTINCT Sport) AS unique_sports
FROM olympic
GROUP BY City
ORDER BY unique_sports DESC
LIMIT 10;


-- 18. top 10 country has the highest ratio of gold medals to total medals won?

SELECT 
    COUNTRY, 
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) / COUNT(*) AS gold_ratio
FROM olympic
GROUP BY COUNTRY
ORDER BY gold_ratio DESC
LIMIT 10;



-- 19. Which sports have seen the most growth in the number of participating countries over the years?

WITH sports_growth AS (
    SELECT 
        Sport, 
        Year, 
        COUNT(DISTINCT COUNTRY) AS country_count
    FROM olympic
    GROUP BY Sport, Year
),
growth_diff AS (
    SELECT 
        Sport, 
        country_count - LAG(country_count, 1) OVER (PARTITION BY Sport ORDER BY Year) AS growth
    FROM sports_growth
)
SELECT 
    Sport, 
    AVG(growth) AS avg_growth
FROM growth_diff
GROUP BY Sport
ORDER BY avg_growth DESC
LIMIT 10;

-- 20.Analyze the performance of new participating countries in their first Olympics.
WITH first_olympics AS (SELECT COUNTRY, MIN(Year) AS first_year
    FROM olympic GROUP BY COUNTRY
)
SELECT olympic.COUNTRY, olympic.Year, COUNT(*) AS medal_count
FROM olympic
JOIN first_olympics ON olympic.COUNTRY = first_olympics.COUNTRY 
AND olympic.Year = first_olympics.first_year
GROUP BY olympic.COUNTRY, olympic.Year
ORDER BY medal_count DESC
limit 5;














