class MaterialItem {
  final String id;
  final String projectId;
  final String materialName;
  final double quantity;
  final String unit;

  MaterialItem({
    required this.id,
    required this.projectId,
    required this.materialName,
    required this.quantity,
    required this.unit,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      materialName: json['material_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'material_name': materialName,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
