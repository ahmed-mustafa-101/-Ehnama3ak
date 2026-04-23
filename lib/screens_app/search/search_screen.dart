import 'package:flutter/material.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:ehnama3ak/screen_tap/therapists.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/screen_tap/therapist/presentation/cubit/doctor_cubit.dart';

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
        const SizedBox(height: 100),
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
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
              _TabPage(index: 0, controller: _pageController),
              const TherapistsPage(showHeader: false),
              _TabPage(index: 2, controller: _pageController),
              _TabPage(index: 3, controller: _pageController),
              _TabPage(index: 4, controller: _pageController),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabPage extends StatelessWidget {
  final int index;
  final PageController controller;

  const _TabPage({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.recent,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
              GestureDetector(
                onTap: () {
                  if (index < 4) {
                    controller.animateToPage(index + 1,
                        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  }
                },
                child: Text(l10n.seeAll,
                    style: const TextStyle(color: Color(0xFF0DA5FE), fontSize: 14)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              return Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFF7FAFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(l10n.translate('content_placeholder'),
                      style: const TextStyle(color: Colors.grey)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
