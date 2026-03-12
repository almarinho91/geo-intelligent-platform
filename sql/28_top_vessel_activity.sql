SELECT
  mmsi,
  n_points,
  avg_sog,
  max_sog,
  stopped_ratio,
  speed_anomaly_points
FROM vessel_behavior_features
ORDER BY n_points DESC
LIMIT 20;