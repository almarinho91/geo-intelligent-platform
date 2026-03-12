
# AIS Maritime Data Platform (AWS)

This project demonstrates the design of a hybrid Data Engineering + Data Science pipeline for maritime AIS (Automatic Identification System) data using AWS services.

The system ingests raw vessel trajectory data, builds a scalable data lake, performs analytics, detects anomalies, and derives vessel behavioral clusters.

The dataset processed in this project contains ~800 MB of AIS messages representing over 16,000 vessels and millions of trajectory points.

---

## Architecture Overview

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
Analytics Layer (vessel traffic metrics)
↓
Feature Engineering (vessel_behavior_features)
↓
Anomaly Detection
↓
Vessel Behavior Clustering

---

## Technologies Used

- Amazon S3 — Data lake storage
- Amazon Athena — Serverless SQL analytics
- AWS Glue / Spark — Optional ETL processing
- AWS Lambda — Event-driven ingestion demo
- Parquet — Columnar storage format
- SQL (Athena) — Feature engineering and analytics

---

## Data Lake Structure

andre-geo-platform-dev/

raw/  
curated/  
curated_parquet/  
glue_output/  
glue_output_partitioned/  

raw_ais/  
curated_ais_parquet/  
curated_ais_parquet_hour/  

analytics_vessel_hourly/  

---

## Raw AIS Dataset

Important fields:

- mmsi — unique vessel identifier
- base_date_time — AIS timestamp
- longitude / latitude — vessel position
- sog — speed over ground (knots)

AIS data is widely used by port authorities, shipping companies, maritime surveillance systems, and logistics monitoring platforms.

---

## Data Engineering Pipeline

The raw AIS CSV data is ingested into Amazon S3 and queried using Athena external tables.

To optimize analytics performance, the dataset is converted to Parquet format using Athena CTAS, enabling:

- columnar storage
- compression
- faster queries
- lower query cost

---

## Partition Strategy

The dataset is partitioned by hour (dt_hour).

Example:

curated_ais_parquet_hour/

dt_hour=2025-01-01 00/  
dt_hour=2025-01-01 01/  
...  
dt_hour=2025-01-01 23/

Partitioning enables Athena partition pruning so only relevant partitions are scanned during queries.

---

## Analytics Layer

An analytics table was created:

analytics_vessel_hourly

Metrics computed per hour:

- number of AIS points
- number of active vessels
- average vessel speed
- speed percentiles
- number of stopped vessels

Example insight:

Approximately 71–79% of AIS messages correspond to vessels with speed < 0.5 knots, consistent with maritime operational patterns where ships spend long periods anchored or in port.

---

## Anomaly Detection

Three anomaly detection strategies were implemented.

### Speed anomalies

Detect vessels reporting unrealistic speeds:

sog > 40 knots

### Vessel-level anomaly summary

Anomalies are aggregated per vessel to avoid counting repeated messages.

### Trajectory jump detection

Using SQL window functions (LAG), the system computes movement between consecutive AIS points:

distance / time

This allows detection of impossible trajectory jumps indicating corrupted AIS data.

---

## Feature Engineering

A feature dataset was created with one row per vessel:

vessel_behavior_features

Features:

- n_points
- avg_sog
- max_sog
- stopped_ratio
- speed_anomaly_points

Dataset statistics:

- 16,286 vessels
- ~450 AIS points per vessel on average
- average stopped ratio ≈ 0.74

---

## Vessel Behavior Clustering

Vessels were grouped into behavioral clusters based on movement patterns.

Cluster results:

| Cluster | Vessels |
|---|---|
anchored_vessels | 9648 |
normal_traffic | 4008 |
slow_movers | 2034 |
other | 575 |
anomalous_vessels | 21 |

Interpretation:

- Anchored vessels (~59%) represent ships in ports or anchorage areas.
- Normal traffic (~25%) corresponds to regular commercial shipping activity.
- Slow movers (~12%) likely include fishing vessels or harbor operations.
- Anomalous vessels (~0.1%) represent corrupted AIS records or unusual vessel behavior.

---

## Key Data Engineering Concepts Demonstrated

- Data lake architecture
- Schema-on-read analytics
- Columnar storage optimization
- Partition pruning
- Serverless data analytics
- Reproducible SQL pipelines

---

## Key Data Science Concepts Demonstrated

- Feature engineering
- Behavioral clustering
- Trajectory anomaly detection
- Maritime traffic analysis

---

## Future Improvements

Possible extensions:

- maritime traffic heatmaps
- vessel trajectory visualization
- AIS streaming pipeline
- vessel trajectory prediction

---