class ApiConstants {
  ApiConstants._();

  // Mets à true si tu veux repasser sur le backend local en dev.
  static const useLocalBackend = false;

  static const _localDetectionUrl = 'http://localhost:8000';
  static const _productionUrl =
      'https://agent-detection-production.up.railway.app';

  static const baseUrl = useLocalBackend ? _localDetectionUrl : _productionUrl;

  static const predictEndpoint = '/predict';
  static const maxImageSizeBytes = 10 * 1024 * 1024;
  static const appDownloadUrl =
      'https://agent-detection-production.up.railway.app/downloads/plant-ai.apk';
}