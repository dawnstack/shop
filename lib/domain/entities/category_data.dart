class CategoryData {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;

  const CategoryData({
    required this.id,
    required this.name,
    required this.icon,
    this.sortOrder = 0,
  });
}
