import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fertilizer_model.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class FertilizerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'fertilizers';

  // Global List of Common Fertilizers (Fallback & Seeding Data)
  static final List<Fertilizer> _fallbackFertilizers = [
    // Nitrogen Sources
    Fertilizer(
      id: 'urea',
      name: 'Urea',
      n: 46.0,
      p: 0.0,
      k: 0.0,
      type: 'Inorganic',
      form: 'Granular',
      conditions: [
        'Apply in split doses',
        'Avoid in heavy rain (Leaching risk)',
      ],
    ),
    Fertilizer(
      id: 'can',
      name: 'Calcium Ammonium Nitrate (CAN)',
      n: 25.0,
      p: 0.0,
      k: 0.0,
      type: 'Inorganic',
      form: 'Granular',
      conditions: ['Neutral PH effect', 'Good for acidic soils'],
    ),
    Fertilizer(
      id: 'an',
      name: 'Ammonium Nitrate',
      n: 33.0,
      p: 0.0,
      k: 0.0,
      type: 'Inorganic',
      form: 'Granular',
      conditions: ['Highly soluble', 'Explosive if mixed with fuel'],
    ),

    // Phosphorus Sources
    Fertilizer(
      id: 'tsp',
      name: 'Triple Super Phosphate (TSP)',
      n: 0.0,
      p: 46.0,
      k: 0.0,
      type: 'Inorganic',
      form: 'Granular',
      conditions: ['Basal application recommended'],
    ),
    Fertilizer(
      id: 'ssp',
      name: 'Single Super Phosphate (SSP)',
      n: 0.0,
      p: 16.0,
      k: 0.0,
      type: 'Inorganic',
      form: 'Powder/Granular',
      conditions: ['Contains Sulphur and Calcium', 'Good for oilseeds'],
    ),

    // Potassium Sources
    Fertilizer(
      id: 'mop',
      name: 'Muriate of Potash (MOP)',
      n: 0.0,
      p: 0.0,
      k: 60.0,
      type: 'Inorganic',
      form: 'Granular/Powder',
      conditions: [
        'High Chloride content',
        'Avoid for tobacco/potato if quality matters',
      ],
    ),
    Fertilizer(
      id: 'sop',
      name: 'Sulphate of Potash (SOP)',
      n: 0.0,
      p: 0.0,
      k: 50.0,
      type: 'Inorganic',
      form: 'Powder',
      conditions: ['Low salt index', 'Good for sensitive crops'],
    ),

    // NPK Complexes
    Fertilizer(
      id: 'dap',
      name: 'Diammonium Phosphate (DAP)',
      n: 18.0,
      p: 46.0,
      k: 0.0,
      type: 'Inorganic',
      form: 'Granular',
      conditions: ['Basal application', 'Do not mix with lime'],
    ),
    Fertilizer(
      id: 'npk_10_26_26',
      name: 'NPK 10:26:26',
      n: 10.0,
      p: 26.0,
      k: 26.0,
      type: 'Inorganic',
      form: 'Granular',
      conditions: ['Balanced starter for legumes'],
    ),
    Fertilizer(
      id: 'npk_12_32_16',
      name: 'NPK 12:32:16',
      n: 12.0,
      p: 32.0,
      k: 16.0,
      type: 'Inorganic',
      form: 'Granular',
      conditions: ['Good for cereals at sowing'],
    ),
    Fertilizer(
      id: 'npk_19_19_19',
      name: 'NPK 19:19:19 (Water Soluble)',
      n: 19.0,
      p: 19.0,
      k: 19.0,
      type: 'Inorganic',
      form: 'Powder',
      conditions: ['Foliar spray', 'Booster dose'],
    ),
  ];

  // In-memory cache
  List<Fertilizer> _cachedFertilizers = [];

  Future<List<Fertilizer>> getFertilizers() async {
    try {
      // 1. Try to fetch from Firestore
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();

      // 2. If empty, SEED data
      if (snapshot.docs.isEmpty) {
        debugPrint('Fertilizer Collection is empty. Seeding data...');
        await _seedFertilizers();
        _cachedFertilizers = List.from(_fallbackFertilizers);
        return _cachedFertilizers;
      }

      // 3. Parse data
      _cachedFertilizers = snapshot.docs.map((doc) {
        return Fertilizer.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      debugPrint(
        'Fetched ${_cachedFertilizers.length} fertilizers from Firestore',
      );
      return _cachedFertilizers;
    } catch (e) {
      debugPrint('Error fetching fertilizers from Firestore: $e');
      debugPrint('Falling back to local data.');
      // 4. Fallback to local data on error
      if (_cachedFertilizers.isEmpty) {
        _cachedFertilizers = List.from(_fallbackFertilizers);
      }
      return _cachedFertilizers;
    }
  }

  Future<void> _seedFertilizers() async {
    WriteBatch batch = _firestore.batch();
    for (var fertilizer in _fallbackFertilizers) {
      DocumentReference docRef = _firestore
          .collection(_collection)
          .doc(fertilizer.id);
      batch.set(docRef, fertilizer.toMap());
    }
    await batch.commit();
    debugPrint('Seeding complete.');
  }

  Future<Fertilizer?> getFertilizerById(String id) async {
    // Check cache first
    try {
      var cached = _cachedFertilizers.firstWhere((f) => f.id == id);
      return cached;
    } catch (e) {
      // Not in cache, try fetching list (or individual if needed)
      await getFertilizers();
      try {
        return _cachedFertilizers.firstWhere((f) => f.id == id);
      } catch (e) {
        return null;
      }
    }
  }
}
