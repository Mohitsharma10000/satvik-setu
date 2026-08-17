import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'registration_providers.dart';
import '../home/home_providers.dart';
import '../categories/subcategory_providers.dart';
import '../../models/application_model.dart';
import '../../services/location_service.dart';
import '../../services/camera_service.dart';
import '../../utils/validators.dart';

extension ApplicationModelCopy on ApplicationModel {
  ApplicationModel copyWith({
    String? profileImage,
    String? aadhaarFront,
    String? aadhaarBack,
  }) {
    return ApplicationModel(
      applicationId: applicationId,
      name: name,
      phone: phone,
      email: email,
      gender: gender,
      dob: dob,
      address: address,
      state: state,
      city: city,
      pincode: pincode,
      category: category,
      subcategory: subcategory,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      experience: experience,
      description: description,
      profileImage: profileImage ?? this.profileImage,
      aadhaarFront: aadhaarFront ?? this.aadhaarFront,
      aadhaarBack: aadhaarBack ?? this.aadhaarBack,
      verificationStatus: verificationStatus,
      submittedAt: submittedAt,
      latitude: latitude,
      longitude: longitude,
      serviceRate: serviceRate,
      rateDescription: rateDescription,
    );
  }
}

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  int _currentStep = 0;
  
  // Forms & Controllers
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>()];
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _expController = TextEditingController();
  final _descController = TextEditingController();
  final _serviceRateController = TextEditingController();
  final _rateDescController = TextEditingController();
  
  String _selectedGender = 'Male';
  DateTime _selectedDob = DateTime.now().subtract(const Duration(days: 365 * 18));
  
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedSubcategoryId;
  String? _selectedSubcategoryName;
  
  double? _capturedLat;
  double? _capturedLng;
  bool _isCapturingLocation = false;
  
  File? _selfie;
  File? _aadhaarFront;
  File? _aadhaarBack;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _expController.dispose();
    _descController.dispose();
    _serviceRateController.dispose();
    _rateDescController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() => _isCapturingLocation = true);
    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();
      setState(() {
        _capturedLat = position.latitude;
        _capturedLng = position.longitude;
        _isCapturingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Location Captured Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isCapturingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submit() async {
    final application = ApplicationModel(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      gender: _selectedGender,
      dob: _selectedDob,
      address: _addressController.text.trim(),
      state: _stateController.text.trim(),
      city: _cityController.text.trim(),
      pincode: _pincodeController.text.trim(),
      categoryId: _selectedCategoryId!,
      category: _selectedCategoryName!,
      subcategoryId: _selectedSubcategoryId!,
      subcategory: _selectedSubcategoryName!,
      experience: int.tryParse(_expController.text) ?? 0,
      description: _descController.text.trim(),
      profileImage: '',
      aadhaarFront: '',
      aadhaarBack: '',
      latitude: _capturedLat,
      longitude: _capturedLng,
      serviceRate: double.tryParse(_serviceRateController.text.trim()),
      rateDescription: _rateDescController.text.trim(),
    );
    
    final success = await ref.read(registrationProvider.notifier).submitRegistration(
      application, _selfie, _aadhaarFront, _aadhaarBack
    );
    
    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Application Submitted'),
          content: const Text('Your registration has been submitted successfully. We will verify your details and activate your profile soon.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(registrationProvider).error ?? 'Submission failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final regState = ref.watch(registrationProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Provider')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (!_formKeys[0].currentState!.validate()) return;
            if (_capturedLat == null || _capturedLng == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📍 Mandatory: Please tap "Capture My GPS Location" before proceeding!'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            setState(() => _currentStep += 1);
          } else if (_currentStep == 1) {
            if (_formKeys[1].currentState!.validate() && _selectedSubcategoryId != null) {
              setState(() => _currentStep += 1);
            } else if (_selectedSubcategoryId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select category and subcategory')),
              );
            }
          } else if (_currentStep == 2) {
            if (_selfie != null) {
              setState(() => _currentStep += 1);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please capture a selfie')),
              );
            }
          } else if (_currentStep == 3) {
            if (_aadhaarFront != null && _aadhaarFront!.existsSync() && _aadhaarFront!.path.isNotEmpty &&
                _aadhaarBack != null && _aadhaarBack!.existsSync() && _aadhaarBack!.path.isNotEmpty) {
              setState(() => _currentStep += 1);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please upload both sides of Aadhaar')),
              );
            }
          } else if (_currentStep == 4) {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          if (regState.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_currentStep == 4 ? 'Submit Application' : 'Continue'),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ),
                ]
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Personal Details & Location'),
            isActive: _currentStep >= 0,
            content: Form(
              key: _formKeys[0],
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', prefixText: '+91 '),
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email (Optional)'),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setState(() => _selectedGender = val!),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Date of Birth'),
                    subtitle: Text('${_selectedDob.toLocal()}'.split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDob,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                      );
                      if (date != null) setState(() => _selectedDob = date);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (v) => Validators.validateRequired(v, 'Address'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'City'), validator: (v) => Validators.validateRequired(v, 'City'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _stateController, decoration: const InputDecoration(labelText: 'State'), validator: (v) => Validators.validateRequired(v, 'State'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pincodeController,
                    decoration: const InputDecoration(labelText: 'PIN Code'),
                    keyboardType: TextInputType.number,
                    validator: Validators.validatePinCode,
                  ),
                  const SizedBox(height: 16),
                  
                  // Mandatory Location Capture Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _capturedLat != null ? Colors.green.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _capturedLat != null ? Colors.green : Colors.blue.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              _capturedLat != null ? Icons.check_circle : Icons.my_location,
                              color: _capturedLat != null ? Colors.green : Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _capturedLat != null
                                    ? 'GPS Location Captured ✅'
                                    : 'GPS Location (Mandatory for 5-7km reach)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _capturedLat != null ? Colors.green.shade900 : Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_capturedLat != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${_capturedLat!.toStringAsFixed(4)}, Lng: ${_capturedLng!.toStringAsFixed(4)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isCapturingLocation ? null : _captureLocation,
                            icon: _isCapturingLocation
                                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.gps_fixed),
                            label: Text(_capturedLat != null ? 'Recapture Location' : 'Capture My GPS Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _capturedLat != null ? Colors.green : Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Professional Details & Service Charge'),
            isActive: _currentStep >= 1,
            content: Form(
              key: _formKeys[1],
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final categoriesAsync = ref.watch(categoriesProvider);
                      return categoriesAsync.when(
                        data: (categories) => DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategoryId = val;
                              _selectedCategoryName = categories.firstWhere((c) => c.id == val).name;
                              _selectedSubcategoryId = null;
                            });
                          },
                          validator: (v) => v == null ? 'Please select category' : null,
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading categories'),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_selectedCategoryId != null)
                    Consumer(
                      builder: (context, ref, child) {
                        final subAsync = ref.watch(subcategoriesProvider(_selectedCategoryId!));
                        return subAsync.when(
                          data: (subs) => DropdownButtonFormField<String>(
                            value: _selectedSubcategoryId,
                            decoration: const InputDecoration(labelText: 'Subcategory'),
                            items: subs.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedSubcategoryId = val;
                                _selectedSubcategoryName = subs.firstWhere((s) => s.id == val).name;
                              });
                            },
                            validator: (v) => v == null ? 'Please select subcategory' : null,
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Error loading subcategories'),
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _expController,
                    decoration: const InputDecoration(labelText: 'Years of Experience'),
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.validateRequired(v, 'Experience'),
                  ),
                  const SizedBox(height: 12),
                  
                  // SINGLE Mandatory Service Charge Field
                  TextFormField(
                    controller: _serviceRateController,
                    decoration: const InputDecoration(
                      labelText: 'Service Charge / Rate (₹)',
                      prefixText: '₹ ',
                      hintText: 'e.g. 300',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.validateRequired(v, 'Service Charge'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _rateDescController,
                    decoration: const InputDecoration(
                      labelText: 'Rate Details / Note (Optional)',
                      hintText: 'e.g. ₹300 basic visit, parts extra',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Short Description of Service'),
                    maxLines: 3,
                    validator: (v) => Validators.validateRequired(v, 'Description'),
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Live Selfie'),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                if (_selfie != null)
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: FileImage(_selfie!), fit: BoxFit.cover),
                    ),
                  )
                else
                  const Icon(Icons.account_circle, size: 100, color: Colors.grey),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final file = await ref.read(cameraServiceProvider).captureSelfie();
                    if (file != null) setState(() => _selfie = file);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_selfie == null ? 'Take Selfie' : 'Retake Selfie'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Aadhaar Verification'),
            isActive: _currentStep >= 3,
            content: Column(
              children: [
                _buildImagePicker('Aadhaar Front', _aadhaarFront, (f) => setState(() => _aadhaarFront = f), () => setState(() => _aadhaarFront = null)),
                const SizedBox(height: 16),
                _buildImagePicker('Aadhaar Back', _aadhaarBack, (f) => setState(() => _aadhaarBack = f), () => setState(() => _aadhaarBack = null)),
              ],
            ),
          ),
          Step(
            title: const Text('Review & Submit'),
            isActive: _currentStep >= 4,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please review your details before submitting:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Name: ${_nameController.text}'),
                Text('Phone: ${_phoneController.text}'),
                Text('Category: $_selectedCategoryName - $_selectedSubcategoryName'),
                Text('Experience: ${_expController.text} years'),
                Text('Service Charge: ₹${_serviceRateController.text}'),
                Text('Location Captured: ${_capturedLat != null ? "Yes ✅" : "No ❌"}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String label, File? file, Function(File) onPicked, VoidCallback onClear) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (file != null && file.path.isNotEmpty && file.existsSync())
          Stack(
            children: [
              Image.file(file, height: 150, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                right: 8, top: 8,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: onClear,
                ),
              )
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final f = await ref.read(cameraServiceProvider).pickImage(fromCamera: true);
                    if (f != null) onPicked(f);
                  },
                  icon: const Icon(Icons.camera),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final f = await ref.read(cameraServiceProvider).pickImage(fromCamera: false);
                    if (f != null) onPicked(f);
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
