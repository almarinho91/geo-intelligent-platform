# Runbook v1 — S3 → Lambda → S3 (Raw to Curated)

## What this does
Reads `raw/test_ais.csv` from S3, adds a derived column (`speed_category`), and writes the result to `curated/test_ais_processed.csv`.

## AWS resources (manual, v1)
- S3 bucket: `andre-geo-platform-dev`
- Lambda function: `geo-platform-s3-test`
- IAM: Lambda execution role with S3 + CloudWatch logs permissions

## How to run
1. Upload `test_ais.csv` to `s3://andre-geo-platform-dev/raw/test_ais.csv`
2. Run the Lambda test event `test1`
3. Verify output at `s3://andre-geo-platform-dev/curated/test_ais_processed.csv`

## Event-driven mode (v2)
An S3 trigger is configured so that any `.csv` uploaded to `raw/` automatically triggers the Lambda and writes a processed file to `curated/`.

Example:
- Upload: `raw/test_ais_2.csv`
- Output: `curated/test_ais_2_processed.csv`

## Athena setup

1. Run sql/00_create_schema.sql
2. Select database geo_platform
3. Run analysis queries from sql/