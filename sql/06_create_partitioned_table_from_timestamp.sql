-- Create partitioned Parquet table using date derived from timestamp

CREATE TABLE curated_ais_partitioned_real
WITH (
  format = 'PARQUET',
  external_location = 's3://andre-geo-platform-dev/curated_partitioned_real/',
  partitioned_by = ARRAY['dt']
) AS
SELECT
  mmsi,
  timestamp,
  lat,
  lon,
  sog,
  speed_category,
  substr(timestamp, 1, 10) AS dt
FROM curated_ais_parquet;