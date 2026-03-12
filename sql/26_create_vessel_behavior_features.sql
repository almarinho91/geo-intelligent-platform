CREATE TABLE vessel_behavior_features AS
WITH base AS (
  SELECT
    mmsi,
    COUNT(*) AS n_points,
    AVG(sog) AS avg_sog,
    MAX(sog) AS max_sog,
    SUM(CASE WHEN sog < 0.5 THEN 1 ELSE 0 END) AS stopped_points
  FROM curated_ais_from_raw_parquet_hour
  GROUP BY mmsi
),
anomalies AS (
  SELECT
    mmsi,
    COUNT(*) AS speed_anomaly_points
  FROM curated_ais_from_raw_parquet_hour
  WHERE sog > 40
  GROUP BY mmsi
)
SELECT
  b.mmsi,
  b.n_points,
  b.avg_sog,
  b.max_sog,
  b.stopped_points,
  CAST(b.stopped_points AS DOUBLE) / NULLIF(b.n_points, 0) AS stopped_ratio,
  COALESCE(a.speed_anomaly_points, 0) AS speed_anomaly_points
FROM base b
LEFT JOIN anomalies a
  ON b.mmsi = a.mmsi;