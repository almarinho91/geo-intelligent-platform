CREATE TABLE curated_ais_from_raw_parquet_hour
WITH (
  format = 'PARQUET',
  external_location = 's3://andre-geo-platform-dev/curated_ais_parquet_hour/',
  partitioned_by = ARRAY['dt_hour']
) AS
SELECT
  mmsi,
  base_date_time AS timestamp,
  longitude AS lon,
  latitude AS lat,
  sog,
  substr(base_date_time, 1, 13) AS dt_hour
FROM raw_ais
WHERE mmsi IS NOT NULL
  AND base_date_time IS NOT NULL
  AND longitude IS NOT NULL
  AND latitude IS NOT NULL;