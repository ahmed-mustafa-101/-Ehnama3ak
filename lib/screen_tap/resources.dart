import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
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
    context.read<ResourceCubit>().fetchResources();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    setState(() => _selectedTab = index);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return BlocListener<ResourceCubit, ResourceState>(
      listenWhen: (prev, curr) => curr is ResourceError && prev is! ResourceLoading,
      listener: (context, state) {
        if (state is ResourceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: isDark
                          ? [const Color(0xFF1E88E5), const Color(0xFF2C3E50)]
                          : [const Color(0xFFD7F0FF), const Color(0xFFEAEAEA)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 40, width: 200,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: const Color(0xFF1F3A4A), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search, color: Colors.white, size: 28),
                            const SizedBox(width: 6),
                            Text(l10n.searchResources, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _tabItem(l10n.articles, 0, isDark),
                          _tabItem(l10n.videos, 1, isDark),
                          _tabItem(l10n.downloads, 2, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _selectedTab = i),
                  children: const [ArticlesTab(), VideosTab(), DownloadsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabItem(String title, int index, bool isDark) {
    final bool selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: Text(title,
          style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: selected
                ? (isDark ? Colors.white : const Color(0xFF1E88E5))
                : (isDark ? Colors.white60 : Colors.blueGrey.shade600),
          )),
    );
  }
}
