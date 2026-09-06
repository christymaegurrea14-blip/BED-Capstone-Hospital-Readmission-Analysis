# Recording Script — Checkpoint 1 & 2 (Simple Version)
**Group STING RAY — BED 106**

How to read this: each step tells you **SHOW** (what to put on screen) and **SAY** (what to say out loud). Just follow it top to bottom, in order. Three people, three colors of steps:

- 🟦 **Christy Mae** — intros, business problem, charts, wrap-ups
- 🟩 **Ana Marie** — data, database, half the SQL, formulas
- 🟨 **Justine** — other half of SQL, stats, correlation, regression

**Before you hit record:** 3 spots below are marked **[SAY IT YOURSELF]**. For those, there is no script — your teacher does not allow AI-written analysis, so your team has to figure out the answer together first, then say it in your own words on camera. Everything else you can read straight off this page.

**Get these open on your computer first**, in this order, so you can just switch tabs:
1. Checkpoint 1 Word report
2. `erd_diagram.png` picture
3. Your database tool (phpMyAdmin) with the queries ready to run
4. Checkpoint 2 Excel file, open to Sheet 1

---

## CHECKPOINT 1

### 🟦 Step 1 — Say hi (30 sec)
**SHOW:** Title page of Checkpoint 1 report.
**SAY:**
> "Hi, we're Group STING RAY. I'm Christy Mae, Project Lead. This is Ana Marie, our Data Engineer, and Justine, our Statistician. This video covers our Checkpoint 1 deliverables."

### 🟦 Step 2 — The problem (1–2 min)
**SHOW:** Task 1.1 section.
**SAY:**
> "We're looking at diabetic patients who get sent back to the hospital within 30 days of being discharged. We want to know: how often does this happen, what factors make it more likely, and can we predict who's at risk before they leave. We're using a public dataset of about 101,766 hospital visits from 130 US hospitals."

### 🟩 Step 3 — The data (2 min)
**SHOW:** Task 1.2, data dictionary table.
**SAY:**
> "Our data comes from the UCI Machine Learning Repository, it's free to use under a Creative Commons license. It has 50 columns — things like how many days the patient stayed, how many prior visits they had, and whether they were readmitted. We found some columns were missing a lot of data — weight was empty in 97% of rows, so we mostly ignored that one. We also found the same patient could show up more than once, so we had to clean that up before loading it into our database."

### 🟩 Step 4 — The database (1.5 min)
**SHOW:** `erd_diagram.png`, then your database tables.
**SAY:**
> "Here's how we organized the data into tables. One patient can have many hospital visits, and each visit links to lookup tables for things like discharge type. Here are the tables actually loaded with data."

### 🟩 Step 5 — First 4 SQL queries (2 min)
For each query: **SHOW** the SQL code, **SHOW** the result, then **SAY** the one-line takeaway.

1. **Longest stays that ended in fast readmission.**
   **SAY:** "These are patients who stayed the longest and still came back within 30 days — that's a red flag we'd want a hospital to review."
2. **Older patients (60+) with lots of past hospital stays.**
   **SAY:** "About 9,400 visits match this. 1 in 5 of them got readmitted again within 30 days — this group needs extra follow-up."
3. **How many patients get readmitted overall.**
   **SAY:** "54% never come back, 35% come back after 30 days, and 11% come back within 30 days. That 11% is the whole reason for this project."
4. **Average stay length and past visits, by outcome.**
   **SAY:** "Patients who get readmitted quickly had more past hospital visits than others — that's a bigger warning sign than how long they stayed."

### 🟨 Step 6 — Last 4 SQL queries (2 min)
Same pattern: **SHOW** code, **SHOW** result, **SAY** the takeaway.

5. **Readmission rate by where the patient was discharged to.**
   **SAY:** "Patients sent to a rehab facility came back within 30 days almost 28% of the time — way above our 11% average. Discharge planning should focus there."
6. **Readmission rate by how the patient was admitted, for emergencies only.**
   **SAY:** "This one didn't change much no matter where the emergency referral came from — so it's a weaker warning sign than discharge type."
7. **Readmission rate by age group.**
   **SAY:** "It's not a straight line — young kids have the lowest rate, but it actually spikes for people in their 20s, dips in middle age, then rises again after 60. Age alone isn't a simple risk score."
8. **Our own 'high-risk' rule: 3+ diagnoses, a past hospital stay, and 5+ days this time.**
   **SAY:** "Patients matching all three of these came back within 30 days almost 17% of the time, versus about 10% for everyone else — nearly double the risk, using only info we already know at discharge."

### 🟦 Step 7 — Wrap up Checkpoint 1 (20 sec)
**SAY:**
> "That's Checkpoint 1 — our problem, our data, our database, and 8 SQL queries. Now Checkpoint 2."

---

## CHECKPOINT 2

### 🟦 Step 8 — Transition (15 sec)
**SAY:**
> "For Checkpoint 2 we took the same cleaned data into Excel to run stats, correlation, and a prediction model."

### 🟩 Step 9 — Sheet 1: Cleaned Data (45 sec)
**SHOW:** Sheet 1.
**SAY:**
> "This is our full cleaned dataset in Excel — 101,766 rows, 26 columns. We added one extra column that flags 'high-risk' patients using the same rule from Checkpoint 1."

### 🟩 Step 10 — Sheet 2: Pivot Tables (1.5 min)
**SHOW:** All 3 pivot tables.
**SAY:**
> "First table breaks down stay length and past visits by whether the patient was readmitted. Second table breaks it down by age group — you can see that spike in the 20s again. Third table breaks it down by discharge type — rehab and psychiatric transfers have the highest readmit rates."

### 🟦 Step 11 — Sheet 3: Charts (1 min)
**SHOW:** All 3 charts.
**SAY:**
> "We turned those three pivot tables into charts so the patterns are easier to see at a glance — a bar chart, a combo chart with a trend line, and a sorted bar chart."

### 🟩 Step 12 — Sheet 4: Formulas (1.5 min)
**SHOW:** Sheet 4, all 6 formulas.
**SAY:**
> "We used six Excel formulas — COUNTIF, SUMIF, AVERAGEIF, IF, XLOOKUP, and TEXT — to answer quick business questions straight from the data. One gotcha we found: Excel reads '<30' as a math symbol instead of text, so we had to write it as '=<30' to make it count correctly. We tested that before trusting the numbers."

### 🟨 Step 13 — Descriptive Statistics (2–3 min)
**SHOW:** The stats table and the histogram.
**SAY (read the numbers):**
> "For length of stay, medications, and number of diagnoses, here's the mean, median, mode, and spread for all 101,766 visits."

**[SAY IT YOURSELF — team decides together first]**
Answer these three simple questions out loud, in your own words:
- Length of stay: is the mean bigger than the median? What does that tell you about the shape of the histogram (lots of short stays, few long ones)?
- Medications: is it more spread out or less spread out than length of stay?
- Diagnoses: what does the range (lowest to highest) tell you about how complicated the average visit is?

### 🟨 Step 14 — Correlation (1.5–2 min)
**SHOW:** Both scatter plot charts.
**SAY (read the numbers):**
> "We checked two relationships. Length of stay vs. number of medications: correlation of 0.47. Length of stay vs. number of lab tests: correlation of 0.32."

**[SAY IT YOURSELF]**
Answer in your own words:
- Is 0.47 weak, medium, or strong? What about 0.32?
- What does that mean in real life — for example, for staffing pharmacy or the lab?
- Does this prove one thing causes the other, or just that they move together?

### 🟨 Step 15 — Regression / Prediction Model (2–2.5 min)
**SHOW:** The regression table and chart.
**SAY (read the numbers):**
> "Our formula is: predicted length of stay equals 1.65 plus 0.17 times number of medications. At the average of 16 medications, that predicts 4.4 days — which matches reality. At 10 medications above average, it predicts 6.1 days."

**[SAY IT YOURSELF]**
Answer in your own words:
- In plain English, what does the "0.17" mean — each extra medication adds about how many extra hours or days?
- This model only explains about 22% of why stays differ — what do you think explains the other 78%?
- Is this result reliable, or could it be random chance? (Hint: check the p-value in your sheet.)
- Give one real recommendation a hospital could use from this.
- Name one limitation — for example, stays are capped at 14 days in this data, so the model might not work for very sick patients.

### 🟦 or 🟨 Step 16 — Why no trend analysis (30 sec)
**SAY:**
> "One task doesn't apply to us — trend analysis over time — because our data has no dates, only visit IDs. We can't fake a timeline that isn't there, so instead we did the prediction model you just saw."

### 🟦 Step 17 — Close it out (20 sec)
**SAY:**
> "That's our Checkpoint 1 and 2 walkthrough. Thanks for watching — Group STING RAY."

---

## Checklist before you press record
- [ ] Team has already talked through and agreed on answers for the 3 **[SAY IT YOURSELF]** spots.
- [ ] Everyone's mic and screen-share works.
- [ ] Database and Excel file are both open and ready.
- [ ] Each person talks for a roughly equal amount of time.
- [ ] Save the video with a clear name, like `STINGRAY_CP1-CP2.mp4`.
