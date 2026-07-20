import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const baseUrl = 'http://192.168.1.5:3000';

  Future<List<dynamic>> getUsers() async {

    final response = await http.get(
      Uri.parse('$baseUrl/users'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Gagal mengambil data');
  }
}