# Patients EHR SQL Data Cleaning Project

## Project Overview

This project demonstrates an ETL-style data cleaning workflow using PostgreSQL on a synthetic Electronic Health Record (EHR) dataset.

The goal is to transform raw healthcare data into a clean, analysis-ready dataset by identifying and resolving common data quality issues, including duplicate records, inconsistent formats, missing values, and datatype inconsistencies.

---

## Objective

Prepare raw EHR data for downstream healthcare analytics by:

- Importing raw CSV data into PostgreSQL
- Creating a staging environment for data cleaning
- Identifying and removing duplicate records
- Standardizing inconsistent data formats
- Converting text fields into appropriate data types
- Performing data quality validation checks

---

## Tools

- PostgreSQL 18
- pgAdmin 4
- SQL
- GitHub

---

## Dataset Description

The dataset contains simplified Electronic Health Record information:

| Column | Description |
|---|---|
| PatientID | Patient identifier |
| DateOfBirth | Patient date of birth |
| Gender | Patient gender |
| ZipCode | Patient ZIP code |
| PrimaryCondition | Primary medical condition |
| AdmissionDate | Hospital admission date |

Original dataset size:

- 74 records

---

## Data Cleaning Workflow

### 1. Data Preparation
- Created raw and staging tables
- Preserved original data while performing transformations in the staging environment

### 2. Duplicate Management
- Identified duplicate records using CTEs and `ROW_NUMBER()`
- Removed exact duplicate rows while preserving valid records

### 3. Data Standardization
- Standardized gender values (e.g., `M`, `male` → `Male`)
- Converted mixed date formats into PostgreSQL `DATE` datatype
- Converted Excel serial dates into standard dates
- Standardized ZIP code formatting

### 4. Data Quality Checks
- Checked for missing values
- Validated date ranges
- Verified cleaned data formats

---

## SQL Skills Demonstrated

- Database Management: CREATE TABLE, ALTER TABLE, INSERT, UPDATE, DELETE
- Data Cleaning: Duplicate removal, missing value handling, validation, datatype standardization
- Advanced SQL: CTEs, Window Functions, ROW_NUMBER(), CASE statements
- Data Transformation: Date parsing, type casting, pattern matching, date arithmetic
- PostgreSQL Functions: TO_DATE(), LENGTH(), NUMERIC conversion
