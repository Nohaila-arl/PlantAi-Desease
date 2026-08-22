enum AppLanguage { en, fr }

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  bool get isFr => language == AppLanguage.fr;

  String get appTagline => isFr
      ? 'Détection intelligente des maladies des plantes'
      : 'Smart Plant Disease Detection';

  String get detectPlant => isFr ? 'Détectez les' : 'Detect Plant';

  String get diseasesWithAi =>
      isFr ? 'maladies avec l\'IA' : 'Diseases with AI';

  String get heroSubtitle => isFr
      ? 'Téléchargez une image de feuille et nos modèles d\'IA identifieront la maladie et vous donneront des résultats détaillés.'
      : 'Upload a leaf image and our AI models will identify the disease and give you detailed results.';

  String get chooseModel => isFr ? '1. Choisir le modèle IA' : '1. Choose AI Model';

  String get uploadLeaf =>
      isFr ? '2. Télécharger l\'image' : '2. Upload Leaf Image';

  String get detectStep => isFr ? '3. Détecter la maladie' : '3. Detect Disease';

  String get dragDrop => isFr
      ? 'Glissez-déposez votre image ici'
      : 'Drag & drop your image here';

  String get chooseFile => isFr ? 'Choisir un fichier' : 'Choose File';

  String get fileHint => isFr
      ? 'JPG, PNG, JPEG · Taille max 10 Mo'
      : 'JPG, PNG, JPEG · Max size 10MB';

  String selectedFile(String name) =>
      isFr ? 'Sélectionné : $name' : 'Selected: $name';

  String get detectDisease => isFr ? 'Détecter la maladie' : 'Detect Disease';

  String get analyzing => isFr ? 'Analyse...' : 'Analyzing...';

  String get startAnalysis =>
      isFr ? 'Lancer l\'analyse IA' : 'Start AI analysis';

  String get analysisInProgress =>
      isFr ? 'Analyse IA en cours...' : 'AI analysis in progress...';

  String get imageTooLarge => isFr
      ? 'L\'image doit faire moins de 10 Mo.'
      : 'The image must be smaller than 10MB.';

  String get chooseImageFirst => isFr
      ? 'Veuillez d\'abord choisir une image de feuille.'
      : 'Please choose a leaf image first.';

  String get detectionFailed => isFr
      ? 'Échec de la détection. Vérifiez que l\'API est en cours d\'exécution.'
      : 'Detection failed. Check that the API is running.';

  String get modelFast => isFr ? 'Rapide et léger' : 'Fast & Lightweight';

  String get modelAccurate => isFr ? 'Haute précision' : 'High Accuracy';

  String get modelDetection =>
      isFr ? 'Détection d\'objets' : 'Object Detection';

  String get predictionResult =>
      isFr ? 'Résultat de la prédiction' : 'Prediction Result';

  String get waitingForImage =>
      isFr ? 'En attente d\'une image' : 'Waiting for an image';

  String get noDetectionYet => isFr
      ? 'Aucune détection pour le moment. Choisissez une image puis cliquez sur « Détecter la maladie ».'
      : 'No detection yet. Choose an image and click "Detect Disease".';

  String get confidenceScore =>
      isFr ? 'Score de confiance' : 'Confidence Score';

  String get recommendation => isFr ? 'Recommandation' : 'Recommendation';

  String get treatment => isFr ? 'Traitement' : 'Treatment';

  String get noTreatment => isFr
      ? 'Aucun traitement disponible pour le moment.'
      : 'No treatment available yet.';

  String get performanceMetrics =>
      isFr ? 'Métriques de performance' : 'Performance Metrics';

  String get responseTime => isFr ? 'Temps de réponse' : 'Response Time';

  String get cpuUsage => isFr ? 'Utilisation CPU' : 'CPU Usage';

  String get ramUsage => isFr ? 'Utilisation RAM' : 'RAM Usage';

  String get modelSize => isFr ? 'Taille du modèle' : 'Model Size';

  String get accuracy => isFr ? 'Exactitude' : 'Accuracy';

  String get precision => isFr ? 'Précision' : 'Precision';

  String get recall => isFr ? 'Rappel' : 'Recall';

  String get f1Score => isFr ? 'Score F1' : 'F1-Score';

  String get modelComparison =>
      isFr ? 'Comparaison des modèles' : 'Model Comparison';

  String get chartAccuracy => isFr ? 'Exactitude (%)' : 'Accuracy (%)';

  String get chartResponseTime =>
      isFr ? 'Temps de réponse (s)' : 'Response Time (s)';

  String get chartCpu => isFr ? 'Utilisation CPU (%)' : 'CPU Usage (%)';

  String get chartRam => isFr ? 'Utilisation RAM (%)' : 'RAM Usage (%)';

  String get recentDetections =>
      isFr ? 'Détections récentes' : 'Recent Detections';

  String get noDetections =>
      isFr ? 'Aucune détection pour le moment.' : 'No detections yet.';

  String get justNow => isFr ? 'À l\'instant' : 'Just now';

  String get downloadApp =>
      isFr ? 'Télécharger l\'application' : 'Download app';

  String get downloadUnavailable => isFr
      ? 'Le lien de téléchargement n\'est pas encore disponible.'
      : 'The download link is not available yet.';

  String get alreadyOnApp => isFr
      ? 'Vous utilisez déjà l\'application.'
      : 'You are already using the app.';

  String get healthy => isFr ? 'Saine' : 'Healthy';

  String get infected => isFr ? 'Infectée' : 'Infected';

  String statusLabel(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('healthy') || normalized.contains('sain')) {
      return healthy;
    }
    if (normalized.contains('infect') || normalized.contains('malad')) {
      return infected;
    }
    return status;
  }

  String modelSubtitle(String modelName) {
    switch (modelName) {
      case 'MobileNet':
        return modelFast;
      case 'ResNet':
        return modelAccurate;
      case 'YOLO':
        return modelDetection;
      default:
        return '';
    }
  }
}
