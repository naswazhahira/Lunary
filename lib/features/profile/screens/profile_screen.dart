import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/cycle_provider.dart';
import 'login_screen.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';

enum ProfileSubPage { main, editProfile, appSettings, privacySettings, help }

/// Data tambahan profil yang disimpan di memori supaya tidak hilang
/// ketika ProfileScreen dibuat ulang (misalnya saat pindah tab).
class _ProfileDraft {
  static String? gender;
  static String dob = '';
  static String height = '';
  static String weight = '';
  static String? imagePath;
  static bool isMetric = true;
  static String language = 'English';

  static void clear() {
    gender = null;
    dob = '';
    height = '';
    weight = '';
    imagePath = null;
    isMetric = true;
    language = 'English';
  }
}

class ProfileScreen extends StatefulWidget {
  final Map<String, String>? userData;

  const ProfileScreen({Key? key, this.userData}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileSubPage _currentPage = ProfileSubPage.main;
  bool _isLoggedIn = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedGender;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _isMetricSystem = true;
  String _selectedLanguage = 'English';
  final TextEditingController _helpSearchController = TextEditingController();
  String _helpQuery = '';

  static final RegExp _emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');

  final List<Map<String, dynamic>> _faqs = [
    {
      'title': 'Getting Started',
      'icon': Icons.rocket_launch_outlined,
      'faqs': [
        {
          'q': 'How do I register an account?',
          'a': 'Open the Profile tab, tap "Log in / Sign up", then choose Sign Up and fill in your name, email, and password.'
        },
        {
          'q': 'How do I track my period cycle?',
          'a': 'Go to the Calendar tab, select the date your period started, and tap "Log Period". Your cycle predictions will update automatically.'
        },
        {
          'q': 'I logged the wrong date. How do I fix it?',
          'a': 'Tap the first day of your logged period to remove it entirely, or tap the correct start date to replace it.'
        },
      ]
    },
    {
      'title': 'Account & Data',
      'icon': Icons.badge_outlined,
      'faqs': [
        {
          'q': 'How do I change my name or email?',
          'a': 'Go to Edit Profile, update your name or email, and tap Save Changes.'
        },
        {
          'q': 'How do I log out?',
          'a': 'Open the Profile tab and tap "Log out" below the settings list.'
        },
        {
          'q': 'How do I delete my account?',
          'a': 'Go to Privacy Settings > Delete my account. This also removes your logged cycle data.'
        },
      ]
    },
  ];

  @override
  void initState() {
    super.initState();

    // Status login: dari parameter, atau dari data global kalau parameter kosong
    _isLoggedIn = widget.userData != null || isUserLoggedIn;
    final name = widget.userData?['name'] ?? globalUserData?['name'] ?? 'Lunary User';
    final email = widget.userData?['email'] ?? globalUserData?['email'] ?? 'user@lunary.com';

    _nameController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);

    // Data tambahan profil dipulihkan dari memori
    _dobController = TextEditingController(text: _ProfileDraft.dob);
    _heightController = TextEditingController(text: _ProfileDraft.height);
    _weightController = TextEditingController(text: _ProfileDraft.weight);
    _selectedGender = _ProfileDraft.gender;
    _isMetricSystem = _ProfileDraft.isMetric;
    _selectedLanguage = _ProfileDraft.language;
    if (_ProfileDraft.imagePath != null) {
      _profileImage = File(_ProfileDraft.imagePath!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _helpSearchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        _ProfileDraft.imagePath = pickedFile.path;
        _showSnackBar('Profile picture updated successfully!');
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoon(String feature) => _showSnackBar('$feature is coming soon');

  Future<bool> _onWillPop() async {
    if (_currentPage != ProfileSubPage.main) {
      setState(() => _currentPage = ProfileSubPage.main);
      return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Aksi akun
  // ---------------------------------------------------------------------------

  void _saveProfile() {
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newName.isEmpty) {
      _showSnackBar('Name cannot be empty');
      return;
    }
    if (!_emailRegex.hasMatch(newEmail)) {
      _showSnackBar('Please enter a valid email address');
      return;
    }

    // Simpan data tambahan profil
    _ProfileDraft.gender = _selectedGender;
    _ProfileDraft.dob = _dobController.text;
    _ProfileDraft.height = _heightController.text.trim();
    _ProfileDraft.weight = _weightController.text.trim();

    // Sinkronkan ke data global (dibaca Home) dan akun terdaftar (dipakai login)
    globalUserData = {'name': newName, 'email': newEmail};
    if (RegisteredAccount.email != null) {
      RegisteredAccount.email = newEmail;
      RegisteredAccount.name = newName;
    }

    setState(() {
      _nameController.text = newName;
      _emailController.text = newEmail;
      _currentPage = ProfileSubPage.main;
    });
    _showSnackBar('Profile updated successfully!');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out? Your data stays on this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            onPressed: () {
              Navigator.pop(dialogContext);

              isUserLoggedIn = false;
              globalUserData = null;

              setState(() {
                _isLoggedIn = false;
                _currentPage = ProfileSubPage.main;
              });
              _showSnackBar('Logged out successfully.');
            },
            child: const Text('Log out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete My Account', style: TextStyle(color: Colors.redAccent)),
        content: const Text(
            'Are you sure? All of your period cycle data and health history will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogContext);

              // Hapus data siklus
              context.read<CycleProvider>().clearAllData();

              // Hapus akun terdaftar & status login
              RegisteredAccount.clear();
              isUserLoggedIn = false;
              globalUserData = null;

              // Reset data profil
              _ProfileDraft.clear();

              setState(() {
                _isLoggedIn = false;
                _currentPage = ProfileSubPage.main;
                _nameController.text = 'Lunary User';
                _emailController.text = 'user@lunary.com';
                _dobController.clear();
                _heightController.clear();
                _weightController.clear();
                _selectedGender = null;
                _profileImage = null;
                _isMetricSystem = true;
                _selectedLanguage = 'English';
              });

              _showSnackBar('Account deleted successfully.');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCurrentSubPage(),
                  ),
                ),
                if (_currentPage == ProfileSubPage.main)
                  AppBottomNavBar(
                    currentTab: AppNavTab.profile,
                    onTabSelected: (tab) {
                      if (tab == AppNavTab.profile) return;
                      handleAppNavTap(context, tab);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSubPage() {
    switch (_currentPage) {
      case ProfileSubPage.editProfile:
        return _buildEditProfilePage();
      case ProfileSubPage.appSettings:
        return _buildAppSettingsPage();
      case ProfileSubPage.privacySettings:
        return _buildPrivacySettingsPage();
      case ProfileSubPage.help:
        return _buildHelpPage();
      case ProfileSubPage.main:
      default:
        return _buildMainProfilePage();
    }
  }

  Widget _buildMainProfilePage() {
    return ListView(
      key: const ValueKey('MainPage'),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      children: [
        Row(
          children: const [
            SizedBox(width: 8),
            Text(
              'Profile',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildProfileHeaderCard(),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppColors.cardRadius),
            boxShadow: [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'App settings',
                onTap: () => setState(() => _currentPage = ProfileSubPage.appSettings),
              ),
              _buildMenuItem(
                icon: Icons.visibility_off_outlined,
                title: 'Hide content',
                onTap: () => _showComingSoon('Hide content'),
              ),
              _buildMenuItem(
                icon: Icons.bar_chart_rounded,
                title: 'Charts & reports',
                onTap: () => _showComingSoon('Charts & reports'),
              ),
              _buildMenuItem(
                icon: Icons.water_drop_outlined,
                title: 'Cycle and ovulation',
                onTap: () => _showComingSoon('Cycle & ovulation settings'),
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Reminders',
                onTap: () => _showComingSoon('Reminders'),
              ),
              _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'Privacy settings',
                onTap: () => setState(() => _currentPage = ProfileSubPage.privacySettings),
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                showDivider: false,
                onTap: () => setState(() => _currentPage = ProfileSubPage.help),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppColors.cardRadius),
            boxShadow: [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.security_rounded, color: AppColors.primaryPurple, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your data is protected',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkText)),
                        SizedBox(height: 4),
                        Text(
                            'Your privacy is our top priority. Your data will never be sold and can be deleted at any time.',
                            style: TextStyle(fontSize: 12, color: AppColors.darkerSubText, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple.withOpacity(0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => setState(() => _currentPage = ProfileSubPage.privacySettings),
                  child: const Text('Learn more',
                      style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
        if (_isLoggedIn) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _showLogoutDialog,
              child: const Text('Log out',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
        ],
        const SizedBox(height: 24),
        const Center(
          child: Column(
            children: [
              Text('Lunary Period & Ovulation Tracker', style: TextStyle(fontSize: 12, color: AppColors.subText)),
              SizedBox(height: 2),
              Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppColors.subText)),
              SizedBox(height: 2),
              Text('© 2026 Lunary Health, Inc.', style: TextStyle(fontSize: 12, color: AppColors.subText)),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: _isLoggedIn ? _buildLoggedInProfileContent() : _buildGuestProfileContent(),
    );
  }

  Widget _buildLoggedInProfileContent() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _currentPage = ProfileSubPage.editProfile),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB197FC),
                  border: Border.all(color: Colors.white, width: 2.5),
                  image: _profileImage != null
                      ? DecorationImage(
                    image: FileImage(_profileImage!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: _profileImage == null
                    ? const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 32))
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.primaryPink, shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 10, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_nameController.text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const SizedBox(height: 2),
              Text(_emailController.text, style: const TextStyle(fontSize: 13, color: AppColors.darkerSubText)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() => _currentPage = ProfileSubPage.editProfile),
                child: const Text('Edit info',
                    style: TextStyle(fontSize: 13, color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuestProfileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFB197FC),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Log in',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Log in or create an account to back up your cycle data and enjoy all features.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.darkerSubText,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );

              if (result != null && result is Map<String, dynamic>) {
                isUserLoggedIn = true;
                globalUserData = {
                  'name': result['name'] ?? 'Lunary User',
                  'email': result['email'] ?? 'user@lunary.com',
                };
                setState(() {
                  _isLoggedIn = true;
                  _nameController.text = globalUserData!['name']!;
                  _emailController.text = globalUserData!['email']!;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Log in / Sign up',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfilePage() {
    return Column(
      key: const ValueKey('EditProfilePage'),
      children: [
        _buildSubPageHeader('Edit Profile'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD6C7FF),
                          image: _profileImage != null
                              ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _profileImage == null
                            ? const Icon(Icons.person, size: 46, color: Colors.white)
                            : null,
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppColors.primaryPurple, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: const Text('Change Profile Picture',
                      style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(height: 20),

                _buildInputField(label: 'Full Name', controller: _nameController, icon: Icons.person_outline),
                const SizedBox(height: 12),
                _buildInputField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  icon: Icons.calendar_today_outlined,
                  hintText: 'Select Date of Birth',
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000, 1, 1),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _dobController.text = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gender',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          hint: Text('Select Gender', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                          isExpanded: true,
                          items: ['Female', 'Male'].map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (newValue) => setState(() => _selectedGender = newValue),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Height',
                        controller: _heightController,
                        icon: Icons.height,
                        hintText: _isMetricSystem ? 'e.g. 160 cm' : 'e.g. 5 ft 3 in',
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: 'Weight',
                        controller: _weightController,
                        icon: Icons.monitor_weight_outlined,
                        hintText: _isMetricSystem ? 'e.g. 52 kg' : 'e.g. 115 lb',
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _saveProfile,
                    child: const Text('Save Changes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppSettingsPage() {
    return Column(
      key: const ValueKey('AppSettingsPage'),
      children: [
        _buildSubPageHeader('App Settings'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => _showComingSoon('Health Connect'),
                      leading: const Icon(Icons.favorite_border, color: AppColors.primaryPurple, size: 24),
                      title: const Text('Health Connect',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    ),
                    Divider(height: 1, thickness: 0.5, indent: 52, endIndent: 16, color: Colors.grey.shade200),
                    ListTile(
                      onTap: _showLanguageDialog,
                      leading: const Icon(Icons.language, color: AppColors.primaryPurple, size: 24),
                      title: const Text('Change language',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                      subtitle: Text(_selectedLanguage, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SwitchListTile(
                  activeColor: AppColors.primaryPurple,
                  title: const Text('Metric system (kg, cm)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                  value: _isMetricSystem,
                  onChanged: (bool value) {
                    setState(() => _isMetricSystem = value);
                    _ProfileDraft.isMetric = value;
                    _showSnackBar(value ? 'Metric system enabled' : 'Imperial system enabled');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySettingsPage() {
    return Column(
      key: const ValueKey('PrivacySettingsPage'),
      children: [
        _buildSubPageHeader('Privacy Settings'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            children: [
              _buildSectionTitle('General'),
              _buildCardContainer([
                _buildListTile(
                  icon: Icons.shield_outlined,
                  title: 'About Lunary privacy',
                  subtitle: 'See how Lunary keeps your data safe.',
                  onTap: () => _showComingSoon('Privacy information'),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('My Privacy'),
              _buildCardContainer([
                _buildListTile(
                  icon: Icons.info_outline,
                  title: 'Request information',
                  subtitle: 'Find out what cycle and health data we store.',
                  onTap: () => _showComingSoon('Data request'),
                ),
                _buildListDivider(),
                _buildListTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Manage your consent',
                  subtitle: 'Choose and control your privacy options.',
                  onTap: () => _showComingSoon('Consent settings'),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('Security'),
              _buildCardContainer([
                _buildListTile(
                  icon: Icons.lock_outline,
                  title: 'App lock',
                  subtitle: 'Set or change passcode to protect your account.',
                  onTap: () => _showComingSoon('App lock'),
                ),
              ]),
              // Hapus akun hanya relevan kalau user sudah login
              if (_isLoggedIn) ...[
                const SizedBox(height: 20),
                _buildCardContainer([
                  _buildListTile(
                    icon: Icons.delete_outline,
                    iconColor: Colors.redAccent,
                    title: 'Delete my account',
                    titleColor: Colors.redAccent,
                    subtitle: 'Permanently delete your account and all data.',
                    onTap: _showDeleteAccountDialog,
                  ),
                ]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHelpPage() {
    final query = _helpQuery.trim().toLowerCase();

    // Filter FAQ berdasarkan kata kunci di pertanyaan atau jawaban
    final List<Map<String, dynamic>> visibleCategories = [];
    for (final category in _faqs) {
      final matches = (category['faqs'] as List).where((faq) {
        if (query.isEmpty) return true;
        return faq['q'].toString().toLowerCase().contains(query) ||
            faq['a'].toString().toLowerCase().contains(query);
      }).toList();
      if (matches.isNotEmpty) {
        visibleCategories.add({
          'title': category['title'],
          'icon': category['icon'],
          'faqs': matches,
        });
      }
    }

    return Column(
      key: const ValueKey('HelpPage'),
      children: [
        _buildSubPageHeader('Help Center'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEBFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('How can we help you?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _helpSearchController,
                      onChanged: (value) => setState(() => _helpQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search help topics...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryPurple),
                        suffixIcon: _helpQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _helpSearchController.clear();
                            setState(() => _helpQuery = '');
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (visibleCategories.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No help topics found.',
                        style: TextStyle(fontSize: 13, color: AppColors.darkerSubText)),
                  ),
                ),
              ...visibleCategories.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
                      child: Row(
                        children: [
                          Icon(category['icon'] as IconData, size: 18, color: AppColors.primaryPurple),
                          const SizedBox(width: 8),
                          Text(category['title'].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkText)),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: (category['faqs'] as List).map<Widget>((faq) {
                          return ExpansionTile(
                            title: Text(faq['q'].toString(),
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                                child: Text(faq['a'].toString(),
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.darkerSubText, height: 1.4)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubPageHeader(String title) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkText, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: () => setState(() => _currentPage = ProfileSubPage.main),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool showDivider = true,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.primaryPurple, size: 22),
          title: Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.subText, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 0.5, indent: 54, endIndent: 16, color: Colors.grey.withOpacity(0.15)),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: AppColors.primaryPurple),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListDivider() {
    return Divider(height: 1, thickness: 0.5, indent: 52, endIndent: 16, color: Colors.grey.shade200);
  }

  Widget _buildListTile({
    required IconData icon,
    Color iconColor = AppColors.primaryPurple,
    required String title,
    Color titleColor = AppColors.darkText,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: titleColor)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              activeColor: AppColors.primaryPurple,
              onChanged: (val) {
                setState(() => _selectedLanguage = val!);
                _ProfileDraft.language = val!;
                Navigator.pop(dialogContext);
                _showSnackBar('Language changed to English');
              },
            ),
            RadioListTile<String>(
              title: const Text('Bahasa Indonesia'),
              value: 'Bahasa Indonesia',
              groupValue: _selectedLanguage,
              activeColor: AppColors.primaryPurple,
              onChanged: (val) {
                setState(() => _selectedLanguage = val!);
                _ProfileDraft.language = val!;
                Navigator.pop(dialogContext);
                _showSnackBar('Bahasa diubah ke Bahasa Indonesia');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
