import 'package:get/get.dart';
import '../views/home_view.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final count = 0.obs;
  var namaKaryawan = "".obs;
  
  Future<void> login(String username, String password) async {
    final response = await dio.post("/auth/login", data: {
      "username": username,
      "password": password,
    });

    final token = response.data['token'];
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  // Ambil dashboard karyawan
  Future<void> getDashboard() async {
    try {
      final response = await dio.get("/karyawan/dashboard");
      print(response.data); // tampilkan data karyawan yg login
    } catch (e) {
      print("Error: $e");
    }
  }
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
