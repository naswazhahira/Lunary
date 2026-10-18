import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import 'login_screen.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';

enum ProfileSubPage { main, editProfile, appSettings, privacySettings, help }

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

  // Variabel untuk menyimpan foto profil terpilih
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _isMetricSystem = true;
  String _selectedLanguage = 'English';
  final TextEditingController _helpSearchController = TextEditingController();

  final List<Map<String, dynamic>> _faqs = [
    {
      'title': 'Getting Started',
      'icon': Icons.rocket_launch_outlined,
      'faqs': [
        {'q': 'How do I register an account?', 'a': 'You can sign up using your email or Google account on the login page.'},
        {'q': 'How do I track my period cycle?', 'a': 'Tap the "+" button on the home screen to log your period start and end dates.'},
      ]
    },
    {
      'title': 'Account & Data',
      'icon': Icons.badge_outlined,
      'faqs': [
        {'q': 'How do I change my email?', 'a': 'Go to Edit Profile, update your Email, and tap Save.'},
        {'q': 'How do I delete my account?', 'a': 'Go to Privacy Settings > Delete My Account at the bottom of the screen.'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.userData != null;
    _nameController = TextEditingController(text: widget.userData?['name'] ?? 'Lunary User');
    _emailController = TextEditingController(text: widget.userData?['email'] ?? 'user@lunary.com');

    _dobController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
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

  // Fungsi untuk mengambil gambar dari galeri
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

  Future<bool> _onWillPop() async {
    if (_currentPage != ProfileSubPage.main) {
      setState(() => _currentPage = ProfileSubPage.main);
      return false;
    }
    return true;
  }

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
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: const Icon(Icons.close_rounded, color: AppColors.darkText, size: 22),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText),
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
                onTap: () => _showSnackBar('Hide content tapped'),
              ),
              _buildMenuItem(
                icon: Icons.bar_chart_rounded,
                title: 'Charts & reports',
                onTap: () => _showSnackBar('Opening Charts & Reports'),
              ),
              _buildMenuItem(
                icon: Icons.water_drop_outlined,
                title: 'Cycle and ovulation',
                onTap: () => _showSnackBar('Opening Cycle & Ovulation'),
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Reminders',
                onTap: () => _showSnackBar('Reminders tapped'),
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
                    decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.security_rounded, color: AppColors.primaryPurple, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your data is protected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkText)),
                        SizedBox(height: 4),
                        Text('Your privacy is our top priority. Your data will never be sold and can be deleted at any time.',
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
                  onPressed: () => _showSnackBar('Learn more tapped'),
                  child: const Text('Learn more', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
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
              Text(_nameController.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const SizedBox(height: 2),
              Text(_emailController.text, style: const TextStyle(fontSize: 13, color: AppColors.darkerSubText)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() => _currentPage = ProfileSubPage.editProfile),
                child: const Text('Edit info', style: TextStyle(fontSize: 13, color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
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
                        width: 90,
                        height: 90,
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
                            ? const Icon(Icons.person, size: 55, color: Colors.white)
                            : null,
                      ),
                      GestureDetector(
                        onTap: _pickImage, // Memanggil penyeleksi gambar
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
                  onTap: _pickImage, // Memanggil penyeleksi gambar
                  child: const Text('Change Profile Picture', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(height: 28),

                _buildInputField(label: 'Full Name', controller: _nameController, icon: Icons.person_outline),
                const SizedBox(height: 16),
                _buildInputField(label: 'Email', controller: _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText)),
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
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Height',
                        controller: _heightController,
                        icon: Icons.height,
                        hintText: 'e.g. 160 cm',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: 'Weight',
                        controller: _weightController,
                        icon: Icons.monitor_weight_outlined,
                        hintText: 'e.g. 52 kg',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      setState(() => _currentPage = ProfileSubPage.main);
                      _showSnackBar('Profile updated successfully!');
                    },
                    child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                      onTap: () => _showSnackBar('Connecting to Health Connect...'),
                      leading: const Icon(Icons.favorite_border, color: AppColors.primaryPurple, size: 24),
                      title: const Text('Health Connect', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    ),
                    Divider(height: 1, thickness: 0.5, indent: 52, endIndent: 16, color: Colors.grey.shade200),
                    ListTile(
                      onTap: _showLanguageDialog,
                      leading: const Icon(Icons.language, color: AppColors.primaryPurple, size: 24),
                      title: const Text('Change language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
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
                  title: const Text('Metric system (kg, cm)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                  value: _isMetricSystem,
                  onChanged: (bool value) {
                    setState(() => _isMetricSystem = value);
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
                  onTap: () => _showSnackBar('Opening Lunary Privacy information'),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('My Privacy'),
              _buildCardContainer([
                _buildListTile(
                  icon: Icons.info_outline,
                  title: 'Request information',
                  subtitle: 'Find out what cycle and health data we store.',
                  onTap: () => _showSnackBar('Data export request sent to email.'),
                ),
                _buildListDivider(),
                _buildListTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Manage your consent',
                  subtitle: 'Choose and control your privacy options.',
                  onTap: () => _showSnackBar('Opening Data Consent Settings'),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('Security'),
              _buildCardContainer([
                _buildListTile(
                  icon: Icons.lock_outline,
                  title: 'App lock',
                  subtitle: 'Set or change passcode to protect your account.',
                  onTap: () => _showSnackBar('Opening App Lock settings'),
                ),
              ]),
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
          ),
        ),
      ],
    );
  }

  Widget _buildHelpPage() {
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
                    const Text('How can we help you?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _helpSearchController,
                      decoration: InputDecoration(
                        hintText: 'Search help topics...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryPurple),
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
              ..._faqs.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
                      child: Row(
                        children: [
                          Icon(category['icon'] as IconData, size: 18, color: AppColors.primaryPurple),
                          const SizedBox(width: 8),
                          Text(category['title'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkText)),
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
                            title: Text(faq['q'].toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                                child: Text(faq['a'].toString(), style: const TextStyle(fontSize: 12, color: AppColors.darkerSubText, height: 1.4)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
            onPressed: () => setState(() => _currentPage = ProfileSubPage.main),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
          ),
          const SizedBox(width: 48),
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
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2)),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      builder: (context) => AlertDialog(
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
                Navigator.pop(context);
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
                Navigator.pop(context);
                _showSnackBar('Bahasa diubah ke Bahasa Indonesia');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete My Account', style: TextStyle(color: Colors.redAccent)),
        content: const Text('Are you sure? All of your period cycle data and health history will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);

              isUserLoggedIn = false;
              globalUserData = null;

              setState(() {
                _isLoggedIn = false;
                _currentPage = ProfileSubPage.main;
              });

              _showSnackBar('Account deleted successfully.');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}
