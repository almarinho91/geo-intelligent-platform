CREATE TABLE analytics_vessel_hourly
WITH (
  format = 'PARQUET',
  external_location = 's3://andre-geo-platform-dev/analytics_vessel_hourly/',
  partitioned_by = ARRAY['dt_hour']
) AS
SELECT
  COUNT(*)                          AS n_points,
  COUNT(DISTINCT mmsi)              AS n_vessels,
  AVG(sog)                          AS avg_sog,
  approx_percentile(sog, 0.50)      AS p50_sog,
  approx_percentile(sog, 0.90)      AS p90_sog,
  SUM(CASE WHEN sog < 0.5 THEN 1 ELSE 0 END) AS n_stopped_points,
  dt_hour
FROM curated_ais_from_raw_parquet_hour
GROUP BY dt_hour;