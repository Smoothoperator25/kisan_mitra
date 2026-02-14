import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'fertilizer_controller.dart';
import 'fertilizer_model.dart';

class EditFertilizerScreen extends StatefulWidget {
  final Fertilizer fertilizer;
  final bool isNewFertilizer;

  const EditFertilizerScreen({
    super.key,
    required this.fertilizer,
    required this.isNewFertilizer,
  });

  @override
  State<EditFertilizerScreen> createState() => _EditFertilizerScreenState();
}

class _EditFertilizerScreenState extends State<EditFertilizerScreen> {
  final FertilizerController _controller = FertilizerController();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _npkController;
  late TextEditingController _cropsController;
  late TextEditingController _dosageController;
  late TextEditingController _safetyNotesController;
  late TextEditingController _descriptionController;
  late TextEditingController _manufacturerController;
  late TextEditingController _shelfLifeController;
  late TextEditingController _storageController;
  late TextEditingController _benefitsController;
  late TextEditingController _timingController;
  late TextEditingController _precautionsController;
  late TextEditingController _priceController;

  // State
  late String _applicationMethod;
  late String _dosageUnit;
  late String _category;
  late String _form;
  late String _imageUrl;
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fertilizer.name);
    _npkController = TextEditingController(
      text: widget.fertilizer.npkComposition,
    );
    _cropsController = TextEditingController(
      text: widget.fertilizer.suitableCrops,
    );
    _dosageController = TextEditingController(
      text: widget.fertilizer.recommendedDosage > 0
          ? widget.fertilizer.recommendedDosage.toStringAsFixed(0)
          : '',
    );
    _safetyNotesController = TextEditingController(
      text: widget.fertilizer.safetyNotes,
    );
    _descriptionController = TextEditingController(
      text: widget.fertilizer.description,
    );
    _manufacturerController = TextEditingController(
      text: widget.fertilizer.manufacturer,
    );
    _shelfLifeController = TextEditingController(
      text: widget.fertilizer.shelfLife,
    );
    _storageController = TextEditingController(
      text: widget.fertilizer.storageInstructions,
    );
    _benefitsController = TextEditingController(
      text: widget.fertilizer.benefits,
    );
    _timingController = TextEditingController(
      text: widget.fertilizer.applicationTiming,
    );
    _precautionsController = TextEditingController(
      text: widget.fertilizer.precautions,
    );
    _priceController = TextEditingController(
      text: widget.fertilizer.pricePerUnit != null
          ? widget.fertilizer.pricePerUnit!.toStringAsFixed(2)
          : '',
    );
    _applicationMethod = widget.fertilizer.applicationMethod;
    _dosageUnit = widget.fertilizer.dosageUnit;
    _category = widget.fertilizer.category;
    _form = widget.fertilizer.form;
    _imageUrl = widget.fertilizer.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _npkController.dispose();
    _cropsController.dispose();
    _dosageController.dispose();
    _safetyNotesController.dispose();
    _descriptionController.dispose();
    _manufacturerController.dispose();
    _shelfLifeController.dispose();
    _storageController.dispose();
    _benefitsController.dispose();
    _timingController.dispose();
    _precautionsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _controller.pickImage();
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: $e');
    }
  }

  Future<void> _saveFertilizer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final fertilizer = Fertilizer(
        id: widget.fertilizer.id,
        name: _nameController.text.trim(),
        imageUrl: _imageUrl,
        npkComposition: _npkController.text.trim(),
        applicationMethod: _applicationMethod,
        suitableCrops: _cropsController.text.trim(),
        recommendedDosage: double.tryParse(_dosageController.text.trim()) ?? 0,
        dosageUnit: _dosageUnit,
        safetyNotes: _safetyNotesController.text.trim(),
        description: _descriptionController.text.trim(),
        manufacturer: _manufacturerController.text.trim(),
        category: _category,
        form: _form,
        shelfLife: _shelfLifeController.text.trim(),
        storageInstructions: _storageController.text.trim(),
        benefits: _benefitsController.text.trim(),
        applicationTiming: _timingController.text.trim(),
        precautions: _precautionsController.text.trim(),
        pricePerUnit: double.tryParse(_priceController.text.trim()),
        isArchived: false,
        createdAt: widget.fertilizer.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.isNewFertilizer) {
        await _controller.createFertilizer(
          fertilizer,
          imageFile: _selectedImage,
        );
        _showSuccessSnackbar('Fertilizer created successfully');
      } else {
        await _controller.updateFertilizer(
          widget.fertilizer.id,
          fertilizer,
          imageFile: _selectedImage,
        );
        _showSuccessSnackbar('Fertilizer updated successfully');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _archiveFertilizer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Fertilizer'),
        content: const Text(
          'Are you sure you want to archive this fertilizer record? It will be hidden from the list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'ARCHIVE',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _controller.archiveFertilizer(widget.fertilizer.id);
        _showSuccessSnackbar('Fertilizer archived successfully');
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        _showErrorSnackbar('Failed to archive: $e');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isNewFertilizer ? 'Add Fertilizer' : 'Edit Fertilizer',
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveFertilizer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'SAVE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildBasicInformationSection(),
              const SizedBox(height: 24),
              _buildUsageDosageSection(),
              const SizedBox(height: 24),
              _buildPrecautionsSafetySection(),
              if (!widget.isNewFertilizer) ...[
                const SizedBox(height: 24),
                _buildArchiveButton(),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            children: [
              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : _imageUrl.isNotEmpty
                    ? Image.network(
                        _imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
              // Edit icon overlay
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Text(
              'CHANGE PRODUCT IMAGE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.image, size: 64, color: Color(0xFF94A3B8)),
    );
  }

  Widget _buildBasicInformationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BASIC INFORMATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'FERTILIZER NAME',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Fertilizer name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'NPK COMPOSITION',
                  controller: _npkController,
                  hint: 'e.g., 46-0-0',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'NPK composition is required';
                    }
                    final pattern = RegExp(r'^\d+-\d+-\d+$');
                    if (!pattern.hasMatch(value.trim())) {
                      return 'Invalid format. Use "46-0-0"';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APPLICATION METHOD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _applicationMethod,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: ApplicationMethod.all.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(
                            method,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _applicationMethod = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'DESCRIPTION',
            controller: _descriptionController,
            hint: 'Detailed description of the fertilizer',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'MANUFACTURER/BRAND',
                  controller: _manufacturerController,
                  hint: 'e.g., IFFCO, Coromandel',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'PRICE PER UNIT (₹)',
                  controller: _priceController,
                  hint: 'Optional',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _category,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: FertilizerCategory.all.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _category = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FORM/STATE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _form,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: FertilizerForm.all.map((form) {
                        return DropdownMenuItem(
                          value: form,
                          child: Text(
                            form,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _form = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageDosageSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'USAGE & DOSAGE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'SUITABLE CROPS',
            controller: _cropsController,
            hint: 'Rice, Wheat, Corn, Cotton, Sugarcane',
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Suitable crops are required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'RECOMMENDED DOSAGE',
                  controller: _dosageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Dosage is required';
                    }
                    final dosage = double.tryParse(value.trim());
                    if (dosage == null || dosage <= 0) {
                      return 'Must be greater than 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _buildUnitButton('KG/ACRE', DosageUnit.kgPerAcre),
                        _buildUnitButton('G/SQM', DosageUnit.gPerSqm),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'KEY BENEFITS',
            controller: _benefitsController,
            hint:
                'e.g., Promotes rapid growth, Increases yield, Improves soil health',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'APPLICATION TIMING',
                  controller: _timingController,
                  hint: 'e.g., Pre-sowing, Vegetative stage',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'SHELF LIFE',
                  controller: _shelfLifeController,
                  hint: 'e.g., 2 years, 24 months',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String label, String unit) {
    final isSelected = _dosageUnit == unit;
    return GestureDetector(
      onTap: () {
        setState(() {
          _dosageUnit = unit;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildPrecautionsSafetySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'STORAGE & SAFETY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'STORAGE INSTRUCTIONS',
            controller: _storageController,
            hint:
                'e.g., Store in cool, dry place. Keep away from direct sunlight.',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'SAFETY PRECAUTIONS',
            controller: _precautionsController,
            hint:
                'e.g., Keep away from children, Do not mix with other chemicals',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'DETAILED SAFETY NOTES',
            controller: _safetyNotesController,
            hint:
                '1. Avoid direct contact with skin and eyes.\n2. Use gloves and protective mask during application.\n3. Wash hands thoroughly after handling.',
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF10B981)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArchiveButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _archiveFertilizer,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Archive Fertilizer Record',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
