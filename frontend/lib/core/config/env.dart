class Env {
  static late String apiBaseUrl;
  static late bool isProduction;

  // Call this in main.dart before runApp()
  static Future<void> load() async {
    // You can later load these from .env or remote config
    // isProduction = kReleaseMode;

    // apiBaseUrl = isProduction
    //     ? "https://api.classqr.com"         // <-- PROD URL
    //     : "http://localhost:3000";          // <-- DEV URL

    apiBaseUrl = "http://localhost:5000";

    // Add other config values here:
    // googleAuthClientId
    // websocketUrl
  }
}
