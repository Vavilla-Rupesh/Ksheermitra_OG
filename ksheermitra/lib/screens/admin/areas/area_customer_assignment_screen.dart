import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/dairy_theme.dart';
import '../../../models/area.dart';
import '../../../models/user.dart';
import '../../../providers/customer_provider.dart';
import '../../../services/api_service.dart';

class AreaCustomerAssignmentScreen extends StatefulWidget {
  final Area area;

  const AreaCustomerAssignmentScreen({super.key, required this.area});

  @override
  State<AreaCustomerAssignmentScreen> createState() => _AreaCustomerAssignmentScreenState();
}

class _AreaCustomerAssignmentScreenState extends State<AreaCustomerAssignmentScreen> {
  final ApiService _apiService = ApiService();
  List<User> _allCustomers = [];
  List<String> _assignedCustomerIds = [];
  List<String> _selectedCustomerIds = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load all customers
      await context.read<CustomerProvider>().loadCustomers();
      _allCustomers = context.read<CustomerProvider>().customers;

      // Load currently assigned customers for this area
      final response = await _apiService.get('/admin/areas/${widget.area.id}/customers');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        _assignedCustomerIds = data.map((c) => c['id']?.toString() ?? '').toList();
      } else {
        // Demo: Filter customers by area
        _assignedCustomerIds = _allCustomers
            .where((c) => c.areaId == widget.area.id)
            .map((c) => c.id)
            .toList();
      }

      _selectedCustomerIds = List.from(_assignedCustomerIds);
    } catch (e) {
      debugPrint('Error loading data: $e');
      // Use demo data
      _assignedCustomerIds = _allCustomers
          .where((c) => c.areaId == widget.area.id)
          .map((c) => c.id)
          .toList();
      _selectedCustomerIds = List.from(_assignedCustomerIds);
    }

    setState(() => _isLoading = false);
  }

  List<User> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _allCustomers;
    final query = _searchQuery.toLowerCase();
    return _allCustomers.where((customer) {
      return (customer.name?.toLowerCase().contains(query) ?? false) ||
          customer.phone.contains(query) ||
          (customer.address?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _saveAssignments() async {
    setState(() => _isSaving = true);

    try {
      final response = await _apiService.put(
        '/admin/areas/${widget.area.id}/customers',
        {'customerIds': _selectedCustomerIds},
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer assignments saved successfully!'),
              backgroundColor: DairyColorsLight.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to save assignments'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving assignments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isSaving = false);
  }

  void _toggleCustomer(String customerId) {
    setState(() {
      if (_selectedCustomerIds.contains(customerId)) {
        _selectedCustomerIds.remove(customerId);
      } else {
        _selectedCustomerIds.add(customerId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedCustomerIds = _filteredCustomers.map((c) => c.id).toList();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedCustomerIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasChanges = !_listEquals(_selectedCustomerIds, _assignedCustomerIds);

    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Customers to ${widget.area.name}'),
        actions: [
          if (_filteredCustomers.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'select_all') {
                  _selectAll();
                } else if (value == 'deselect_all') {
                  _deselectAll();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'select_all',
                  child: Row(
                    children: [
                      Icon(Icons.select_all, size: 20),
                      SizedBox(width: 12),
                      Text('Select All'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'deselect_all',
                  child: Row(
                    children: [
                      Icon(Icons.deselect, size: 20),
                      SizedBox(width: 12),
                      Text('Deselect All'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Stats
                Container(
                  padding: const EdgeInsets.all(DairySpacing.md),
                  color: DairyColorsLight.surface,
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search customers...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: DairyRadius.defaultBorderRadius,
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),

                      const SizedBox(height: DairySpacing.md),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Customers',
                              '${_allCustomers.length}',
                              Icons.people,
                              DairyColorsLight.primary,
                            ),
                          ),
                          const SizedBox(width: DairySpacing.sm),
                          Expanded(
                            child: _buildStatCard(
                              'Selected',
                              '${_selectedCustomerIds.length}',
                              Icons.check_circle,
                              DairyColorsLight.success,
                            ),
                          ),
                          const SizedBox(width: DairySpacing.sm),
                          Expanded(
                            child: _buildStatCard(
                              'Previously',
                              '${_assignedCustomerIds.length}',
                              Icons.history,
                              DairyColorsLight.info,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Customer List
                Expanded(
                  child: _filteredCustomers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                size: 64,
                                color: DairyColorsLight.textTertiary,
                              ),
                              const SizedBox(height: DairySpacing.md),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No customers found'
                                    : 'No matching customers',
                                style: DairyTypography.headingSmall(),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(DairySpacing.md),
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            return _buildCustomerTile(customer);
                          },
                        ),
                ),

                // Save Button
                if (hasChanges)
                  Container(
                    padding: const EdgeInsets.all(DairySpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveAssignments,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Saving...' : 'Save Assignments'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(DairySpacing.sm + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DairyRadius.defaultBorderRadius,
        border: Border.all(color: DairyColorsLight.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: DairyTypography.headingSmall(),
          ),
          Text(
            label,
            style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTile(User customer) {
    final isSelected = _selectedCustomerIds.contains(customer.id);
    final wasAssigned = _assignedCustomerIds.contains(customer.id);

    return Card(
      margin: const EdgeInsets.only(bottom: DairySpacing.sm),
      color: isSelected ? DairyColorsLight.primarySurface : null,
      child: InkWell(
        onTap: () => _toggleCustomer(customer.id),
        borderRadius: DairyRadius.defaultBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(DairySpacing.md),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? DairyColorsLight.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? DairyColorsLight.primary : DairyColorsLight.border,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),

              const SizedBox(width: DairySpacing.md),

              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DairyColorsLight.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (customer.name ?? 'C').substring(0, 1).toUpperCase(),
                    style: DairyTypography.headingSmall(color: DairyColorsLight.primary),
                  ),
                ),
              ),

              const SizedBox(width: DairySpacing.md),

              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name ?? 'Unknown',
                            style: DairyTypography.bodyLarge().copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (wasAssigned)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: DairyColorsLight.infoSurface,
                              borderRadius: DairyRadius.pillBorderRadius,
                            ),
                            child: Text(
                              'Current',
                              style: DairyTypography.caption(color: DairyColorsLight.info),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: DairyTypography.bodySmall(color: DairyColorsLight.textSecondary),
                    ),
                    if (customer.address != null && customer.address!.isNotEmpty)
                      Text(
                        customer.address!,
                        style: DairyTypography.caption(color: DairyColorsLight.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sortedA = List<String>.from(a)..sort();
    final sortedB = List<String>.from(b)..sort();
    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }
}

