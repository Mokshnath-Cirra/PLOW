import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/diagnosis_report.dart';
import 'plant_repository.dart';

class PlantApiService {
  static const String defaultBaseUrl = 'http://localhost:8000';
  final String baseUrl;

  PlantApiService({this.baseUrl = defaultBaseUrl});

  Future<DiagnosisReport> analyzeImage(Uint8List imageBytes, String filename) async {
    final uri = Uri.parse('$baseUrl/analyze');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
      ),
    );

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(responseBody);
        var report = DiagnosisReport.fromJson(jsonMap);

        // Enrich with verified 150+ database care information
        report = PlantRepository().enrichDiagnosis(report);
        return report;
      } else if (streamedResponse.statusCode == 503) {
        throw ApiException(
          'Gemini API Key Missing: Please add GEMINI_API_KEY in backend/.env to enable live AI vision.',
          statusCode: 503,
        );
      } else if (streamedResponse.statusCode == 413) {
        throw ApiException(
          'Image Too Large: Please upload an image under 15 MB.',
          statusCode: 413,
        );
      } else {
        String errorMsg = 'Server analysis error (${streamedResponse.statusCode})';
        try {
          final errJson = json.decode(responseBody);
          if (errJson.containsKey('detail')) errorMsg = errJson['detail'].toString();
        } catch (_) {}
        throw ApiException(errorMsg, statusCode: streamedResponse.statusCode);
      }
    } on http.ClientException {
      throw ApiException(
        'Cannot connect to backend server at $baseUrl. Ensure FastAPI is running (`python -m uvicorn backend.main:app --port 8000`).',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network timeout or connection error: ${e.toString()}');
    }
  }

  Future<String> askAgronomist({
    required String question,
    DiagnosisReport? contextReport,
  }) async {
    final uri = Uri.parse('$baseUrl/chat');
    final payload = {
      'message': question,
      'plant_context': contextReport != null
          ? {
              'common_name': contextReport.commonName,
              'scientific_name': contextReport.scientificName,
              'health_status': contextReport.healthStatus,
              'disease_name': contextReport.diseaseName,
              'symptoms': contextReport.symptomsSeen,
            }
          : null,
    };

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['reply'] as String? ?? 'No response received from agronomist.';
      } else {
        return 'Agronomist service temporary error (${response.statusCode}). Please follow the care instructions in the dossier.';
      }
    } catch (e) {
      return 'Unable to reach Agronomist AI. Check that the backend server is running on port 8000.';
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
