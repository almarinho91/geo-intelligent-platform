# System Architecture — AIS Maritime Data Platform

This document describes the technical architecture of the AIS Maritime Data Platform.
The system processes maritime AIS (Automatic Identification System) data using a hybrid
Data Engineering + Data Science workflow built on AWS.

---

# 1. High-Level Architecture

The platform processes vessel trajectory data from raw ingestion to behavioral insights.

AIS CSV Dataset -> Amazon S3 Data Lake -> Athena External Tables (schema-on-read) -> CTAS Transformation (CSV → Parquet) -> Partitioned Dataset (dt_hour) -> Analytics Layer (vessel traffic metrics) -> Feature Engineering (vessel_behavior_features) -> Anomaly Detection -> 
Vessel Behavior Clustering

---

# 2. Data Layers

The pipeline follows a layered data lake architecture.

## Raw Layer

Contains original AIS CSV data exactly as received.

Example location:

s3://andre-geo-platform-dev/raw_ais/

Characteristics:

- schema-on-read
- immutable raw data
- used for reproducibility

---

## Curated Layer

Raw AIS data is transformed into optimized Parquet datasets.

Transformation performed with Athena CTAS.

Example dataset:

curated_ais_from_raw_parquet_hour

Characteristics:

- Parquet columnar format
- reduced query cost
- improved scan performance

---

## Partition Strategy

The dataset is partitioned by hour.

Example partition:

dt_hour = 2025-01-01 10

S3 structure:

curated_ais_parquet_hour/

dt_hour=2025-01-01 00/
dt_hour=2025-01-01 01/
...
dt_hour=2025-01-01 23/

Benefits:

- partition pruning
- faster Athena queries
- lower cost

---

# 3. Analytics Layer

An aggregated analytics table was created:

analytics_vessel_hourly

Metrics computed:

- number of AIS messages
- number of active vessels
- average speed
- speed percentiles
- stopped vessel ratio

Example insight:

Approximately 70–80% of AIS messages correspond to vessels with speed below 0.5 knots.

---

# 4. Feature Engineering

A vessel-level feature table was created:

vessel_behavior_features

One row per vessel.

Features:

- n_points
- avg_sog
- max_sog
- stopped_ratio
- speed_anomaly_points

Dataset statistics:

- ~16k vessels
- ~450 AIS messages per vessel
- average stopped ratio ≈ 0.74

---

# 5. Anomaly Detection

Two anomaly detection strategies were implemented.

## Speed Anomalies

Detection rule:

sog > 40 knots

This flags unrealistic vessel speeds.

---

## Trajectory Jump Detection

AIS trajectories were analyzed using SQL window functions.

Example:

LAG(timestamp) OVER (PARTITION BY mmsi ORDER BY timestamp)

Steps:

1. retrieve previous AIS point
2. compute time difference
3. estimate movement distance
4. flag unrealistic jumps

Example anomaly:

A vessel appearing hundreds of kilometers away within one second.

---

# 6. Vessel Behavior Clustering

Vessels were grouped into behavior categories based on movement features.

Clusters:

| Cluster | Meaning |
|-------|-------|
anchored_vessels | vessels mostly stopped |
normal_traffic | typical commercial vessel speeds |
slow_movers | slow vessel activity |
other | mixed behavior |
anomalous_vessels | vessels with extreme anomalies |

Cluster distribution example:

- anchored_vessels ≈ 59%
- normal_traffic ≈ 25%
- slow_movers ≈ 12%
- anomalous_vessels < 1%

---

# 7. Key Design Decisions

## Parquet format

Chosen for:

- columnar storage
- efficient compression
- faster analytics

---

## Athena for analytics

Advantages:

- serverless architecture
- no cluster management
- direct queries on S3

---

## Hourly partitioning

Chosen because:

- dataset initially contains one day
- high temporal resolution
- efficient partition pruning

---

## Rule-based clustering

Chosen because:

- interpretable results
- suitable for exploratory analysis
- avoids unnecessary ML complexity

---

# 8. Future Improvements

Possible extensions:

- vessel trajectory visualization
- maritime traffic heatmaps
- streaming AIS ingestion pipeline
- vessel trajectory prediction models

---