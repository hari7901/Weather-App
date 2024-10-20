import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class StorageService {
  final CollectionReference _dailySummariesCollection =
  FirebaseFirestore.instance.collection('daily_summaries');
  final CollectionReference _alertsCollection =
  FirebaseFirestore.instance.collection('alerts');

  Future<void> saveDailySummary(DailySummary summary) async {
    try {
      await _dailySummariesCollection.doc(summary.date).set(summary.toMap());
      print("Saved summary for ${summary.city} on ${summary.date}");
    } catch (e) {
      print('Error saving daily summary: $e');
    }
  }


  Future<List<DailySummary>> getAllDailySummaries() async {
    try {
      QuerySnapshot snapshot = await _dailySummariesCollection.orderBy('date').get();
      return snapshot.docs
          .map((doc) => DailySummary.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching daily summaries: $e');
      return [];
    }
  }

  Future<void> saveAlert(Alert alert) async {
    try {
      await _alertsCollection.add(alert.toMap());
    } catch (e) {
      print('Error saving alert: $e');
    }
  }

  Future<List<Alert>> getAllAlerts() async {
    try {
      QuerySnapshot snapshot = await _alertsCollection.orderBy('alertTime', descending: true).get();
      return snapshot.docs
          .map((doc) => Alert.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }
}