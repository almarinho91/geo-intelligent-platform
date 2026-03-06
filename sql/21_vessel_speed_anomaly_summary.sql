SELECT
  mmsi,
  COUNT(*) AS anomaly_points,
  MAX(sog) AS max_speed,
  AVG(sog) AS avg_anomaly_speed
FROM curated_ais_from_raw_parquet_hour
WHERE sog > 40
GROUP BY mmsi
ORDER BY max_speed DESC
LIMIT 50;