
# AIS Maritime Data Platform (AWS)

This project demonstrates the design and implementation of a cloud-based data platform for maritime AIS (Automatic Identification System) data using AWS services.
It covers the full pipeline from raw data ingestion to analytics-ready datasets optimized for large-scale querying.

The system processes real AIS vessel trajectory data (~800 MB CSV) and transforms it into partitioned Parquet datasets that can be efficiently queried with SQL.

---

## Architecture Overview

AIS CSV dataset
↓
Amazon S3 (raw_ais/)
↓
Athena External Table (schema-on-read)
↓
Athena CTAS transformation (CSV → Parquet)
↓
Partitioned dataset (dt_hour)
↓
Analytics Layer (analytics_vessel_hourly)

---

## Technologies Used

- Amazon S3 — Data lake storage
- Amazon Athena — Serverless SQL query engine
- AWS Glue / Spark — Batch data processing (optional ETL layer)
- AWS Lambda — Event-driven ingestion (demo pipeline)
- Parquet — Columnar storage for efficient analytics

---

## Data Lake Structure

andre-geo-platform-dev/

raw/ — small demo CSV files  
curated/ — Lambda processed data  
curated_parquet/ — Athena CTAS output  
glue_output/ — Spark output  
glue_output_partitioned/ — Spark partitioned output  

raw_ais/ — real AIS dataset  
curated_ais_parquet/ — curated AIS dataset (daily partitions)  
curated_ais_parquet_hour/ — curated AIS dataset (hourly partitions)

---

## Real AIS Dataset

The pipeline processes Automatic Identification System (AIS) vessel tracking data.

Important columns:

- mmsi — unique vessel identifier
- base_date_time — AIS message timestamp
- longitude / latitude — vessel position
- sog — speed over ground (knots)

AIS data is used by:

- port authorities
- shipping companies
- maritime surveillance systems
- logistics and fleet monitoring

---

## Raw Data Ingestion

The AIS dataset is uploaded to:

s3://andre-geo-platform-dev/raw_ais/

Example file:

ais-2025-01-01.csv

An Athena external table reads the CSV using schema-on-read.

---

## CSV → Parquet Transformation

The raw CSV dataset is converted to Parquet using Athena CTAS.

Benefits:

- columnar storage
- better compression
- faster queries
- lower Athena cost

Example:

CREATE TABLE curated_ais_from_raw_parquet
WITH (
  format = 'PARQUET',
  external_location = 's3://andre-geo-platform-dev/curated_ais_parquet/',
  partitioned_by = ARRAY['dt']
) AS
SELECT
  mmsi,
  base_date_time AS timestamp,
  longitude AS lon,
  latitude AS lat,
  sog,
  substr(base_date_time, 1, 10) AS dt
FROM raw_ais;

---

## Partition Strategy

Because the dataset initially contained one day of data, hourly partitioning was used:

dt_hour = 2025-01-01 10

Structure:

curated_ais_parquet_hour/
dt_hour=2025-01-01 00/
dt_hour=2025-01-01 01/
...
dt_hour=2025-01-01 23/

This enables partition pruning in Athena.

Example:

SELECT *
FROM curated_ais_from_raw_parquet_hour
WHERE dt_hour = '2025-01-01 10';

Athena reads only one partition instead of the entire dataset.

---

## Analytics Layer

An aggregated analytics table was created:

analytics_vessel_hourly

Metrics calculated per hour:

- n_points — number of AIS messages
- n_vessels — unique vessels observed
- avg_sog — average vessel speed
- p50_sog — median vessel speed
- p90_sog — high-speed percentile
- n_stopped_points — AIS messages where vessel speed < 0.5 knots

Example query:

SELECT dt_hour, n_vessels
FROM analytics_vessel_hourly
ORDER BY dt_hour;

---

## Traffic Analysis Results

Example:

Hour: 06:00  
Vessels: ~12,500  
Average speed: ~1.7 knots  

Key insight:

Approximately 71%–79% of AIS messages correspond to stopped vessels (speed < 0.5 knots).

This is consistent with maritime operations where ships spend significant time anchored or in port.

---

## Example Analytics Queries

### Vessel activity per hour

SELECT dt_hour, n_vessels
FROM analytics_vessel_hourly
ORDER BY dt_hour;

### Stopped vessel ratio

SELECT
dt_hour,
CAST(n_stopped_points AS DOUBLE)/n_points AS stopped_ratio
FROM analytics_vessel_hourly
ORDER BY dt_hour;

### Top vessels by AIS messages

SELECT
mmsi,
COUNT(*) AS n_points
FROM curated_ais_from_raw_parquet_hour
GROUP BY mmsi
ORDER BY n_points DESC
LIMIT 20;

---

## Key Data Engineering Concepts Demonstrated

- Data lake architecture (S3)
- Schema-on-read analytics
- CSV → Parquet optimization
- Partitioned datasets
- Partition pruning
- Serverless analytics with Athena

---

## Repository Structure

docs/
runbook_v2.md

sql/
11_create_raw_ais_table.sql
12_ctas_curated_ais_parquet.sql
13_ctas_curated_ais_parquet_hour.sql
14_perf_compare_hour_partition.sql
17_stopped_ratio_by_hour.sql
18_top_vessels_per_hour.sql

src/
glue/jobs/
glue_transform.py
glue_transform_partitioned.py
glue_transform_partitioned_incremental.py

---

## Future Improvements

- Maritime traffic visualization
- Vessel trajectory clustering
- AIS anomaly detection
- Incremental ingestion pipelines
