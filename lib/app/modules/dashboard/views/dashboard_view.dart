import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:document_manager/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:document_manager/app/modules/documents/views/documents_view.dart';
import 'package:document_manager/app/modules/folders/views/folders_view.dart';
import 'package:document_manager/app/modules/search/views/search_view.dart';
import 'package:document_manager/app/modules/settings/views/settings_view.dart';
import 'package:document_manager/app/widgets/loading_indicator.dart';
import 'package:document_manager/app/widgets/document_card.dart';
import 'package:document_manager/app/widgets/folder_card.dart';
import 'package:document_manager/app/data/services/auth_service.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }
        
        return IndexedStack(
          index: controller.currentTabIndex.value,
          children: [
            _buildHomeTab(),
            const DocumentsView(),
            const FoldersView(),
            const SearchView(),
            const SettingsView(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.currentTabIndex.value,
        onTap: controller.changeTab,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Folders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      )),
      floatingActionButton: controller.currentTabIndex.value == 0
          ? FloatingActionButton(
              onPressed: controller.uploadDocument,
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildHomeTab() {
    final AuthService authService = Get.find<AuthService>();
    
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        'Hello, ${authService.userName.value}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      Text(
                        'Manage your documents',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: controller.navigateToSettings,
                    child: CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Obx(() => Text(
                        authService.userName.value.isNotEmpty 
                            ? authService.userName.value[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Documents',
                      controller.totalDocuments.value.toString(),
                      Icons.description,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Folders',
                      controller.totalFolders.value.toString(),
                      Icons.folder,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => _buildStatCard(
                      'Storage',
                      controller.totalStorage.value,
                      Icons.storage,
                      Colors.green,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      'Upload Document',
                      Icons.cloud_upload,
                      Colors.indigo,
                      controller.uploadDocument,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      'Create Folder',
                      Icons.create_new_folder,
                      Colors.orange,
                      controller.navigateToFolders,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Recent Documents
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Documents',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.navigateToDocuments,
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.recentDocuments.isEmpty) {
                  return _buildEmptyState(
                    'No recent documents',
                    'Upload your first document to get started',
                    Icons.description_outlined,
                    controller.uploadDocument,
                    'Upload Document',
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.recentDocuments.length,
                  itemBuilder: (context, index) {
                    final document = controller.recentDocuments[index];
                    return DocumentCard(
                      document: document,
                      onTap: () => controller.viewDocumentDetail(document),
                      onFavoriteToggle: () => controller.toggleFavorite(document.id),
                    );
                  },
                );
              }),
              const SizedBox(height: 32),
              
              // Folders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Folders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.navigateToFolders,
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.folders.isEmpty) {
                  return _buildEmptyState(
                    'No folders yet',
                    'Create folders to organize your documents',
                    Icons.folder_outlined,
                    controller.navigateToFolders,
                    'Create Folder',
                  );
                }
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: controller.folders.length,
                  itemBuilder: (context, index) {
                    final folder = controller.folders[index];
                    return FolderCard(
                      folder: folder,
                      onTap: () => controller.navigateToFolders(),
                    );
                  },
                );
              }),
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onAction,
    String actionText,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}
