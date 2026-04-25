import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/product.dart';
import '../../../models/offline_sale.dart';
import '../../../providers/product_provider.dart';
import '../../../services/offline_sale_service.dart';
import '../../../services/api_service.dart';

class CreateOfflineSaleScreen extends StatefulWidget {
  const CreateOfflineSaleScreen({super.key});

  @override
  State<CreateOfflineSaleScreen> createState() => _CreateOfflineSaleScreenState();
}

class _CreateOfflineSaleScreenState extends State<CreateOfflineSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, int> _selectedProducts = {}; // productId -> quantity
  String _paymentMethod = 'cash';
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    final productProvider = context.read<ProductProvider>();
    double total = 0;

    _selectedProducts.forEach((productId, quantity) {
      final product = productProvider.products.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(
          id: '',
          name: '',
          pricePerUnit: 0,
          unit: '',
          stock: 0,
          isActive: false,
        ),
      );
      total += product.pricePerUnit * quantity;
    });

    return total;
  }

  Future<void> _createSale() async {
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final offlineSaleService = OfflineSaleService(apiService);

      final items = _selectedProducts.entries.map((entry) {
        return CreateOfflineSaleItem(
          productId: entry.key,
          quantity: entry.value,
        );
      }).toList();

      final request = CreateOfflineSaleRequest(
        items: items,
        customerName: _customerNameController.text.trim().isEmpty
            ? null
            : _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim().isEmpty
            ? null
            : _customerPhoneController.text.trim(),
        paymentMethod: _paymentMethod,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await offlineSaleService.createOfflineSale(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(provider.error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.loadProducts(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductSelection(provider.products),
                            const SizedBox(height: 24),
                            _buildCustomerInfo(),
                            const SizedBox(height: 24),
                            _buildPaymentMethod(),
                            const SizedBox(height: 24),
                            _buildNotes(),
                            const SizedBox(height: 24),
                            _buildSummary(),
                            const SizedBox(height: 24),
                            _buildCreateButton(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.appBarGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const Expanded(
              child: Text(
                'Create In-Store Sale',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelection(List<Product> products) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Products',
              style: AppTheme.h4,
            ),
            const SizedBox(height: 16),
            ...products.where((p) => p.isActive).map((product) {
              final isSelected = _selectedProducts.containsKey(product.id);
              final quantity = _selectedProducts[product.id] ?? 1;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedProducts[product.id] = 1;
                        } else {
                          _selectedProducts.remove(product.id);
                        }
                      });
                    },
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    '\u{20B9}${product.pricePerUnit}/${product.unit} \u{2022} Stock: ${product.stock}',
                  ),
                  trailing: isSelected
                      ? Container(
                          width: 120,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (quantity > 1) {
                                      _selectedProducts[product.id] = quantity - 1;
                                    }
                                  });
                                },
                              ),
                              Text('$quantity'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  if (quantity < product.stock) {
                                    setState(() {
                                      _selectedProducts[product.id] = quantity + 1;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Insufficient stock for ${product.name}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information (Optional)',
              style: AppTheme.h4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Customer Phone',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                    return 'Invalid phone number';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: AppTheme.h4,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Cash'),
                  selected: _paymentMethod == 'cash',
                  onSelected: (selected) {
                    setState(() => _paymentMethod = 'cash');
                  },
                ),
                ChoiceChip(
                  label: const Text('Card'),
                  selected: _paymentMethod == 'card',
                  onSelected: (selected) {
                    setState(() => _paymentMethod = 'card');
                  },
                ),
                ChoiceChip(
                  label: const Text('UPI'),
                  selected: _paymentMethod == 'upi',
                  onSelected: (selected) {
                    setState(() => _paymentMethod = 'upi');
                  },
                ),
                ChoiceChip(
                  label: const Text('Other'),
                  selected: _paymentMethod == 'other',
                  onSelected: (selected) {
                    setState(() => _paymentMethod = 'other');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes (Optional)',
              style: AppTheme.h4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add any notes about this sale...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final total = _calculateTotal();

    return Card(
      color: AppTheme.primaryLight.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items Selected:',
                  style: AppTheme.bodyLarge,
                ),
                Text(
                  '${_selectedProducts.length}',
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: AppTheme.h4,
                ),
                Text(
                  '\u{20B9}${total.toStringAsFixed(2)}',
                  style: AppTheme.h4.copyWith(color: AppTheme.primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createSale,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Create Sale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

