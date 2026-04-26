# 🏢 Enterprise Revenue & Operations Intelligence Platform

> A real-world Business Analyst portfolio project demonstrating end-to-end data pipeline design, cloud data warehousing, and multi-dashboard BI reporting.

---

## 📌 Project Overview

This project simulates an enterprise-grade analytics solution for a logistics and revenue operations business. Raw transactional data is ingested from CSV sources, transformed through a cloud pipeline, stored in a Snowflake data warehouse, and visualized through four Power BI dashboards — covering everything from executive revenue KPIs to SLA compliance and partner performance.

---

## 🧱 Architecture

```
CSV Files (Raw Data)
        │
        ▼
Azure Blob Storage (raw-csvs container)
        │
        ▼
Azure Data Factory (ADF Pipelines)
        │  ├── pl_load_dimensions
        │  └── Copy Data Activities (4)
        ▼
Snowflake Data Warehouse
        │  ├── Dimension Tables
        │  └── Fact Tables
        ▼
Power BI Dashboards (4)
```

---

## 🛠️ Tech Stack

| Layer | Tool |
|---|---|
| Raw Data Storage | Azure Blob Storage |
| Data Orchestration | Azure Data Factory (ADF) |
| Data Warehouse | Snowflake |
| Transformation | SQL |
| Visualization | Power BI |

---

## 📊 Dashboards

### 1. 📈 Executive Revenue Dashboard
High-level revenue KPIs for C-suite visibility — total revenue, revenue trends, period-over-period comparisons, and top-line financial performance metrics.

### 2. 🤝 Partner Scorecard Dashboard
Performance tracking across business partners — partner-level revenue contribution, ranking, and scorecard metrics to support vendor management decisions.

### 3. ✅ SLA & Compliance Dashboard
Operational compliance monitoring — SLA breach rates, on-time delivery performance, and compliance trends segmented by partner, region, or product line.

### 4. 🗼 Operations Control Tower Dashboard
Real-time operations oversight — end-to-end visibility into pipeline health, operational bottlenecks, and delivery performance across the business.

---

## 🗂️ Project Structure

```
├── sql/
│   ├── 01_create_schema.sql
│   ├── 02_dim_customers.sql
│   ├── 03_dim_products.sql
│   ├── 04_dim_partners.sql
│   ├── 05_fact_revenue.sql
│   ├── 06_fact_operations.sql
│   └── 07_sla_compliance.sql
├── adf/
│   └── pipelines/
│       └── pl_load_dimensions/
├── dashboards/
│   ├── executive_revenue.pbix
│   ├── partner_scorecard.pbix
│   ├── sla_compliance.pbix
│   └── operations_control_tower.pbix
└── README.md
```

---

## ⚙️ Pipeline Details

### Azure Data Factory Setup

**Linked Services**
- `ls_blob_raw` — connects ADF to Azure Blob Storage (raw-csvs container)
- `ls_snowflake_revenue` — connects ADF to Snowflake data warehouse

**Datasets**
- Blob datasets pointing to individual CSV files (dim & fact tables)
- Snowflake datasets pointing to target tables (UPPERCASE naming convention)

**Pipelines**
- `pl_load_dimensions` — orchestrates 4 Copy Data activities to load dimension tables from Blob CSV → Snowflake

### Snowflake Setup
- Tables created for both dimension and fact layers
- Data modeled using a **Star Schema** design
- All SQL scripts included in the `/sql` directory

---

## 🚀 How to Run

### Prerequisites
- Azure subscription with Blob Storage and ADF access
- Snowflake account
- Power BI Desktop

### Steps

1. **Upload CSV files** to Azure Blob Storage in the `raw-csvs` container
2. **Configure Linked Services** in ADF using your Snowflake credentials
3. **Create Datasets** pointing to your CSV files and Snowflake tables
4. **Run the ADF Pipeline** (`pl_load_dimensions`) to load data into Snowflake
5. **Execute SQL scripts** in `/sql` to set up schema and transformations
6. **Open Power BI dashboards** and connect to your Snowflake instance

---

## 💡 Key Learnings

- Designed and deployed an **end-to-end cloud data pipeline** using ADF and Snowflake
- Built **Linked Services, Datasets, and Copy Activities** in Azure Data Factory
- Modeled data using a **Star Schema** (dim + fact tables) for analytical efficiency
- Wrote **7 SQL scripts** covering schema creation, dimension tables, and fact tables
- Developed **4 Power BI dashboards** covering executive, partner, compliance, and operations views

---

## 👤 Author

**Pankaj**
Data Analyst | Azure | Snowflake | Power BI | SQL

---

## 📄 License

This project is built for portfolio and learning purposes.
