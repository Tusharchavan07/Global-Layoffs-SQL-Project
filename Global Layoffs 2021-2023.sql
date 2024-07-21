-- DATA CLEANING

-- We have copied the layoffs table data to layoffs_staging because we don't want to do anything in raw data 
-- So we create a copy of the raw data using below queries

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-- 1.Removing duplicates

-- In the below query we craeted use the PARTITION BY to get the duplicates values
-- We use the CTE because we need to do filtering on row_num column

WITH duplicate_cte AS 
( 
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

SELECT * FROM layoffs_staging where company = "Better.com";

-- We cannot direclty delete the duplicates from CTE so we need to create another table, copy of the layoffs_staging

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2
WHERE row_num >1;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num >1;


-- 2.Standardize the Data 

SELECT DISTINCT industry
FROM layoffs_staging2;

-- Checking the Crypto indusrty as there are multiple names of it
SELECT *  
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- We have checked industry and company column lets check country column

SELECT DISTINCT country 
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- now we will check the date column
SELECT `date`
FROM layoffs_staging2; 

-- We found that the dates are in text data type need to change it to date type 
-- to change the date type we will convert text to date
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d%/%y')
FROM layoffs_staging2; 

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the data type properly

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 4.NULL values or Blank Values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

-- Now we check the NULL values in industry column

SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- As we can see Airbnb having two records and having Travel industry, we need to set the industry

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company  
WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL; 

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company  
SET t1.industry=t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL; 

SELECT * 
FROM layoffs_staging2;


-- 4.Remove unwanted columns and rows 

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;