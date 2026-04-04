import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
  });

  final int currentIndex;
  final Function(int) onTap;
  final String? profileImageUrl;

  String _getCorrectImageUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http')) return url;
    const baseUrl = 'http://e7nama3ak.runasp.net';
    if (url.startsWith('/')) return '$baseUrl$url';
    return '$baseUrl/$url';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: currentIndex > 4 ? 0 : currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E88E5),
      unselectedItemColor: Colors.blueGrey.shade300,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      iconSize: 35,
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded), label: l10n.home),
        BottomNavigationBarItem(
            icon: const Icon(Icons.search_rounded), label: l10n.search),
        BottomNavigationBarItem(
            icon: const Icon(Icons.smart_toy_outlined), label: l10n.bot),
        BottomNavigationBarItem(
            icon: const Icon(Icons.graphic_eq_outlined), label: l10n.podcasts),
        BottomNavigationBarItem(
          icon: profileImageUrl != null && profileImageUrl!.isNotEmpty
              ? Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                          _getCorrectImageUrl(profileImageUrl!)),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: currentIndex == 4
                          ? const Color(0xFF1E88E5)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                )
              : const Icon(Icons.account_circle),
          label: l10n.profile,
        ),
      ],
    );
  }
}
