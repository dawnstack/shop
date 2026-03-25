import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/app_router.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/models/product_model.dart';
import 'package:shop/presentation/widgets/images/app_image.dart';

class ProductSearchPage extends StatefulWidget {
  final String initialKeyword;

  const ProductSearchPage({super.key, this.initialKeyword = ''});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  late final TextEditingController _keywordController;
  String _sort = '';
  late Future<List<ProductModel>> _searchFuture;

  static const Map<String, String> _sortOptions = {
    '': '默认排序',
    'price_asc': '价格升序',
    'price_desc': '价格降序',
    'sales': '销量优先',
  };

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController(text: widget.initialKeyword);
    _searchFuture = _loadProducts();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> _loadProducts() async {
    final response = await di.getIt<ApiService>().searchProducts(
      keyword: _keywordController.text.trim(),
      sort: _sort,
    );
    return response.data ?? <ProductModel>[];
  }

  Future<void> _search() async {
    setState(() {
      _searchFuture = _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商品搜索')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: '搜索商品名称',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _search, child: const Text('搜索')),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: _sortOptions.entries.map((entry) {
                final selected = _sort == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _sort = entry.key;
                        _searchFuture = _loadProducts();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data ?? <ProductModel>[];
                if (products.isEmpty) {
                  return const Center(child: Text('没有找到匹配商品'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        context.push(
                          AppRouter.detail,
                          extra: {
                            'id': product.id,
                            'name': product.name,
                            'imageUrl': product.imageUrl,
                            'price': product.price / 100,
                            'originalPrice': product.price / 100,
                            'sales': product.sales,
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: AppImage(url: product.imageUrl),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.description.isNotEmpty
                                          ? product.description
                                          : '暂无商品描述',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '¥${(product.price / 100).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Color(0xFFFF5000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
