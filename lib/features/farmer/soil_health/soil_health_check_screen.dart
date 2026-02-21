import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kisan_mitra/l10n/app_localizations.dart';

/// ── Futuristic Soil Health Check Screen (Light Theme) ────────────────
/// Multi-step wizard with glassmorphism, animated progress, 13+ fields,
/// and a review/summary page before final submission.
class SoilHealthCheckScreen extends StatefulWidget {
  const SoilHealthCheckScreen({super.key});

  @override
  State<SoilHealthCheckScreen> createState() => _SoilHealthCheckScreenState();
}

class _SoilHealthCheckScreenState extends State<SoilHealthCheckScreen>
    with SingleTickerProviderStateMixin {
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

  // ── Light-theme constants ───────────────────────────────────────────
  static const _gradStart = Color(0xFF2E7D32);
  static const _gradEnd = Color(0xFF43A047);
  static const _accent = Color(0xFF2E7D32);
  static const _accentLight = Color(0xFFE8F5E9);
  static const _scaffoldBg = Color(0xFFF6F8F6);
  static const _cardBg = Colors.white;
  static const _fieldBorder = Color(0xFFD6E4D9);
  static const _fieldFill = Color(0xFFF0F5F1);
  static const _textPrimary = Color(0xFF212121);
  static const _textSecondary = Color(0xFF757575);
  static const _textHint = Color(0xFFB0BEC5);

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
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _accent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _captureGPS() {
    setState(() => _gpsLocation = '19.0760° N, 72.8777° E');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.gps_fixed, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).gpsLocationCaptured),
          ],
        ),
        backgroundColor: _accent,
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
      backgroundColor: _scaffoldBg,
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
        title: Text(
          AppLocalizations.of(context).soilHealthCheck,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  HEADER + PROGRESS
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    final labels = [
      AppLocalizations.of(context).farmerInfo,
      AppLocalizations.of(context).soilDetails,
      AppLocalizations.of(context).review,
    ];
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
                            ? const Color(0xCCFFFFFF)
                            : const Color(0x40FFFFFF),
                      ),
                    ),
                  ),
                _buildStepCircle(i, icons[i]),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final active = i <= _currentStep;
              return Text(
                labels[i],
                style: TextStyle(
                  color: active ? Colors.white : const Color(0x80FFFFFF),
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
          color: active ? const Color(0x40FFFFFF) : const Color(0x1AFFFFFF),
          border: Border.all(
            color: active ? Colors.white : const Color(0x40FFFFFF),
            width: current ? 2.5 : 1.5,
          ),
          boxShadow: current
              ? [BoxShadow(color: const Color(0x40FFFFFF), blurRadius: 12)]
              : [],
        ),
        child: Icon(
          i < _currentStep ? Icons.check : icon,
          color: active ? Colors.white : const Color(0x80FFFFFF),
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
            _sectionTitle(
              AppLocalizations.of(context).personalInformation,
              Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            _card(
              child: Column(
                children: [
                  _styledTextField(
                    controller: _nameCtrl,
                    label: AppLocalizations.of(context).fullName,
                    hint: AppLocalizations.of(context).fullName,
                    icon: Icons.person_outline,
                    validator: (v) => v == null || v.isEmpty
                        ? AppLocalizations.of(context).errorFieldRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _styledTextField(
                    controller: _phoneCtrl,
                    label: AppLocalizations.of(context).phone,
                    hint: AppLocalizations.of(context).phoneHint,
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return AppLocalizations.of(context).errorFieldRequired;
                      }
                      if (v.length != 10) {
                        return AppLocalizations.of(context).phoneLengthError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _styledTextField(
                    controller: _addressCtrl,
                    label: AppLocalizations.of(context).villageAddress,
                    hint: 'Village, Taluka, District',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (v) => v == null || v.isEmpty
                        ? AppLocalizations.of(context).errorFieldRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _styledTextField(
                    controller: _pinCodeCtrl,
                    label: AppLocalizations.of(context).pinCodeLabel,
                    hint: AppLocalizations.of(context).pinCodeHint,
                    icon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return AppLocalizations.of(context).pinCodeRequired;
                      }
                      if (v.length != 6) {
                        return AppLocalizations.of(context).invalidPinCode;
                      }
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
            _card(
              child: Column(
                children: [
                  _styledTextField(
                    controller: _farmAreaCtrl,
                    label: AppLocalizations.of(context).farmAreaAcres,
                    hint: AppLocalizations.of(context).farmAreaHint,
                    icon: Icons.square_foot,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? AppLocalizations.of(context).farmAreaRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _styledDropdown<String>(
                    label: AppLocalizations.of(context).soilType,
                    icon: Icons.layers_outlined,
                    value: _selectedSoilType,
                    items: _soilTypes
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(_getLocalizedSoilType(context, s)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSoilType = v),
                    validator: (v) => v == null
                        ? AppLocalizations.of(context).selectSoilType
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _styledTextField(
                    controller: _prevCropCtrl,
                    label: AppLocalizations.of(context).prevCropGrown,
                    hint: AppLocalizations.of(context).prevCropHint,
                    icon: Icons.grass,
                  ),
                  const SizedBox(height: 16),
                  _styledDropdown<String>(
                    label: AppLocalizations.of(context).waterSource,
                    icon: Icons.water_drop_outlined,
                    value: _selectedWaterSource,
                    items: _waterSources
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(_getLocalizedWaterSource(context, s)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedWaterSource = v),
                    validator: (v) => v == null
                        ? AppLocalizations.of(context).selectWaterSource
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _styledDropdown<String>(
                    label: AppLocalizations.of(context).irrigationType,
                    icon: Icons.opacity,
                    value: _selectedIrrigation,
                    items: _irrigationTypes
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              _getLocalizedIrrigationType(context, s),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedIrrigation = v),
                    validator: (v) => v == null
                        ? AppLocalizations.of(context).selectIrrigationType
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle(
              AppLocalizations.of(context).collectionLocation,
              Icons.calendar_month,
            ),
            const SizedBox(height: 16),
            _card(
              child: Column(
                children: [
                  // ── Date Picker ──
                  InkWell(
                    onTap: _presentDatePicker,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: _inputDecoration(
                        AppLocalizations.of(context).sampleCollectionDate,
                        Icons.calendar_today,
                      ),
                      child: Text(
                        _selectedDate == null
                            ? AppLocalizations.of(context).chooseADate
                            : DateFormat('dd MMM yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? _textHint
                              : _textPrimary,
                          fontSize: 15,
                        ),
                      ),
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
                          color: _gpsLocation != null ? _accent : _fieldBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.gps_fixed,
                            color: _gpsLocation != null ? _accent : _textHint,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).gpsLocation,
                                  style: TextStyle(
                                    color: _textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _gpsLocation ??
                                      AppLocalizations.of(
                                        context,
                                      ).captureLocation,
                                  style: TextStyle(
                                    color: _gpsLocation != null
                                        ? _accent
                                        : _textHint,
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
                            color: _gpsLocation != null ? _accent : _textHint,
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
          _sectionTitle(
            AppLocalizations.of(context).reviewDetails,
            Icons.fact_check_outlined,
          ),
          const SizedBox(height: 16),

          // ── Farmer Info Card ──
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewCardHeader(
                  AppLocalizations.of(context).farmerInformation,
                  Icons.person,
                ),
                const Divider(height: 24),
                _reviewRow(
                  AppLocalizations.of(context).fullName,
                  _nameCtrl.text,
                ),
                _reviewRow(AppLocalizations.of(context).phone, _phoneCtrl.text),
                _reviewRow(
                  AppLocalizations.of(context).villageAddress,
                  _addressCtrl.text,
                ),
                _reviewRow(
                  AppLocalizations.of(context).pinCodeLabel,
                  _pinCodeCtrl.text,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Soil Details Card ──
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewCardHeader(
                  AppLocalizations.of(context).soilFarmDetails,
                  Icons.landscape,
                ),
                const Divider(height: 24),
                _reviewRow(
                  AppLocalizations.of(context).farmAreaAcres,
                  '${_farmAreaCtrl.text} Acres',
                ),
                _reviewRow(
                  AppLocalizations.of(context).soilType,
                  _selectedSoilType == null
                      ? '—'
                      : _getLocalizedSoilType(context, _selectedSoilType!),
                ),
                _reviewRow(
                  AppLocalizations.of(context).prevCropGrown,
                  _prevCropCtrl.text.isEmpty ? '—' : _prevCropCtrl.text,
                ),
                _reviewRow(
                  AppLocalizations.of(context).waterSource,
                  _selectedWaterSource == null
                      ? '—'
                      : _getLocalizedWaterSource(
                          context,
                          _selectedWaterSource!,
                        ),
                ),
                _reviewRow(
                  AppLocalizations.of(context).irrigationType,
                  _selectedIrrigation == null
                      ? '—'
                      : _getLocalizedIrrigationType(
                          context,
                          _selectedIrrigation!,
                        ),
                ),
                _reviewRow(
                  AppLocalizations.of(context).sampleCollectionDate,
                  _selectedDate == null
                      ? '—'
                      : DateFormat('dd MMM yyyy').format(_selectedDate!),
                ),
                _reviewRow(
                  AppLocalizations.of(context).gpsLocation,
                  _gpsLocation ?? 'Not captured',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Notes ──
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewCardHeader(
                  AppLocalizations.of(context).additionalNotes,
                  Icons.note_alt_outlined,
                ),
                const SizedBox(height: 12),
                _styledTextField(
                  controller: _notesCtrl,
                  label: AppLocalizations.of(context).notesSpecialRequests,
                  hint: AppLocalizations.of(context).notesHint,
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
      backgroundColor: _scaffoldBg,
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
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [_gradStart, _gradEnd],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.3),
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
                Text(
                  AppLocalizations.of(context).bookingConfirmed,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(
                    context,
                  ).bookingSuccessMessage(_phoneCtrl.text),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textSecondary,
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
                      color: _accentLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: _accent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(_selectedDate!),
                          style: const TextStyle(
                            color: _accent,
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
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context).backToHome,
                      style: const TextStyle(
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _prevStep,
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: Text(AppLocalizations.of(context).back),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textSecondary,
                  side: BorderSide(color: _fieldBorder),
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
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : (isLast ? _submit : _nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _accent.withValues(alpha: 0.5),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast
                                  ? AppLocalizations.of(context).submit
                                  : AppLocalizations.of(context).continueText,
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

  /// Section title
  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _accent, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Light card with soft shadow
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Input decoration helper
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: _accent, size: 20),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
      ),
      errorStyle: TextStyle(color: Colors.red.shade400, fontSize: 12),
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
      style: const TextStyle(color: _textPrimary, fontSize: 15),
      cursorColor: _accent,
      decoration: _inputDecoration(label, icon).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(color: _textHint),
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
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      dropdownColor: Colors.white,
      style: const TextStyle(color: _textPrimary, fontSize: 15),
      icon: Icon(Icons.keyboard_arrow_down, color: _accent),
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
            color: _accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _accent, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Review row
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
              style: const TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedSoilType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case 'Alluvial':
        return l10n.soilAlluvial;
      case 'Black (Regur)':
        return l10n.soilBlack;
      case 'Red':
        return l10n.soilRed;
      case 'Laterite':
        return l10n.soilLaterite;
      case 'Sandy':
        return l10n.soilSandy;
      case 'Loamy':
        return l10n.soilLoamy;
      case 'Clay':
        return l10n.soilClay;
      case 'Saline':
        return l10n.soilSaline;
      case 'Peaty':
        return l10n.soilPeaty;
      case 'Arid (Desert)':
        return l10n.soilArid;
      default:
        return type;
    }
  }

  String _getLocalizedWaterSource(BuildContext context, String source) {
    final l10n = AppLocalizations.of(context);
    switch (source) {
      case 'Borewell':
        return l10n.waterBorewell;
      case 'Canal':
        return l10n.waterCanal;
      case 'Rain-fed':
        return l10n.waterRainFed;
      case 'River':
        return l10n.waterRiver;
      case 'Tank / Pond':
        return l10n.waterTank;
      case 'Other':
        return l10n.waterOther;
      default:
        return source;
    }
  }

  String _getLocalizedIrrigationType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case 'Drip':
        return l10n.irrDrip;
      case 'Sprinkler':
        return l10n.irrSprinkler;
      case 'Flood / Surface':
        return l10n.irrFlood;
      case 'Furrow':
        return l10n.irrFurrow;
      case 'None (Rain-fed)':
        return l10n.irrNone;
      default:
        return type;
    }
  }
}
