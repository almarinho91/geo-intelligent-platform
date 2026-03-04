# Runbook v1 — S3 → Lambda → Athena → Glue (Data Platform Pipeline)

## What this project does

Implements a small cloud data platform on AWS for processing AIS vessel trajectory data.

The pipeline demonstrates:

* Event-driven ingestion with AWS Lambda
* Data lake architecture using Amazon S3
* Serverless SQL analytics using Amazon Athena
* Columnar storage optimization with Parquet
* Batch data processing using AWS Glue (Spark)
* Partitioned data layout for scalable analytics

---

# Architecture Overview

Pipeline flow:

raw CSV (S3)
→ Lambda transformation
→ curated CSV
→ Athena CTAS (convert to Parquet)
→ curated_parquet/
→ Glue Spark job
→ partitioned Parquet dataset
→ Athena analytics

S3 Data Lake layout:

andre-geo-platform-dev/
raw/
curated/
curated_parquet/
glue_output/
glue_output_partitioned/

---

# AWS Resources

## S3

Bucket:

andre-geo-platform-dev

Data lake zones:

raw/                    → raw uploaded CSV files
curated/                → Lambda processed CSV files
curated_parquet/        → Athena-generated Parquet files
glue_output/            → Spark output (unpartitioned)
glue_output_partitioned/ → Spark output partitioned by date

---

## Lambda

Function:

geo-platform-s3-test

Purpose:

* Triggered when CSV files are uploaded to raw/
* Reads AIS CSV data
* Adds derived column: speed_category
* Writes processed file to curated/

Output example:

raw/test_ais_3days.csv
→ curated/test_ais_3days_processed.csv

---

## IAM

Roles used:

Lambda execution role

* S3 read/write
* CloudWatch logs

Glue execution role

geo-platform-glue-role

Permissions:

* AmazonS3FullAccess
* AWSGlueServiceRole

---

# Step 1 — Upload Raw Data

Upload AIS CSV file to:

s3://andre-geo-platform-dev/raw/

Example file:

test_ais_3days.csv

Example contents:

mmsi,timestamp,lat,lon,sog
123456789,2024-01-01T10:00:00,53.54,9.99,12.5
123456789,2024-01-02T10:05:00,53.55,10.01,13.2
987654321,2024-01-03T10:00:00,53.52,9.95,0.2

This automatically triggers the Lambda function.

---

# Step 2 — Lambda Processing

Lambda reads the CSV and generates:

speed_category

Example output:

curated/test_ais_3days_processed.csv

---

# Step 3 — Create Athena Schema

Run:

sql/00_create_schema.sql

This creates:

Database

geo_platform

External table

curated_ais

pointing to:

s3://andre-geo-platform-dev/curated/

---

# Step 4 — Query Data in Athena

Example queries:

sql/01_preview.sql

sql/02_speed_distribution.sql

These demonstrate basic analytics queries.

---

# Step 5 — Convert CSV → Parquet

Run:

sql/03_create_parquet_table.sql

This uses CTAS (Create Table As Select) to generate:

s3://andre-geo-platform-dev/curated_parquet/

Benefits:

* columnar storage
* faster queries
* lower Athena scan cost

---

# Step 6 — Create Partitioned Dataset with Spark (Glue)

Glue job:

geo-platform-spark-test

Script:

src/glue/jobs/glue_transform_partitioned.py

Spark logic:

1. Read Parquet dataset
2. Derive date column from timestamp
3. Write partitioned Parquet dataset

Partition key:

dt = substring(timestamp,1,10)

Output layout:

s3://andre-geo-platform-dev/glue_output_partitioned/

dt=2024-01-01/
dt=2024-01-02/
dt=2024-01-03/

---

# Step 7 — Create Athena Table on Partitioned Dataset

Run:

sql/08_create_athena_table_glue_output_partitioned.sql

Then load partitions:

sql/09_repair_partitions.sql

---

# Step 8 — Validate Dataset

Run:

sql/10_counts_by_dt.sql

Expected output:

dt           | n_rows
2024-01-01   | 1
2024-01-02   | 1
2024-01-03   | 1

---

# Key Data Engineering Concepts Demonstrated

This project demonstrates:

Event-driven ingestion
Serverless compute
Data lake architecture
Schema-on-read
Columnar storage (Parquet)
Partition pruning
Spark batch processing
Athena SQL analytics

---

# How to Reproduce the Pipeline

1. Upload AIS CSV to raw/
2. Lambda automatically generates curated dataset
3. Run Athena CTAS to produce Parquet
4. Run Glue Spark job to create partitioned dataset
5. Create Athena table on partitioned dataset
6. Query analytics using SQL

---

# Next Improvements (planned)

* Incremental data ingestion
* Glue crawler for automatic schema detection
* Feature engineering layer
* Machine learning model for vessel behavior analysis
* Dashboard / visualization
