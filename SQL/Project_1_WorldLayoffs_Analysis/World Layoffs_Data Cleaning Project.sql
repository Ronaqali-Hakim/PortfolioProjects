SELECT *
FROM layoffs;


-- 1. Create a staging table

CREATE TABLE layoffs_staging
LIKE layoffs;


SELECT *
FROM layoffs_staging;


INSERT layoffs_staging
SELECT *
FROM layoffs;


-- Remove duplicates

SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


-- Verify duplicates by checking companies

SELECT *
FROM layoffs_staging2
WHERE company = 'Casper';


-- These are the duplicates and ok to be deleted

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- Create a second staging table with the row number column to easily delete duplicates

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


SELECT *
FROM layoffs_staging2;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


DELETE FROM layoffs_staging2
WHERE row_num > 1;


SELECT company
FROM layoffs_staging2;


-- 2. Standardize the data

-- Remove empty spaces before data in company

SELECT company, TRIM(company)
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT DISTINCT company
FROM layoffs_staging2;


SELECT *
FROM layoffs_staging2;


SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;


-- Crypto has multiple variations. Industry name for crypto standardized to 'Crypto'

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
 

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


-- Few entries for United States have a trailing period. Removed the period. 

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';


SELECT DISTINCT country, TRIM(TRAILING ('.') FROM country)
FROM layoffs_staging2
ORDER BY 1;


UPDATE layoffs_staging2
SET country = TRIM(TRAILING ('.') FROM country)
WHERE country LIKE 'United States%';


SELECT *
FROM layoffs_staging2;

-- Standardize date format

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') `date`
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- Convert data type for date column

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;


SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;


SELECT *
FROM layoffs_staging2;

-- 3. Look at Blank and Null spaces

-- Starting with indsutry

SELECT *
FROM layoffs_staging2
WHERE industry = '';


SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';


-- Airbnb seems to be in the 'Travel' industry but not populated for some entries. 
-- Seems to be the same for others and can be populated easily.

SELECT layoffs_staging2.company, layoffs_staging2.industry
FROM layoffs_staging2;


SELECT t1.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
WHERE t1.industry = ''
AND t2.industry != '';


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry = ''
AND t2.industry != '';

-- Testing fix

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;

-- Bally's is the only company with an unknown industry and cannot be populated.


-- Checking other Null values
-- The columns where both total_laid_off and percentage_laid_off columns are Null, are not going to be useful in data exploration and can be deleted.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove the row_num column created earlier for quicker processing

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT *
FROM layoffs_staging2;










