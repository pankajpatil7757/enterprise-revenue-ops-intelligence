-- ============================================================
-- FILE: 07_order_to_invoice_tat.sql
-- PROJECT: Enterprise Revenue & Operations Intelligence Platform
-- AUTHOR: Pankaj
-- DESCRIPTION: Order to Invoice Turnaround Time (TAT) analysis
--              Result: 57,224 rows analyzed
--              Insight: Most invoices raised within 15 days — healthy TAT
-- ============================================================

USE DATABASE REVENUE_OPS_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE REVENUE_WH;

-- ============================================================
-- QUERY 1: Order to Invoice TAT — Full Detail
-- Days between order date and invoice date per order
-- ============================================================
SELECT
    O.ORDER_ID,
    O.PARTNER_ID,
    O.CUSTOMER_ID,
    O.ORDER_DATE,
    I.INVOICE_DATE,
    DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE)   AS TAT_DAYS,
    O.NET_AMOUNT,
    O.STATUS
FROM FACT_ORDERS O
INNER JOIN FACT_INVOICES I
    ON O.ORDER_ID = I.ORDER_ID
ORDER BY TAT_DAYS DESC;

-- ============================================================
-- QUERY 2: Avg Order-to-Invoice TAT by Partner
-- Highlights which partners are slowest to invoice
-- ============================================================
SELECT
    O.PARTNER_ID,
    P.PARTNER_NAME,
    COUNT(O.ORDER_ID)                                           AS TOTAL_ORDERS,
    ROUND(AVG(DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE)), 1) AS AVG_TAT_DAYS,
    MIN(DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE))          AS MIN_TAT_DAYS,
    MAX(DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE))          AS MAX_TAT_DAYS
FROM FACT_ORDERS O
INNER JOIN FACT_INVOICES I
    ON O.ORDER_ID = I.ORDER_ID
LEFT JOIN DIM_PARTNERS P
    ON O.PARTNER_ID = P.PARTNER_ID
GROUP BY O.PARTNER_ID, P.PARTNER_NAME
ORDER BY AVG_TAT_DAYS DESC;

-- ============================================================
-- QUERY 3: TAT Bucket Distribution
-- Buckets orders by how quickly they were invoiced
-- ============================================================
SELECT
    CASE
        WHEN DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE) <= 7   THEN '1 - Within 7 Days'
        WHEN DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE) <= 15  THEN '2 - 8 to 15 Days'
        WHEN DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE) <= 30  THEN '3 - 16 to 30 Days'
        WHEN DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE) <= 60  THEN '4 - 31 to 60 Days'
        ELSE '5 - 60+ Days'
    END                     AS TAT_BUCKET,
    COUNT(O.ORDER_ID)       AS ORDER_COUNT,
    ROUND(AVG(DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE)), 1) AS AVG_TAT_DAYS
FROM FACT_ORDERS O
INNER JOIN FACT_INVOICES I
    ON O.ORDER_ID = I.ORDER_ID
GROUP BY TAT_BUCKET
ORDER BY TAT_BUCKET ASC;

-- ============================================================
-- QUERY 4: Partners Breaching 15-Day TAT Target
-- Partners who consistently invoice late
-- ============================================================
SELECT
    O.PARTNER_ID,
    P.PARTNER_NAME,
    COUNT(O.ORDER_ID)                                               AS TOTAL_ORDERS,
    SUM(CASE
        WHEN DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE) > 15
        THEN 1 ELSE 0
    END)                                                            AS LATE_INVOICED_ORDERS,
    ROUND(
        SUM(CASE
            WHEN DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE) > 15
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(O.ORDER_ID), 2
    )                                                               AS LATE_INVOICE_PCT
FROM FACT_ORDERS O
INNER JOIN FACT_INVOICES I
    ON O.ORDER_ID = I.ORDER_ID
LEFT JOIN DIM_PARTNERS P
    ON O.PARTNER_ID = P.PARTNER_ID
GROUP BY O.PARTNER_ID, P.PARTNER_NAME
HAVING LATE_INVOICE_PCT > 50
ORDER BY LATE_INVOICE_PCT DESC;

-- ============================================================
-- QUERY 5: Overall TAT KPI
-- ============================================================
SELECT
    COUNT(O.ORDER_ID)                                               AS TOTAL_INVOICED_ORDERS,
    ROUND(AVG(DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE)), 1)   AS OVERALL_AVG_TAT_DAYS,
    MIN(DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE))             AS MIN_TAT_DAYS,
    MAX(DATEDIFF('DAY', O.ORDER_DATE, I.INVOICE_DATE))             AS MAX_TAT_DAYS
FROM FACT_ORDERS O
INNER JOIN FACT_INVOICES I
    ON O.ORDER_ID = I.ORDER_ID;
