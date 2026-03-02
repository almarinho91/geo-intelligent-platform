-- Create partitioned Parquet table

CREATE TABLE curated_ais_partitioned
WITH (
  format = 'PARQUET',
  external_location = 's3://andre-geo-platform-dev/curated_partitioned/',
  partitioned_by = ARRAY['dt']
) AS
SELECT *,
       '2024-01-01' AS dt
FROM curated_ais_parquet;