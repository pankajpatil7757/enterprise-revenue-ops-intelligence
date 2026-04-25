-- ============================================================
-- FILE: 01_create_tables.sql
-- PROJECT: Enterprise Revenue & Operations Intelligence Platform
-- AUTHOR: Pankaj
-- DESCRIPTION: Creates all dimension and fact tables in Snowflake
-- ============================================================

USE DATABASE REVENUE_OPS_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE REVENUE_WH;

-- ============================================================
-- DIMENSION TABLES
-- ============================================================

-- Partners dimension
CREATE OR REPLACE TABLE DIM_PARTNERS (
    PARTNER_ID        VARCHAR(10)     NOT NULL,
    PARTNER_NAME      VARCHAR(100),
    REGION            VARCHAR(50),
    PARTNER_TYPE      VARCHAR(50),
    CONTACT_EMAIL     VARCHAR(100),
    PRIMARY KEY (PARTNER_ID)
);

-- Customers dimension
CREATE OR REPLACE TABLE DIM_CUSTOMERS (
    CUSTOMER_ID       VARCHAR(10)     NOT NULL,
    CUSTOMER_NAME     VARCHAR(100),
    CITY              VARCHAR(50),
    STATE             VARCHAR(50),
    COUNTRY           VARCHAR(50),
    SEGMENT           VARCHAR(50),
    PRIMARY KEY (CUSTOMER_ID)
);

-- Products dimension
CREATE OR REPLACE TABLE DIM_PRODUCTS (
    PRODUCT_ID        VARCHAR(10)     NOT NULL,
    PRODUCT_NAME      VARCHAR(100),
    CATEGORY          VARCHAR(50),
    SUBCATEGORY       VARCHAR(50),
    UNIT_PRICE        NUMBER(10,2),
    PRIMARY KEY (PRODUCT_ID)
);

-- SLA Targets dimension
CREATE OR REPLACE TABLE DIM_SLA_TARGETS (
    SLA_ID            VARCHAR(10)     NOT NULL,
    PARTNER_ID        VARCHAR(10),
    REGION            VARCHAR(50),
    PROMISED_SLA_DAYS NUMBER(3),
    PRIMARY KEY (SLA_ID)
);

-- ============================================================
-- FACT TABLES
-- ============================================================

-- Orders fact table
CREATE OR REPLACE TABLE FACT_ORDERS (
    ORDER_ID          VARCHAR(10)     NOT NULL,
    CUSTOMER_ID       VARCHAR(10),
    PARTNER_ID        VARCHAR(10),
    PRODUCT_ID        VARCHAR(10),
    ORDER_DATE        DATE,
    QUANTITY          NUMBER(5),
    ORDER_CHANNEL     VARCHAR(50),
    PRIORITY          VARCHAR(20),
    PROMISED_SLA_DAYS NUMBER(3),
    STATUS            VARCHAR(20),
    DISCOUNT_PCT      NUMBER(5,3),
    GROSS_AMOUNT      NUMBER(12,2),
    NET_AMOUNT        NUMBER(12,2),
    PRIMARY KEY (ORDER_ID)
);

-- Shipments fact table
CREATE OR REPLACE TABLE FACT_SHIPMENTS (
    SHIPMENT_ID           VARCHAR(10)  NOT NULL,
    ORDER_ID              VARCHAR(10),
    PARTNER_ID            VARCHAR(10),
    PICKUP_DATE           DATE,
    DELIVERY_DATE         DATE,
    PROMISED_DELIVERY_DATE DATE,
    SLA_BREACHED          BOOLEAN,
    SHIPMENT_STATUS       VARCHAR(20),
    PRIMARY KEY (SHIPMENT_ID)
);

-- Invoices fact table
CREATE OR REPLACE TABLE FACT_INVOICES (
    INVOICE_ID        VARCHAR(10)     NOT NULL,
    ORDER_ID          VARCHAR(10),
    CUSTOMER_ID       VARCHAR(10),
    PARTNER_ID        VARCHAR(10),
    INVOICE_DATE      DATE,
    DUE_DATE          DATE,
    INVOICE_AMOUNT    NUMBER(12,2),
    INVOICE_STATUS    VARCHAR(20),
    PRIMARY KEY (INVOICE_ID)
);

-- Payments fact table
CREATE OR REPLACE TABLE FACT_PAYMENTS (
    PAYMENT_ID        VARCHAR(10)     NOT NULL,
    INVOICE_ID        VARCHAR(10),
    PAYMENT_DATE      DATE,
    PAYMENT_AMOUNT    NUMBER(12,2),
    PAYMENT_MODE      VARCHAR(50),
    PAYMENT_STATUS    VARCHAR(20),
    PRIMARY KEY (PAYMENT_ID)
);
