import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getPerfil() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/perfil'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getIndicadores() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/home/indicadores'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getMof({
    String? categoria,
    String? nivel,
    String? buscar,
  }) async {
    String url = '${ApiConfig.baseUrl}/mof';
    final params = <String, String>{};
    if (categoria != null) params['categoria'] = categoria;
    if (nivel != null) params['nivel'] = nivel;
    if (buscar != null) params['buscar'] = buscar;
    if (params.isNotEmpty) url += '?${Uri(queryParameters: params).query}';

    final response = await http.get(Uri.parse(url), headers: await _headers());
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getCategorias() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/mof/categorias'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUsuarios({
    String? nombre,
    String? categoria,
    String? puesto,
    int page = 1,
  }) async {
    String url = '${ApiConfig.baseUrl}/usuarios?page=$page';
    if (nombre != null && nombre.isNotEmpty) url += '&nombre=$nombre';
    if (categoria != null) url += '&categoria=$categoria';
    if (puesto != null && puesto.isNotEmpty) url += '&puesto=$puesto';

    final response = await http.get(Uri.parse(url), headers: await _headers());
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePerfil({
    String? email,
    String? telefono,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/perfil'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'telefono': telefono}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>?> getValuacion(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/usuarios/$userId/valuacion'),
      headers: await _headers(),
    );
    if (response.statusCode == 404) return null;
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateFoto(String filePath) async {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/perfil/foto'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(
      await http.MultipartFile.fromPath('foto', filePath),
    );
    final response = await request.send();
    final body = await response.stream.bytesToString();
    return jsonDecode(body);
  }

  static Future<List<dynamic>> getEscalaAnios() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/escala/anios'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getEscala({
    String anio = '2025',
    String? seccion,
  }) async {
    String url = '${ApiConfig.baseUrl}/escala?anio=$anio';
    if (seccion != null) url += '&seccion=$seccion';
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAnalisisSalarial() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/analisis-salarial'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> importarExcel(String filePath) async {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/importar-usuarios'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(
      await http.MultipartFile.fromPath('archivo', filePath),
    );
    final response = await request.send();
    final body = await response.stream.bytesToString();
    return jsonDecode(body);
  }

  static Future<List<dynamic>> getHistorial() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/historial'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAnalisisRangos() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/analisis-salarial/rangos'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>?> getEscalaRangos() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/perfil/escala-rangos'),
      headers: await _headers(),
    );
    if (response.statusCode == 404) return null;
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getDetalleEscala() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/detalle-escala'),
    headers: await _headers(),
  );
  return jsonDecode(response.body);
}
}