# Patients EHR SQL Data Cleaning Project

## Project Overview

This project demonstrates a complete **ETL-style data cleaning workflow** using PostgreSQL on a synthetic Electronic Health Record (EHR) dataset.

The goal is to transform raw healthcare data into a clean, analysis-ready dataset by identifying and resolving data quality issues, including duplicate records, inconsistent formats, missing values, and datatype standardization.

---

## Objective

Prepare a raw EHR dataset for downstream healthcare analytics by:

- Creating a structured database table
- Loading raw CSV data into PostgreSQL
- Creating a staging environment for cleaning
- Identifying and removing duplicate records
- Standardizing inconsistent data formats
- Converting text fields into appropriate data types
- Validating data quality

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
| PatientID | Unique patient identifier |
| DateOfBirth | Patient date of birth |
| Gender | Patient gender |
| ZipCode | Patient ZIP code |
| PrimaryCondition | Main medical condition |
| AdmissionDate | Hospital admission date |

Original dataset size:

- 74 records

---


