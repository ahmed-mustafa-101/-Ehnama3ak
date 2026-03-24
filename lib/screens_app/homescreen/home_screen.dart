import 'package:flutter/material.dart';
import '../../screen_tap/help_screen/help_screen.dart';
import '../../screen_tap/settings_screen.dart';
import '../../screen_tap/for_you.dart';
import '../../screen_tap/myprogress.dart';
import '../../screen_tap/therapists.dart';
import '../../screen_tap/resources.dart';

import '../../core/models/user_role.dart';
import '../../core/storage/pref_manager.dart';

class HomeScreen extends StatefulWidget {
  final int initialSubTab;
  
  const HomeScreen({super.key, this.initialSubTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedTab;
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialSubTab;
    _loadRole();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSubTab != oldWidget.initialSubTab) {
      setState(() {
        _selectedTab = widget.initialSubTab;
      });
    }
  }

  Future<void> _loadRole() async {
    final role = await PrefManager.getUserRole();
    if (!mounted) return;
    setState(() {
      _userRole = role;
    });
  }

  void setSubTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentSubPage;
    
    // For Doctors, strictly show the ForYouPage as the Home content
    if (_userRole == UserRole.doctor) {
      return const ForYouPage();
    }

    // For Patients, handle the sub-tab selection (managed by AppDrawer)
    switch (_selectedTab) {
      case 0:
        currentSubPage = const ForYouPage();
        break;
      case 1:
        currentSubPage = const MyProgressPage();
        break;
      case 2:
        currentSubPage = const TherapistsPage();
        break;
      case 3:
        currentSubPage = const Resources();
        break;
      case 4:
        currentSubPage = const SettingsScreen();
        break;
      case 5:
        currentSubPage = const HelpScreen();
        break;
      default:
        currentSubPage = const ForYouPage();
    }

    return currentSubPage;
  }
}
