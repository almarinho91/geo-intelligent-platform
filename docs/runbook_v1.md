# Runbook v2 — AWS AIS Data Lake (S3 + Lambda + Athena + Glue/Spark)

This runbook documents the **end-to-end pipeline** you built to ingest **real AIS data** into an AWS data lake, transform it into **Parquet**, write **partitioned datasets**, and query them with **Athena**.

> Repo goal: keep the project **reproducible**.  
> Data files stay in S3; the repo stores **scripts + SQL + docs**.

---

## 0) High-level architecture

```
(Real AIS CSV) → S3 raw_ais/
     ↓
Athena external table (schema-on-read)
     ↓
Athena CTAS → Parquet (partitioned by dt or dt_hour)
     ↓
Glue (Spark) ETL jobs (optional / for advanced transforms)
     ↓
Athena external tables on analytics datasets
```

---

## 1) AWS resources

### S3 bucket
- `andre-geo-platform-dev`

### S3 layout (current)
- `raw/` — small demo CSVs (toy data)
- `curated/` — Lambda outputs (toy)
- `curated_parquet/` — Athena CTAS outputs (toy)
- `glue_output/` — Glue/Spark output (toy)
- `glue_output_partitioned/` — Glue/Spark output partitioned (toy)
- `raw_ais/` — **real AIS CSV** (750 MB+)
- `curated_ais_parquet/` — curated AIS Parquet (day partition)
- `curated_ais_parquet_hour/` — curated AIS Parquet (**hour partition**)

### Lambda
- Function: `geo-platform-s3-test`
- Trigger: S3 event on `raw/` (toy pipeline)
- Purpose: add derived field `speed_category`, write to `curated/`

### Glue / Spark
- Role: `geo-platform-glue-role`
- Jobs: used for Spark batch processing (toy pipeline)
- Outputs: `glue_output/`, `glue_output_partitioned/`

### Athena / Glue Data Catalog
- Database: `geo_platform`
- Tables are **metadata** only; data lives in S3.

---

## 2) Real AIS dataset ingestion (AWS-only)

### 2.1 Upload raw AIS CSV
Upload your AIS CSV to:

- `s3://andre-geo-platform-dev/raw_ais/`

Example:
- `raw_ais/ais-2025-01-01.csv`

---

### 2.2 Create Athena external table on raw AIS (tolerant to blanks)

Run `sql/11_create_raw_ais_table.sql` (or paste in Athena):

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS raw_ais (
  mmsi BIGINT,
  base_date_time STRING,
  longitude DOUBLE,
  latitude DOUBLE,
  sog DOUBLE,
  cog DOUBLE,
  heading DOUBLE,
  vessel_name STRING,
  imo STRING,
  call_sign STRING,
  vessel_type INT,
  status DOUBLE,
  length DOUBLE,
  width DOUBLE,
  draft DOUBLE,
  cargo DOUBLE,
  transceiver STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"'
)
LOCATION 's3://andre-geo-platform-dev/raw_ais/'
TBLPROPERTIES (
  'skip.header.line.count'='1',
  'use.null.for.invalid.data'='true'
);
```

Quick check:

```sql
SELECT COUNT(*) FROM raw_ais;
SELECT * FROM raw_ais LIMIT 10;
```

---

## 3) Curated Parquet (recommended)

### 3.1 Day partition (dt)
Use when you have multiple days of data.

Run `sql/12_ctas_curated_ais_parquet.sql`:

```sql
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
FROM raw_ais
WHERE mmsi IS NOT NULL
  AND base_date_time IS NOT NULL
  AND longitude IS NOT NULL
  AND latitude IS NOT NULL
  AND sog IS NOT NULL;
```

Validate:

```sql
SELECT dt, COUNT(*) AS n_rows
FROM curated_ais_from_raw_parquet
GROUP BY dt
ORDER BY dt;
```

---

### 3.2 Hour partition (dt_hour) — best for single-day datasets
If you ingest only one day (like your `2025-01-01` file), **partition by hour**.

Run `sql/13_ctas_curated_ais_parquet_hour.sql`:

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
FROM raw_ais
WHERE mmsi IS NOT NULL
  AND base_date_time IS NOT NULL
  AND longitude IS NOT NULL
  AND latitude IS NOT NULL
  AND sog IS NOT NULL;
```

Validate partitions (expect ~24):

```sql
SELECT dt_hour, COUNT(*) AS n_rows
FROM curated_ais_from_raw_parquet_hour
GROUP BY dt_hour
ORDER BY dt_hour;
```

Performance proof (partition pruning):

```sql
-- scans all partitions
SELECT SUM(sog) FROM curated_ais_from_raw_parquet_hour;

-- scans a single partition
SELECT SUM(sog)
FROM curated_ais_from_raw_parquet_hour
WHERE dt_hour = '2025-01-01 10';
```

---

## 4) Toy pipeline (small CSVs) — still kept for portfolio completeness

### 4.1 Upload a demo CSV
Upload to:
- `s3://andre-geo-platform-dev/raw/`

Lambda trigger writes:
- `s3://andre-geo-platform-dev/curated/<name>_processed.csv`

### 4.2 Athena on curated (toy)
- `sql/00_create_schema.sql`
- `sql/01_preview.sql`, `sql/02_speed_distribution.sql`

### 4.3 CTAS → Parquet (toy)
- `sql/03_create_parquet_table.sql`

### 4.4 Glue/Spark jobs (toy)
Repo scripts:
- `src/glue/jobs/glue_transform.py`
- `src/glue/jobs/glue_transform_partitioned.py`
- `src/glue/jobs/glue_transform_partitioned_incremental.py` (append + dedup)

Athena table on Spark output (toy):
- `sql/08_create_athena_table_glue_output_partitioned.sql`
- `sql/09_repair_partitions.sql`
- `sql/10_counts_by_dt.sql`

---

## 5) Quick troubleshooting

### Athena shows 0 rows
- Check that files are directly under the S3 `LOCATION` (no extra subfolders).

### BAD_DATA / NumberFormatException (empty string in numeric columns)
- Ensure table property: `'use.null.for.invalid.data'='true'`

### CTAS fails with HIVE_PATH_ALREADY_EXISTS
- Athena CTAS won’t overwrite existing S3 data.
- Delete the target folder contents in S3 or change `external_location`.

---
