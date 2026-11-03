CREATE DATABASE IF NOT EXISTS highway_traffic_analysis;
USE highway_traffic_analysis;

DROP TABLE IF EXISTS traffic_hourly;
DROP TABLE IF EXISTS traffic_daily_staging;
DROP TABLE IF EXISTS stations;

CREATE TABLE stations (
    station_key INT PRIMARY KEY,
    station_id VARCHAR(50), name VARCHAR(150), road_name VARCHAR(150), full_name VARCHAR(255),
    suburb VARCHAR(100), lga VARCHAR(100), rms_region VARCHAR(100), post_code VARCHAR(20),
    device_type VARCHAR(150), lane_count VARCHAR(50), road_functional_hierarchy VARCHAR(100),
    road_classification_admin VARCHAR(100), permanent_station BOOLEAN, vehicle_classifier BOOLEAN,
    latitude DECIMAL(10,7), longitude DECIMAL(10,7), quality_rating TINYINT, updated_on DATETIME NULL
);

CREATE TABLE traffic_daily_staging (
    station_key INT, traffic_direction_seq TINYINT, cardinal_direction_seq TINYINT,
    classification_seq SMALLINT, observation_date DATETIME, source_year SMALLINT,
    source_month TINYINT, day_of_week TINYINT, public_holiday BOOLEAN, school_holiday BOOLEAN,
    daily_total INT, hour_00 INT, hour_01 INT, hour_02 INT, hour_03 INT, hour_04 INT,
    hour_05 INT, hour_06 INT, hour_07 INT, hour_08 INT, hour_09 INT, hour_10 INT,
    hour_11 INT, hour_12 INT, hour_13 INT, hour_14 INT, hour_15 INT, hour_16 INT,
    hour_17 INT, hour_18 INT, hour_19 INT, hour_20 INT, hour_21 INT, hour_22 INT, hour_23 INT,
    source_record_id VARCHAR(50), source_md5 CHAR(32)
);

CREATE TABLE traffic_hourly (
    hourly_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_key INT NOT NULL, observation_date DATE NOT NULL, hour_of_day TINYINT NOT NULL,
    traffic_direction_seq TINYINT, cardinal_direction_seq TINYINT, classification_seq SMALLINT,
    vehicle_count INT, public_holiday BOOLEAN, school_holiday BOOLEAN,
    CONSTRAINT fk_hourly_station FOREIGN KEY (station_key) REFERENCES stations(station_key),
    CONSTRAINT uq_hourly_observation UNIQUE
      (station_key, observation_date, hour_of_day, traffic_direction_seq, cardinal_direction_seq, classification_seq),
    CONSTRAINT chk_hour CHECK (hour_of_day BETWEEN 0 AND 23),
    CONSTRAINT chk_vehicle_count CHECK (vehicle_count IS NULL OR vehicle_count >= 0)
);

CREATE INDEX idx_hourly_date ON traffic_hourly(observation_date);
CREATE INDEX idx_hourly_station_date ON traffic_hourly(station_key, observation_date);
CREATE INDEX idx_hourly_classification ON traffic_hourly(classification_seq);
