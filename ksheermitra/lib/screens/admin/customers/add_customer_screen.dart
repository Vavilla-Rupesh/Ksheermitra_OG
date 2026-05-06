import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/customer_provider.dart';
import '../../common/location_picker_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
   final _formKey = GlobalKey<FormState>();
   final _nameController = TextEditingController();
   final _phoneController = TextEditingController();
   final _emailController = TextEditingController();
   final _addressController = TextEditingController();
   bool _isLoading = false;
   double? _latitude;
   double? _longitude;
   bool _isLoadingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

   Future<void> _createCustomer() async {
     if (!_formKey.currentState!.validate()) return;

     setState(() => _isLoading = true);

     try {
       await context.read<CustomerProvider>().createCustomer(
             name: _nameController.text.trim(),
             phone: _phoneController.text.trim(),
             email: _emailController.text.trim().isEmpty
                 ? null
                 : _emailController.text.trim(),
             address: _addressController.text.trim().isEmpty
                 ? null
                 : _addressController.text.trim(),
             latitude: _latitude,
             longitude: _longitude,
           );

       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Customer added successfully!'),
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

   Future<void> _getCurrentLocation() async {
     setState(() {
       _isLoadingLocation = true;
     });

     try {
       // Check location permission
       LocationPermission permission = await Geolocator.checkPermission();
       if (permission == LocationPermission.denied) {
         permission = await Geolocator.requestPermission();
         if (permission == LocationPermission.denied) {
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Location permission denied')),
             );
           }
           setState(() {
             _isLoadingLocation = false;
           });
           return;
         }
       }

       if (permission == LocationPermission.deniedForever) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Location permission permanently denied. Please enable in settings.'),
             ),
           );
         }
         setState(() {
           _isLoadingLocation = false;
         });
         return;
       }

       // Get current position
       Position position = await Geolocator.getCurrentPosition(
         desiredAccuracy: LocationAccuracy.high,
       );

       _latitude = position.latitude;
       _longitude = position.longitude;

       // Get address from coordinates
       try {
         List<Placemark> placemarks = await placemarkFromCoordinates(
           position.latitude,
           position.longitude,
         );

         if (placemarks.isNotEmpty) {
           Placemark place = placemarks[0];
           String address = '';

           if (place.street != null && place.street!.isNotEmpty) {
             address += '${place.street}, ';
           }
           if (place.subLocality != null && place.subLocality!.isNotEmpty) {
             address += '${place.subLocality}, ';
           }
           if (place.locality != null && place.locality!.isNotEmpty) {
             address += '${place.locality}, ';
           }
           if (place.postalCode != null && place.postalCode!.isNotEmpty) {
             address += '${place.postalCode}';
           }

           setState(() {
             _addressController.text = address;
           });
         }
       } catch (e) {
         print('Error getting address: $e');
       }

       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Location fetched successfully')),
         );
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error getting location: $e')),
         );
       }
     } finally {
       setState(() {
         _isLoadingLocation = false;
       });
     }
   }

   Future<void> _openLocationPicker() async {
     final result = await Navigator.of(context).push<LocationResult>(
       MaterialPageRoute(
         builder: (context) => LocationPickerScreen(
           initialLatitude: _latitude,
           initialLongitude: _longitude,
           initialAddress: _addressController.text,
         ),
       ),
     );

     if (result != null) {
       setState(() {
         _latitude = result.latitude;
         _longitude = result.longitude;
         _addressController.text = result.address;
       });
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Location selected successfully')),
         );
       }
     }
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name *',
                          prefixIcon: Icon(Icons.person),
                          hintText: 'Enter full name',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
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
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'e.g. 9876543210',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          final phone = value.trim();
                          if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone)) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email (Optional)',
                          prefixIcon: Icon(Icons.email),
                          hintText: 'customer@example.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

               // Address
               Card(
                 child: Padding(
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text(
                         'Address (Optional)',
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                       const SizedBox(height: 16),
                       TextFormField(
                         controller: _addressController,
                         decoration: const InputDecoration(
                           labelText: 'Address',
                           prefixIcon: Icon(Icons.location_on),
                           hintText: 'Enter full address',
                         ),
                         maxLines: 3,
                       ),
                       const SizedBox(height: 16),
                       // Location buttons
                       Row(
                         children: [
                           Expanded(
                             child: OutlinedButton.icon(
                               onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                               icon: _isLoadingLocation
                                   ? const SizedBox(
                                       width: 16,
                                       height: 16,
                                       child: CircularProgressIndicator(
                                         strokeWidth: 2,
                                       ),
                                     )
                                   : const Icon(Icons.my_location),
                               label: const Text('Current Location'),
                               style: OutlinedButton.styleFrom(
                                 padding: const EdgeInsets.symmetric(vertical: 12),
                               ),
                             ),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             child: OutlinedButton.icon(
                               onPressed: _openLocationPicker,
                               icon: const Icon(Icons.map),
                               label: const Text('Choose on Map'),
                               style: OutlinedButton.styleFrom(
                                 padding: const EdgeInsets.symmetric(vertical: 12),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                 ),
               ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCustomer,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add Customer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

