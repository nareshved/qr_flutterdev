class QrItem {
  final String id;
  final bool isGenerated;
  final String type; // e.g., 'QR', 'Barcode'
  final String category; // e.g., 'URL', 'Phone', 'Text'
  final String content;
  final String? label;
  final bool isFavorite;
  final DateTime timestamp;

  QrItem({
    required this.id,
    required this.isGenerated,
    required this.type,
    required this.category,
    required this.content,
    this.label,
    required this.isFavorite,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isGenerated': isGenerated ? 1 : 0,
      'type': type,
      'category': category,
      'content': content,
      'label': label,
      'isFavorite': isFavorite ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory QrItem.fromMap(Map<String, dynamic> map) {
    return QrItem(
      id: map['id'],
      isGenerated: map['isGenerated'] == 1,
      type: map['type'],
      category: map['category'],
      content: map['content'],
      label: map['label'],
      isFavorite: map['isFavorite'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  QrItem copyWith({
    String? id,
    bool? isGenerated,
    String? type,
    String? category,
    String? content,
    String? label,
    bool? isFavorite,
    DateTime? timestamp,
  }) {
    return QrItem(
      id: id ?? this.id,
      isGenerated: isGenerated ?? this.isGenerated,
      type: type ?? this.type,
      category: category ?? this.category,
      content: content ?? this.content,
      label: label ?? this.label,
      isFavorite: isFavorite ?? this.isFavorite,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
