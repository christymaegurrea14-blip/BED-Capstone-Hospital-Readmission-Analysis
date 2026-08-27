-- =============================================================
-- Hospital Readmission Analysis — Diabetes 130-US Hospitals
-- Checkpoint 1, Task 1.3: Relational Database Design
--
-- STEP 3 of 3 — TRANSFORM raw rows into the cleaned schema
--
-- Run this AFTER:
--   1. schema.sql has been imported (creates the tables), AND
--   2. data/diabetic_data.csv has been imported into the
--      diabetic_data_raw table via phpMyAdmin's per-table
--      CSV import (Import tab on that table, Format: CSV,
--      "first line contains column names" checked).
--
-- What this does:
--   - '?' is converted to NULL for cleaning.
--   - Each patient_nbr can appear on multiple encounters in the
--     raw file; one representative demographic row per patient
--     is kept (their earliest encounter on file) for `patients`.
--   - All 101,766 raw rows are cast to proper types and loaded
--     into `encounters`.
--
-- If MySQL/MariaDB errors on ROW_NUMBER() (needs MySQL 8.0+ /
-- MariaDB 10.2+), see the correlated-subquery fallback commented
-- at the bottom of this file.
-- =============================================================

USE hospital_readmission;

-- Make this script safe to re-run: clear any rows left over from a
-- previous (partial or full) run before reloading. DELETE (not
-- TRUNCATE) is used so this works as a plain statement with no
-- session-level FOREIGN_KEY_CHECKS juggling — encounters is cleared
-- first since it holds the FK to patients.
DELETE FROM encounters;
DELETE FROM patients;

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
            PARTITION BY CAST(patient_nbr AS UNSIGNED)
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

-- -------------------------------------------------------------
-- Verify the load worked (expect 101766 / 101766 / 71518):
-- -------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM diabetic_data_raw) AS raw_rows,
    (SELECT COUNT(*) FROM encounters)        AS encounter_rows,
    (SELECT COUNT(*) FROM patients)          AS patient_rows;

-- -------------------------------------------------------------
-- FALLBACK: if your MySQL/MariaDB version doesn't support
-- ROW_NUMBER() OVER (...), replace the `patients` INSERT above
-- with this correlated-subquery version instead:
--
-- INSERT INTO patients (patient_nbr, race, gender, age, weight)
-- SELECT
--     CAST(r.patient_nbr AS UNSIGNED),
--     NULLIF(r.race, '?'),
--     r.gender,
--     r.age,
--     NULLIF(r.weight, '?')
-- FROM diabetic_data_raw r
-- WHERE CAST(r.encounter_id AS UNSIGNED) = (
--     SELECT MIN(CAST(r2.encounter_id AS UNSIGNED))
--     FROM diabetic_data_raw r2
--     WHERE CAST(r2.patient_nbr AS UNSIGNED) = CAST(r.patient_nbr AS UNSIGNED)
-- );
-- -------------------------------------------------------------
