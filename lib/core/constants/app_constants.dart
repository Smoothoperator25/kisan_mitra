class AppConstants {
  // App Info
  static const String appName = 'Kisan Mitra';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String storesCollection = 'stores';
  static const String adminsCollection = 'admins';
  static const String fertilizersCollection = 'fertilizers';
  static const String storeFertilizersCollection = 'store_fertilizers';

  // User Roles
  static const String roleFarmer = 'farmer';
  static const String roleStore = 'store';
  static const String roleAdmin = 'admin';

  // Routes
  static const String splashRoute = '/';
  static const String roleSelectionRoute = '/role-selection';
  static const String loginRoute = '/login';
  static const String farmerLoginRoute = '/farmer-login';
  static const String farmerSignupRoute = '/farmer-signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String storeLoginRoute = '/store-login';
  static const String storeRegistrationRoute = '/store-registration';
  static const String adminLoginRoute = '/admin-login';
  static const String farmerHomeRoute = '/farmer-home';
  static const String storeHomeRoute = '/store-home';
  static const String adminDashboardRoute = '/admin-dashboard';

  // Map Configuration (Mapbox)
  static const String mapboxAccessToken =
      'pk.eyJ1IjoiY29kZWJ5c2F0eWFqaXQiLCJhIjoiY21sa3NnbjllMDAwMjNjcXhzNXA2amEzZSJ9.g5WX1ReVtrtZFShKGxBcBA';
  static const double nearbyRadiusKm = 5.0;
  static const double defaultLatitude = 0.0;
  static const double defaultLongitude = 0.0;
}
