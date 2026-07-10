import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class ApiService extends GetxService {
  late dio.Dio dioClient;

  @override
  void onInit() {
    super.onInit();
    dioClient = dio.Dio(
      dio.BaseOptions(
        baseUrl: "https://stylar-nonseverable-denver.ngrok-free.dev/api",
        headers: {"Content-Type": "application/json"},
      ),
    );
  }

  Future<dio.Response> get(String endpoint) async => await dioClient.get(endpoint);
  Future<dio.Response> post(String endpoint, Map<String, dynamic> data) async =>
      await dioClient.post(endpoint, data: data);
}
