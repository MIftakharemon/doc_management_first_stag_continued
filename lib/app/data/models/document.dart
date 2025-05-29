import 'package:document_manager/app/data/models/folder.dart';

enum DocumentType {
  pdf,
  image,
  text,
  video,
  audio,
  other,
}

class Document {
  final String id;
  final String name;
  final String originalName;
  final DocumentType type;
  final String path;
  final String? url;
  final int size;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? folderId;
  final List<String> tags;
  final String? description;
  final bool isFavorite;
  final bool isShared;

  Document({
    required this.id,
    required this.name,
    required this.originalName,
    required this.type,
    required this.path,
    this.url,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
    this.tags = const [],
    this.description,
    this.isFavorite = false,
    this.isShared = false,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      type: DocumentType.values.firstWhere(
        (e) => e.toString() == 'DocumentType.${json['type']}',
        orElse: () => DocumentType.other,
      ),
      path: json['path'] ?? '',
      url: json['url'],
      size: json['size'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      folderId: json['folder_id'],
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'],
      isFavorite: json['is_favorite'] ?? false,
      isShared: json['is_shared'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'type': type.toString().split('.').last,
      'path': path,
      'url': url,
      'size': size,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'folder_id': folderId,
      'tags': tags,
      'description': description,
      'is_favorite': isFavorite,
      'is_shared': isShared,
    };
  }

  Document copyWith({
    String? id,
    String? name,
    String? originalName,
    DocumentType? type,
    String? path,
    String? url,
    int? size,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? folderId,
    List<String>? tags,
    String? description,
    bool? isFavorite,
    bool? isShared,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      originalName: originalName ?? this.originalName,
      type: type ?? this.type,
      path: path ?? this.path,
      url: url ?? this.url,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      isShared: isShared ?? this.isShared,
    );
  }

  String get fileExtension {
    return originalName.split('.').last.toLowerCase();
  }

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  static DocumentType getTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return DocumentType.pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return DocumentType.image;
      case 'txt':
      case 'doc':
      case 'docx':
      case 'rtf':
        return DocumentType.text;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
        return DocumentType.video;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return DocumentType.audio;
      default:
        return DocumentType.other;
    }
  }
}
