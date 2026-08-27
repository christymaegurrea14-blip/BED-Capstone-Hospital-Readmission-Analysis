-- =============================================================
-- Hospital Readmission Analysis — Diabetes 130-US Hospitals
-- Checkpoint 1, Task 1.3: Relational Database Design
--
-- Dataset : Diabetes 130-US Hospitals for Years 1999-2008
-- Source  : UCI Machine Learning Repository
--           https://archive.ics.uci.edu/dataset/296/diabetes+130-us+hospitals+for+years+1999-2008
-- Files   : data/diabetic_data.csv (encounter-level records)
--           data/IDS_mapping.csv   (lookup codes used below)
-- Access date: [INSERT DATE ACCESSED]
--
-- Target RDBMS: MySQL 8.0+ (uses window functions in Section 4).
-- For MySQL <8.0 / phpMyAdmin without window function support,
-- replace the ROW_NUMBER() step with a correlated subquery.
-- =============================================================

CREATE DATABASE IF NOT EXISTS hospital_readmission;
USE hospital_readmission;

-- -------------------------------------------------------------
-- 1. RAW STAGING TABLE
--    Mirrors diabetic_data.csv column-for-column (all VARCHAR)
--    so the raw file can be imported as-is, missing values kept
--    as the literal '?' used by the source file, before any
--    cleaning or type conversion happens.
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

-- Import the raw CSV into the staging table.
-- Adjust the file path to your local copy of diabetic_data.csv,
-- and make sure the server/client allow LOCAL INFILE.
--
-- LOAD DATA LOCAL INFILE 'data/diabetic_data.csv'
-- INTO TABLE diabetic_data_raw
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

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
-- 3. NORMALIZED TABLES (cleaned, typed schema)
--    patients  = one row per patient_nbr (demographics)
--    encounters = one row per hospital stay, FK back to patients
--                 and to the three lookup tables above.
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

-- -------------------------------------------------------------
-- 4. ETL: POPULATE THE NORMALIZED TABLES FROM THE RAW STAGING TABLE
--    - '?' is converted to NULL for cleaning.
--    - Each patient_nbr can appear on multiple encounters in the raw
--      file; one representative demographic row per patient is kept
--      (their earliest encounter on file).
-- -------------------------------------------------------------
INSERT INTO patients (patient_nbr, race, gender, age, weight)
SELECT patient_nbr, race, gender, age, weight
FROM (
    SELECT
        CAST(patient_nbr AS UNSIGNED)   AS patient_nbr,
        NULLIF(race, '?')                 AS race,
        gender,
        age,
        NULLIF(weight, '?')               AS weight,
        ROW_NUMBER() OVER (
            PARTITION BY patient_nbr
            ORDER BY CAST(encounter_id AS UNSIGNED)
        ) AS rn
    FROM diabetic_data_raw
) AS first_encounter_per_patient
WHERE rn = 1;

INSERT INTO encounters (
    encounter_id, patient_nbr, admission_type_id, discharge_disposition_id,
    admission_source_id, time_in_hospital, payer_code, medical_specialty,
    num_lab_procedures, num_procedures, num_medications, number_outpatient,
    number_emergency, number_inpatient, diag_1, diag_2, diag_3,
    number_diagnoses, max_glu_serum, A1Cresult, change_med, diabetes_med, readmitted
)
SELECT
    CAST(encounter_id AS UNSIGNED),
    CAST(patient_nbr AS UNSIGNED),
    CAST(admission_type_id AS UNSIGNED),
    CAST(discharge_disposition_id AS UNSIGNED),
    CAST(admission_source_id AS UNSIGNED),
    CAST(time_in_hospital AS UNSIGNED),
    NULLIF(payer_code, '?'),
    NULLIF(medical_specialty, '?'),
    CAST(num_lab_procedures AS UNSIGNED),
    CAST(num_procedures AS UNSIGNED),
    CAST(num_medications AS UNSIGNED),
    CAST(number_outpatient AS UNSIGNED),
    CAST(number_emergency AS UNSIGNED),
    CAST(number_inpatient AS UNSIGNED),
    NULLIF(diag_1, '?'),
    NULLIF(diag_2, '?'),
    NULLIF(diag_3, '?'),
    CAST(number_diagnoses AS UNSIGNED),
    max_glu_serum,
    A1Cresult,
    `change`,
    diabetesMed,
    readmitted
FROM diabetic_data_raw;

-- Medication columns (metformin, insulin, etc.) are kept in the raw
-- staging table only for CP1. They can be normalized into a separate
-- encounter_medications table in a later checkpoint if the analysis
-- needs per-drug detail.
