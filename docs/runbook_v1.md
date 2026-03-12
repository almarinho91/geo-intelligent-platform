# Runbook — AIS Maritime Data Platform (AWS)

This runbook describes how to reproduce the AIS data pipeline built for this project.
The pipeline ingests raw AIS CSV data, transforms it into optimized Parquet datasets,
performs analytics, detects anomalies, and builds vessel behavior features.

---

# 1. Architecture Overview

AIS CSV Dataset
↓
Amazon S3 (Data Lake)
↓
Athena External Table (schema-on-read)
↓
CTAS Transformation (CSV → Parquet)
↓
Hourly Partitioned Dataset
↓
Analytics Tables
↓
Feature Engineering
↓
Anomaly Detection
↓
Behavior Clustering

---

# 2. AWS Resources

## S3 Bucket

Example bucket used in this project:

```
andre-geo-platform-dev
```

Important folders:

```
raw_ais/
curated_ais_parquet/
curated_ais_parquet_hour/
analytics_vessel_hourly/
```

---

# 3. Upload Raw AIS Data

Upload the AIS CSV file to:

```
s3://andre-geo-platform-dev/raw_ais/
```

Example:

```
ais-2025-01-01.csv
```

---

# 4. Create Athena External Table

Create the raw AIS table:

```sql
CREATE EXTERNAL TABLE raw_ais (
  mmsi BIGINT,
  base_date_time STRING,
  longitude DOUBLE,
  latitude DOUBLE,
  sog DOUBLE
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
LOCATION 's3://andre-geo-platform-dev/raw_ais/';
```

Verify ingestion:

```sql
SELECT *
FROM raw_ais
LIMIT 10;
```

---

# 5. Convert CSV → Parquet

Use Athena CTAS to optimize the dataset.

Example:

```sql
CREATE TABLE curated_ais_from_raw_parquet_hour
WITH (
  format = 'PARQUET',
  external_location = 's3://andre-geo-platform-dev/curated_ais_parquet_hour/',
  partitioned_by = ARRAY['dt_hour']
) AS
SELECT
  mmsi,
  base_date_time AS timestamp,
  longitude AS lon,
  latitude AS lat,
  sog,
  substr(base_date_time, 1, 13) AS dt_hour
FROM raw_ais;
```

Benefits:

- columnar storage
- compression
- faster queries
- lower Athena cost

---

# 6. Validate Partitioning

Example query:

```sql
SELECT *
FROM curated_ais_from_raw_parquet_hour
WHERE dt_hour = '2025-01-01 10'
LIMIT 10;
```

Athena scans only the relevant partition.

---

# 7. Build Analytics Layer

Create aggregated vessel metrics.

Example:

```sql
SELECT
  dt_hour,
  COUNT(*) AS n_points,
  COUNT(DISTINCT mmsi) AS n_vessels,
  AVG(sog) AS avg_speed
FROM curated_ais_from_raw_parquet_hour
GROUP BY dt_hour
ORDER BY dt_hour;
```

Example insight:

Most AIS messages correspond to vessels with speed < 0.5 knots,
indicating vessels anchored or waiting in port.

---

# 8. Detect Speed Anomalies

Speed anomaly rule:

```sql
SELECT *
FROM curated_ais_from_raw_parquet_hour
WHERE sog > 40;
```

This identifies vessels reporting unrealistic speeds.

---

# 9. Trajectory Anomaly Detection

Trajectory anomalies are detected using window functions.

Example:

```sql
LAG(timestamp) OVER (PARTITION BY mmsi ORDER BY timestamp)
```

This allows comparison of consecutive vessel positions.

Steps:

1. Retrieve previous AIS point
2. Compute time difference
3. Estimate movement distance
4. Flag unrealistic jumps

Example anomaly:

A vessel appearing hundreds of kilometers away within one second,
indicating corrupted AIS data.

---

# 10. Create Vessel Behavior Feature Table

Create ML-ready features:

```sql
CREATE TABLE vessel_behavior_features AS
SELECT
  mmsi,
  COUNT(*) AS n_points,
  AVG(sog) AS avg_sog,
  MAX(sog) AS max_sog,
  SUM(CASE WHEN sog < 0.5 THEN 1 ELSE 0 END) AS stopped_points
FROM curated_ais_from_raw_parquet_hour
GROUP BY mmsi;
```

Derived feature:

```
stopped_ratio = stopped_points / n_points
```

---

# 11. Vessel Behavior Clustering

Rule-based clusters:

| Cluster | Description |
|------|------|
anchored_vessels | mostly stopped |
normal_traffic | typical vessel speeds |
slow_movers | slow moving vessels |
anomalous_vessels | vessels with speed anomalies |

Example query:

```sql
SELECT
  vessel_behavior_cluster,
  COUNT(*)
FROM vessel_behavior_features
GROUP BY vessel_behavior_cluster;
```

---

# 12. Dataset Statistics

Example results from the dataset:

- ~16,286 vessels
- ~450 AIS messages per vessel (average)
- ~74% of messages represent stopped vessels
- only ~21 vessels exhibit strong anomaly behavior

---

# 13. Repository Workflow

Typical workflow:

1. Upload raw data
2. Create external table
3. Convert to Parquet
4. Build analytics tables
5. Run anomaly detection
6. Generate behavior features
7. Perform clustering

---

# 14. Reproducibility

All SQL scripts required to reproduce the pipeline are stored in:

```
sql/
```

Key scripts:

```
26_create_vessel_behavior_features.sql
27_feature_distribution_summary.sql
28_top_vessel_activity.sql
29_vessel_behavior_clusters.sql
30_cluster_counts.sql
```

---