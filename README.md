# Geo-Intelligent Mobility Analytics Platform (AWS)

An end-to-end serverless data pipeline on AWS for trajectory data processing and analytics.

## Current Architecture (Week 1)

**Ingestion Layer**
- Amazon S3 (raw zone)
- AWS Lambda (event-driven processing)

**Storage**
- Data Lake structure:
  - raw/
  - curated/
  - curated_parquet/

**Analytics**
- Amazon Athena (SQL on S3)

## What Is Implemented

- Event-driven S3 → Lambda transformation
- Automated processing from raw/ to curated/
- External table in Athena
- Analytical SQL queries
- Conversion from CSV to Parquet using Athena (CTAS)
- Columnar storage for improved performance and cost efficiency

## Example Flow

1. Upload CSV to `raw/`
2. Lambda processes file automatically
3. Output written to `curated/`
4. Query curated data using Athena

## Next Steps

- Introduce partitioning
- Add feature engineering layer
- Add ML training pipeline