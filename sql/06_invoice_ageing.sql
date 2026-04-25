-- ============================================================
-- FILE: 06_invoice_ageing.sql
-- PROJECT: Enterprise Revenue & Operations Intelligence Platform
-- AUTHOR: Pankaj
-- DESCRIPTION: Invoice ageing analysis — overdue invoice buckets
--              Result: 9,008 unpaid invoices found
--              Insight: 9,008 invoices overdue by 800+ days — bad debt risk
-- ============================================================

USE DATABASE REVENUE_OPS_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE REVENUE_WH;

-- ============================================================
-- QUERY 1: Invoice Ageing Buckets
-- Buckets overdue invoices by days outstanding
-- ============================================================
SELECT
    INVOICE_ID,
    ORDER_ID,
    PARTNER_ID,
    CUSTOMER_ID,
    INVOICE_DATE,
    DUE_DATE,
    INVOICE_AMOUNT,
    INVOICE_STATUS,
    DATEDIFF('DAY', DUE_DATE, CURRENT_DATE())       AS DAYS_OVERDUE,
    CASE
        WHEN DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) <= 30   THEN '1 - 0 to 30 Days'
        WHEN DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) <= 90   THEN '2 - 31 to 90 Days'
        WHEN DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) <= 180  THEN '3 - 91 to 180 Days'
        WHEN DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) <= 365  THEN '4 - 181 to 365 Days'
        WHEN DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) > 365   THEN '5 - 800+ Days'
        ELSE 'Not Overdue'
    END                                             AS AGEING_BUCKET
FROM FACT_INVOICES
WHERE INVOICE_STATUS = 'Open'
ORDER BY DAYS_OVERDUE DESC;

-- ============================================================
-- QUERY 2: Ageing Bucket Summary
-- Count and amount per bucket
-- ============================================================
SELECT
    CASE
        WHEN DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) <= 30   THEN '1 - 0 to 30 Days'
        WHEN DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) <= 90   THEN '2 - 31 to 90 Days'
        WHEN DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) <= 180  THEN '3 - 91 to 180 Days'
        WHEN DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) <= 365  THEN '4 - 181 to 365 Days'
        WHEN DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) > 365   THEN '5 - 800+ Days'
        ELSE 'Not Overdue'
    END                             AS AGEING_BUCKET,
    COUNT(INVOICE_ID)               AS INVOICE_COUNT,
    SUM(INVOICE_AMOUNT)             AS TOTAL_OVERDUE_AMOUNT,
    ROUND(AVG(INVOICE_AMOUNT), 2)   AS AVG_INVOICE_AMOUNT
FROM FACT_INVOICES
WHERE INVOICE_STATUS = 'Open'
GROUP BY AGEING_BUCKET
ORDER BY AGEING_BUCKET ASC;

-- ============================================================
-- QUERY 3: Overdue Invoices by Partner
-- Which partners owe the most
-- ============================================================
SELECT
    I.PARTNER_ID,
    P.PARTNER_NAME,
    COUNT(I.INVOICE_ID)             AS OVERDUE_INVOICES,
    SUM(I.INVOICE_AMOUNT)           AS TOTAL_OVERDUE_AMOUNT,
    MAX(DATEDIFF('DAY', I.DUE_DATE, CURRENT_DATE())) AS MAX_DAYS_OVERDUE
FROM FACT_INVOICES I
LEFT JOIN DIM_PARTNERS P
    ON I.PARTNER_ID = P.PARTNER_ID
WHERE I.INVOICE_STATUS = 'Open'
GROUP BY I.PARTNER_ID, P.PARTNER_NAME
ORDER BY TOTAL_OVERDUE_AMOUNT DESC;

-- ============================================================
-- QUERY 4: Bad Debt Risk — invoices overdue 800+ days
-- ============================================================
SELECT
    INVOICE_ID,
    ORDER_ID,
    PARTNER_ID,
    INVOICE_AMOUNT,
    DUE_DATE,
    DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) AS DAYS_OVERDUE
FROM FACT_INVOICES
WHERE INVOICE_STATUS = 'Open'
  AND DATEDIFF('DAY', DUE_DATE, CURRENT_DATE()) > 365
ORDER BY DAYS_OVERDUE DESC;
