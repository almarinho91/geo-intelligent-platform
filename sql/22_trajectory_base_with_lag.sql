WITH ordered_points AS (
  SELECT
    mmsi,
    timestamp,
    lat,
    lon,
    sog,
    dt_hour,
    LAG(timestamp) OVER (PARTITION BY mmsi ORDER BY timestamp) AS prev_timestamp,
    LAG(lat) OVER (PARTITION BY mmsi ORDER BY timestamp) AS prev_lat,
    LAG(lon) OVER (PARTITION BY mmsi ORDER BY timestamp) AS prev_lon
  FROM curated_ais_from_raw_parquet_hour
)
SELECT *
FROM ordered_points
WHERE prev_timestamp IS NOT NULL
LIMIT 50;