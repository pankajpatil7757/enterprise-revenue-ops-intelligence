-- ============================================================
-- FILE: 04_sla_breach.sql
-- PROJECT: Enterprise Revenue & Operations Intelligence Platform
-- AUTHOR: Pankaj
-- DESCRIPTION: SLA breach analysis by partner
--              Identifies worst performing partners
-- ============================================================

USE DATABASE REVENUE_OPS_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE REVENUE_WH;

-- ============================================================
-- QUERY 1: SLA Breach % by Partner
-- Result: 25 partners analyzed
-- Insight: Partner P1005 worst at 76.51% breach rate
-- ============================================================
SELECT
    S.PARTNER_ID,
    P.PARTNER_NAME,
    COUNT(S.SHIPMENT_ID)                                            AS TOTAL_SHIPMENTS,
    SUM(CASE WHEN S.SLA_BREACHED = TRUE THEN 1 ELSE 0 END)         AS BREACHED_SHIPMENTS,
    SUM(CASE WHEN S.SLA_BREACHED = FALSE THEN 1 ELSE 0 END)        AS ONTIME_SHIPMENTS,
    ROUND(
        SUM(CASE WHEN S.SLA_BREACHED = TRUE THEN 1 ELSE 0 END) * 100.0
        / COUNT(S.SHIPMENT_ID), 2
    )                                                               AS SLA_BREACH_PCT,
    ROUND(
        SUM(CASE WHEN S.SLA_BREACHED = FALSE THEN 1 ELSE 0 END) * 100.0
        / COUNT(S.SHIPMENT_ID), 2
    )                                                               AS OTD_PCT
FROM FACT_SHIPMENTS S
LEFT JOIN DIM_PARTNERS P
    ON S.PARTNER_ID = P.PARTNER_ID
GROUP BY S.PARTNER_ID, P.PARTNER_NAME
ORDER BY SLA_BREACH_PCT DESC;

-- ============================================================
-- QUERY 2: SLA Breach % by Region
-- Shows which regions have the most SLA issues
-- ============================================================
SELECT
    P.REGION,
    COUNT(S.SHIPMENT_ID)                                            AS TOTAL_SHIPMENTS,
    SUM(CASE WHEN S.SLA_BREACHED = TRUE THEN 1 ELSE 0 END)         AS BREACHED_SHIPMENTS,
    ROUND(
        SUM(CASE WHEN S.SLA_BREACHED = TRUE THEN 1 ELSE 0 END) * 100.0
        / COUNT(S.SHIPMENT_ID), 2
    )                                                               AS SLA_BREACH_PCT
FROM FACT_SHIPMENTS S
LEFT JOIN DIM_PARTNERS P
    ON S.PARTNER_ID = P.PARTNER_ID
GROUP BY P.REGION
ORDER BY SLA_BREACH_PCT DESC;

-- ============================================================
-- QUERY 3: SLA Breach Trend by Month
-- Shows if breach rates are improving or worsening over time
-- ============================================================
SELECT
    DATE_TRUNC('MONTH', S.PICKUP_DATE)                             AS SHIPMENT_MONTH,
    COUNT(S.SHIPMENT_ID)                                            AS TOTAL_SHIPMENTS,
    SUM(CASE WHEN S.SLA_BREACHED = TRUE THEN 1 ELSE 0 END)         AS BREACHED_SHIPMENTS,
    ROUND(
        SUM(CASE WHEN S.SLA_BREACHED = TRUE THEN 1 ELSE 0 END) * 100.0
        / COUNT(S.SHIPMENT_ID), 2
    )                                                               AS SLA_BREACH_PCT
FROM FACT_SHIPMENTS S
GROUP BY DATE_TRUNC('MONTH', S.PICKUP_DATE)
ORDER BY SHIPMENT_MONTH ASC;

-- ============================================================
-- QUERY 4: Overall SLA KPIs
-- ============================================================
SELECT
    COUNT(SHIPMENT_ID)                                              AS TOTAL_SHIPMENTS,
    SUM(CASE WHEN SLA_BREACHED = TRUE THEN 1 ELSE 0 END)           AS TOTAL_BREACHED,
    SUM(CASE WHEN SLA_BREACHED = FALSE THEN 1 ELSE 0 END)          AS TOTAL_ONTIME,
    ROUND(
        SUM(CASE WHEN SLA_BREACHED = TRUE THEN 1 ELSE 0 END) * 100.0
        / COUNT(SHIPMENT_ID), 2
    )                                                               AS OVERALL_BREACH_PCT,
    ROUND(
        SUM(CASE WHEN SLA_BREACHED = FALSE THEN 1 ELSE 0 END) * 100.0
        / COUNT(SHIPMENT_ID), 2
    )                                                               AS OVERALL_OTD_PCT
FROM FACT_SHIPMENTS;
