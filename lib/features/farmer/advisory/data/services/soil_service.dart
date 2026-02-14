class SoilService {
  static const List<String> soilTypes = [
    'Alluvial',
    'Black',
    'Red',
    'Laterite',
    'Arid',
    'Saline',
    'Peaty',
    'Sandy',
    'Clay',
    'Loamy',
  ];

  static Map<String, String> getSoilCharacteristics(String type) {
    final t = type.toLowerCase();
    if (t.contains('black'))
      return {'retention': 'High', 'suitable': 'Cotton, Sugarcane'};
    if (t.contains('red'))
      return {'retention': 'Low-Medium', 'suitable': 'Pulses, Oilseeds'};
    if (t.contains('sandy'))
      return {'retention': 'Low', 'suitable': 'Melons, Coconut'};
    if (t.contains('loamy'))
      return {
        'retention': 'Medium',
        'suitable': 'Vegetables, Wheat, Sugarcane',
      };
    // ... add more logic
    return {'retention': 'Medium', 'suitable': 'General crops'};
  }
}
