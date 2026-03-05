CREATE TABLE curated_ais_from_raw_parquet
WITH (
  format = 'PARQUET',
  external_location = 's3://andre-geo-platform-dev/curated_ais_parquet/',
  partitioned_by = ARRAY['dt']
) AS
SELECT
  mmsi,
  base_date_time AS timestamp,
  longitude AS lon,
  latitude AS lat,
  sog,
  substr(base_date_time, 1, 10) AS dt
FROM raw_ais
WHERE mmsi IS NOT NULL
  AND base_date_time IS NOT NULL
  AND longitude IS NOT NULL
  AND latitude IS NOT NULL;