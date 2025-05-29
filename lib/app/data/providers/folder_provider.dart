import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:document_manager/app/data/models/folder.dart';
import 'package:document_manager/app/data/providers/document_provider.dart';

class FolderProvider extends GetxService {
  final GetStorage _box = GetStorage();
  final String _foldersKey = 'folders';
  final RxBool isLoading = false.obs;
  final RxList<Folder> _cachedFolders = <Folder>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFolders();
  }

  Future<List<Folder>> loadFolders() async {
    try {
      isLoading.value = true;
      
      final String? foldersJson = _box.read<String>(_foldersKey);
      
      if (foldersJson != null && foldersJson.isNotEmpty) {
        final List<dynamic> foldersData = json.decode(foldersJson);
        _cachedFolders.value = foldersData
            .map((folder) => Folder.fromJson(folder))
            .toList();
      } else {
        await _loadSampleFolders();
      }
      
      // Update document counts
      await _updateDocumentCounts();
      
      return _cachedFolders;
    } catch (e) {
      print('Error loading folders: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSampleFolders() async {
    final sampleFolders = [
      Folder(
        id: '1',
        name: 'Work Documents',
        description: 'All work-related documents',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        color: 'blue',
      ),
      Folder(
        id: '2',
        name: 'Personal',
        description: 'Personal documents and files',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
        color: 'green',
      ),
      Folder(
        id: '3',
        name: 'Photos',
        description: 'Image collection',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        color: 'orange',
      ),
    ];
    
    _cachedFolders.value = sampleFolders;
    await _saveFolders();
  }

  Future<void> _updateDocumentCounts() async {
    try {
      final documentProvider = Get.find<DocumentProvider>();
      
      for (int i = 0; i < _cachedFolders.length; i++) {
        final folder = _cachedFolders[i];
        final count = documentProvider.getDocumentsByFolder(folder.id).length;
        _cachedFolders[i] = folder.copyWith(documentCount: count);
      }
      
      await _saveFolders();
    } catch (e) {
      print('Error updating document counts: $e');
    }
  }

  Future<void> _saveFolders() async {
    try {
      final foldersData = _cachedFolders.map((folder) => folder.toJson()).toList();
      await _box.write(_foldersKey, json.encode(foldersData));
    } catch (e) {
      print('Error saving folders: $e');
    }
  }

  Future<Folder?> createFolder({
    required String name,
    String? description,
    String? parentId,
    String color = 'blue',
  }) async {
    try {
      if (name.trim().isEmpty) return null;
      
      final folder = Folder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        description: description?.trim(),
        parentId: parentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: color,
      );
      
      _cachedFolders.add(folder);
      await _saveFolders();
      
      return folder;
    } catch (e) {
      print('Error creating folder: $e');
      return null;
    }
  }

  Future<void> deleteFolder(String folderId) async {
    try {
      _cachedFolders.removeWhere((folder) => folder.id == folderId);
      await _saveFolders();
    } catch (e) {
      print('Error deleting folder: $e');
    }
  }

  Future<void> updateFolder(Folder folder) async {
    try {
      final index = _cachedFolders.indexWhere((f) => f.id == folder.id);
      if (index != -1) {
        _cachedFolders[index] = folder.copyWith(updatedAt: DateTime.now());
        await _saveFolders();
      }
    } catch (e) {
      print('Error updating folder: $e');
    }
  }

  Future<void> renameFolder(String folderId, String newName) async {
    try {
      if (newName.trim().isEmpty) return;
      
      final index = _cachedFolders.indexWhere((f) => f.id == folderId);
      if (index != -1) {
        final folder = _cachedFolders[index];
        _cachedFolders[index] = folder.copyWith(
          name: newName.trim(),
          updatedAt: DateTime.now(),
        );
        await _saveFolders();
      }
    } catch (e) {
      print('Error renaming folder: $e');
    }
  }

  List<Folder> searchFolders(String query) {
    if (query.isEmpty) return _cachedFolders;
    
    final lowerQuery = query.toLowerCase();
    return _cachedFolders.where((folder) =>
      folder.name.toLowerCase().contains(lowerQuery) ||
      (folder.description?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  Folder? getFolderById(String id) {
    try {
      return _cachedFolders.firstWhere((folder) => folder.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Folder> get allFolders => _cachedFolders;
}
