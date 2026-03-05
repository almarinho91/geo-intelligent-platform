SELECT mmsi, COUNT(*) AS n_points
FROM curated_ais_from_raw_parquet_hour
GROUP BY mmsi
ORDER BY n_points DESC
LIMIT 50;