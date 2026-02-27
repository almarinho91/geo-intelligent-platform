-- Create Parquet version of curated AIS table
CREATE TABLE curated_ais_parquet
WITH (
  format = 'PARQUET',
  external_location = 's3://andre-geo-platform-dev/curated_parquet/'
) AS
SELECT *
FROM curated_ais;