-- ============================================================
-- FILE: 03_revenue_leakage.sql
-- PROJECT: Enterprise Revenue & Operations Intelligence Platform
-- AUTHOR: Pankaj
-- DESCRIPTION: Identifies delivered orders with no invoice raised
--              Critical revenue leakage analysis
-- ============================================================

USE DATABASE REVENUE_OPS_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE REVENUE_WH;

-- ============================================================
-- QUERY 1: Revenue Leakage — Delivered Orders Never Invoiced
-- Result: 11,420 rows found
-- Insight: Orders delivered to customers but never billed
-- ============================================================
SELECT
    O.ORDER_ID,
    O.PARTNER_ID,
    O.CUSTOMER_ID,
    O.ORDER_DATE,
    O.STATUS,
    O.NET_AMOUNT,
    O.ORDER_CHANNEL
FROM FACT_ORDERS O
LEFT JOIN FACT_INVOICES I
    ON O.ORDER_ID = I.ORDER_ID
WHERE O.STATUS = 'Delivered'
  AND I.INVOICE_ID IS NULL
ORDER BY O.NET_AMOUNT DESC;

-- ============================================================
-- QUERY 2: Revenue Leakage Summary by Partner
-- Shows which partners have the most uninvoiced delivered orders
-- ============================================================
SELECT
    O.PARTNER_ID,
    P.PARTNER_NAME,
    COUNT(O.ORDER_ID)       AS UNINVOICED_ORDERS,
    SUM(O.NET_AMOUNT)       AS REVENUE_AT_RISK,
    ROUND(AVG(O.NET_AMOUNT), 2) AS AVG_ORDER_VALUE
FROM FACT_ORDERS O
LEFT JOIN FACT_INVOICES I
    ON O.ORDER_ID = I.ORDER_ID
LEFT JOIN DIM_PARTNERS P
    ON O.PARTNER_ID = P.PARTNER_ID
WHERE O.STATUS = 'Delivered'
  AND I.INVOICE_ID IS NULL
GROUP BY O.PARTNER_ID, P.PARTNER_NAME
ORDER BY REVENUE_AT_RISK DESC;

-- ============================================================
-- QUERY 3: Revenue Leakage Trend by Month
-- Shows if leakage is growing or reducing over time
-- ============================================================
SELECT
    DATE_TRUNC('MONTH', O.ORDER_DATE)   AS ORDER_MONTH,
    COUNT(O.ORDER_ID)                   AS UNINVOICED_ORDERS,
    SUM(O.NET_AMOUNT)                   AS REVENUE_AT_RISK
FROM FACT_ORDERS O
LEFT JOIN FACT_INVOICES I
    ON O.ORDER_ID = I.ORDER_ID
WHERE O.STATUS = 'Delivered'
  AND I.INVOICE_ID IS NULL
GROUP BY DATE_TRUNC('MONTH', O.ORDER_DATE)
ORDER BY ORDER_MONTH ASC;

-- ============================================================
-- QUERY 4: Total Revenue at Risk (KPI)
-- ============================================================
SELECT
    COUNT(O.ORDER_ID)   AS TOTAL_UNINVOICED_ORDERS,
    SUM(O.NET_AMOUNT)   AS TOTAL_REVENUE_AT_RISK
FROM FACT_ORDERS O
LEFT JOIN FACT_INVOICES I
    ON O.ORDER_ID = I.ORDER_ID
WHERE O.STATUS = 'Delivered'
  AND I.INVOICE_ID IS NULL;
