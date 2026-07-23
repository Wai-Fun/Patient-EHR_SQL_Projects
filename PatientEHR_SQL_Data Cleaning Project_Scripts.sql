/*
Patient EHR Data Cleaning Project

    ├── 01_create_raw_table and import cvs
    ├── 02_create_staging
    ├── 03_manage_duplicates
    ├── 04_standardize_data
    	    ├── a. manage inconsistant input in'gender'
            ├── b. manage inconsistant DATE in 'date_of_birth'
			├── c. Manage inconsistant DATE in 'admission_date'
			├── d.Standardize zip_code to INTEGER 
			
    ├── 05_Handle Missing Values
    ├── 06_Remove Unnecessary Columns
    
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
-- Staging table is used as the working environment while preserving the original raw dataset.
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
-- Find duplicates using CTE, ROW_NUMBER() and PARTITION BY()
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
 -- OUTPUT NOTE: identified 2 duplicated rows. 

 -- Remove duplicate rows 
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

-- Verify duplicate rows were removed: 
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


--4b. Standardize DATE for date_of_birth 
-- inspect 'date_of_birth' 
SELECT date_of_birth
FROM patients_ehr_stg;  
-- Output note: Majority in the format YYYY-MM-DD; some in DD-MM-YYYY

--= Standardize 'date_of_birth'
-- create a new date_of_birth column 
ALTER TABLE patients_ehr_stg
ADD COLUMN date_of_birth_clean DATE;

UPDATE patients_ehr_stg
SET date_of_birth_clean =
    CASE
        WHEN date_of_birth LIKE '__-__-____'
            THEN TO_DATE(date_of_birth, 'DD-MM-YYYY')
        ELSE
            TO_DATE(date_of_birth, 'YYYY-MM-DD')
    END;

-- Verify update
SELECT date_of_birth_clean
FROM patients_ehr_stg;   

-- Check the range of date_of_birth_clean: 
SELECT 
    MAX(date_of_birth_clean) AS latest_dob,
    MIN(date_of_birth_clean) AS earliest_dob
FROM patients_ehr_stg;
-- Output note: there is not out of range DOB 

--4c. Standardize DATE for 'admission_date'
-- inspect 'admission_date' 
SELECT admission_date
FROM patients_ehr_stg;  
-- Output note: Two input appeared to be excel seriel date number: 45258, 45439.00 

ALTER TABLE patients_ehr_stg
ADD COLUMN admission_date_clean DATE;

UPDATE patients_ehr_stg
SET admission_date_clean =
    CASE
        WHEN admission_date LIKE '%-%'
            THEN TO_DATE(admission_date, 'DD-MM-YYYY')
        ELSE
            DATE '1899-12-30' + admission_date::NUMERIC::INTEGER
    END;

-- Verify Changes
SELECT admission_date_clean
FROM patients_ehr_stg;  

--4d. Standardize zip_code to INTEGER 
ALTER TABLE patients_ehr_stg
ADD COLUMN zip_code_clean INTEGER;

UPDATE patients_ehr_stg
	-- cast zip_code from numeric to integer and then to text (in case the zip_code start with 0)
SET zip_code_clean = zip_code::NUMERIC::INTEGER::TEXT; 

-- Check if any zip_code is not 5 digit
SELECT 
    zip_code,
    LENGTH(zip_code) AS len_zip_code
FROM patients_ehr_stg
WHERE LENGTH(zip_code) != 5;
-- output note: All zip code are 5 digit. 

-- Verify change
SELECT zip_code
FROM patients_ehr_stg;

-- Handle Missing Value

-- 5. check for missing values:
SELECT *
FROM patients_ehr_stg
WHERE 
    patient_id IS NULL OR patient_id = ''
    OR date_of_birth IS NULL OR date_of_birth = ''
    OR gender IS NULL OR gender = ''
    OR zip_code IS NULL OR zip_code = ''
    OR primary_condition IS NULL OR primary_condition = ''
    OR admission_date IS NULL OR admission_date = '';

	-- Output note: date_of_birth and zip_code, both have 3 null values. 	
	-- Will not take further action on null until analysis require so. 


-- 6. Remove Unnecessary Columns
ALTER TABLE patients_ehr_stg
DROP COLUMNS data_of_birth, gender, zip_code
