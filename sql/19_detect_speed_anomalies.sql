SELECT
  dt_hour,
  mmsi,
  timestamp,
  lat,
  lon,
  sog
FROM curated_ais_from_raw_parquet_hour
WHERE sog > 40
ORDER BY sog DESC
LIMIT 200;