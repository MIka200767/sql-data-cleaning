-- Data Cleaning

-- 1. Remove Duplicates
-- 2. Standardize the Data 
-- 3. Null Values or blank values
-- 4. Remove Any Columns


create table layoffs_stagin
like layoffs;

insert layoffs_stagin
select * 
from layoffs;


select *, row_number() over( 
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as rw_number
from layoffs_stagin;

with duplicate_cte as (
select *, row_number() over( 
partition by company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) as rw_number
from layoffs_stagin
)
delete 
from duplicate_cte 
where rw_number > 1;

create table `layoffs_staging2` (
	`company` text, 
    `location` text,
    `industry` text, 
	`total_laid_off` int default null, 
    `percentage_laid_off` text, 
    `date` text, 
    `stage` text, 
	`country` text, 
    `funds_raised_millions` int default null,
	`rw_number` int 
) engine = InnoDB default charset = utf8mb4 collate = utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select *, row_number() over( 
partition by company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) as rw_number
from layoffs_stagin;

DELETE
from layoffs_staging2 
where rw_number > 1;

SELECT *
FROM layoffs_staging2
ORDER BY company;

-- standardizing data

select company, trim(company)
from layoffs_staging2;

UPDATE layoffs_staging2
set company = trim(company);

select *
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

update layoffs_staging2
set `date` = DATE_FORMAT(
        STR_TO_DATE(`date`, '%m/%d/%Y'),
        '%d-%m-%Y');
        
SELECT `date`
FROM layoffs_staging2;

alter table layoffs_staging2
modify column `date` date;

select * 
from layoffs_staging2;

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

select * 
from layoffs_staging2
where company like 'Bally%';

delete 
from layoffs_staging2
where total_laid_off is null or total_laid_off = ''
and percentage_laid_off is null or percentage_laid_off = '';

alter table layoffs_staging2
drop column rw_number;

select * from layoffs_staging2;

    






