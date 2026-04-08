SELECT *
FROM layoffs_staging2;


-- Date range for the layoffs for this data set

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


-- How big these lay offs were

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;


-- Looking at companies that laid off a 100% of their work force

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- mostly start ups. Looks like all went out of business during COVID

-- Looking at the total lay offs by each company

SELECT company, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- Highest number of layoffs came from some of the most dominant firms. 
-- Suggests they aggressively adjusted workforce levels during 2020–2023, reflecting large-scale strategic recalibration rather than just economic distress.

-- Looking at total number of people laid off by country to identify which countries were most impacted by layoffs and compare their overall scale.

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- This suggests layoffs were concentrated in major tech and business hubs like the United States, India, and Netherlands, where large global companies operate and scale workforce changes.


SELECT *
FROM layoffs_staging2;


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
-- This suggests layoffs were highest among later-stage and mature companies (Post-IPO, Acquired, Series C), where scaling corrections and profitability pressures are more pronounced.


SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Calculating monthly layoffs and then building a cumulative (running) total over time to track how layoffs progressed.

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
-- Layoffs peaked in Q1 2020 and Q1 2023, highlighting major workforce cuts during periods of economic shock and subsequent market correction.


SELECT company, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;


-- Identifying the top 5 companies and industries with the highest layoffs in each year using ranking.

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5;


WITH Industry_Year (industry, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
), Industry_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Industry_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Industry_Year_Rank
WHERE ranking <= 5 AND years = 2023;

-- The largest layoffs each year shifted across industries—early-stage. Highlighting that layoffs increasingly affected both core and diverse sectors over time.
-- Travel companies dominated 2020
-- Consumer and service sectors led in 2021
-- Retail, Transportation, and Finance saw the highest cuts in 2022
-- Widespread reductions across Consumer, Retail, Hardware, and Healthcare in 2023






































