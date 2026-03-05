SELECT
  dt_hour,
  n_vessels,
  n_points,
  n_stopped_points,
  CAST(n_stopped_points AS DOUBLE) / NULLIF(n_points, 0) AS stopped_ratio
FROM analytics_vessel_hourly
ORDER BY dt_hour;