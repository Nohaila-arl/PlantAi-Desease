class ApiConstants {
  ApiConstants._();

  // Mets à false quand tu repasses sur le backend de production (Railway).
  static const useLocalBackend = true;

  static const _localDetectionUrl = 'http://localhost:8000';
  static const _productionUrl =
      'https://plant-disease-cloud-api-production.up.railway.app';

  static const baseUrl = useLocalBackend ? _localDetectionUrl : _productionUrl;

  static const predictEndpoint = '/predict';
  static const maxImageSizeBytes = 10 * 1024 * 1024;
  static const appDownloadUrl =
      'https://plant-disease-cloud-api-production.up.railway.app/downloads/plant-ai.apk';
}