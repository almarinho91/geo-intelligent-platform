SELECT SUM(sog) FROM curated_ais_from_raw_parquet_hour;

SELECT SUM(sog)
FROM curated_ais_from_raw_parquet_hour
WHERE dt_hour = '2025-01-01 10';