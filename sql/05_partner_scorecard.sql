-- ============================================================
-- FILE: 05_partner_scorecard.sql
-- PROJECT: Enterprise Revenue & Operations Intelligence Platform
-- AUTHOR: Pankaj
-- DESCRIPTION: Partner performance scorecard
--              Revenue + Orders + OTD% per partner
--              Insight: Partner P1015 top revenue at ₹40.5M
-- ============================================================

USE DATABASE REVENUE_OPS_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE REVENUE_WH;

-- ============================================================
-- QUERY 1: Full Partner Scorecard
-- Revenue + Orders + SLA + OTD per partner — 25 partners ranked
-- ============================================================
SELECT
    O.PARTNER_ID,
    P.PARTNER_NAME,
    P.REGION,
    COUNT(DISTINCT O.ORDER_ID)                                      AS TOTAL_ORDERS,
    SUM(O.NET_AMOUNT)                                               AS TOTAL_REVENUE,
    ROUND(AVG(O.NET_AMOUNT), 2)                                     AS AVG_ORDER_VALUE,
    COUNT(DISTINCT S.SHIPMENT_ID)                                   AS TOTAL_SHIPMENTS,
    SUM(CASE WHEN S.SLA_BREACHED = FALSE THEN 1 ELSE 0 END)        AS ONTIME_DELIVERIES,
    SUM(CASE WHEN S.SLA_BREACHED = TRUE THEN 1 ELSE 0 END)         AS BREACHED_DELIVERIES,
    ROUND(
        SUM(CASE WHEN S.SLA_BREACHED = FALSE THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(DISTINCT S.SHIPMENT_ID), 0), 2
    )                                                               AS OTD_PCT,
    ROUND(
        SUM(CASE WHEN S.SLA_BREACHED = TRUE THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(DISTINCT S.SHIPMENT_ID), 0), 2
    )                                                               AS SLA_BREACH_PCT
FROM FACT_ORDERS O
LEFT JOIN DIM_PARTNERS P
    ON O.PARTNER_ID = P.PARTNER_ID
LEFT JOIN FACT_SHIPMENTS S
    ON O.ORDER_ID = S.ORDER_ID
GROUP BY O.PARTNER_ID, P.PARTNER_NAME, P.REGION
ORDER BY TOTAL_REVENUE DESC;

-- ============================================================
-- QUERY 2: Top 10 Partners by Revenue
-- ============================================================
SELECT
    O.PARTNER_ID,
    P.PARTNER_NAME,
    SUM(O.NET_AMOUNT)   AS TOTAL_REVENUE,
    COUNT(O.ORDER_ID)   AS TOTAL_ORDERS
FROM FACT_ORDERS O
LEFT JOIN DIM_PARTNERS P
    ON O.PARTNER_ID = P.PARTNER_ID
GROUP BY O.PARTNER_ID, P.PARTNER_NAME
ORDER BY TOTAL_REVENUE DESC
LIMIT 10;

-- ============================================================
-- QUERY 3: Partner Performance Tier Classification
-- Classifies partners as Platinum / Gold / Silver / Bronze
-- ============================================================
WITH PARTNER_STATS AS (
    SELECT
        O.PARTNER_ID,
        SUM(O.NET_AMOUNT) AS TOTAL_REVENUE,
        ROUND(
            SUM(CASE WHEN S.SLA_BREACHED = FALSE THEN 1 ELSE 0 END) * 100.0
            / NULLIF(COUNT(S.SHIPMENT_ID), 0), 2
        ) AS OTD_PCT
    FROM FACT_ORDERS O
    LEFT JOIN FACT_SHIPMENTS S ON O.ORDER_ID = S.ORDER_ID
    GROUP BY O.PARTNER_ID
)
SELECT
    PARTNER_ID,
    TOTAL_REVENUE,
    OTD_PCT,
    CASE
        WHEN TOTAL_REVENUE >= 35000000 AND OTD_PCT >= 30 THEN 'Platinum'
        WHEN TOTAL_REVENUE >= 25000000 AND OTD_PCT >= 25 THEN 'Gold'
        WHEN TOTAL_REVENUE >= 15000000 AND OTD_PCT >= 20 THEN 'Silver'
        ELSE 'Bronze'
    END AS PERFORMANCE_TIER
FROM PARTNER_STATS
ORDER BY TOTAL_REVENUE DESC;

-- ============================================================
-- QUERY 4: Revenue by Region / Channel
-- ============================================================
SELECT
    P.REGION,
    O.ORDER_CHANNEL,
    COUNT(O.ORDER_ID)       AS TOTAL_ORDERS,
    SUM(O.NET_AMOUNT)       AS TOTAL_REVENUE
FROM FACT_ORDERS O
LEFT JOIN DIM_PARTNERS P
    ON O.PARTNER_ID = P.PARTNER_ID
GROUP BY P.REGION, O.ORDER_CHANNEL
ORDER BY TOTAL_REVENUE DESC;
