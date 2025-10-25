import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/delivery_boy_provider.dart';

class DeliveryBoyFormScreen extends StatefulWidget {
  final User? deliveryBoy;

  const DeliveryBoyFormScreen({super.key, this.deliveryBoy});

  @override
  State<DeliveryBoyFormScreen> createState() => _DeliveryBoyFormScreenState();
}

class _DeliveryBoyFormScreenState extends State<DeliveryBoyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.deliveryBoy != null) {
      _nameController.text = widget.deliveryBoy!.name ?? '';
      _phoneController.text = widget.deliveryBoy!.phone;
      _emailController.text = widget.deliveryBoy!.email ?? '';
      _addressController.text = widget.deliveryBoy!.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deliveryBoy == null
            ? 'Add Delivery Boy'
            : 'Edit Delivery Boy'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: '+919876543210',
              ),
              keyboardType: TextInputType.phone,
              enabled: widget.deliveryBoy == null, // Can't change phone
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                // Basic phone validation
                if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
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
                      widget.deliveryBoy == null
                          ? 'Add Delivery Boy'
                          : 'Update Delivery Boy',
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

    final provider = context.read<DeliveryBoyProvider>();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email =
        _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null;
    final address = _addressController.text.trim().isNotEmpty
        ? _addressController.text.trim()
        : null;

    bool success;
    if (widget.deliveryBoy == null) {
      success = await provider.createDeliveryBoy(
        name: name,
        phone: phone,
        email: email,
        address: address,
      );
    } else {
      success = await provider.updateDeliveryBoy(
        id: widget.deliveryBoy!.id,
        name: name,
        email: email,
        address: address,
      );
    }

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.deliveryBoy == null
                  ? 'Delivery boy added successfully'
                  : 'Delivery boy updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error: ${provider.error ?? 'Failed to save delivery boy'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
