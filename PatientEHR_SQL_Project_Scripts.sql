/*
Patient EHR Project

    ├── 01_create_raw_table and import cvs
    ├── 02_create_staging
    ├── 03_manage_duplicates
    ├── 04_standardize_data
    |        |- a. manage inconsistant input in'gender'
             |- b. 
    ├── 05_
    ├── 06_data_quality_checks
    └── 07_business_analysis
 */

-- 1_create_raw_table
DROP TABLE IF EXISTS patients_ehr;
CREATE TABLE patients_ehr (
    patient_id        VARCHAR(20),
    date_of_birth     TEXT,
    gender            VARCHAR(20),
    zip_code          VARCHAR(10),
    primary_condition TEXT,
    admission_date    TEXT
);

--Verify the dataset
Select *
FROM patients_ehr
LIMIT 10; 

SELECT COUNT(*) 
FROM patients_ehr;
-- output note: The dataset has a total of 74 rows

-- 2_create_staging 
DROP TABLE IF EXISTS patients_ehr_stg;
-- Create staging table with the same structure
CREATE TABLE patients_ehr_stg
(LIKE patients_ehr INCLUDING ALL);

-- Copy data into staging table
INSERT INTO patients_ehr_stg
SELECT *
FROM patients_ehr; 

-- Verify the staging table: 
Select *
FROM patients_ehr_stg
LIMIT 10; 

-- 3_manage_duplicates
-- Find duplicates using CTE and ROW_NUMBER()
WITH duplicate_cte AS 
(
SELECT *, 
	ROW_NUMBER()OVER(
		PARTITION BY 
			patient_id, 
			date_of_birth, 	
			gender, 
			zip_code, 
			primary_condition, 
			admission_date 
		ORDER BY patient_id
	)AS row_num
FROM patients_ehr_stg
)

SELECT *
FROM  duplicate_cte
WHERE row_num >1;
 -- OUTPUT NOTE: 2 duplicate rows. 

 -- Delete duplicate 
ALTER TABLE patients_ehr_stg
ADD COLUMN row_id SERIAL;

WITH duplicate_cte AS (
    SELECT row_id,
           ROW_NUMBER() OVER (
               PARTITION BY
                   patient_id,
                   date_of_birth,
                   gender,
                   zip_code,
                   primary_condition,
                   admission_date
               ORDER BY row_id
           ) AS row_num
    FROM patients_ehr_stg
)
DELETE FROM patients_ehr_stg
WHERE row_id IN (
    SELECT row_id
    FROM duplicate_cte
    WHERE row_num > 1
);

-- Verify duplicate were removed: 
SELECT COUNT(*) 
FROM patients_ehr_stg; 

-- 4_standardize_data

-- 4a. Manage inconsistent entries in 'gender'

-- Check inconsistency 
SELECT DISTINCT gender
FROM patients_ehr_stg; 
-- Output note: Male, M, male, Female, F 

UPDATE patients_ehr_stg
SET gender = CASE
    WHEN gender IN ('F', 'female', 'Female') THEN 'Female'
    WHEN gender IN ('M', 'male', 'Male') THEN 'Male'
    ELSE gender
END;

--Verify UPDATE
SELECT DISTINCT gender
FROM patients_ehr_stg; 

