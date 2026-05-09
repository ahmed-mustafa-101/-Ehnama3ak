import 'package:flutter/material.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:ehnama3ak/screen_tap/therapists.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/screen_tap/therapist/presentation/cubit/doctor_cubit.dart';
import 'package:ehnama3ak/screen_tap/widgets_resources/articles_tab.dart';
import 'package:ehnama3ak/screen_tap/widgets_resources/videos_tab.dart';
import 'package:ehnama3ak/screen_tap/widgets_resources/downloads_tab.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final Function(int)? onDrawerItemTap;

  const SearchScreen({super.key, this.onNotificationTap, this.onDrawerItemTap});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color primaryColor = Color(0xFF0DA5FE);

  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  int _currentIndex = 0;
  String searchText = '';

  List<String> _getTabs(AppLocalizations l10n) => [
    'All',
    l10n.therapists,
    l10n.articles,
    l10n.downloads,
    l10n.videos,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = _getTabs(l10n);

    return Column(
      children: [
        // const SizedBox(height: 100),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => searchText = value);
                context.read<DoctorCubit>().searchDoctors(value);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.grey),
                hintText: l10n.searchHint,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final bool selected = _currentIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() => _currentIndex = index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? primaryColor
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: [
              AllTab(controller: _pageController),
              const TherapistsPage(showHeader: false),
              const ArticlesTab(),
              const DownloadsTab(),
              const VideosTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class AllTab extends StatelessWidget {
  final PageController controller;

  const AllTab({super.key, required this.controller});

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              l10n.seeAll,
              style: const TextStyle(color: Color(0xFF0DA5FE), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        const SizedBox(height: 10),
        _buildSectionHeader(context, l10n.therapists, () {
          controller.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }),
        const SizedBox(height: 10),
        const SizedBox(height: 350, child: TherapistsPage(showHeader: false)),
        const SizedBox(height: 20),
        _buildSectionHeader(context, l10n.articles, () {
          controller.animateToPage(
            2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }),
        const SizedBox(height: 10),
        const SizedBox(height: 350, child: ArticlesTab()),
        const SizedBox(height: 20),
        _buildSectionHeader(context, l10n.videos, () {
          controller.animateToPage(
            4,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }),
        const SizedBox(height: 10),
        const SizedBox(height: 350, child: VideosTab()),
        const SizedBox(height: 20),
      ],
    );
  }
}
