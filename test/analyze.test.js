const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

test('project has the supplied source files', () => {
  const root = path.resolve(__dirname, '..');
  assert.ok(fs.existsSync(path.join(root, 'data/raw/road_traffic_counts_station_reference.csv')));
  assert.ok(fs.existsSync(path.join(root, 'data/raw/road_traffic_counts_hourly_sample_0.csv')));
  assert.ok(fs.existsSync(path.join(root, 'docs/nsw_traffic_counts_data_dictionary.pdf')));
});

test('analysis report is valid after running npm run analyze', () => {
  const reportPath = path.resolve(__dirname, '..', 'report', 'traffic_analysis.json');
  assert.ok(fs.existsSync(reportPath), 'run npm run analyze before npm test');
  const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
  assert.ok(report.coverage.hourlyRows > 0);
  assert.equal(report.traffic.averageHourlyVolume.length, 24);
  assert.ok(report.traffic.peakHour.hour >= 0 && report.traffic.peakHour.hour < 24);
});
