import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/cycle_provider.dart';
import 'login_screen.dart';
import 'cycle_type_screen.dart';
import 'app_settings_screen.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/services/cycle_settings.dart';
import '../../reports/screens/reports_screen.dart';
import '../../../core/services/tracker_store.dart';

enum ProfileSubPage { main, editProfile, cycleSettings, reminders, privacySettings, help }

class _ReminderDef {
  final String key;
  final int id;
  final String section;
  final String title;
  final String body;
  final IconData icon;
  final TimeOfDay defaultTime;

  const _ReminderDef({
    required this.key,
    required this.id,
    required this.section,
    required this.title,
    required this.body,
    required this.icon,
    required this.defaultTime,
  });
}

const List<_ReminderDef> _reminderDefs = [
  _ReminderDef(
    key: 'pill',
    id: 101,
    section: 'Medication & contraception',
    title: 'Contraception pill',
    body: 'Time to take your pill.',
    icon: Icons.medication_outlined,
    defaultTime: TimeOfDay(hour: 20, minute: 0),
  ),
  _ReminderDef(
    key: 'weight',
    id: 201,
    section: 'Lifestyle',
    title: 'Log weight',
    body: 'Time to log your weight.',
    icon: Icons.monitor_weight_outlined,
    defaultTime: TimeOfDay(hour: 7, minute: 0),
  ),
  _ReminderDef(
    key: 'sleep',
    id: 202,
    section: 'Lifestyle',
    title: 'Log bedtime',
    body: "Don't forget to log your bedtime.",
    icon: Icons.bedtime_outlined,
    defaultTime: TimeOfDay(hour: 22, minute: 0),
  ),
  _ReminderDef(
    key: 'water',
    id: 203,
    section: 'Lifestyle',
    title: 'Drink water',
    body: 'Stay hydrated! Time for a glass of water.',
    icon: Icons.water_drop_outlined,
    defaultTime: TimeOfDay(hour: 10, minute: 0),
  ),
  _ReminderDef(
    key: 'temperature',
    id: 204,
    section: 'Lifestyle',
    title: 'Log temperature',
    body: 'Take and log your basal body temperature.',
    icon: Icons.thermostat_outlined,
    defaultTime: TimeOfDay(hour: 7, minute: 30),
  ),
];

class _ProfileDraft {
  static String? gender;
  static String dob = '';
  static String height = '';
  static String weight = '';
  static String? imagePath;
  static bool isMetric = true;

  // Pilihan persetujuan (consent) opsional
  static bool consentAnalytics = false;
  static bool consentPersonalized = false;
  static bool consentMarketing = false;

  static void clear() {
    gender = null;
    dob = '';
    height = '';
    weight = '';
    imagePath = null;
    isMetric = true;
    consentAnalytics = false;
    consentPersonalized = false;
    consentMarketing = false;
  }
}

class ProfileScreen extends StatefulWidget {
  final Map<String, String>? userData;

  const ProfileScreen({Key? key, this.userData}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
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
  final TextEditingController _helpSearchController = TextEditingController();
  String _helpQuery = '';
  // Reminders
  bool _reminderChecking = true;
  bool _reminderPermission = false;
  final Map<String, bool> _reminderOn = {};
  final Map<String, TimeOfDay> _reminderTime = {};

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
          'q': 'Do I need an account to use Lunary?',
          'a': 'You can explore the app without an account. Logging in lets you keep your profile and cycle data tied to your account.'
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
      'title': 'Cycle & Predictions',
      'icon': Icons.water_drop_outlined,
      'faqs': [
        {
          'q': 'How does Lunary predict my next period?',
          'a': 'Lunary looks at the dates of your previously logged periods and calculates your average cycle length to estimate the next one.'
        },
        {
          'q': 'Why is my prediction not accurate?',
          'a': 'Predictions get better the more cycles you log. Stress, illness, travel, and hormonal changes can also shift your cycle.'
        },
        {
          'q': 'What is the fertile window and ovulation day?',
          'a': 'Ovulation usually happens around 12 to 16 days before your next period. The fertile window is the few days before and including ovulation.'
        },
        {
          'q': 'My cycle is irregular. Can I still use Lunary?',
          'a': 'Yes. Keep logging every period so the app can learn your pattern. For irregular cycles, treat predictions as estimates, not exact dates.'
        },
        {
          'q': 'Can I use Lunary as birth control?',
          'a': 'No. Lunary is a tracking tool and its predictions are estimates, so it should not be used as a contraceptive method.'
        },
      ]
    },
    {
      'title': 'Profile & Account',
      'icon': Icons.badge_outlined,
      'faqs': [
        {
          'q': 'How do I change my name or email?',
          'a': 'Go to Edit Profile, update your name or email, and tap Save Changes.'
        },
        {
          'q': 'How do I add, change, or delete my profile photo?',
          'a': 'Tap your profile picture. If you have no photo yet, choose Take photo or Choose from gallery. If you already have one, you can Edit, Change, or Delete it.'
        },
        {
          'q': 'How do I switch between metric and imperial units?',
          'a': 'Open Edit Profile and use the "Metric system" switch above the height and weight fields. Your existing values are converted automatically.'
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
    {
      'title': 'Privacy & Security',
      'icon': Icons.lock_outline,
      'faqs': [
        {
          'q': 'Is my data shared or sold?',
          'a': 'No. Your data is never sold. You can read more under Privacy Settings > About Lunary privacy.'
        },
        {
          'q': 'How do I change what data I consent to?',
          'a': 'Go to Privacy Settings > Manage your consent, then turn the optional permissions on or off at any time.'
        },
        {
          'q': 'What are security notifications?',
          'a': 'They are alerts about potentially suspicious activity on your account. They are always active and are sent to the email linked to your Lunary account.'
        },
        {
          'q': 'Can I delete all my data?',
          'a': 'Yes. Deleting your account permanently removes your profile and all logged cycle and health data.'
        },
      ]
    },
    {
      'title': 'Troubleshooting',
      'icon': Icons.build_outlined,
      'faqs': [
        {
          'q': 'My profile photo does not change.',
          'a': 'Make sure Lunary is allowed to access your photos or camera in your phone settings, then try again.'
        },
        {
          'q': 'My changes were not saved.',
          'a': 'After editing your profile, always tap "Save Changes" at the bottom of the Edit Profile page.'
        },
        {
          'q': 'I cannot log in.',
          'a': 'Check that your email and password are correct. If the problem continues, try signing up again with the same email you used before.'
        },
        {
          'q': 'The app is slow or acting strange.',
          'a': 'Close and reopen the app. If the issue stays, update Lunary to the latest version.'
        },
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
    if (_ProfileDraft.imagePath != null) {
      _profileImage = File(_ProfileDraft.imagePath!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _helpSearchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Foto profil
  // ---------------------------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
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

  void _deleteProfilePhoto() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete profile photo'),
        content: const Text('Are you sure you want to remove your profile photo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() => _profileImage = null);
              _ProfileDraft.imagePath = null;
              _showSnackBar('Profile photo removed.');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Belum punya foto  -> opsi "Add profile photo" (kamera / galeri)
  /// Sudah punya foto  -> opsi Edit, Change, Delete
  /// (Di halaman Edit Profile, opsi "Edit" disembunyikan karena sudah di halaman itu.)
  void _showProfilePhotoOptions({bool fromEditPage = false}) {
    if (_profileImage == null) {
      _showOptionsSheet(
        title: 'Add profile photo',
        options: [
          _buildSheetOption(
            icon: Icons.photo_camera_outlined,
            label: 'Take photo',
            onTap: () => _pickImage(ImageSource.camera),
          ),
          _buildSheetOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from gallery',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ],
      );
      return;
    }

    _showOptionsSheet(
      title: 'Profile photo',
      options: [
        if (!fromEditPage)
          _buildSheetOption(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: () => setState(() => _currentPage = ProfileSubPage.editProfile),
          ),
        _buildSheetOption(
          icon: Icons.photo_library_outlined,
          label: 'Change',
          onTap: _showChangePhotoSourceSheet,
        ),
        _buildSheetOption(
          icon: Icons.delete_outline,
          label: 'Delete',
          iconColor: Colors.redAccent,
          textColor: Colors.redAccent,
          onTap: _deleteProfilePhoto,
        ),
      ],
    );
  }

  void _showChangePhotoSourceSheet() {
    // Dipanggil setelah sheet sebelumnya ditutup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showOptionsSheet(
        title: 'Change profile photo',
        options: [
          _buildSheetOption(
            icon: Icons.photo_camera_outlined,
            label: 'Take photo',
            onTap: () => _pickImage(ImageSource.camera),
          ),
          _buildSheetOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from gallery',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ],
      );
    });
  }

  void _showOptionsSheet({required String title, required List<Widget> options}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHandle(),
              const SizedBox(height: 14),
              Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const SizedBox(height: 8),
              ...options,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color textColor = AppColors.darkText,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primaryPurple),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper umum
  // ---------------------------------------------------------------------------

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

  /// Pindah ke halaman Lunary AI dari Help Center
  void _openLunaryAI() {
    handleAppNavTap(context, AppNavTab.lunaryAi);
  }

  Future<bool> _onWillPop() async {
    if (_currentPage != ProfileSubPage.main) {
      setState(() => _currentPage = ProfileSubPage.main);
      return false;
    }
    return true;
  }

  /// Kelengkapan profil (nama & email dianggap selalu terisi)
  double get _profileCompleteness {
    int filled = 2;
    if (_profileImage != null) filled++;
    if (_dobController.text.trim().isNotEmpty) filled++;
    if (_selectedGender != null) filled++;
    if (_heightController.text.trim().isNotEmpty) filled++;
    if (_weightController.text.trim().isNotEmpty) filled++;
    return filled / 7;
  }

  String _formatNumber(double value) {
    final text = value.toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  /// Ganti sistem satuan + konversi nilai tinggi/berat yang sudah terisi.
  /// Metrik: cm & kg. Imperial: inch & lb.
  void _onMetricChanged(bool useMetric) {
    final h = double.tryParse(_heightController.text.trim().replaceAll(',', '.'));
    final w = double.tryParse(_weightController.text.trim().replaceAll(',', '.'));

    setState(() {
      if (h != null) {
        _heightController.text = _formatNumber(useMetric ? h * 2.54 : h / 2.54);
      }
      if (w != null) {
        _weightController.text = _formatNumber(useMetric ? w / 2.2046226 : w * 2.2046226);
      }
      _isMetricSystem = useMetric;
    });
  }

  // ---------------------------------------------------------------------------
  // Aksi akun
  // ---------------------------------------------------------------------------

  void _saveProfile() {
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final heightText = _heightController.text.trim().replaceAll(',', '.');
    final weightText = _weightController.text.trim().replaceAll(',', '.');

    if (newName.isEmpty) {
      _showSnackBar('Name cannot be empty');
      return;
    }
    if (!_emailRegex.hasMatch(newEmail)) {
      _showSnackBar('Please enter a valid email address');
      return;
    }
    if (heightText.isNotEmpty && (double.tryParse(heightText) ?? 0) <= 0) {
      _showSnackBar('Please enter a valid height');
      return;
    }
    if (weightText.isNotEmpty && (double.tryParse(weightText) ?? 0) <= 0) {
      _showSnackBar('Please enter a valid weight');
      return;
    }

    // Simpan data tambahan profil
    _ProfileDraft.gender = _selectedGender;
    _ProfileDraft.dob = _dobController.text;
    _ProfileDraft.height = heightText;
    _ProfileDraft.weight = weightText;
    _ProfileDraft.isMetric = _isMetricSystem;

    // Sinkronkan ke data global (dibaca Home) dan akun terdaftar (dipakai login)
    globalUserData = {'name': newName, 'email': newEmail};
    if (RegisteredAccount.email != null) {
      RegisteredAccount.email = newEmail;
      RegisteredAccount.name = newName;
    }

    setState(() {
      _nameController.text = newName;
      _emailController.text = newEmail;
      _heightController.text = heightText;
      _weightController.text = weightText;
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
            onPressed: () async {
              Navigator.pop(dialogContext);

              final cycleProvider = context.read<CycleProvider>();

              isUserLoggedIn = false;
              globalUserData = null;

              // Kosongkan data akun, lalu aktifkan kembali data guest
              CycleSettings.unload();
              await CycleSettings.loadGuest();
              cycleProvider.reloadFromSettings();

              if (!mounted) return;
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
            onPressed: () async {
              Navigator.pop(dialogContext);

              final cycleProvider = context.read<CycleProvider>();
              final accountEmail = _emailController.text.trim();

              // Hapus pengaturan, survei, dan tanggal haid akun ini dari penyimpanan,
              // lalu aktifkan kembali data guest dan segarkan Home/Calendar
              await CycleSettings.deleteAccountData();
              await CycleSettings.loadGuest();
              cycleProvider.reloadFromSettings();

              TrackerStore.clearAccount(accountEmail);

              // Hapus akun terdaftar & status login
              RegisteredAccount.clear();
              isUserLoggedIn = false;
              globalUserData = null;

              // Reset data profil
              _ProfileDraft.clear();
              ReminderService.cancelAll();

              if (!mounted) return;
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
  // Privasi: info & consent
  // ---------------------------------------------------------------------------

  void _showPrivacyInfoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _buildSheetHandle(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.shield_outlined, color: AppColors.primaryPurple, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('How Lunary protects your privacy',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Your cycle and health information is personal. Here is how we keep it safe and under your control.',
                style: TextStyle(fontSize: 13, color: AppColors.darkerSubText, height: 1.5),
              ),
              const SizedBox(height: 20),
              _buildInfoPoint(
                icon: Icons.money_off_csred_outlined,
                title: 'We never sell your data',
                description:
                'Your personal and health information is never sold to advertisers or third parties.',
              ),
              _buildInfoPoint(
                icon: Icons.phone_android_outlined,
                title: 'Your data stays on your device',
                description:
                'Your logged cycle data is kept on this device, and logging out does not erase it.',
              ),
              _buildInfoPoint(
                icon: Icons.tune_outlined,
                title: 'You are in control',
                description:
                'Choose which optional permissions you give in Manage your consent, and change them anytime.',
              ),
              _buildInfoPoint(
                icon: Icons.delete_sweep_outlined,
                title: 'Delete anytime',
                description:
                'When you delete your account, your profile and all logged cycle and health data are permanently removed.',
              ),
              _buildInfoPoint(
                icon: Icons.notifications_active_outlined,
                title: 'Security notifications',
                description:
                'We notify you by email about potentially suspicious activity related to your account.',
              ),
              _buildInfoPoint(
                icon: Icons.visibility_outlined,
                title: 'Only what we need',
                description:
                'We only ask for the information needed to track your cycle and make your predictions useful.',
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryPurple, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.darkerSubText, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConsentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setSheetState) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 16),
                const Text('Manage your consent',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                const SizedBox(height: 8),
                const Text(
                  'Choose how Lunary may use your information. You can change these choices at any time.',
                  style: TextStyle(fontSize: 13, color: AppColors.darkerSubText, height: 1.5),
                ),
                const SizedBox(height: 16),
                _buildConsentTile(
                  title: 'Cycle & health data',
                  description:
                  'Needed to log your periods and calculate predictions. Required to use Lunary.',
                  value: true,
                  onChanged: null,
                ),
                _buildConsentTile(
                  title: 'Analytics & app improvement',
                  description:
                  'Share anonymous usage information to help us fix bugs and improve the app.',
                  value: _ProfileDraft.consentAnalytics,
                  onChanged: (v) {
                    setSheetState(() => _ProfileDraft.consentAnalytics = v);
                  },
                ),
                _buildConsentTile(
                  title: 'Personalized insights',
                  description:
                  'Use your logged data to give you tips and insights that fit your cycle.',
                  value: _ProfileDraft.consentPersonalized,
                  onChanged: (v) {
                    setSheetState(() => _ProfileDraft.consentPersonalized = v);
                  },
                ),
                _buildConsentTile(
                  title: 'Product updates & offers',
                  description: 'Receive news about new features and updates from Lunary.',
                  value: _ProfileDraft.consentMarketing,
                  onChanged: (v) {
                    setSheetState(() => _ProfileDraft.consentMarketing = v);
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryPurple),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      setSheetState(() {
                        _ProfileDraft.consentAnalytics = false;
                        _ProfileDraft.consentPersonalized = false;
                        _ProfileDraft.consentMarketing = false;
                      });
                      _showSnackBar('Optional consent withdrawn.');
                    },
                    child: Text('Withdraw all optional consent',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showSnackBar('Consent preferences saved.');
                    },
                    child: const Text('Done',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsentTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        activeColor: AppColors.primaryPurple,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description,
              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Supaya layar digambar ulang saat tema berganti
    context.watchTheme();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
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
      case ProfileSubPage.reminders:
        return _buildRemindersPage();
      case ProfileSubPage.cycleSettings:
        return _buildCycleSettingsPage();
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
                icon: Icons.bar_chart_rounded,
                title: 'Charts & reports',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportsScreen(
                      accountId: _isLoggedIn ? _emailController.text.trim() : 'guest',
                      isMetric: _ProfileDraft.isMetric,
                    ),
                  ),
                ),
              ),
              _buildMenuItem(
                icon: Icons.water_drop_outlined,
                title: 'Cycle and ovulation',
                onTap: () => setState(() => _currentPage = ProfileSubPage.cycleSettings),
              ),
              _buildMenuItem(
                icon: Icons.category_outlined,
                title: 'Cycle type',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CycleTypeScreen()),
                ),
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Reminders',
                onTap: _openReminders,
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'App settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppSettingsScreen()),
                ),
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
                    child: Icon(Icons.security_rounded, color: AppColors.primaryPurple, size: 24),
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
                  onPressed: _showPrivacyInfoSheet,
                  child: Text('Learn more',
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
    final completeness = _profileCompleteness;
    final percent = (completeness * 100).round();

    return Column(
      children: [
        Row(
          children: [
            // Tap foto: belum ada -> tambah foto, sudah ada -> Edit / Change / Delete
            GestureDetector(
              onTap: () => _showProfilePhotoOptions(),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.avatar,
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
                    decoration: BoxDecoration(color: AppColors.primaryPink, shape: BoxShape.circle),
                    child: Icon(_profileImage == null ? Icons.add : Icons.edit, size: 10, color: Colors.white),
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
                  Text(_emailController.text,
                      style: const TextStyle(fontSize: 13, color: AppColors.darkerSubText)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _currentPage = ProfileSubPage.editProfile),
                    child: Text('Edit info',
                        style: TextStyle(fontSize: 13, color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (completeness < 1) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completeness,
                    minHeight: 6,
                    backgroundColor: AppColors.primaryPurple.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('$percent%',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
            ],
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Complete your profile to get more accurate insights.',
                style: TextStyle(fontSize: 12, color: AppColors.darkerSubText)),
          ),
        ],
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
              decoration: BoxDecoration(
                color: AppColors.avatar,
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

                // Survei siklus (sekali per akun)
                final surveyShown = await showSurveyIfNeeded(context, globalUserData!['email']!);
                if (!mounted) return;
                if (surveyShown) {
                  // Setelah survei (diisi / dilewati) langsung ke beranda
                  handleAppNavTap(context, AppNavTab.cycle);
                } else {
                  setState(() {});
                }
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
                          color: AppColors.avatar,
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
                        onTap: () => _showProfilePhotoOptions(fromEditPage: true),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primaryPurple, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showProfilePhotoOptions(fromEditPage: true),
                  child: Text(_profileImage == null ? 'Add Profile Photo' : 'Change Profile Picture',
                      style: TextStyle(
                          color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13)),
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
                          items: ['Female', 'Male', 'Other', 'Prefer not to say'].map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (newValue) => setState(() => _selectedGender = newValue),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Metric system (dipindah dari App Settings)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SwitchListTile(
                    activeColor: AppColors.primaryPurple,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    title: const Text('Metric system (kg, cm)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                    subtitle: Text(_isMetricSystem ? 'Using kg and cm' : 'Using lb and in',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    value: _isMetricSystem,
                    onChanged: _onMetricChanged,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Height',
                        controller: _heightController,
                        icon: Icons.height,
                        hintText: _isMetricSystem ? 'e.g. 160' : 'e.g. 63',
                        suffixText: _isMetricSystem ? 'cm' : 'in',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: 'Weight',
                        controller: _weightController,
                        icon: Icons.monitor_weight_outlined,
                        hintText: _isMetricSystem ? 'e.g. 52' : 'e.g. 115',
                        suffixText: _isMetricSystem ? 'kg' : 'lb',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  // ---------------------------------------------------------------------------
  // Reminders
  // ---------------------------------------------------------------------------

  /// Cek ulang izin saat user kembali dari layar pengaturan "Alarms & reminders".
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _currentPage == ProfileSubPage.reminders) {
      _refreshReminders();
    }
  }

  Future<void> _openReminders() async {
    setState(() {
      _currentPage = ProfileSubPage.reminders;
      _reminderChecking = true;
    });
    await _refreshReminders();
  }

  Future<void> _refreshReminders() async {
    final granted = await ReminderService.hasPermission();
    final on = <String, bool>{};
    final times = <String, TimeOfDay>{};
    for (final d in _reminderDefs) {
      on[d.key] = await ReminderService.isEnabled(d.key);
      times[d.key] = await ReminderService.getTime(d.key, d.defaultTime);
    }
    if (!mounted) return;
    setState(() {
      _reminderPermission = granted;
      _reminderOn
        ..clear()
        ..addAll(on);
      _reminderTime
        ..clear()
        ..addAll(times);
      _reminderChecking = false;
    });
  }

  Future<void> _allowReminders() async {
    final result = await ReminderService.requestPermission();
    await _refreshReminders();
    if (!mounted) return;

    if (result == ReminderPermissionResult.notificationsDenied) {
      _showSnackBar('Notifications are blocked. Please allow them in your phone settings.');
    } else if (result == ReminderPermissionResult.needsAlarmPermission) {
      _showSnackBar('Please allow "Alarms & reminders" for Lunary, then come back.');
    }
  }

  Future<void> _toggleReminder(_ReminderDef d, bool value) async {
    final time = _reminderTime[d.key] ?? d.defaultTime;
    try {
      if (value) {
        await ReminderService.enableDaily(
          key: d.key,
          id: d.id,
          title: d.title,
          body: d.body,
          time: time,
        );
      } else {
        await ReminderService.disable(key: d.key, id: d.id);
      }
      if (!mounted) return;
      setState(() => _reminderOn[d.key] = value);
      _showSnackBar(value ? '${d.title} set for ${time.format(context)}' : '${d.title} turned off');
    } catch (e) {
      _showSnackBar('Could not set the alarm. Please check the alarm permission.');
    }
  }

  Future<void> _pickReminderTime(_ReminderDef d) async {
    final current = _reminderTime[d.key] ?? d.defaultTime;
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;

    try {
      await ReminderService.enableDaily(
        key: d.key,
        id: d.id,
        title: d.title,
        body: d.body,
        time: picked,
      );
      if (!mounted) return;
      setState(() {
        _reminderTime[d.key] = picked;
        _reminderOn[d.key] = true;
      });
      _showSnackBar('${d.title} set for ${picked.format(context)}');
    } catch (e) {
      _showSnackBar('Could not set the alarm. Please check the alarm permission.');
    }
  }

  Future<void> _sendTestAlarm() async {
    try {
      await ReminderService.scheduleTest();
      _showSnackBar('Test alarm will ring in 10 seconds.');
    } catch (e) {
      _showSnackBar('Could not set the test alarm.');
    }
  }

  Widget _buildRemindersPage() {
    return Column(
      key: const ValueKey('RemindersPage'),
      children: [
        _buildSubPageHeader('Reminders'),
        Expanded(
          child: _reminderChecking
              ? Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
              : !_reminderPermission
              ? _buildReminderPermissionGate()
              : _buildReminderList(),
        ),
      ],
    );
  }

  /// Ditampilkan sebelum user bisa mengatur alarm.
  Widget _buildReminderPermissionGate() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.alarm, color: AppColors.primaryPurple, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Allow Lunary to use alarms?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const SizedBox(height: 10),
              const Text(
                'Lunary needs permission to send notifications and set alarms so your reminders ring at the time you choose.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.darkerSubText, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _allowReminders,
                  child: const Text('Allow',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => setState(() => _currentPage = ProfileSubPage.main),
                child: const Text('Not now', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderList() {
    final sections = <String>[];
    for (final d in _reminderDefs) {
      if (!sections.contains(d.section)) sections.add(d.section);
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final s in sections) _buildReminderSection(s),
      ],
    );
  }

  Widget _buildReminderSection(String section) {
    final defs = _reminderDefs.where((d) => d.section == section).toList();
    final tiles = <Widget>[];
    for (int i = 0; i < defs.length; i++) {
      tiles.add(_buildReminderTile(defs[i]));
      if (i != defs.length - 1) tiles.add(Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(section,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
        ),
        _buildCardContainer(tiles),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReminderTile(_ReminderDef d) {
    final on = _reminderOn[d.key] ?? false;
    final time = _reminderTime[d.key] ?? d.defaultTime;

    return ListTile(
      onTap: () => _pickReminderTime(d),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(d.icon, color: AppColors.primaryPurple),
      title: Text(d.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
      subtitle: Text(on ? time.format(context) : 'Off',
          style: TextStyle(fontSize: 12, color: on ? AppColors.primaryPurple : Colors.grey)),
      trailing: Switch(
        value: on,
        activeColor: AppColors.primaryPurple,
        onChanged: (v) => _toggleReminder(d, v),
      ),
    );
  }

  /// Ubah satu pengaturan siklus, simpan ke akun, dan segarkan kalender/beranda.
  void _updateCycleSetting(VoidCallback update) {
    setState(update);
    CycleSettings.save();
    context.read<CycleProvider>().onSettingsChanged();
  }

  // ---------------------------------------------------------------------------
  // Cycle and ovulation
  // ---------------------------------------------------------------------------

  Widget _buildCycleSettingsPage() {
    return Column(
      key: const ValueKey('CycleSettingsPage'),
      children: [
        _buildSubPageHeader('Cycle and ovulation'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Durasi siklus & periode
                    _buildNumberDropdown(
                      label: 'Cycle length (days)',
                      value: CycleSettings.cycleLength,
                      min: 20,
                      max: 100,
                      onChanged: (v) => _updateCycleSetting(() => CycleSettings.cycleLength = v),
                    ),
                    _buildNumberDropdown(
                      label: 'Period length (days)',
                      value: CycleSettings.periodLength,
                      min: 1,
                      max: 12,
                      onChanged: (v) => _updateCycleSetting(() => CycleSettings.periodLength = v),
                    ),
                    _buildSettingDescription(
                      'The app predicts based on your cycle length and period length settings. '
                          'However, if you log your periods regularly, predictions will follow the data you have logged.',
                    ),
                    _buildSettingDivider(),

                    // Peluang hamil
                    SwitchListTile(
                      activeColor: AppColors.primaryPurple,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: const Text('Chance of pregnancy',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                      value: CycleSettings.showPregnancyChance,
                      onChanged: (v) => _updateCycleSetting(() => CycleSettings.showPregnancyChance = v),
                    ),
                    _buildSettingDescription(
                      'If you turn this off, only your ovulation day will be shown.',
                    ),
                    _buildSettingDivider(),

                    // Fase luteal
                    _buildNumberDropdown(
                      label: 'Luteal phase (days)',
                      value: CycleSettings.lutealPhase,
                      min: 8,
                      max: 17,
                      onChanged: (v) => _updateCycleSetting(() => CycleSettings.lutealPhase = v),
                    ),
                    _buildSettingDescription(
                      'The luteal phase is the time between ovulation and the start of your next period. '
                          'If you know how long your luteal phase is, enter it for more accurate ovulation predictions.',
                    ),
                    _buildSettingDivider(),

                    // Tampilkan hari siklus
                    SwitchListTile(
                      activeColor: AppColors.primaryPurple,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: const Text('Show cycle days',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                      value: CycleSettings.showCycleDays,
                      onChanged: (v) => _updateCycleSetting(() => CycleSettings.showCycleDays = v),
                    ),
                    _buildSettingDescription(
                      'Cycle days (day 1, 2, 3, etc.) will be shown right above the calendar dates.',
                    ),
                    const SizedBox(height: 4),
                    _buildCycleDayPreview(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberDropdown({
    required String label,
    required int? value,
    required int min,
    required int max,
    required ValueChanged<int?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
          ),
          SizedBox(
            width: 110,
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              menuMaxHeight: 300,
              hint: Text('Select', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              underline: Container(height: 1, color: Colors.grey.shade300),
              items: List.generate(max - min + 1, (i) {
                final n = min + i;
                return DropdownMenuItem<int>(
                  value: n,
                  child: Text('$n', style: const TextStyle(fontSize: 14, color: AppColors.darkText)),
                );
              }),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingDescription(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Text(text, style: const TextStyle(fontSize: 12.5, color: Colors.grey, height: 1.4)),
    );
  }

  Widget _buildSettingDivider() {
    return Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300);
  }

  /// Contoh tampilan hari siklus: hari haid (pink penuh), prediksi haid (pink garis),
  /// masa subur (teal), dan hari ovulasi (teal garis).
  Widget _buildCycleDayPreview() {
    const teal = Color(0xFF26A69A);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPreviewDay('3', color: AppColors.primaryPink, filled: true),
          _buildPreviewDay('4', color: AppColors.primaryPink, filled: true),
          _buildPreviewDay('5', color: AppColors.primaryPink, filled: true),
          _buildPreviewDay('6', color: AppColors.primaryPink, outlined: true),
          _buildPreviewDay('7', color: teal),
          _buildPreviewDay('8', color: teal, outlined: true),
          _buildPreviewDay('9', color: teal),
        ],
      ),
    );
  }

  Widget _buildPreviewDay(String text, {required Color color, bool filled = false, bool outlined = false}) {
    return Container(
      width: 38,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: outlined ? Border.all(color: color, width: 2) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: filled ? Colors.white : color,
        ),
      ),
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
                  onTap: _showPrivacyInfoSheet,
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('My Privacy'),
              _buildCardContainer([
                _buildListTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Manage your consent',
                  subtitle: 'Choose and control your privacy options.',
                  onTap: _showConsentSheet,
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('ALWAYS ACTIVE'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Security notifications',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    SizedBox(height: 6),
                    Text(
                      'You will automatically receive notifications about potentially suspicious activity related to your account.',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey, height: 1.4),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 12, 4, 0),
                child: Text(
                  'Security notifications will be sent to the email linked to your Lunary account.',
                  style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                ),
              ),
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
                  color: AppColors.softTint,
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
                        prefixIcon: Icon(Icons.search, color: AppColors.primaryPurple),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Text('No help topics found.',
                          style: TextStyle(fontSize: 13, color: AppColors.darkerSubText)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _openLunaryAI,
                        child: Text('Ask Lunary AI instead',
                            style: TextStyle(
                                color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                      ),
                    ],
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
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(faq['a'].toString(),
                                      style: const TextStyle(
                                          fontSize: 12, color: AppColors.darkerSubText, height: 1.4)),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 4),
              // Arahkan user ke Lunary AI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.auto_awesome,
                              color: AppColors.primaryPurple, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Still need help?',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText)),
                              SizedBox(height: 2),
                              Text(
                                "Can't find your answer? Ask Lunary AI and get help right away.",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.darkerSubText,
                                    height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _openLunaryAI,
                        icon: const Icon(Icons.auto_awesome,
                            size: 18, color: Colors.white),
                        label: const Text('Ask Lunary AI',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
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
    String? suffixText,
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
            suffixText: suffixText,
            suffixStyle: const TextStyle(fontSize: 13, color: AppColors.darkerSubText),
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
                borderSide: BorderSide(color: AppColors.primaryPurple, width: 2)),
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

  Widget _buildListTile({
    required IconData icon,
    Color? iconColor,
    required String title,
    Color titleColor = AppColors.darkText,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: iconColor ?? AppColors.primaryPurple, size: 24),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: titleColor)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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
