SELECT
  COUNT(*) AS n_vessels,
  AVG(n_points) AS avg_points,
  MIN(n_points) AS min_points,
  MAX(n_points) AS max_points,
  AVG(avg_sog) AS avg_speed,
  MAX(max_sog) AS max_observed_speed,
  AVG(stopped_ratio) AS avg_stopped_ratio,
  MAX(speed_anomaly_points) AS max_anomaly_points
FROM vessel_behavior_features;