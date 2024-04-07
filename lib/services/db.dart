import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

late Database _db;

Future<Database> initDatabase() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, "device_db.db");
  _db = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    await db.execute("CREATE TABLE Device (id INTEGER PRIMARY KEY, deviceId TEXT)");
  });
  return _db;
}

Future<String> fetchDeviceId(Database db) async {
  List<Map<String, dynamic>> result =
      await db.query('Device');
  String deviceId;
  if (result.isNotEmpty) {
    deviceId = result.first['deviceId'];
  } else {
    deviceId = Uuid().v4();
    await db.insert('Device', {'deviceId': deviceId});
  }
  return deviceId;
}
