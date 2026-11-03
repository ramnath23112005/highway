USE highway_traffic_analysis;

-- Enable LOCAL INFILE in MySQL Workbench if required.
-- Replace C:/ABSOLUTE/PATH with the real path on your computer.
LOAD DATA LOCAL INFILE 'C:/ABSOLUTE/PATH/data/raw/road_traffic_counts_station_reference.csv'
INTO TABLE stations
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 ROWS
(@geom,@cartodb,@webmerc,@record,station_key,station_id,name,road_name,full_name,@common,@secondary,@base,@type,@intersection,@distance,@road_number,@link,@mab_type,@mab_number,@mab_id,road_functional_hierarchy,@road_on_type,lane_count,road_classification_type,road_classification_admin,rms_region,lga,suburb,post_code,device_type,@heavy,permanent_station,vehicle_classifier,@east,@north,latitude,longitude,@direction,@quality,@publish,@md5,@updated)
SET quality_rating = NULLIF(@quality,''), updated_on = STR_TO_DATE(SUBSTRING_INDEX(@updated,'+',1),'%Y-%m-%d %H:%i:%s');

LOAD DATA LOCAL INFILE 'C:/ABSOLUTE/PATH/data/raw/road_traffic_counts_hourly_sample_0.csv'
INTO TABLE traffic_daily_staging
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 ROWS
(@geom,@cartodb,@webmerc,@record,station_key,traffic_direction_seq,cardinal_direction_seq,classification_seq,@date,source_year,source_month,day_of_week,public_holiday,school_holiday,daily_total,hour_00,hour_01,hour_02,hour_03,hour_04,hour_05,hour_06,hour_07,hour_08,hour_09,hour_10,hour_11,hour_12,hour_13,hour_14,hour_15,hour_16,hour_17,hour_18,hour_19,hour_20,hour_21,hour_22,hour_23,@md5,@updated)
SET observation_date = STR_TO_DATE(SUBSTRING_INDEX(@date,'+',1),'%Y-%m-%d %H:%i:%s'), source_record_id = @record, source_md5 = @md5;

INSERT IGNORE INTO traffic_hourly
(station_key, observation_date, hour_of_day, traffic_direction_seq, cardinal_direction_seq, classification_seq, vehicle_count, public_holiday, school_holiday)
SELECT station_key, DATE(observation_date), 0, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_00, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date), 1, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_01, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date), 2, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_02, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date), 3, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_03, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date), 4, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_04, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date), 5, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_05, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date), 6, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_06, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date), 7, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_07, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date), 8, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_08, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date), 9, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_09, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),10, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_10, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),11, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_11, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),12, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_12, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),13, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_13, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),14, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_14, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),15, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_15, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),16, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_16, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),17, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_17, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),18, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_18, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),19, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_19, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),20, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_20, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),21, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_21, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),22, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_22, public_holiday, school_holiday FROM traffic_daily_staging
UNION ALL SELECT station_key, DATE(observation_date),23, traffic_direction_seq, cardinal_direction_seq, classification_seq, hour_23, public_holiday, school_holiday FROM traffic_daily_staging;
