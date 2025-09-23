class NetworkStorage {
  /// Base URL for Laravel storage
  static const String baseUrl = "http://10.108.72.19:8000/storage/";

  /// Returns the full URL for a given file path
  static String getUrl(String? path) {
    if (path == null || path.isEmpty) {
      // Return a placeholder if no image is provided
      return "https://via.placeholder.com/150";
    }
    return "$baseUrl$path";
  }
}
