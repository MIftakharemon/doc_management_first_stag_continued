import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:document_manager/app/data/models/document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class DocumentProvider extends GetxService {
  final GetStorage _box = GetStorage();
  final String _documentsKey = 'documents';
  final RxBool isLoading = false.obs;
  final RxList<Document> _cachedDocuments = <Document>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
  }

  Future<List<Document>> loadDocuments() async {
    try {
      isLoading.value = true;
      
      // Load from local storage first
      final String? documentsJson = _box.read<String>(_documentsKey);
      
      if (documentsJson != null && documentsJson.isNotEmpty) {
        final List<dynamic> documentsData = json.decode(documentsJson);
        _cachedDocuments.value = documentsData
            .map((doc) => Document.fromJson(doc))
            .toList();
      } else {
        // Load sample data if no documents exist
        await _loadSampleDocuments();
      }
      
      return _cachedDocuments;
    } catch (e) {
      print('Error loading documents: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSampleDocuments() async {
    final sampleDocs = [
      Document(
        id: '1',
        name: 'Project Proposal',
        originalName: 'project_proposal.pdf',
        type: DocumentType.pdf,
        path: '/documents/project_proposal.pdf',
        size: 2048576, // 2MB
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        tags: ['work', 'proposal'],
        description: 'Q4 project proposal document',
        isFavorite: true,
      ),
      Document(
        id: '2',
        name: 'Meeting Notes',
        originalName: 'meeting_notes.txt',
        type: DocumentType.text,
        path: '/documents/meeting_notes.txt',
        size: 15360, // 15KB
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['meeting', 'notes'],
        description: 'Weekly team meeting notes',
      ),
      Document(
        id: '3',
        name: 'Profile Picture',
        originalName: 'profile.jpg',
        type: DocumentType.image,
        path: '/documents/profile.jpg',
        size: 512000, // 500KB
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['personal', 'photo'],
        description: 'Updated profile picture',
      ),
    ];
    
    _cachedDocuments.value = sampleDocs;
    await _saveDocuments();
  }

  Future<void> _saveDocuments() async {
    try {
      final documentsData = _cachedDocuments.map((doc) => doc.toJson()).toList();
      await _box.write(_documentsKey, json.encode(documentsData));
    } catch (e) {
      print('Error saving documents: $e');
    }
  }

  Future<Document?> uploadDocument({
    String? folderId,
    List<String>? tags,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Create document object
        final document = Document(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: file.name.split('.').first,
          originalName: file.name,
          type: Document.getTypeFromExtension(file.extension ?? ''),
          path: '/documents/${file.name}',
          size: file.size,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          folderId: folderId,
          tags: tags ?? [],
          description: description,
        );
        
        // Add to cache and save
        _cachedDocuments.add(document);
        await _saveDocuments();
        
        return document;
      }
      
      return null;
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      _cachedDocuments.removeWhere((doc) => doc.id == documentId);
      await _saveDocuments();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> updateDocument(Document document) async {
    try {
      final index = _cachedDocuments.indexWhere((doc) => doc.id == document.id);
      if (index != -1) {
        _cachedDocuments[index] = document.copyWith(updatedAt: DateTime.now());
        await _saveDocuments();
      }
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<void> toggleFavorite(String documentId) async {
    try {
      final index = _cachedDocuments.indexWhere((doc) => doc.id == documentId);
      if (index != -1) {
        final document = _cachedDocuments[index];
        _cachedDocuments[index] = document.copyWith(
          isFavorite: !document.isFavorite,
          updatedAt: DateTime.now(),
        );
        await _saveDocuments();
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  List<Document> searchDocuments(String query) {
    if (query.isEmpty) return _cachedDocuments;
    
    final lowerQuery = query.toLowerCase();
    return _cachedDocuments.where((doc) =>
      doc.name.toLowerCase().contains(lowerQuery) ||
      doc.originalName.toLowerCase().contains(lowerQuery) ||
      doc.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
      (doc.description?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  List<Document> getDocumentsByFolder(String? folderId) {
    return _cachedDocuments.where((doc) => doc.folderId == folderId).toList();
  }

  List<Document> getFavoriteDocuments() {
    return _cachedDocuments.where((doc) => doc.isFavorite).toList();
  }

  List<Document> getRecentDocuments({int limit = 10}) {
    final sortedDocs = List<Document>.from(_cachedDocuments);
    sortedDocs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortedDocs.take(limit).toList();
  }

  List<Document> getDocumentsByType(DocumentType type) {
    return _cachedDocuments.where((doc) => doc.type == type).toList();
  }

  Document? getDocumentById(String id) {
    try {
      return _cachedDocuments.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Document> get allDocuments => _cachedDocuments;
}
