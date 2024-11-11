/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
Database Load Issues (follow if receiving permission denied when running SQL code below)

NOTE: If you are having issues with permissions. And you get error: 

'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'

1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `sql_course` database
3. Right-click `sql_course` and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of your csv files
    1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
5. Paste the following into `PSQL Tool`, (with the CORRECT file path)

\copy company_dim FROM 'C:\Users\manov\Documents\SQL\DataNerd\csv_files-20241003T005556Z-001\csv_files\company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM 'C:\Users\manov\Documents\SQL\DataNerd\csv_files-20241003T005556Z-001\csv_files\skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM 'C:\Users\manov\Documents\SQL\DataNerd\csv_files-20241003T005556Z-001\csv_files\job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM 'C:\Users\manov\Documents\SQL\DataNerd\csv_files-20241003T005556Z-001\csv_files\skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

SELECT * FROM company_dim;

-- NOTE: This has been updated from the video to fix issues with encoding

COPY company_dim
FROM 'C:\Users\manov\Documents\SQL\DataNerd\csv_files-20241003T005556Z-001\csv_files\company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM 'C:\Users\manov\Documents\SQL\DataNerd\csv_files-20241003T005556Z-001\csv_files\skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM 'C:\Users\manov\Documents\SQL\DataNerd\csv_files-20241003T005556Z-001\csv_files\job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM 'C:\Users\manov\Documents\SQL\DataNerd\csv_files-20241003T005556Z-001\csv_files\skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1
LIMIT 100;

CREATE TABLE january_jobs AS 
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT job_posted_date
FROM march_jobs;

SELECT
    job_title_short,
    job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact;

SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;

/*
SUBQUERIES
*/
SELECT *
FROM ( --Subquery starts here
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date)
    AS january_jobs;
)
--Subquery ends here

/*
Common table expressions (CTEs)
*/

WITH january_job AS ( --CTE starts
    SELECT *
    FROM january_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date)
) --CTE ends
SELECT *
FROM january_jobs;

SELECT 
    company_id,
    job_no_degree_mention
FROM
    job_postings_fact
WHERE
    job_no_degree_mention = true;

SELECT 
    company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN (
    SELECT 
    company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention = true
    ORDER BY 
        company_id
)
LIMIT 100;

-- Excersice of companies with the most number of job postings
WITH company_job_count AS (
SELECT
    company_id,
    COUNT(*) AS total_jobs
FROM
    job_postings_fact
GROUP BY
    company_id
)
SELECT company_dim.name AS company_name,
        company_job_count.total_jobs
FROM company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY
    total_jobs DESC;

SELECT *
FROM job_postings_fact
LIMIT 10;

SELECT *
FROM skills_job_dim


/*
 Problem using CTEs and Subqueries
*/
WITH remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = True
    GROUP BY
        skill_id
)
SELECT 
    skills.skill_id,
    skills as skill_name,
    skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5;

/*
UNIONS, this eliminates duplicates from the union
*/

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs;

-- UNION ALL, this will include duplicates

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs;

SELECT quarter1_job_postings.job_title_short,
        quarter1_job_postings.job_location,
        quarter1_job_postings.job_via,
        quarter1_job_postings.job_posted_date::DATE,
        quarter1_job_postings.salary_year_avg
FROM (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS quarter1_job_postings
WHERE
    quarter1_job_postings.salary_year_avg > 70000 AND
    quarter1_job_postings.job_title_short = 'Data Analyst'
ORDER BY
quarter1_job_postings.salary_year_avg DESC;
