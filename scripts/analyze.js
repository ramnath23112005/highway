const fs = require('fs');
const path = require('path');
const readline = require('readline');

const root = path.resolve(__dirname, '..');
const raw = path.join(root, 'data', 'raw');
const stationFile = path.join(raw, 'road_traffic_counts_station_reference.csv');
const hourlyFile = path.join(raw, 'road_traffic_counts_hourly_sample_0.csv');
const outputFile = path.join(root, 'report', 'traffic_analysis.json');

function csvLine(line) {
  const fields = []; let field = ''; let quoted = false;
  for (let i = 0; i < line.length; i += 1) {
    const c = line[i];
    if (c === '"') {
      if (quoted && line[i + 1] === '"') { field += '"'; i += 1; }
      else quoted = !quoted;
    } else if (c === ',' && !quoted) { fields.push(field); field = ''; }
    else field += c;
  }
  fields.push(field);
  return fields;
}

async function readCsv(file, onRow) {
  const input = readline.createInterface({ input: fs.createReadStream(file), crlfDelay: Infinity });
  let headers;
  for await (const line of input) {
    if (!headers) { headers = csvLine(line); continue; }
    if (!line.trim()) continue;
    const values = csvLine(line); const row = {};
    headers.forEach((key, i) => { row[key] = values[i] ?? ''; });
    onRow(row);
  }
  return headers;
}

function number(value) { const n = Number(value); return Number.isFinite(n) ? n : null; }
function inc(map, key, value = 1) { map[key] = (map[key] || 0) + value; }
function sortedEntries(map, limit = Infinity) {
  return Object.entries(map).sort((a, b) => b[1] - a[1]).slice(0, limit)
    .map(([key, value]) => ({ key, value }));
}

async function main() {
  const stations = new Map(); let stationRows = 0;
  await readCsv(stationFile, row => {
    stationRows += 1;
    stations.set(row.station_key, {
      stationKey: row.station_key, stationId: row.station_id,
      name: row.name, roadName: row.road_name, lga: row.lga,
      suburb: row.suburb, region: row.rms_region,
      latitude: number(row.wgs84_latitude), longitude: number(row.wgs84_longitude),
      permanent: row.permanent_station === '1', deviceType: row.device_type,
    });
  });

  const dates = []; const years = {}; const directions = {}; const dayTypes = {};
  const hourly = Array.from({ length: 24 }, () => 0); const stationTotals = {};
  const stationDays = {}; let rows = 0; let holidayRows = 0; let schoolHolidayRows = 0;
  let dailyMismatchRows = 0; let dailyMismatchVehicles = 0; let missingHourlyValues = 0;
  await readCsv(hourlyFile, row => {
    rows += 1; dates.push(row.date.slice(0, 10)); inc(years, row.year); inc(directions, row.traffic_direction_seq);
    const holiday = row.public_holiday === 'true'; const school = row.school_holiday === 'true';
    if (holiday) holidayRows += 1; if (school) schoolHolidayRows += 1;
    inc(dayTypes, holiday ? 'public_holiday' : school ? 'school_holiday' : 'regular_day');
    const values = [];
    for (let h = 0; h < 24; h += 1) { const v = number(row[`hour_${String(h).padStart(2, '0')}`]); if (v === null) missingHourlyValues += 1; else { values.push(v); hourly[h] += v; } }
    const total = number(row.daily_total); const sum = values.reduce((a, b) => a + b, 0);
    if (total !== null && sum !== total) { dailyMismatchRows += 1; dailyMismatchVehicles += Math.abs(sum - total); }
    const key = row.station_key; inc(stationTotals, key, total ?? sum); inc(stationDays, key);
  });
  dates.sort();
  const topStations = sortedEntries(stationTotals, 10).map(({ key, value }) => ({
    ...stations.get(key), averageDailyTotal: Math.round(value / stationDays[key] * 100) / 100,
    observations: stationDays[key],
  }));
  const averageHourlyVolume = hourly.map(v => Math.round(v / Math.max(rows, 1) * 100) / 100);
  const peakHour = averageHourlyVolume.indexOf(Math.max(...averageHourlyVolume));
  const report = {
    generatedAt: new Date().toISOString(), source: { stationFile: path.relative(root, stationFile), hourlyFile: path.relative(root, hourlyFile) },
    coverage: { stationRows, hourlyRows: rows, dateFrom: dates[0], dateTo: dates[dates.length - 1], stationCount: Object.keys(stationTotals).length, years },
    quality: { missingHourlyValues, dailyTotalMismatchRows: dailyMismatchRows, absoluteVehicleDifferenceOnMismatchRows: dailyMismatchVehicles },
    flags: { publicHolidayRows: holidayRows, schoolHolidayRows, dayTypes },
    traffic: { directionRows: directions, averageHourlyVolume, peakHour: { hour: peakHour, label: `${String(peakHour).padStart(2, '0')}:00` }, topStations },
    notes: ['daily_total mismatches are counted rather than silently corrected.', 'Traffic direction and classification sequences are source codes; consult the supplied data dictionary before assigning semantic labels.'],
  };
  fs.mkdirSync(path.dirname(outputFile), { recursive: true });
  fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);
  console.log(`Wrote ${path.relative(process.cwd(), outputFile)} (${rows.toLocaleString()} hourly rows, ${stationRows.toLocaleString()} stations)`);
}

main().catch(error => { console.error(error); process.exitCode = 1; });
