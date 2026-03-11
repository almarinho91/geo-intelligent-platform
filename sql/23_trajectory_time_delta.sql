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
),

time_diff AS (
  SELECT
    mmsi,
    timestamp,
    prev_timestamp,
    lat,
    lon,
    prev_lat,
    prev_lon,
    sog,
    date_diff(
      'second',
      CAST(prev_timestamp AS timestamp),
      CAST(timestamp AS timestamp)
    ) AS delta_seconds
  FROM ordered_points
  WHERE prev_timestamp IS NOT NULL
)

SELECT *
FROM time_diff
LIMIT 50;