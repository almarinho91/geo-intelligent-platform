WITH vessel_hour AS (
  SELECT
    dt_hour,
    mmsi,
    COUNT(*) AS n_points
  FROM curated_ais_from_raw_parquet_hour
  GROUP BY dt_hour, mmsi
),
ranked AS (
  SELECT
    dt_hour,
    mmsi,
    n_points,
    row_number() OVER (PARTITION BY dt_hour ORDER BY n_points DESC) AS rnk
  FROM vessel_hour
)
SELECT dt_hour, mmsi, n_points
FROM ranked
WHERE rnk <= 10
ORDER BY dt_hour, n_points DESC;