# Architecture v1 — Geo-Intelligent Mobility Platform

## Objective
Build an end-to-end cloud data pipeline for trajectory data (AIS), including:

- Automated ingestion
- Data lake storage (raw → curated)
- Feature engineering
- Batch ML anomaly detection
- Analytics layer

## High-Level Flow

1. AIS data ingestion (AWS Lambda)
2. Storage in Amazon S3 (raw zone)
3. Transformation to curated Parquet datasets
4. Feature generation
5. Model training & batch scoring
6. Analytical queries and visualization

## Data Lake Structure

s3://<bucket>/
    raw/
    curated/
    features/
    predictions/

## Tech Stack (Planned)

- Amazon S3
- AWS Lambda
- AWS Glue (PySpark)
- Amazon Athena
- Amazon SageMaker
- Amazon CloudWatch