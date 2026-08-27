-- =============================================================
-- Hospital Readmission Analysis — Diabetes 130-US Hospitals
-- Checkpoint 1, Task 1.4: SQL Query Report
--
-- Run schema.sql then load_data.sql first (creates and populates
-- hospital_readmission.patients / encounters / lookup tables).
-- Each query below is grouped to match the template's four
-- required categories. Paste each query's SQL + result screenshot
-- + a 2-3 sentence business interpretation into the Task 1.4
-- section of the checkpoint report.
-- =============================================================

USE hospital_readmission;

-- =============================================================
-- 1. BASIC DATA RETRIEVAL (SELECT + WHERE + ORDER BY)
-- =============================================================

-- Query 1.1 — Longest-stay encounters that ended in an early (<30 day) readmission.
SELECT
    encounter_id,
    patient_nbr,
    time_in_hospital,
    number_diagnoses,
    readmitted
FROM encounters
WHERE readmitted = '<30'
ORDER BY time_in_hospital DESC
LIMIT 20;
-- Business interpretation: surfaces the specific encounters most worth reviewing first —
-- long inpatient stays that still ended in a readmission within 30 days — as candidates
-- for a discharge-planning case review.

-- Query 1.2 — Senior patients (60+) with a history of frequent prior inpatient stays.
SELECT
    e.encounter_id,
    e.patient_nbr,
    p.age,
    e.number_inpatient,
    e.discharge_disposition_id,
    e.readmitted
FROM encounters e
JOIN patients p ON p.patient_nbr = e.patient_nbr
WHERE p.age IN ('[60-70)', '[70-80)', '[80-90)', '[90-100)')
  AND e.number_inpatient >= 2
ORDER BY e.number_inpatient DESC, e.time_in_hospital DESC
LIMIT 20;
-- Business interpretation: highlights older patients who are already frequent inpatients,
-- a group likely to benefit most from a targeted post-discharge follow-up program.

-- =============================================================
-- 2. AGGREGATE ANALYSIS (GROUP BY + aggregate functions)
-- =============================================================

-- Query 2.1 — Readmission outcome counts and share of total encounters.
SELECT
    readmitted,
    COUNT(*) AS encounter_count,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM encounters), 2) AS pct_of_total
FROM encounters
GROUP BY readmitted
ORDER BY encounter_count DESC;
-- Business interpretation: establishes the baseline readmission rate (answers Key
-- Business Question 1) — the share of encounters that are readmitted within 30 days,
-- after 30 days, or not at all.

-- Query 2.2 — Average length of stay and average prior-visit counts by readmission outcome.
SELECT
    readmitted,
    COUNT(*)                          AS encounter_count,
    ROUND(AVG(time_in_hospital), 2)   AS avg_length_of_stay,
    ROUND(AVG(number_inpatient), 2)   AS avg_prior_inpatient_visits,
    ROUND(AVG(number_emergency), 2)   AS avg_prior_emergency_visits,
    MAX(time_in_hospital)             AS max_length_of_stay
FROM encounters
GROUP BY readmitted;
-- Business interpretation: answers Key Business Question 2 — whether length of stay and
-- prior-visit history are, on average, higher for patients who come back within 30 days.

-- =============================================================
-- 3. MULTI-TABLE JOINS (2+ tables)
-- =============================================================

-- Query 3.1 — Readmission rate broken down by discharge disposition description.
SELECT
    dd.description                                            AS discharge_disposition,
    COUNT(*)                                                  AS encounter_count,
    SUM(CASE WHEN e.readmitted = '<30' THEN 1 ELSE 0 END)     AS readmitted_under_30,
    ROUND(100 * SUM(CASE WHEN e.readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_readmitted_under_30
FROM encounters e
JOIN discharge_disposition dd ON dd.discharge_disposition_id = e.discharge_disposition_id
GROUP BY dd.description
ORDER BY pct_readmitted_under_30 DESC
LIMIT 15;
-- Business interpretation: joins encounters to the discharge_disposition lookup table to
-- show which discharge routes (e.g., home vs. transferred to a facility) carry the
-- highest early-readmission rate, pointing to where discharge planning needs attention.

-- Query 3.2 — Readmission rate by admission source and admission type, for emergency-type admissions.
SELECT
    at.description  AS admission_type,
    ads.description AS admission_source,
    COUNT(*)        AS encounter_count,
    ROUND(100 * SUM(CASE WHEN e.readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_readmitted_under_30
FROM encounters e
JOIN admission_type   at  ON at.admission_type_id = e.admission_type_id
JOIN admission_source  ads ON ads.admission_source_id = e.admission_source_id
WHERE at.description = 'Emergency'
GROUP BY at.description, ads.description
ORDER BY encounter_count DESC;
-- Business interpretation: a three-table join isolating emergency admissions to see which
-- referral source feeds the most early readmissions among already high-risk ER patients.

-- =============================================================
-- 4. BUSINESS-RELEVANT INSIGHTS (answer the Task 1.1 key questions)
-- =============================================================

-- Query 4.1 — Readmission rate by age group (answers: do rates differ across demographics?).
SELECT
    p.age                                                      AS age_group,
    COUNT(*)                                                   AS encounter_count,
    SUM(CASE WHEN e.readmitted = '<30' THEN 1 ELSE 0 END)      AS readmitted_under_30,
    ROUND(100 * SUM(CASE WHEN e.readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_readmitted_under_30
FROM encounters e
JOIN patients p ON p.patient_nbr = e.patient_nbr
GROUP BY p.age
ORDER BY p.age;
-- Business interpretation: directly answers Key Business Question 3 — whether readmission
-- risk varies by age band, which is exactly the fairness/bias check this project needs for
-- the Checkpoint 4 ethics discussion.

-- Query 4.2 — High-risk profile: patients with 3+ diagnoses AND 1+ prior inpatient visit
-- AND a stay of 5+ days, versus their actual readmission outcome.
SELECT
    CASE
        WHEN e.number_diagnoses >= 3 AND e.number_inpatient >= 1 AND e.time_in_hospital >= 5
            THEN 'High-risk profile'
        ELSE 'Lower-risk profile'
    END AS risk_profile,
    COUNT(*)                                               AS encounter_count,
    SUM(CASE WHEN e.readmitted = '<30' THEN 1 ELSE 0 END)  AS readmitted_under_30,
    ROUND(100 * SUM(CASE WHEN e.readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_readmitted_under_30
FROM encounters e
GROUP BY risk_profile;
-- Business interpretation: answers Key Business Question 3/4 — tests whether a simple,
-- discharge-time risk profile (multiple diagnoses + prior admissions + long stay) actually
-- carries a higher real-world 30-day readmission rate, which is the core premise the
-- predictive model in later checkpoints will need to prove out.
