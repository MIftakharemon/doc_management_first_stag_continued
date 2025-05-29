import 'package:get/get.dart';
import 'package:document_manager/app/data/models/document.dart';
import 'package:document_manager/app/data/models/folder.dart';
import 'package:document_manager/app/data/providers/document_provider.dart';
import 'package:document_manager/app/data/providers/folder_provider.dart';
import 'package:document_manager/app/data/services/auth_service.dart';
import 'package:document_manager/app/routes/app_pages.dart';

class DashboardController extends GetxController {
  final DocumentProvider _documentProvider = Get.find<DocumentProvider>();
  final FolderProvider _folderProvider = Get.find<FolderProvider>();
  final AuthService _authService = Get.find<AuthService>();
  
  final RxList<Document> recentDocuments = <Document>[].obs;
  final RxList<Folder> folders = <Folder>[].obs;
  final RxList<Document> favoriteDocuments = <Document>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt currentTabIndex = 0.obs;
  
  // Storage stats
  final RxInt totalDocuments = 0.obs;
  final RxInt totalFolders = 0.obs;
  final RxString totalStorage = '0 MB'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }
  
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      
      // Load documents and folders
      await _documentProvider.loadDocuments();
      await _folderProvider.loadFolders();
      
      // Update dashboard data
      recentDocuments.value = _documentProvider.getRecentDocuments(limit: 5);
      folders.value = _folderProvider.allFolders.take(4).toList();
      favoriteDocuments.value = _documentProvider.getFavoriteDocuments();
      
      // Update stats
      totalDocuments.value = _documentProvider.allDocuments.length;
      totalFolders.value = _folderProvider.allFolders.length;
      
      // Calculate total storage
      final totalBytes = _documentProvider.allDocuments
          .fold<int>(0, (sum, doc) => sum + doc.size);
      totalStorage.value = _formatBytes(totalBytes);
      
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  void changeTab(int index) {
    currentTabIndex.value = index;
  }
  
  void navigateToDocuments() {
    Get.toNamed(Routes.DOCUMENTS);
  }
  
  void navigateToFolders() {
    Get.toNamed(Routes.FOLDERS);
  }
  
  void navigateToSearch() {
    Get.toNamed(Routes.SEARCH);
  }
  
  void navigateToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }
  
  void viewDocumentDetail(Document document) {
    Get.toNamed(Routes.DOCUMENT_DETAIL, arguments: document);
  }
  
  Future<void> uploadDocument() async {
    try {
      final document = await _documentProvider.uploadDocument();
      if (document != null) {
        Get.snackbar(
          'Success',
          'Document uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadDashboardData();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload document',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> toggleFavorite(String documentId) async {
    try {
      await _documentProvider.toggleFavorite(documentId);
      await loadDashboardData();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }
  
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
  
  void refreshData() {
    loadDashboardData();
  }
}
