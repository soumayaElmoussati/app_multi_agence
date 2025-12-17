class Env {
  // static const String baseUrl = 'https://mealmanagement.xyz';

  static const String baseUrl = 'http://localhost:8000';

  // Vous pouvez ajouter d'autres variables d'environnement ici
  static const String appName = 'Commerce_app';
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}
