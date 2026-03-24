import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/features/resources/presentation/cubit/resource_cubit.dart';
import 'package:ehnama3ak/features/resources/presentation/cubit/resource_state.dart';

import 'widgets_resources/articles_tab.dart';
import 'widgets_resources/downloads_tab.dart';
import 'widgets_resources/videos_tab.dart';

class Resources extends StatefulWidget {
  const Resources({super.key});

  @override
  State<Resources> createState() => _ResourcesState();
}

class _ResourcesState extends State<Resources> {
  int _selectedTab = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Kick off the API call as soon as the screen mounts.
    context.read<ResourceCubit>().fetchResources();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    setState(() => _selectedTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for errors that arrive *after* a loaded state
    // (e.g. after a failed createResource) so we can show a snackbar.
    return BlocListener<ResourceCubit, ResourceState>(
      listenWhen: (prev, curr) => curr is ResourceError && prev is! ResourceLoading,
      listener: (context, state) {
        if (state is ResourceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ===== HEADER CARD (SEARCH + TABS) =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [const Color(0xFF1E88E5), const Color(0xFF2C3E50)]
                          : [const Color(0xFFD7F0FF), const Color(0xFFEAEAEA)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      // ===== SEARCH =====
                      Container(
                        height: 40,
                        width: 200,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F3A4A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white, size: 28),
                            SizedBox(width: 6),
                            Text(
                              'Search a resources',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // ===== TABS =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _tabItem('Articles', 0),
                          _tabItem('Videos', 1),
                          _tabItem('Downloads', 2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===== CONTENT =====
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) {
                    setState(() => _selectedTab = i);
                  },
                  children: const [ArticlesTab(), VideosTab(), DownloadsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== TAB ITEM =====
  Widget _tabItem(String title, int index) {
    final bool selected = _selectedTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: selected
              ? (isDark ? Colors.white : const Color(0xFF1E88E5))
              : (isDark ? Colors.white60 : Colors.blueGrey.shade600),
        ),
      ),
    );
  }
}
