# Highway Traffic Pattern and Congestion Analysis Using SQL

## Project overview

This project analyses historical road-traffic observations using MySQL 8.0. It demonstrates data cleaning, relational modelling, joins, aggregation, date functions, CTEs, `CASE WHEN`, subqueries, and window functions.

The supplied data is from the Transport for NSW Roads Traffic Volume Counts API. The hourly sample contains daily records with 24 hourly vehicle-count columns. The station reference table provides road, location, coordinates, device, and station-quality fields.

Source: [NSW Roads Traffic Volume Counts API](https://data.nsw.gov.au/data/dataset/2-nsw-roads-traffic-volume-counts-api). The hourly sample resource is [available as CSV](https://opendata.transport.nsw.gov.au/data/dataset/ef2b0bd2-db1e-48f3-9ea1-2bb9e6bc6504/resource/b8bd742f-af37-4999-887f-6d3657349d13/download/road_traffic_counts_hourly_sample_0.csv). The source is published by Transport for NSW under CC BY 4.0.

## Business problem

Highway authorities need to understand when and where traffic demand is highest, how demand varies by day and month, and whether unusual observations require investigation. This project converts raw traffic-count files into an auditable SQL analysis that can support traffic-management and infrastructure-planning discussions.

## Scope and limitations

- The project analyses traffic counts, station locations, direction codes, classification codes, holidays, and hourly patterns.
- `classification_seq` supports the source categories Unclassified, All vehicles, Light vehicles, Heavy vehicles, and Missing classification. It is not an individual make/model vehicle type.
- The hourly sample is a collection of station-date-direction-classification observations, not a speed, travel-time, capacity, or congestion-delay dataset.
- “Low”, “Moderate”, and “High” are analytical labels. They are not official congestion levels and should be calibrated against road capacity if capacity data becomes available.
- Results must be interpreted with the source quality and availability fields; stations do not necessarily have identical coverage.

## Folder structure

```text
data/raw/        Original CSV files; do not edit
docs/             Supplied data dictionary
sql/              Schema, import, quality checks, and analysis queries
scripts/          Dependency-free validation/report script
report/           Generated JSON report and future screenshots
```

## How to run the SQL project

1. Install MySQL 8.0 and open MySQL Workbench.
2. Run `sql/01_schema.sql`.
3. In `sql/02_import_and_transform.sql`, replace `C:/ABSOLUTE/PATH` with the absolute project path. For example, use forward slashes in a MySQL path.
4. Enable `LOAD DATA LOCAL INFILE` in Workbench if MySQL rejects local file loading, then run the import script.
5. Run `sql/03_quality_checks.sql` and record the outputs.
6. Run `sql/04_analysis_queries.sql` and save screenshots of the result grids.

The import script keeps a wide staging table because that matches the source file, then transforms the 24 hourly columns into the normalized `traffic_hourly` table. This makes hour-based analysis straightforward.

## Tables and relationship

`stations` stores one row per station. `traffic_hourly` stores one row per station, date, hour, direction, and classification. The relationship is:

```text
stations (1) ────────< traffic_hourly (many)
 station_key                 station_key
```

`traffic_daily_staging` is an import/audit table and preserves the source's daily wide format.

## Analysis questions

The SQL answers overall traffic, peak hours, weekday patterns, monthly trends, source vehicle classifications, high-traffic locations, weekday versus weekend traffic, analytical traffic levels, station ranking, and unusual observations. Query comments explain the SQL concepts and the interpretation of each output.

Do not write numerical findings in this README until the queries have been executed. Add only verified results under a future `## Key findings` section, with the query date and filters used.

## Quality checks

The project checks nulls, duplicate keys, invalid hours, negative vehicle counts, date coverage, station coverage, and whether the sum of 24 hourly values agrees with the source daily total. Rows with quality issues should be investigated and documented rather than silently deleted.

## Resume description

**Highway Traffic Pattern and Congestion Analysis Using SQL** — Built a MySQL 8.0 data-analysis project using Transport for NSW traffic-count data; designed a relational schema for stations and hourly observations, validated source quality, and analysed traffic by hour, weekday, month, classification, location, and anomalous volume using joins, CTEs, conditional logic, aggregate functions, and window functions.

Resume bullets:

- Designed normalized MySQL tables for station metadata, source staging records, and hourly traffic observations.
- Transformed 24 hourly CSV fields into an analysis-ready relational table and created quality checks for duplicates, nulls, invalid counts, and daily-total mismatches.
- Used CTEs, date functions, `CASE WHEN`, aggregations, and window functions to identify peak periods, high-volume stations, traffic classes, and unusual observations.
- Documented source limitations and avoided treating analytical traffic bands as official congestion measurements.

## Interview preparation

1. **Why use `GROUP BY` for peak hours?** It groups observations by hour so `AVG` or `SUM` can compare hourly demand.
2. **Why use `HAVING` instead of `WHERE` for aggregate filters?** `WHERE` filters rows before grouping; `HAVING` filters groups after aggregation.
3. **Why join stations to traffic observations?** The traffic table has the station key; the join adds road and location attributes.
4. **What does a CTE do?** It names a temporary result set, making multi-step logic easier to read and reuse.
5. **When is a subquery useful?** It can calculate a benchmark such as an overall average before filtering observations above that benchmark.
6. **How does `CASE WHEN` classify traffic?** It evaluates conditions and returns labels such as Low, Moderate, or High.
7. **How can MySQL extract the weekday?** `WEEKDAY(observation_date)` returns 0 for Monday through 6 for Sunday.
8. **Why use `DENSE_RANK()`?** It ranks stations by average traffic while giving tied stations the same rank.
9. **Why avoid summing all classifications together?** Light, heavy, all-vehicle, and unclassified rows may overlap; choose a documented classification filter.
10. **How is an unusual observation identified?** Compare a count with its station/hour baseline and flag values more than two standard deviations from the mean; this is an analytical screen, not proof of an incident.

## Existing validation script

The optional Node.js script is independent of the MySQL workflow and produces `report/traffic_analysis.json`:

```text
npm run analyze
npm test
```
"# ddd" 
