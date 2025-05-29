import 'package:get/get.dart';
import 'package:document_manager/app/data/providers/document_provider.dart';
import 'package:document_manager/app/data/providers/folder_provider.dart';
import 'package:document_manager/app/data/services/auth_service.dart';
import 'package:document_manager/app/modules/dashboard/controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure providers and services are registered
    if (!Get.isRegistered<DocumentProvider>()) {
      Get.put<DocumentProvider>(DocumentProvider(), permanent: true);
    }
    
    if (!Get.isRegistered<FolderProvider>()) {
      Get.put<FolderProvider>(FolderProvider(), permanent: true);
    }
    
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }
    
    Get.put<DashboardController>(DashboardController());
  }
}
