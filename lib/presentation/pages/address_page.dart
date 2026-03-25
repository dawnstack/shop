import 'package:flutter/material.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/models/address_model.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  late Future<List<AddressModel>> _addressFuture;

  @override
  void initState() {
    super.initState();
    _addressFuture = _loadAddresses();
  }

  Future<List<AddressModel>> _loadAddresses() async {
    final response = await di.getIt<ApiService>().getAddresses();
    return response.data ?? <AddressModel>[];
  }

  Future<void> _refresh() async {
    setState(() {
      _addressFuture = _loadAddresses();
    });
  }

  Future<void> _createOrUpdateAddress([AddressModel? address]) async {
    final result = await showDialog<AddressModel>(
      context: context,
      builder: (context) => _AddressFormDialog(initialValue: address),
    );
    if (result == null) {
      return;
    }

    if (address == null) {
      await di.getIt<ApiService>().createAddress(result);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('地址已新增')));
    } else {
      await di.getIt<ApiService>().updateAddress(address.id, result);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('地址已更新')));
    }

    await _refresh();
  }

  Future<void> _deleteAddress(AddressModel address) async {
    await di.getIt<ApiService>().deleteAddress(address.id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('地址已删除')));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地址管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createOrUpdateAddress,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<AddressModel>>(
        future: _addressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data ?? <AddressModel>[];
          if (addresses.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(child: Text('还没有收货地址，点击右下角添加')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.receiverName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 8),
                            Text(address.phone),
                            const Spacer(),
                            if (address.isDefault)
                              const Chip(label: Text('默认地址')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${address.province}${address.city}${address.district}${address.detail}',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _createOrUpdateAddress(address),
                              child: const Text('编辑'),
                            ),
                            TextButton(
                              onPressed: () => _deleteAddress(address),
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AddressFormDialog extends StatefulWidget {
  final AddressModel? initialValue;

  const _AddressFormDialog({this.initialValue});

  @override
  State<_AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<_AddressFormDialog> {
  late final TextEditingController _receiverNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _provinceController;
  late final TextEditingController _cityController;
  late final TextEditingController _districtController;
  late final TextEditingController _detailController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _receiverNameController = TextEditingController(
      text: initial?.receiverName ?? '',
    );
    _phoneController = TextEditingController(text: initial?.phone ?? '');
    _provinceController = TextEditingController(text: initial?.province ?? '');
    _cityController = TextEditingController(text: initial?.city ?? '');
    _districtController = TextEditingController(text: initial?.district ?? '');
    _detailController = TextEditingController(text: initial?.detail ?? '');
    _isDefault = initial?.isDefault ?? false;
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialValue == null ? '新增地址' : '编辑地址'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(_receiverNameController, '收件人'),
            _buildField(_phoneController, '手机号'),
            _buildField(_provinceController, '省'),
            _buildField(_cityController, '市'),
            _buildField(_districtController, '区'),
            _buildField(_detailController, '详细地址'),
            SwitchListTile(
              value: _isDefault,
              title: const Text('设为默认地址'),
              onChanged: (value) => setState(() => _isDefault = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(
              AddressModel(
                id: widget.initialValue?.id ?? '',
                userId: widget.initialValue?.userId ?? '',
                receiverName: _receiverNameController.text.trim(),
                phone: _phoneController.text.trim(),
                province: _provinceController.text.trim(),
                city: _cityController.text.trim(),
                district: _districtController.text.trim(),
                detail: _detailController.text.trim(),
                isDefault: _isDefault,
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
