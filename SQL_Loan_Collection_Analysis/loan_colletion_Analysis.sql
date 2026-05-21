CREATE DATABASE loan_analysis;
USE loan_analysis;

CREATE TABLE loan_collection (
	Record_ID               VARCHAR(10),
    Month                   VARCHAR(15),
    Week                    VARCHAR(10),
    Agent_ID                VARCHAR(10),
    Agent_Name              VARCHAR(50),
    Team_Leader_ID          VARCHAR(10),
    Team_Leader_Name        VARCHAR(50),
    Region                  VARCHAR(20),
    Loan_Type               VARCHAR(20),
    DPD_Bucket              VARCHAR(15),
    Total_Calls_Made        INT,
    Customers_Contacted     INT,
    EMI_Due_Amount          DECIMAL(12,2),
    EMI_Collected_Amount    DECIMAL(12,2),
    Target_Amount           DECIMAL(12,2),
    Achievement_Pct         DECIMAL(8,2),
    Collection_Status       VARCHAR(25)
);


SELECT * FROM loan_collection
limit 5;

-- SOLVE THESE BUSINESS QUESTIONS 

-- Query 1 — Total Collection by Region

SELECT 
Region,
COUNT(*) as Total_Records,
ROUND(SUM(EMI_Due_Amount),2) as Total_Emi_Due,
ROUND(SUM(EMI_Collected_Amount),2) as Total_Collected,
ROUND(SUM(EMI_Collected_Amount)/SUM(EMI_Due_Amount) *100 ,2) as Collection_rate_PCT
FROM loan_collection
GROUP BY Region 
ORDER BY Total_Collected DESC ;

/* 
Query 1 INSISHTS :- 
1. Delhi is top region — 1.37 Crore — 50.59% collection rate
2. Gurgaon is lowest — 0.95 Crore — 36.18% collection rate
3. Gap between Delhi and Gurgaon — 42 Lakh
4. Only Delhi is above 50% collection rate
5. All other regions need strategy improvement 
*/

-- Top 5 agents by collection

SELECT * FROM loan_collection
limit 5;

SELECT 
Agent_Name,
Region,
Team_Leader_Name,
ROUND(SUM(EMI_Due_Amount),2) as Total_Emi_Due,
ROUND(SUM(EMI_Collected_Amount),2) as Total_Collected,
ROUND(SUM(EMI_Collected_Amount)/SUM(EMI_Due_Amount) *100 ,2) as Collection_rate_PCT
FROM loan_collection
GROUP BY Agent_Name, Region, Team_Leader_Name 
ORDER BY Total_Collected DESC
LIMIT 5 ;

/* 
INSIGHTS :- 
1. Vikram Mishra top by collection amount — 52.6 Lakh — Mumbai
2. Amit Sharma top by collection rate — 56.56% — Delhi
3. Delhi has 2 agents in top 5 — Rajesh Verma is best TL
4. All top 5 agents have 53%+ collection rate
5. Kavita Rao from Bangalore impressive — 55.83% rate
*/


-- Monthly collection trend

SELECT 
`Month`,
ROUND(SUM(EMI_Due_Amount),2) as Total_Emi_Due,
ROUND(SUM(EMI_Collected_Amount),2) as Total_Collected,
ROUND(SUM(EMI_Collected_Amount)/SUM(EMI_Due_Amount) *100 ,2) as Collection_rate_PCT
FROM loan_collection
GROUP BY `Month` 
ORDER BY FIELD(Month,
        'Jan-2024','Feb-2024','Mar-2024','Apr-2024',
        'May-2024','Jun-2024','Jul-2024','Aug-2024',
        'Sep-2024','Oct-2024','Nov-2024','Dec-2024');


/*
INSIGHTS :- 
1. Overall upward trend — Jan 42.1L to Dec 51.9L — 23% growth
2. January is lowest — 38.77% rate — new year slowdown
3. June spike — 49.88L — possible special campaign — 4.27L jump from May
4. July slight dip after June spike — normal correction
5. November highest rate — 47.10% — year end push
6. December highest collection — 51.87L
7. Collection rate improved by 8.33% over full year — positive sign
 */
 
 
-- DPD bucket wise EMI due

SELECT 
    DPD_Bucket,
    COUNT(*)                                    AS Total_Records,
    ROUND(SUM(EMI_Due_Amount), 2)               AS Total_EMI_Due,
    ROUND(SUM(EMI_Collected_Amount), 2)         AS Total_Collected,
    ROUND(SUM(EMI_Collected_Amount) /
          SUM(EMI_Due_Amount) * 100, 2)         AS Collection_Rate_Pct,
    ROUND(AVG(EMI_Due_Amount), 2)               AS Avg_EMI_Due
FROM loan_collection
GROUP BY DPD_Bucket
ORDER BY 
    FIELD(DPD_Bucket,
        'X (Current)', '1-30 DPD', 
        '31-60 DPD', '61-90 DPD', '90+ DPD');

/* 
INSIGHTS :- 
1. X Current — 60.20% collection rate — healthy segment
2. Collection rate drops 13-14% with each DPD bucket
3. 90+ DPD only 9.24% rate — 99 Lakh practically at write-off risk
4. Total at risk EMI — 8.42 Crore across all DPD buckets
5. Average EMI similar across all buckets — 17,000
   - Problem is customer behavior, not loan amount
6. Immediate action needed on 1-30 DPD — 1.49 Crore still recoverable
*/

-- Loan type wise collection rate

SELECT 
Loan_Type,
ROUND(SUM(EMI_Due_Amount),2) as Total_Emi_Due,
ROUND(SUM(EMI_Collected_Amount),2) as Total_Collected,
ROUND(SUM(EMI_Collected_Amount)/SUM(EMI_Due_Amount) *100 ,2) as Collection_rate_PCT,
ROUND(AVG(EMI_Due_Amount), 2) as Avg_EMI_Due,
ROUND(AVG(EMI_Collected_Amount), 2) as Avg_EMI_Collected
FROM loan_collection
GROUP BY Loan_Type 
ORDER BY Collection_rate_PCT DESC;


/*
INSIGHTS :- 

Query 5 — Loan Type Wise Collection Rate

1. Business Loan best — 53.34% — 14% above all others
   - Business customers are financially disciplined
   
2. Auto Loan lowest — 38.22%
   - Asset backed loan still lowest — repossession strategy needed

3. Home Loan highest average EMI — 26,704
   - Big ticket — but only 38.62% collected
   - 2.43 Crore uncollected from Home Loan alone

4. Personal, Gold, Home, Auto all at 38-39%
   - Same strategy applied to all — wrong approach
   - Product specific strategies needed

5. Overall collection rate — 42.88%
   - 57.12% EMI still uncollected — critical finding
 */
 
-- Collection status breakdown

SELECT 
Collection_Status,
COUNT(*) as Total_Records,
 ROUND(COUNT(*) / 
          (SELECT COUNT(*) FROM loan_collection) 
          * 100, 2) as Percentage,
ROUND(SUM(EMI_Due_Amount),2) as Total_Emi_Due,
ROUND(SUM(EMI_Collected_Amount),2) as Total_Collected,
ROUND(SUM(EMI_Collected_Amount)/SUM(EMI_Due_Amount) *100 ,2) as Collection_rate_PCT
FROM loan_collection
GROUP BY Collection_Status 
ORDER BY Collection_rate_PCT DESC ;


/*
INSIGHTS :-
1. Partially Collected highest — 48.41% records — 3681 cases
   - Follow up can convert these to full collection

2. Dispute Raised — 31.60% — 2403 cases — serious concern
   - Still 31.85% collection happening even in disputes
   - Dispute resolution team needed

3. Promise to Pay — surprising finding!
   - Highest collection rate — 64.23%
   - Customers who promise actually pay more often
   - PTP follow up should be prioritized

4. Collected status missing — merged into Unknown during cleaning
   - Data quality improvement needed in source system

5. Subquery used to calculate percentage of each status
 */
 
 
-- Agent wise target vs achievement — with collection efficiency %

SELECT 
Agent_Name,
SUM(Target_Amount) as Total_Target,
SUM(EMI_Collected_Amount) as Total_Achievement,
ROUND((SUM(EMI_Collected_Amount)/SUM(Target_Amount))*100,2) as Collection_Efficiency_Pct
FROM Loan_Collection
GROUP BY Agent_Name
ORDER BY Collection_Efficiency_Pct DESC;



-- Team leader wise team performance comparison

SELECT
Team_Leader_Name,
Region,
COUNT(DISTINCT Agent_Name) as Total_Agents,
COUNT(*) as Total_Records,
SUM(EMI_Due_Amount) as Total_EMI_Due,
SUM(EMI_Collected_Amount) as Total_Collected,
ROUND(SUM(EMI_Collected_Amount)/SUM(EMI_Due_Amount) *100,2) as Collection_Rate_Pct,
AVG(EMI_Collected_Amount) as Avg_Collection
FROM Loan_collection
GROUP BY Team_Leader_Name, Region
ORDER BY Collection_Rate_Pct DESC;


/*
INSIGHTS :- 

1. Rajesh Verma best TL — Delhi — 50.59% — avg 8,814 per record
2. Meena Joshi lowest — Gurgaon — 36.18% — avg 6,352 per record
3. Each TL has exactly 3 agents — fair comparison
4. Gap between best and worst TL — 14.41%
5. If Meena Joshi matches Rajesh Verma — 37 Lakh extra collection possible
6. COUNT(DISTINCT) used to count unique agents per TL
 */
 
 -- Month Over Month Growth
 
 SELECT 
 `Month`,
 SUM(EMI_Collected_Amount) as Total_Collected,
LAG(ROUND(SUM(EMI_Collected_Amount), 2)) 
        OVER (ORDER BY FIELD(Month,
            'Jan-2024','Feb-2024','Mar-2024','Apr-2024',
            'May-2024','Jun-2024','Jul-2024','Aug-2024',
            'Sep-2024','Oct-2024','Nov-2024','Dec-2024')) as Prev_Month_Collection,
  ROUND(
        (SUM(EMI_Collected_Amount) - 
         LAG(SUM(EMI_Collected_Amount)) 
             OVER (ORDER BY FIELD(Month,
                'Jan-2024','Feb-2024','Mar-2024','Apr-2024',
                'May-2024','Jun-2024','Jul-2024','Aug-2024',
                'Sep-2024','Oct-2024','Nov-2024','Dec-2024')))
        / LAG(SUM(EMI_Collected_Amount)) 
             OVER (ORDER BY FIELD(Month,
                'Jan-2024','Feb-2024','Mar-2024','Apr-2024',
                'May-2024','Jun-2024','Jul-2024','Aug-2024',
                'Sep-2024','Oct-2024','Nov-2024','Dec-2024'))
        * 100, 2) as MOM_Growth_Pct
FROM Loan_collection
GROUP By `Month`
ORDER BY 
	FIELD(Month,
    'Jan-2024','Feb-2024','Mar-2024','Apr-2024',
    'May-2024','Jun-2024','Jul-2024','Aug-2024',
    'Sep-2024','Oct-2024','Nov-2024','Dec-2024');


/*
INSIGHTS :-
1. January NULL — no previous month to compare
2. June highest MOM growth — +9.36% — 4.27 Lakh jump
   - Special campaign effect confirmed
3. July only negative month — -6.30% — post campaign dip
4. Overall trend positive — 10 out of 11 months positive growth
5. LAG() Window Function used to get previous month value
6. FIELD() used to maintain calendar order
 */


-- Contact Rate by Agent

SELECT
Agent_Name,
Region,
AVG(Total_Calls_Made) as AVG_Calls_Made,
AVG(Customers_Contacted) as Avg_Contacted,
ROUND(AVG(Customers_Contacted)/AVG(Total_Calls_Made) *100,2) as Contact_Rate_PCT,
SUM(EMI_Collected_Amount) as Total_Collected,
AVG(EMI_Collected_Amount) as Avg_Collected_Per_record
FROM Loan_Collection
GROUP BY Agent_Name,Region
ORDER BY Contact_Rate_PCT DESC;

/*
INSIGHTS :-
1. 3 clear groups identified — confirmed from Python EDA
   - Group 1 : 74%+ contact → 44-52 Lakh collection
   - Group 2 : 58-60% contact → 32-40 Lakh collection
   - Group 3 : 39-40% contact → 23-24 Lakh collection

2. Gap between Group 1 and Group 3 — almost 2x collection

3. Avg calls also different across groups —
   - Group 1 makes ~99 calls per record
   - Group 2 makes ~70 calls per record
   - Group 3 makes only ~46 calls per record

4. Key finding — more calls = more contacts = more collection

5. Same finding as Python EDA — cross tool validation done!

6. Recommendation — Group 3 agents must increase daily calls
 */


-- Agent Ranking Within Each Region


SELECT
Agent_Name,
Region,
SUM(EMI_Collected_Amount) as Total_Collected,
ROUND(SUM(EMI_Collected_Amount) / SUM(EMI_DUE_Amount) *100 ,2) as Collection_Rate_Pct,
RANK() OVER(PARTITION BY Region 
			ORDER BY SUM(EMI_Collected_Amount) DESC ) as Region_Rnk
FROM Loan_Collection
GROUP BY Agent_Name,Region
ORDER BY Region, Region_Rnk;


/* 
INSIGHTS :-

1. RANK() OVER PARTITION BY Region used successfully
2. Each region has 3 agents — clear Rank 1, 2, 3

3. Rank 1 agents in each region —
   - Bangalore : Kavita Rao    55.83%
   - Delhi     : Amit Sharma   56.56%
   - Gurgaon   : Sunita Patel  41.43%
   - Mumbai    : Vikram Mishra  56.36%
   - Pune      : Rekha Jain    53.28%

4. All Rank 3 agents around 27-30% — need urgent training

5. Key finding — Gurgaon Rank 1 (41.43%) is almost same
   as Delhi Rank 3 (41.08%) — Gurgaon overall very weak region

6. PARTITION BY divided data into 5 regional groups
   — separate ranking applied to each group
*/

-- Running Total of Collection Month by Month

SELECT 
`Month`,
SUM(EMI_Collected_Amount) as Total_Collected,
SUM(SUM(EMI_Collected_Amount)) OVER(
ORDER BY field(`Month`,
   'Jan-2024','Feb-2024','Mar-2024','Apr-2024',
	'May-2024','Jun-2024','Jul-2024','Aug-2024',
	'Sep-2024','Oct-2024','Nov-2024','Dec-2024'
)
) as Running_Total,
ROUND(SUM(SUM(EMI_Collected_Amount)) OVER (
        ORDER BY FIELD(Month,
            'Jan-2024','Feb-2024','Mar-2024','Apr-2024',
            'May-2024','Jun-2024','Jul-2024','Aug-2024',
            'Sep-2024','Oct-2024','Nov-2024','Dec-2024')
    ) / SUM(SUM(EMI_Collected_Amount)) OVER () 
    * 100, 2) as Cumulative_Pct
FROM Loan_Collection
GROUP By `Month`
ORDER BY field(`Month`,
            'Jan-2024','Feb-2024','Mar-2024','Apr-2024',
            'May-2024','Jun-2024','Jul-2024','Aug-2024',
            'Sep-2024','Oct-2024','Nov-2024','Dec-2024'
);

/* 
INSIGHTS :- 
1. Total yearly collection = 5.64 Crore
2. Second half better than first half
   - H1 = 2.68 Crore (47.49%)
   - H2 = 2.96 Crore (52.51%)

3. Quarter wise — every quarter improved
   - Q1 = 22.64%
   - Q2 = 24.85%
   - Q3 = 25.35%
   - Q4 = 27.15% — best quarter

4. 50% milestone crossed between June and July
5. June campaign added 8.83% to cumulative in one month

6. SUM() OVER ORDER BY used — running total window function
7. Double SUM used — inner for monthly group, outer for cumulative

*/

-- Agent vs Team Average Comparison

SELECT 
Agent_Name,
Team_Leader_name,
Region,
SUM(EMI_Collected_Amount) as Agent_Total_Collected,
ROUND(AVG(SUM(EMI_Collected_Amount)) OVER(PARTITION BY Team_Leader_Name),2) Avg_Team_Collection,
ROUND(SUM(EMI_Collected_Amount) - AVG(SUM(EMI_Collected_Amount)) OVER(PARTITION BY Team_Leader_Name),2) as Diff_From_TEAM_Avg,
CASE 
WHEN SUM(EMI_Collected_Amount) > 
		AVG(SUM(EMI_Collected_Amount)) OVER(PARTITION BY Team_Leader_Name)
THEN 'Above Average'
ELSE 'Below Average'
END as Performance_status
FROM 
Loan_Collection
GROUP BY Agent_Name,Team_Leader_Name,Region
ORDER BY Team_Leader_Name, Agent_Total_Collected DESC;

/*
Insights :- 

1. AVG() OVER PARTITION BY Team_Leader used successfully
2. CASE WHEN used to classify Above/Below Average

3. Key finding — every team has exactly 2 above + 1 below average
   - Consistent pattern across all 5 teams

4. Biggest underperformer — Ravi Tiwari — Mumbai
   - 14.40 Lakh below team average
   - 27.78 Lakh gap from Vikram Mishra in same team!

5. Pooja Gupta barely above average — only 75,533 above
   - Risk of dropping to below average

6. This query helps TL identify who needs support in their team
 */
 
-- Top Agent in Each Region Using CTE

WITH Agent_Rankings AS (
    SELECT 
        Agent_Name,
        Region,
        Team_Leader_Name,
        ROUND(SUM(EMI_Collected_Amount), 2)as Total_Collected,
        ROUND(SUM(EMI_Collected_Amount) /
              SUM(EMI_Due_Amount) * 100, 2)as Collection_Rate_Pct,
        ROW_NUMBER() OVER (
            PARTITION BY Region 
            ORDER BY SUM(EMI_Collected_Amount) DESC
        ) as Row_Num
    FROM loan_collection
    GROUP BY Agent_Name, Region, Team_Leader_Name
)
SELECT 
    Agent_Name,
    Region,
    Team_Leader_Name,
    Total_Collected,
    Collection_Rate_Pct,
    Row_Num as Region_Rank
FROM Agent_Rankings
WHERE Row_Num = 1
ORDER BY Total_Collected DESC;

/*
INSIGHTS : - 
1. CTE — WITH Agent_Rankings AS (...) — used successfully
2. ROW_NUMBER() OVER PARTITION BY Region — unique rank per region
3. WHERE Row_Num = 1 — filtered only top agent per region
4. 5 rows returned — one per region — exactly as expected

5. Key findings —
   - Vikram Mishra — Mumbai — best overall — 52.6 Lakh
   - Amit Sharma — Delhi — best collection rate — 56.56%
   - Sunita Patel — Gurgaon — weakest topper — 38.28 Lakh
   - Gurgaon rate 41.43% — far behind other regions 53-56%

6. CTE advantage — clean readable code vs nested subquery
7. ROW_NUMBER used instead of RANK — ensures exactly 1 per region
 */

-- Based on collection rate — classify every agent into performance tiers — Elite, Good, Average, or Needs Improvement?


-- Query 14: Collection Efficiency Tier Classification
SELECT 
    Agent_Name,
    Region,
    Team_Leader_Name,
    Total_Collected,
    Collection_Rate_Pct,
    CASE 
        WHEN Collection_Rate_Pct >= 55 
            THEN 'Elite Performer'
        WHEN Collection_Rate_Pct >= 45 
            THEN 'Good Performer'
        WHEN Collection_Rate_Pct >= 35 
            THEN 'Average Performer'
        ELSE 
            'Needs Improvement'
    END as Performance_Tier,
    CASE
        WHEN Collection_Rate_Pct >= 55 
            THEN '🏆 Top Tier'
        WHEN Collection_Rate_Pct >= 45 
            THEN '✅ On Track'
        WHEN Collection_Rate_Pct >= 35 
            THEN '⚠️ Watch Out'
        ELSE 
            '🚨 Urgent Action'
    END  as Action_Required
FROM (
    SELECT 
        Agent_Name,
        Region,
        Team_Leader_Name,
        ROUND(SUM(EMI_Collected_Amount), 2) as Total_Collected,
        ROUND(SUM(EMI_Collected_Amount) /
              SUM(EMI_Due_Amount) * 100, 2) as Collection_Rate_Pct
    FROM loan_collection
    GROUP BY Agent_Name, Region, Team_Leader_Name
) as Agent_Summary
ORDER BY Collection_Rate_Pct DESC;


/*

INSIGHTS :-

1. CASE WHEN + Subquery used — last advanced query
2. Two CASE WHEN in same query — tier label + action label
3. Subquery calculates rates — outer query classifies

4. Tier Distribution —
   - Elite (55%+)     : 3 agents — Amit, Vikram, Kavita
   - Good (45-54%)    : 4 agents — Priya, Rekha, Neha, Manoj
   - Average (35-44%) : 4 agents — Sunita, Rohit, Pooja, Arjun
   - Needs Imp (<35%) : 4 agents — Ravi, Sonal, Sunil, Deepak

5. Gurgaon has zero Elite or Good performers — worst region
6. Only 20% agents are Elite — 80% need improvement
7. Needs Improvement agents need only 5-8% improvement
   to reach Average tier — training can achieve this
 */





















































