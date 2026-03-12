SELECT
  mmsi,
  n_points,
  avg_sog,
  max_sog,
  stopped_ratio,
  speed_anomaly_points,

  CASE
    WHEN stopped_ratio > 0.9 THEN 'anchored_vessels'
    WHEN avg_sog < 2 THEN 'slow_movers'
    WHEN avg_sog BETWEEN 2 AND 12 THEN 'normal_traffic'
    WHEN speed_anomaly_points > 0 THEN 'anomalous_vessels'
    ELSE 'other'
  END AS vessel_behavior_cluster

FROM vessel_behavior_features;