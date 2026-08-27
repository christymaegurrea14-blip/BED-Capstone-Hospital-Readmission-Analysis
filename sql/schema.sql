-- =============================================================
-- Hospital Readmission Analysis — Diabetes 130-US Hospitals
-- Checkpoint 1, Task 1.3: Relational Database Design
--
-- STEP 1 of 3 — SCHEMA ONLY (no data from diabetic_data.csv yet)
--
-- How to use this file in phpMyAdmin:
--   1. phpMyAdmin -> Import tab -> choose this file -> Go.
--      This creates the hospital_readmission database, the raw
--      staging table, the three lookup tables (pre-populated),
--      and the empty patients / encounters tables.
--   2. Click into the new `diabetic_data_raw` table -> Import tab
--      -> upload data/diabetic_data.csv -> Format: CSV ->
--      check "The first line of the file contains the table
--      column names" -> Go. This loads the 101,766 raw rows.
--   3. phpMyAdmin -> Import tab -> choose load_data.sql -> Go.
--      This transforms the raw rows into the cleaned patients /
--      encounters tables.
--   4. Run the queries in 02_task1.4_query_report.sql.
--
-- Dataset : Diabetes 130-US Hospitals for Years 1999-2008
-- Source  : UCI Machine Learning Repository
--           https://archive.ics.uci.edu/dataset/296/diabetes+130-us+hospitals+for+years+1999-2008
-- Files   : data/diabetic_data.csv (encounter-level records)
--           data/IDS_mapping.csv   (lookup codes used below)
-- Access date: [INSERT DATE ACCESSED]
--
-- Target RDBMS: MySQL 8.0+ / MariaDB (phpMyAdmin default).
-- =============================================================

CREATE DATABASE IF NOT EXISTS hospital_readmission;
USE hospital_readmission;

-- -------------------------------------------------------------
-- 1. RAW STAGING TABLE
--    Mirrors diabetic_data.csv column-for-column (all VARCHAR)
--    so the raw file can be imported as-is via phpMyAdmin's CSV
--    import, missing values kept as the literal '?' used by the
--    source file, before any cleaning or type conversion happens.
-- -------------------------------------------------------------
DROP TABLE IF EXISTS diabetic_data_raw;
CREATE TABLE diabetic_data_raw (
    encounter_id                VARCHAR(20),
    patient_nbr                 VARCHAR(20),
    race                        VARCHAR(30),
    gender                      VARCHAR(15),
    age                         VARCHAR(15),
    weight                      VARCHAR(15),
    admission_type_id           VARCHAR(5),
    discharge_disposition_id    VARCHAR(5),
    admission_source_id         VARCHAR(5),
    time_in_hospital            VARCHAR(5),
    payer_code                  VARCHAR(10),
    medical_specialty           VARCHAR(50),
    num_lab_procedures          VARCHAR(5),
    num_procedures              VARCHAR(5),
    num_medications             VARCHAR(5),
    number_outpatient           VARCHAR(5),
    number_emergency            VARCHAR(5),
    number_inpatient            VARCHAR(5),
    diag_1                      VARCHAR(10),
    diag_2                      VARCHAR(10),
    diag_3                      VARCHAR(10),
    number_diagnoses            VARCHAR(5),
    max_glu_serum               VARCHAR(10),
    A1Cresult                   VARCHAR(10),
    metformin                   VARCHAR(10),
    repaglinide                 VARCHAR(10),
    nateglinide                 VARCHAR(10),
    chlorpropamide              VARCHAR(10),
    glimepiride                 VARCHAR(10),
    acetohexamide                VARCHAR(10),
    glipizide                   VARCHAR(10),
    glyburide                   VARCHAR(10),
    tolbutamide                 VARCHAR(10),
    pioglitazone                VARCHAR(10),
    rosiglitazone                VARCHAR(10),
    acarbose                    VARCHAR(10),
    miglitol                    VARCHAR(10),
    troglitazone                 VARCHAR(10),
    tolazamide                   VARCHAR(10),
    examide                      VARCHAR(10),
    citoglipton                  VARCHAR(10),
    insulin                      VARCHAR(10),
    `glyburide-metformin`        VARCHAR(10),
    `glipizide-metformin`        VARCHAR(10),
    `glimepiride-pioglitazone`   VARCHAR(10),
    `metformin-rosiglitazone`    VARCHAR(10),
    `metformin-pioglitazone`     VARCHAR(10),
    `change`                     VARCHAR(5),
    diabetesMed                  VARCHAR(5),
    readmitted                   VARCHAR(5)
);

-- NOTE: this table is intentionally left empty here. Load it via
-- phpMyAdmin -> diabetic_data_raw table -> Import tab -> CSV
-- (see Step 2 in the header above), then run load_data.sql.

-- -------------------------------------------------------------
-- 2. LOOKUP TABLES
--    Sourced from IDS_mapping.csv, distributed with the dataset.
-- -------------------------------------------------------------
DROP TABLE IF EXISTS admission_type;
CREATE TABLE admission_type (
    admission_type_id  INT PRIMARY KEY,
    description         VARCHAR(50) NOT NULL
);
INSERT INTO admission_type (admission_type_id, description) VALUES
(1,'Emergency'), (2,'Urgent'), (3,'Elective'), (4,'Newborn'),
(5,'Not Available'), (6,'NULL'), (7,'Trauma Center'), (8,'Not Mapped');

DROP TABLE IF EXISTS discharge_disposition;
CREATE TABLE discharge_disposition (
    discharge_disposition_id  INT PRIMARY KEY,
    description                 VARCHAR(120) NOT NULL
);
INSERT INTO discharge_disposition (discharge_disposition_id, description) VALUES
(1,'Discharged to home'),
(2,'Discharged/transferred to another short term hospital'),
(3,'Discharged/transferred to SNF'),
(4,'Discharged/transferred to ICF'),
(5,'Discharged/transferred to another type of inpatient care institution'),
(6,'Discharged/transferred to home with home health service'),
(7,'Left AMA'),
(8,'Discharged/transferred to home under care of Home IV provider'),
(9,'Admitted as an inpatient to this hospital'),
(10,'Neonate discharged to another hospital for neonatal aftercare'),
(11,'Expired'),
(12,'Still patient or expected to return for outpatient services'),
(13,'Hospice / home'),
(14,'Hospice / medical facility'),
(15,'Discharged/transferred within this institution to Medicare approved swing bed'),
(16,'Discharged/transferred/referred another institution for outpatient services'),
(17,'Discharged/transferred/referred to this institution for outpatient services'),
(18,'NULL'),
(19,'Expired at home. Medicaid only, hospice.'),
(20,'Expired in a medical facility. Medicaid only, hospice.'),
(21,'Expired, place unknown. Medicaid only, hospice.'),
(22,'Discharged/transferred to another rehab fac including rehab units of a hospital'),
(23,'Discharged/transferred to a long term care hospital'),
(24,'Discharged/transferred to a nursing facility certified under Medicaid but not certified under Medicare'),
(25,'Not Mapped'),
(26,'Unknown/Invalid'),
(27,'Discharged/transferred to a federal health care facility'),
(28,'Discharged/transferred/referred to a psychiatric hospital of psychiatric distinct part unit of a hospital'),
(29,'Discharged/transferred to a Critical Access Hospital (CAH)'),
(30,'Discharged/transferred to another Type of Health Care Institution not Defined Elsewhere');

DROP TABLE IF EXISTS admission_source;
CREATE TABLE admission_source (
    admission_source_id  INT PRIMARY KEY,
    description             VARCHAR(80) NOT NULL
);
INSERT INTO admission_source (admission_source_id, description) VALUES
(1,'Physician Referral'), (2,'Clinic Referral'), (3,'HMO Referral'),
(4,'Transfer from a hospital'), (5,'Transfer from a Skilled Nursing Facility (SNF)'),
(6,'Transfer from another health care facility'), (7,'Emergency Room'),
(8,'Court/Law Enforcement'), (9,'Not Available'),
(10,'Transfer from critical access hospital'), (11,'Normal Delivery'),
(12,'Premature Delivery'), (13,'Sick Baby'), (14,'Extramural Birth'),
(15,'Not Available'), (17,'NULL'), (18,'Transfer From Another Home Health Agency'),
(19,'Readmission to Same Home Health Agency'), (20,'Not Mapped'),
(21,'Unknown/Invalid'), (22,'Transfer from hospital inpt/same fac reslt in a sep claim'),
(23,'Born inside this hospital'), (24,'Born outside this hospital'),
(25,'Transfer from Ambulatory Surgery Center'), (26,'Transfer from Hospice');

-- -------------------------------------------------------------
-- 3. NORMALIZED TABLES (cleaned, typed schema) -- created empty
--    patients   = one row per patient_nbr (demographics)
--    encounters = one row per hospital stay, FK back to patients
--                 and to the three lookup tables above.
--    Populated by load_data.sql (Step 3), after diabetic_data_raw
--    has been loaded from the CSV (Step 2).
-- -------------------------------------------------------------
DROP TABLE IF EXISTS encounters;
DROP TABLE IF EXISTS patients;

CREATE TABLE patients (
    patient_nbr   BIGINT PRIMARY KEY,
    race          VARCHAR(30),
    gender        VARCHAR(15),
    age           VARCHAR(15),   -- banded age group, e.g. [60-70)
    weight        VARCHAR(15)    -- banded weight group; mostly missing ('?') in the source data
);

CREATE TABLE encounters (
    encounter_id                BIGINT PRIMARY KEY,
    patient_nbr                 BIGINT NOT NULL,
    admission_type_id           INT,
    discharge_disposition_id    INT,
    admission_source_id         INT,
    time_in_hospital            SMALLINT,
    payer_code                  VARCHAR(10),
    medical_specialty           VARCHAR(50),
    num_lab_procedures          SMALLINT,
    num_procedures              SMALLINT,
    num_medications              SMALLINT,
    number_outpatient           SMALLINT,
    number_emergency            SMALLINT,
    number_inpatient            SMALLINT,
    diag_1                      VARCHAR(10),
    diag_2                      VARCHAR(10),
    diag_3                      VARCHAR(10),
    number_diagnoses            SMALLINT,
    max_glu_serum               VARCHAR(10),
    A1Cresult                   VARCHAR(10),
    change_med                  VARCHAR(5),   -- source column: change
    diabetes_med                VARCHAR(5),   -- source column: diabetesMed
    readmitted                  VARCHAR(5),   -- target variable: NO / <30 / >30
    CONSTRAINT fk_enc_patient
        FOREIGN KEY (patient_nbr) REFERENCES patients(patient_nbr),
    CONSTRAINT fk_enc_admtype
        FOREIGN KEY (admission_type_id) REFERENCES admission_type(admission_type_id),
    CONSTRAINT fk_enc_dischg
        FOREIGN KEY (discharge_disposition_id) REFERENCES discharge_disposition(discharge_disposition_id),
    CONSTRAINT fk_enc_admsrc
        FOREIGN KEY (admission_source_id) REFERENCES admission_source(admission_source_id)
);

CREATE INDEX idx_enc_readmitted ON encounters (readmitted);
CREATE INDEX idx_pat_age ON patients (age);

-- Schema created. Next: load data/diabetic_data.csv into
-- diabetic_data_raw via phpMyAdmin's per-table CSV import, then
-- run load_data.sql.
