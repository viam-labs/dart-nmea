import 'dart:typed_data';

import 'package:dart_nmea/dart_nmea.dart';
import 'package:test/test.dart';
import 'dart:convert';

void main() {
  test('processData with valid data', () {
    final rawString =
        "!PDGY,130567,6,200,255,25631.18,RgPczwYAQnYeAB4AAAADAAAAAABQbiMA";

    final Uint8List byteArr = Uint8List.fromList(utf8.encode(rawString));

    final result = processData(byteArr);

    expect(result.entries.isNotEmpty, true);
  });

  test('processData with valid data returns correct expected output', () {
    final rawString =
        "!PDGY,130567,6,200,255,25631.18,RgPczwYAQnYeAB4AAAADAAAAAABQbiMA";

    final expectedResult = json.decode('''
{
  "timestamp": "25631.18",
  "prio": 6,
  "src": 200,
  "dst": 255,
  "pgn": 130567,
  "description": "Watermaker Input Setting and Status",
  "fields": {
    "Brine Water Flow": 0,
    "Emergency Stop": "No",
    "Feed Pressure": 0,
    "High Pressure Pump Status": "No",
    "Low Pressure Pump Status": "No",
    "Post-filter Pressure": 0.03,
    "Pre-filter Pressure": 0.03,
    "Product Solenoid Valve Status": "OK",
    "Product Water Flow": 0,
    "Product Water Temperature": 29.59000000000003,
    "Production Start/Stop": "Yes",
    "Run Time": 2322000000000000,
    "Salinity": 6,
    "Salinity Status": "Warning",
    "System High Pressure": 0.03,
    "System Status": "OK",
    "Watermaker Operating State": "Initiating"
  }
}
''');

    final Uint8List byteArr = Uint8List.fromList(utf8.encode(rawString));

    final result = processData(byteArr);

    expect(result, expectedResult);
  });

  test('getReadings with invalid data', () {
    final rawString = "!AAABQbiMA";

    final Uint8List byteArr = Uint8List.fromList(utf8.encode(rawString));

    final result = processData(byteArr);

    expect(result.entries.isEmpty, true);
  });
}
