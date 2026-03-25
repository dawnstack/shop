import 'package:flutter/material.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/remote/api_service.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  late Future<Map<String, dynamic>> _healthFuture;

  @override
  void initState() {
    super.initState();
    _healthFuture = _loadHealth();
  }

  Future<Map<String, dynamic>> _loadHealth() async {
    final response = await di.getIt<ApiService>().ping();
    return response.data ?? <String, dynamic>{};
  }

  Future<void> _refresh() async {
    setState(() {
      _healthFuture = _loadHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('服务状态')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _healthFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final health = snapshot.data ?? const <String, dynamic>{};
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: const Icon(Icons.health_and_safety_outlined),
                  title: const Text('服务名'),
                  subtitle: Text((health['service'] ?? '未知服务').toString()),
                ),
                ListTile(
                  leading: const Icon(Icons.public_outlined),
                  title: const Text('环境'),
                  subtitle: Text((health['env'] ?? '未知环境').toString()),
                ),
                const SizedBox(height: 16),
                const Text('`/metrics` 用于 Prometheus 抓取，不作为移动端业务入口。'),
              ],
            ),
          );
        },
      ),
    );
  }
}
