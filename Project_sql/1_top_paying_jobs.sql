/*
Question: What are the toppaying data analyst jobs?
- Identify the top 10 highest-paying Data Analyst rols that are available remotely
- Focuses on jhob postings with specified salaries (remove nulls)
- Why? Highlight the top-paying opportunities for Data Analysts, offering insights into emplo
*/

SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM
    job_postings_fact AS jobs
LEFT JOIN company_dim AS company ON jobs.company_id = company.company_id
WHERE job_title_short = 'Data Analyst' AND
    job_work_from_home = TRUE AND
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;