SELECT
  dt_hour,
  COUNT(*) AS n_speed_anomalies
FROM curated_ais_from_raw_parquet_hour
WHERE sog > 40
GROUP BY dt_hour
ORDER BY dt_hour;