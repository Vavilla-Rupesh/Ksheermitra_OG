import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/area.dart';
import '../../../providers/area_provider.dart';
import '../../../providers/delivery_boy_provider.dart';

class AreaFormScreen extends StatefulWidget {
  final Area? area;

  const AreaFormScreen({super.key, this.area});

  @override
  State<AreaFormScreen> createState() => _AreaFormScreenState();
}

class _AreaFormScreenState extends State<AreaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedDeliveryBoyId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.area != null) {
      _nameController.text = widget.area!.name;
      _descriptionController.text = widget.area!.description ?? '';
      _selectedDeliveryBoyId = widget.area!.deliveryBoyId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.area == null ? 'Add Area' : 'Edit Area'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Area Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter area name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Consumer<DeliveryBoyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final deliveryBoys = provider.activeDeliveryBoys;

                return DropdownButtonFormField<String>(
                  initialValue: _selectedDeliveryBoyId,
                  decoration: const InputDecoration(
                    labelText: 'Assign Delivery Boy',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.delivery_dining),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No delivery boy assigned'),
                    ),
                    ...deliveryBoys.map((db) {
                      return DropdownMenuItem(
                        value: db.id,
                        child: Text(db.name ?? db.phone),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDeliveryBoyId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.area == null ? 'Add Area' : 'Update Area',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<AreaProvider>();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    bool success;
    if (widget.area == null) {
      success = await provider.createArea(
        name: name,
        description: description.isNotEmpty ? description : null,
        deliveryBoyId: _selectedDeliveryBoyId,
      );
    } else {
      // For editing existing area
      if (_selectedDeliveryBoyId != null &&
          _selectedDeliveryBoyId != widget.area!.deliveryBoyId) {
        // If delivery boy assignment changed, use assignAreaWithMap
        success = await provider.assignAreaWithMap(
          areaId: widget.area!.id,
          deliveryBoyId: _selectedDeliveryBoyId!,
          boundaries: widget.area!.boundaries,
          centerLatitude: widget.area!.centerLatitude,
          centerLongitude: widget.area!.centerLongitude,
          mapLink: widget.area!.mapLink,
        );

        // Also update area name and description if changed
        if (success && (name != widget.area!.name ||
            description != (widget.area!.description ?? ''))) {
          success = await provider.updateArea(
            id: widget.area!.id,
            name: name,
            description: description.isNotEmpty ? description : null,
          );
        }
      } else {
        // Just update area details (name, description, deliveryBoyId)
        success = await provider.updateArea(
          id: widget.area!.id,
          name: name,
          description: description.isNotEmpty ? description : null,
          deliveryBoyId: _selectedDeliveryBoyId,
        );
      }
    }

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.area == null
                  ? 'Area added successfully'
                  : 'Area updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        // Show error dialog with retry option for network errors
        final error = provider.error ?? 'Failed to save area';
        final isNetworkError = error.contains('Connection') ||
                              error.contains('Network') ||
                              error.contains('timeout');

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: !isNetworkError, // Allow dismiss if not network error
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(error),
              actions: [
                if (!isNetworkError)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                if (isNetworkError) ...[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitForm(); // Retry
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ],
            ),
          );
        }
      }
    }
  }
}
