import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:pepperdisesesidentification/constant.dart';

class MongoDatabase {
  static Db? db;
  static DbCollection? waterCollection; // Water collection only

  static Future<void> connect() async {
    try {
      db = await Db.create(MONGO_URL);
      await db!.open();
      inspect(db);
      waterCollection =
          db!.collection(GASES_COLLECTION_NAME); // Initialize water collection
    } catch (e) {
      print("MongoDB connection error: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> fetchWaterData() async {
    try {
      return await waterCollection!.find().toList(); // Fetch water data
    } catch (e) {
      print("MongoDB fetch error: $e");
      return [];
    }
  }
}
