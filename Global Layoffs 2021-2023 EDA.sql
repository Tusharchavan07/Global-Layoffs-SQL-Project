-- Exploratory Data Anlysis

SELECT * 
FROM world_layoffs.layoffs_staging2;

-- Checking highest number of layoff

SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;


-- Highest percentage of layoffs

SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;


-- Which company has 1 as 100 percetange of layoff
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1;
-- after going through data we have found that these are mostly startups who went out of business during this time


-- lets order by funds_raised_millions we can see how big some of the companies were

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- Found some big companies as well who raised signifiant amount of funds


-- Companies with the biggest single Layoff

SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;
-- google had most 12000 single lay off


-- Companies with the most Total Layoffs

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;
-- Amazon top the list at most total layoffs


-- Some basic analysis

-- by location
SELECT location, country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location, country
ORDER BY 3 DESC
LIMIT 10;

-- by year
SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;

-- by industry
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- getting insight of top 3 companies had most laid off each year

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;


-- Checking the above query
SELECT company, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE year(`date`) = 2020
GROUP BY company
ORDER BY total_off DESC
LIMIT 3;



-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;


