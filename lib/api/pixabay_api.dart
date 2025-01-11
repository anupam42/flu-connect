import 'dart:convert';
import 'package:http/http.dart' as http;

class PixabayService {
  static const String _apiKey = '48170540-4993f6d4356e871739dc3b7c6';
  static const String _baseUrl = "https://pixabay.com/api/";

  static Future<List<String>> fetchImageUrls(String query, {int count = 10}) async {
    final url = Uri.parse(
      "$_baseUrl?key=$_apiKey&q=${Uri.encodeComponent(query)}&image_type=photo&per_page=$count"
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hits = data['hits'] as List<dynamic>;
      return hits.map<String>((hit) => hit['webformatURL'] as String).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }
}