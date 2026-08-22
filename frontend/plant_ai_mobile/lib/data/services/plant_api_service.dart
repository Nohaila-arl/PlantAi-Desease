import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:plant_ai_mobile/core/constants/api_constants.dart';
import 'package:plant_ai_mobile/data/models/prediction_result.dart';

class PlantApiService {
  Future<PredictionResult> predict({
    required List<int> imageBytes,
    required String fileName,
    required String modelApiName,
    required String modelDisplayName,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.predictEndpoint}');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      ),
    );
    request.fields['modele_choisi'] = modelApiName;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PredictionResult.fromJson(data, modelDisplayName);
  }
}
