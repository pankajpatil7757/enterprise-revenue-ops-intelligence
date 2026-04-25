-- ============================================================
-- FILE: 02_create_views.sql
-- PROJECT: Enterprise Revenue & Operations Intelligence Platform
-- AUTHOR: Pankaj
-- DESCRIPTION: Creates summary views for Power BI consumption
-- ============================================================

USE DATABASE REVENUE_OPS_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE REVENUE_WH;

-- ============================================================
-- VIEW 1: FACT_ORDERS_SUMMARY
-- Deduplicated orders by ORDER_ID
-- ============================================================
CREATE OR REPLACE VIEW FACT_ORDERS_SUMMARY AS
SELECT
    ORDER_ID,
    CUSTOMER_ID,
    PARTNER_ID,
    PRODUCT_ID,
    ORDER_DATE,
    QUANTITY,
    ORDER_CHANNEL,
    PRIORITY,
    PROMISED_SLA_DAYS,
    STATUS,
    DISCOUNT_PCT,
    GROSS_AMOUNT,
    NET_AMOUNT,
    ROW_NUMBER() OVER (PARTITION BY ORDER_ID ORDER BY ORDER_DATE DESC) AS RN
FROM FACT_ORDERS
QUALIFY RN = 1;

-- ============================================================
-- VIEW 2: FACT_SHIPMENTS_SUMMARY
-- Aggregated shipments per order
-- ============================================================
CREATE OR REPLACE VIEW FACT_SHIPMENTS_SUMMARY AS
SELECT
    ORDER_ID,
    PARTNER_ID,
    COUNT(SHIPMENT_ID)                          AS TOTAL_SHIPMENTS,
    MIN(PICKUP_DATE)                            AS FIRST_PICKUP_DATE,
    MAX(DELIVERY_DATE)                          AS LAST_DELIVERY_DATE,
    MAX(PROMISED_DELIVERY_DATE)                 AS PROMISED_DELIVERY_DATE,
    SUM(CASE WHEN SLA_BREACHED = TRUE THEN 1 ELSE 0 END) AS BREACHED_COUNT,
    SUM(CASE WHEN SLA_BREACHED = FALSE THEN 1 ELSE 0 END) AS ONTIME_COUNT
FROM FACT_SHIPMENTS
GROUP BY ORDER_ID, PARTNER_ID;

-- ============================================================
-- VIEW 3: FACT_INVOICES_SUMMARY
-- Aggregated invoices per order
-- ============================================================
CREATE OR REPLACE VIEW FACT_INVOICES_SUMMARY AS
SELECT
    ORDER_ID,
    PARTNER_ID,
    COUNT(INVOICE_ID)       AS TOTAL_INVOICES,
    SUM(INVOICE_AMOUNT)     AS TOTAL_INVOICE_AMOUNT,
    MIN(INVOICE_DATE)       AS FIRST_INVOICE_DATE,
    MAX(DUE_DATE)           AS LATEST_DUE_DATE
FROM FACT_INVOICES
GROUP BY ORDER_ID, PARTNER_ID;

-- ============================================================
-- VIEW 4: FACT_INVOICES_BY_INVOICE
-- Unique invoice level data with days overdue
-- ============================================================
CREATE OR REPLACE VIEW FACT_INVOICES_BY_INVOICE AS
SELECT
    I.INVOICE_ID,
    I.ORDER_ID,
    I.CUSTOMER_ID,
    I.PARTNER_ID,
    I.INVOICE_DATE,
    I.DUE_DATE,
    I.INVOICE_AMOUNT,
    I.INVOICE_STATUS,
    DATEDIFF('DAY', I.DUE_DATE, CURRENT_DATE())  AS DAYS_OVERDUE,
    CASE
        WHEN DATEDIFF('DAY', I.DUE_DATE, CURRENT_DATE()) <= 30   THEN '1 - 0 to 30 Days'
        WHEN DATEDIFF('DAY', I.DUE_DATE, CURRENT_DATE()) <= 90   THEN '2 - 31 to 90 Days'
        WHEN DATEDIFF('DAY', I.DUE_DATE, CURRENT_DATE()) <= 180  THEN '3 - 91 to 180 Days'
        WHEN DATEDIFF('DAY', I.DUE_DATE, CURRENT_DATE()) <= 365  THEN '4 - 181 to 365 Days'
        WHEN DATEDIFF('DAY', I.DUE_DATE, CURRENT_DATE()) > 365   THEN '5 - 800+ Days'
        ELSE 'Not Overdue'
    END AS AGEING_BUCKET
FROM FACT_INVOICES I
WHERE I.INVOICE_STATUS = 'Open';

-- ============================================================
-- VIEW 5: FACT_PAYMENTS_SUMMARY
-- Aggregated payments per invoice
-- ============================================================
CREATE OR REPLACE VIEW FACT_PAYMENTS_SUMMARY AS
SELECT
    INVOICE_ID,
    COUNT(PAYMENT_ID)       AS TOTAL_PAYMENTS,
    SUM(PAYMENT_AMOUNT)     AS TOTAL_PAID_AMOUNT,
    MAX(PAYMENT_DATE)       AS LAST_PAYMENT_DATE,
    MAX(PAYMENT_STATUS)     AS PAYMENT_STATUS
FROM FACT_PAYMENTS
GROUP BY INVOICE_ID;
