import 'package:shop/domain/entities/category_data.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: (json['icon_url'] ?? '').toString(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

extension CategoryModelX on CategoryModel {
  CategoryData toEntity() =>
      CategoryData(id: id, name: name, icon: icon, sortOrder: sortOrder);
}
