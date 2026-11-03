USE highway_traffic_analysis;

-- 1. Overall traffic: filter to ALL VEHICLES (classification 1) to avoid double counting light + heavy.
SELECT COUNT(*) AS observations, SUM(vehicle_count) AS total_vehicles, ROUND(AVG(vehicle_count),2) AS average_hourly_volume
FROM traffic_hourly WHERE classification_seq = 1;

-- 2. Peak traffic hours
SELECT hour_of_day, SUM(vehicle_count) AS total_vehicles, ROUND(AVG(vehicle_count),2) AS average_hourly_volume
FROM traffic_hourly WHERE classification_seq = 1 GROUP BY hour_of_day ORDER BY average_hourly_volume DESC;

-- 3. Day-of-week pattern
SELECT DAYNAME(observation_date) AS day_name, WEEKDAY(observation_date) AS day_number,
       ROUND(AVG(vehicle_count),2) AS average_volume, SUM(vehicle_count) AS total_vehicles
FROM traffic_hourly WHERE classification_seq = 1 GROUP BY day_number, day_name ORDER BY day_number;

-- 4. Monthly trend
SELECT YEAR(observation_date) AS year_number, MONTH(observation_date) AS month_number,
       DATE_FORMAT(observation_date,'%Y-%m') AS month_label, ROUND(AVG(vehicle_count),2) AS average_volume,
       SUM(vehicle_count) AS total_vehicles
FROM traffic_hourly WHERE classification_seq = 1 GROUP BY year_number, month_number, month_label ORDER BY year_number, month_number;

-- 5. Vehicle classification distribution (available in the source as classification codes)
SELECT CASE classification_seq WHEN 0 THEN 'Unclassified' WHEN 1 THEN 'All vehicles' WHEN 2 THEN 'Light vehicles'
       WHEN 3 THEN 'Heavy vehicles' WHEN -9 THEN 'Missing classification' ELSE 'Other' END AS vehicle_class,
       SUM(vehicle_count) AS total_vehicles, ROUND(AVG(vehicle_count),2) AS average_volume
FROM traffic_hourly GROUP BY classification_seq ORDER BY total_vehicles DESC;

-- 6. Highest-traffic locations; station metadata joined by station_key
SELECT s.station_key, s.name, s.road_name, s.lga, ROUND(AVG(h.vehicle_count),2) AS average_volume,
       SUM(h.vehicle_count) AS total_vehicles
FROM traffic_hourly h JOIN stations s ON s.station_key = h.station_key
WHERE h.classification_seq = 1 GROUP BY s.station_key, s.name, s.road_name, s.lga
ORDER BY average_volume DESC LIMIT 20;

-- 7. Weekday versus weekend
SELECT CASE WHEN WEEKDAY(observation_date) < 5 THEN 'Weekday' ELSE 'Weekend' END AS day_type,
       COUNT(*) AS observations, ROUND(AVG(vehicle_count),2) AS average_volume, SUM(vehicle_count) AS total_vehicles
FROM traffic_hourly WHERE classification_seq = 1 GROUP BY day_type;

-- 8. Traffic classification using data-driven quartiles rather than invented thresholds
WITH station_hour AS (
 SELECT station_key, hour_of_day, AVG(vehicle_count) AS avg_volume
 FROM traffic_hourly WHERE classification_seq = 1 GROUP BY station_key, hour_of_day
), cutoffs AS (
 SELECT MIN(avg_volume) AS min_volume, MAX(avg_volume) AS max_volume,
        AVG(avg_volume) AS mean_volume FROM station_hour
)
SELECT station_key, hour_of_day, ROUND(avg_volume,2) AS average_volume,
       CASE WHEN avg_volume < mean_volume * 0.75 THEN 'Low'
            WHEN avg_volume <= mean_volume * 1.25 THEN 'Moderate' ELSE 'High' END AS traffic_level
FROM station_hour CROSS JOIN cutoffs ORDER BY avg_volume DESC;

-- 9. Rank locations using a window function
WITH location_avg AS (
 SELECT s.station_key, s.name, s.road_name, AVG(h.vehicle_count) AS average_volume
 FROM traffic_hourly h JOIN stations s ON s.station_key = h.station_key
 WHERE h.classification_seq = 1 GROUP BY s.station_key, s.name, s.road_name
)
SELECT DENSE_RANK() OVER (ORDER BY average_volume DESC) AS location_rank,
       station_key, name, road_name, ROUND(average_volume,2) AS average_volume
FROM location_avg ORDER BY location_rank;

-- 10. Unusual observations using each station/hour's mean and standard deviation
WITH baseline AS (
 SELECT station_key, hour_of_day, AVG(vehicle_count) AS mean_volume, STDDEV_POP(vehicle_count) AS sd_volume
 FROM traffic_hourly WHERE classification_seq = 1 GROUP BY station_key, hour_of_day
)
SELECT h.station_key, h.observation_date, h.hour_of_day, h.vehicle_count,
       ROUND(b.mean_volume,2) AS normal_volume, ROUND(b.sd_volume,2) AS standard_deviation,
       CASE WHEN h.vehicle_count > b.mean_volume + 2*b.sd_volume THEN 'Unusually high'
            WHEN h.vehicle_count < b.mean_volume - 2*b.sd_volume THEN 'Unusually low' END AS anomaly_type
FROM traffic_hourly h JOIN baseline b USING (station_key, hour_of_day)
WHERE h.classification_seq = 1
  AND (h.vehicle_count > b.mean_volume + 2*b.sd_volume OR h.vehicle_count < b.mean_volume - 2*b.sd_volume)
ORDER BY ABS(h.vehicle_count - b.mean_volume) DESC;
