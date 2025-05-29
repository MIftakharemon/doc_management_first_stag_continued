import 'package:get/get.dart';
import 'package:document_manager/app/data/services/auth_service.dart';
import 'package:document_manager/app/modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }
    
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
