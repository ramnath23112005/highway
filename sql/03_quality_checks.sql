USE highway_traffic_analysis;

-- Row counts and date coverage
SELECT COUNT(*) AS hourly_rows, MIN(observation_date) AS first_date, MAX(observation_date) AS last_date FROM traffic_hourly;
SELECT COUNT(*) AS station_rows, COUNT(DISTINCT station_key) AS unique_stations FROM stations;

-- Missing values, duplicates, invalid counts and invalid hours
SELECT SUM(station_key IS NULL) AS null_station_key, SUM(observation_date IS NULL) AS null_date,
       SUM(vehicle_count IS NULL) AS null_vehicle_count FROM traffic_hourly;
SELECT station_key, observation_date, hour_of_day, traffic_direction_seq, cardinal_direction_seq, classification_seq, COUNT(*) AS duplicate_rows
FROM traffic_hourly GROUP BY station_key, observation_date, hour_of_day, traffic_direction_seq, cardinal_direction_seq, classification_seq HAVING COUNT(*) > 1;
SELECT COUNT(*) AS negative_counts FROM traffic_hourly WHERE vehicle_count < 0;
SELECT COUNT(*) AS invalid_hours FROM traffic_hourly WHERE hour_of_day NOT BETWEEN 0 AND 23;

-- Validate that a daily total equals the sum of its 24 hourly values.
SELECT station_key, DATE(observation_date) AS observation_day, traffic_direction_seq, cardinal_direction_seq, classification_seq,
       (COALESCE(hour_00,0)+COALESCE(hour_01,0)+COALESCE(hour_02,0)+COALESCE(hour_03,0)+COALESCE(hour_04,0)+COALESCE(hour_05,0)
        +COALESCE(hour_06,0)+COALESCE(hour_07,0)+COALESCE(hour_08,0)+COALESCE(hour_09,0)+COALESCE(hour_10,0)+COALESCE(hour_11,0)
        +COALESCE(hour_12,0)+COALESCE(hour_13,0)+COALESCE(hour_14,0)+COALESCE(hour_15,0)+COALESCE(hour_16,0)+COALESCE(hour_17,0)
        +COALESCE(hour_18,0)+COALESCE(hour_19,0)+COALESCE(hour_20,0)+COALESCE(hour_21,0)+COALESCE(hour_22,0)+COALESCE(hour_23,0)) AS calculated_total,
       daily_total AS source_total
FROM traffic_daily_staging
WHERE daily_total IS NOT NULL
HAVING calculated_total <> daily_total;

-- Document source code meanings from the NSW data dictionary:
-- traffic_direction_seq: 0 counter, 1 prescribed, 2 both
-- classification_seq: 0 unclassified, 1 all vehicles, 2 light vehicles, 3 heavy vehicles, -9 missing
