-- Create partitioned Parquet table with dynamic dt assignment

CREATE TABLE curated_ais_partitioned_v2
WITH (
  format = 'PARQUET',
  external_location = 's3://andre-geo-platform-dev/curated_partitioned_v2/',
  partitioned_by = ARRAY['dt']
) AS
SELECT *,
       CASE 
           WHEN mmsi = 123456789 THEN '2024-01-01'
           WHEN mmsi = 987654321 THEN '2024-01-02'
           ELSE '2024-01-03'
       END AS dt
FROM curated_ais_parquet;