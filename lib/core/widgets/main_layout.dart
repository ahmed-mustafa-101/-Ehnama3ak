import 'package:ehnama3ak/screens_app/messages/messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/pref_manager.dart';
import '../../core/models/user_role.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/welcome/welcome_screen.dart';
import 'package:ehnama3ak/screens_app/chatbot/chatbot_wrapper.dart';
import '../../screens_app/homescreen/home_screen.dart';
import '../../screens_app/podcaste/podcasts_screen.dart';
import '../../screens_app/profile/profile_view.dart';
import '../../screens_app/search/search_screen.dart';
import '../../screens_app/doctor/doctor_help_screen.dart';
import '../../screens_app/doctor/doctor_settings_screen.dart';
import '../../screens_app/doctor/patients_screen.dart';
import '../../screens_app/doctor/reports_screen.dart';
import '../../screens_app/doctor/sessions_screen.dart';
import '../../screens_app/widgets/doctor_drawer.dart';
import '../../screens_app/widgets/patient_drawer.dart';
import '../../screens_app/notifications/notifications_screen.dart';
import 'app_bottom_nav_bar.dart';
import 'custom_app_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  static MainLayoutState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainLayoutState>();
  }

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  int _homeSubTab =
      0; // Track which sub-tab is active in HomeScreen for patients
  UserRole? _userRole;
  String? _profileImageUrl;
  bool _showNotifications = false; // Track if notifications overlay is shown
  bool _showMessages = false;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
      _showNotifications = false; // Close notifications when changing tabs
      _showMessages = false;
    });
  }

  void changeHomeSubTab(int subTabIndex) {
    if (!mounted) return;
    setState(() {
      _currentIndex = 0; // Navigate to HomeScreen
      _homeSubTab = subTabIndex; // Set the sub-tab
      _showNotifications = false; // Close notifications
      _showMessages = false;
    });
  }

  void toggleNotifications() {
    if (!mounted) return;
    setState(() {
      _showNotifications = !_showNotifications;
    });
  }

  void toggleMessages() {
    if (!mounted) return;
    setState(() {
      _showMessages = !_showMessages;
    });
  }

  @override
  void initState() {
    super.initState();
    PrefManager.trackActiveDay(); // Track this session
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final role = await PrefManager.getUserRole();
    final imageUrl = await PrefManager.getUserProfileImageUrl();
    if (!mounted) return;
    setState(() {
      _userRole = role;
      _profileImageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
          );
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_userRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDoctor = _userRole == UserRole.doctor;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> screens = isDoctor
        ? [
            HomeScreen(initialSubTab: _homeSubTab), // 0
            const SearchScreen(), // 1
            const ChatbotWrapper(), // 2
            const PodcastsScreen(), // 3
            const ProfileView(), // 4
            const DoctorSessionsScreen(), // 5
            const DoctorPatientsScreen(), // 6
            const DoctorReportsScreen(), // 7
            const DoctorSettingsScreen(), // 8
            const DoctorHelpScreen(), // 9
          ]
        : [
            HomeScreen(initialSubTab: _homeSubTab), // 0
            const SearchScreen(), // 1
            const ChatbotWrapper(), // 2
            const PodcastsScreen(), // 3
            const ProfileView(), // 4
          ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      drawer: isDoctor
          ? DoctorDrawer(
              selectedIndex: _getDrawerIndex(_currentIndex),
              onSelect: (index) {
                final targetIndex = _mapDrawerToStackIndex(index);
                changeTab(targetIndex);
                Navigator.pop(context);
              },
            )
          : AppDrawer(
              selectedIndex: _homeSubTab,
              onSelect: (index) {
                if (index >= 0 && index <= 5) {
                  changeHomeSubTab(index);
                }
                Navigator.pop(context);
              },
            ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                CustomAppBar(
                  onNotificationTap: toggleNotifications,
                  onMessageTap: toggleMessages,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: screens),
                ),
              ],
            ),
          ),
          // Notifications Overlay
          if (_showNotifications)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(child: const NotificationsScreen()),
                  ),
                ),
              ),
            ),

          if (_showMessages)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(child: const MessagesScreen()),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: changeTab,
        profileImageUrl: _profileImageUrl,
      ),
      floatingActionButton:
          (_currentIndex == 0 ||
              _currentIndex == 1 ||
              _currentIndex == 3 ||
              _currentIndex == 4)
          ? GestureDetector(
              onTap: () {
                // Navigate to chatbot tab (index 2)
                changeTab(2);
              },
              child: SizedBox(
                width: 80,
                height: 100,
                child: Image.asset(
                  'assets/images/chatbot.png',
                  fit: BoxFit.contain,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  int _getDrawerIndex(int stackIndex) {
    if (stackIndex == 0) return 0;
    if (stackIndex < 5) return -1;
    return stackIndex - 4; // 5 -> 1, 6 -> 2, etc.
  }

  int _mapDrawerToStackIndex(int drawerIndex) {
    if (drawerIndex == 0) return 0;
    if (drawerIndex < 0) return _currentIndex;
    return drawerIndex + 4; // 1 -> 5, 2 -> 6, etc.
  }
}
