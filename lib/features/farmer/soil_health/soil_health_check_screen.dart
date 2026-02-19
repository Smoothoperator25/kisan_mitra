import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// ── Futuristic Soil Health Check Screen ──────────────────────────────
/// Multi-step wizard with glassmorphism, animated progress, 13+ fields,
/// and a review/summary page before final submission.
class SoilHealthCheckScreen extends StatefulWidget {
  const SoilHealthCheckScreen({super.key});

  @override
  State<SoilHealthCheckScreen> createState() => _SoilHealthCheckScreenState();
}

class _SoilHealthCheckScreenState extends State<SoilHealthCheckScreen>
    with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────────────
  final PageController _pageController = PageController();
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  late AnimationController _progressAnim;

  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  // ── Step 1: Farmer Info ─────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pinCodeCtrl = TextEditingController();

  // ── Step 2: Soil Details ────────────────────────────────────────────
  final _farmAreaCtrl = TextEditingController();
  final _prevCropCtrl = TextEditingController();
  String? _selectedSoilType;
  String? _selectedWaterSource;
  String? _selectedIrrigation;
  DateTime? _selectedDate;
  String? _gpsLocation;

  // ── Step 3: Notes ───────────────────────────────────────────────────
  final _notesCtrl = TextEditingController();

  // ── Dropdown data ───────────────────────────────────────────────────
  static const _soilTypes = [
    'Alluvial',
    'Black (Regur)',
    'Red',
    'Laterite',
    'Sandy',
    'Loamy',
    'Clay',
    'Saline',
    'Peaty',
    'Arid (Desert)',
  ];
  static const _waterSources = [
    'Borewell',
    'Canal',
    'Rain-fed',
    'River',
    'Tank / Pond',
    'Other',
  ];
  static const _irrigationTypes = [
    'Drip',
    'Sprinkler',
    'Flood / Surface',
    'Furrow',
    'None (Rain-fed)',
  ];

  // ── Theme constants ─────────────────────────────────────────────────
  static const _gradStart = Color(0xFF0D4F2B);
  static const _gradEnd = Color(0xFF0A8967);
  static const _accentCyan = Color(0xFF00E5FF);
  static const _cardBg = Color(0xFF112D1B);
  static const _fieldBorder = Color(0xFF1E6E45);
  static const _fieldFill = Color(0xFF0C3D22);

  @override
  void initState() {
    super.initState();
    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnim.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _pinCodeCtrl.dispose();
    _farmAreaCtrl.dispose();
    _prevCropCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────
  void _nextStep() {
    if (_currentStep == 0 && !_step1Key.currentState!.validate()) return;
    if (_currentStep == 1 && !_step2Key.currentState!.validate()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _progressAnim.forward(from: 0);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _progressAnim.forward(from: 0);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });
  }

  void _presentDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _accentCyan,
              onPrimary: Colors.black,
              surface: _cardBg,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _captureGPS() {
    // Simulate GPS capture
    setState(() => _gpsLocation = '19.0760° N, 72.8777° E');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.gps_fixed, color: _accentCyan, size: 18),
            SizedBox(width: 8),
            Text('GPS Location captured!'),
          ],
        ),
        backgroundColor: _cardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: const Color(0xFF071A0E),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Soil Health Check',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Gradient header with progress ──
          _buildHeader(),

          // ── Page content ──
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),

          // ── Bottom navigation ──
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  HEADER + PROGRESS
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    final labels = ['Farmer Info', 'Soil Details', 'Review'];
    final icons = [Icons.person_outline, Icons.landscape, Icons.checklist_rtl];

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 56,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradStart, _gradEnd],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Step indicators — flat: circle ─ line ─ circle ─ line ─ circle
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 2.5,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _currentStep
                            ? const Color(0xCC00E5FF)
                            : const Color(0x26FFFFFF),
                      ),
                    ),
                  ),
                _buildStepCircle(i, icons[i]),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final active = i <= _currentStep;
              return Text(
                labels[i],
                style: TextStyle(
                  color: active ? Colors.white : Colors.white38,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Individual step circle widget
  Widget _buildStepCircle(int i, IconData icon) {
    final active = i <= _currentStep;
    final current = i == _currentStep;
    return AnimatedScale(
      scale: current ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? const Color(0x3300E5FF) : const Color(0x14FFFFFF),
          border: Border.all(
            color: active ? _accentCyan : const Color(0x33FFFFFF),
            width: current ? 2.5 : 1.5,
          ),
          boxShadow: current
              ? [BoxShadow(color: const Color(0x4D00E5FF), blurRadius: 12)]
              : [],
        ),
        child: Icon(
          i < _currentStep ? Icons.check : icon,
          color: active ? _accentCyan : Colors.white38,
          size: 20,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  STEP 1 – FARMER INFO
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Personal Information', Icons.badge_outlined),
            const SizedBox(height: 16),
            _glassCard(
              child: Column(
                children: [
                  _styledTextField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _styledTextField(
                    controller: _phoneCtrl,
                    label: 'Phone Number',
                    hint: '10-digit mobile number',
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Phone is required';
                      if (v.length != 10) return 'Enter 10-digit number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _styledTextField(
                    controller: _addressCtrl,
                    label: 'Village / Address',
                    hint: 'Village, Taluka, District',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _styledTextField(
                    controller: _pinCodeCtrl,
                    label: 'Pin Code',
                    hint: '6-digit pin code',
                    icon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Pin code is required';
                      if (v.length != 6) return 'Enter 6-digit pin code';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  STEP 2 – SOIL DETAILS
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Farm & Soil Details', Icons.eco_outlined),
            const SizedBox(height: 16),
            _glassCard(
              child: Column(
                children: [
                  // ── Farm Area ──
                  _styledTextField(
                    controller: _farmAreaCtrl,
                    label: 'Farm Area (Acres)',
                    hint: 'e.g. 2.5',
                    icon: Icons.square_foot,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Farm area required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Soil Type ──
                  _styledDropdown<String>(
                    label: 'Soil Type',
                    icon: Icons.layers_outlined,
                    value: _selectedSoilType,
                    items: _soilTypes
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSoilType = v),
                    validator: (v) => v == null ? 'Select soil type' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Previous Crop ──
                  _styledTextField(
                    controller: _prevCropCtrl,
                    label: 'Previous Crop Grown',
                    hint: 'e.g. Wheat, Soybean',
                    icon: Icons.grass,
                  ),
                  const SizedBox(height: 16),

                  // ── Water Source ──
                  _styledDropdown<String>(
                    label: 'Water Source',
                    icon: Icons.water_drop_outlined,
                    value: _selectedWaterSource,
                    items: _waterSources
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedWaterSource = v),
                    validator: (v) => v == null ? 'Select water source' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Irrigation Type ──
                  _styledDropdown<String>(
                    label: 'Irrigation Type',
                    icon: Icons.opacity,
                    value: _selectedIrrigation,
                    items: _irrigationTypes
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedIrrigation = v),
                    validator: (v) =>
                        v == null ? 'Select irrigation type' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('Collection & Location', Icons.calendar_month),
            const SizedBox(height: 16),
            _glassCard(
              child: Column(
                children: [
                  // ── Date Picker ──
                  InkWell(
                    onTap: _presentDatePicker,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: _inputDecoration(
                        'Sample Collection Date',
                        Icons.calendar_today,
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Choose a date'
                            : DateFormat('dd MMM yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.white38
                              : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  if (_selectedDate == null)
                    const Padding(
                      padding: EdgeInsets.only(left: 12, top: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(''),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── GPS Capture ──
                  InkWell(
                    onTap: _captureGPS,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: _fieldFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _gpsLocation != null
                              ? _accentCyan.withOpacity(0.5)
                              : _fieldBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.gps_fixed,
                            color: _gpsLocation != null
                                ? _accentCyan
                                : Colors.white38,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GPS Location',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _gpsLocation ?? 'Tap to capture location',
                                  style: TextStyle(
                                    color: _gpsLocation != null
                                        ? _accentCyan
                                        : Colors.white38,
                                    fontSize: 14,
                                    fontWeight: _gpsLocation != null
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _gpsLocation != null
                                ? Icons.check_circle
                                : Icons.my_location,
                            color: _gpsLocation != null
                                ? _accentCyan
                                : Colors.white24,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  STEP 3 – REVIEW & CONFIRM
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Review Your Details', Icons.fact_check_outlined),
          const SizedBox(height: 16),

          // ── Farmer Info Card ──
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewCardHeader('Farmer Information', Icons.person),
                const SizedBox(height: 12),
                _reviewRow('Name', _nameCtrl.text),
                _reviewRow('Phone', _phoneCtrl.text),
                _reviewRow('Address', _addressCtrl.text),
                _reviewRow('Pin Code', _pinCodeCtrl.text),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Soil Details Card ──
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewCardHeader('Soil & Farm Details', Icons.landscape),
                const SizedBox(height: 12),
                _reviewRow('Farm Area', '${_farmAreaCtrl.text} Acres'),
                _reviewRow('Soil Type', _selectedSoilType ?? '—'),
                _reviewRow(
                  'Previous Crop',
                  _prevCropCtrl.text.isEmpty ? '—' : _prevCropCtrl.text,
                ),
                _reviewRow('Water Source', _selectedWaterSource ?? '—'),
                _reviewRow('Irrigation', _selectedIrrigation ?? '—'),
                _reviewRow(
                  'Collection Date',
                  _selectedDate == null
                      ? '—'
                      : DateFormat('dd MMM yyyy').format(_selectedDate!),
                ),
                _reviewRow('GPS Location', _gpsLocation ?? 'Not captured'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Notes ──
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewCardHeader('Additional Notes', Icons.note_alt_outlined),
                const SizedBox(height: 12),
                _styledTextField(
                  controller: _notesCtrl,
                  label: 'Notes / Special Requests',
                  hint: 'Any specific tests or concerns...',
                  icon: Icons.edit_note,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  SUCCESS SCREEN
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF071A0E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (_, v, __) => Transform.scale(
                    scale: v,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [_gradEnd, _accentCyan],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _accentCyan.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your soil health check has been scheduled.\nWe will contact you at ${_phoneCtrl.text}\nfor sample collection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _accentCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accentCyan.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: _accentCyan,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(_selectedDate!),
                          style: const TextStyle(
                            color: _accentCyan,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gradEnd,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  BOTTOM BAR
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildBottomBar() {
    final isLast = _currentStep == 2;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF071A0E),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _prevStep,
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : (isLast ? _submit : _nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast ? _accentCyan : _gradEnd,
                  foregroundColor: isLast ? Colors.black : Colors.white,
                  disabledBackgroundColor: _gradEnd.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast ? 'Submit' : 'Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isLast
                                  ? Icons.check_circle_outline
                                  : Icons.arrow_forward_ios,
                              size: isLast ? 20 : 14,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  REUSABLE WIDGETS
  // ══════════════════════════════════════════════════════════════════════

  /// Section title with icon
  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _accentCyan, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Glassmorphism card
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Input decoration helper
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
      prefixIcon: Icon(icon, color: _accentCyan.withOpacity(0.7), size: 20),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accentCyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
      ),
      errorStyle: TextStyle(color: Colors.red.shade300, fontSize: 12),
    );
  }

  /// Styled text field
  Widget _styledTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: _accentCyan,
      decoration: _inputDecoration(label, icon).copyWith(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
      ),
    );
  }

  /// Styled dropdown
  Widget _styledDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      dropdownColor: _cardBg,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: _accentCyan.withOpacity(0.6),
      ),
      decoration: _inputDecoration(label, icon),
    );
  }

  /// Review card header
  Widget _reviewCardHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _accentCyan.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _accentCyan, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Review row (label + value)
  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
