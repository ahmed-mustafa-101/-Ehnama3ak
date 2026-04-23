import 'dart:ui';
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class _NavItem {
  final IconData icon;
  final String label;
  final bool isProfile;

  _NavItem({required this.icon, required this.label, this.isProfile = false});
}

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navItems = [
      _NavItem(icon: Icons.home_rounded, label: l10n.home),
      _NavItem(icon: Icons.search_rounded, label: l10n.search),
      _NavItem(icon: Icons.smart_toy_outlined, label: l10n.bot),
      _NavItem(icon: Icons.graphic_eq_outlined, label: l10n.podcasts),
      _NavItem(
        icon: Icons.account_circle,
        label: l10n.profile,
        isProfile: true,
      ),
    ];

    final activeIndex = currentIndex > 4 ? 0 : currentIndex;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 16, top: 4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.5),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    final isSelected = activeIndex == index;

                    return GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 14 : 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E88E5).withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              scale: isSelected ? 1.05 : 0.95,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              child:
                                  item.isProfile &&
                                      profileImageUrl != null &&
                                      profileImageUrl!.isNotEmpty
                                  ? Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            _getCorrectImageUrl(
                                              profileImageUrl!,
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF1E88E5)
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF1E88E5,
                                                  ).withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    )
                                  : Container(
                                      decoration: isSelected
                                          ? BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF1E88E5,
                                                  ).withValues(alpha: 0.35),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            )
                                          : null,
                                      child: Icon(
                                        item.icon,
                                        size: 30,
                                        color: isSelected
                                            ? const Color(0xFF1E88E5)
                                            : Colors.blueGrey.shade400,
                                      ),
                                    ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.centerLeft,
                              child: AnimatedOpacity(
                                opacity: isSelected ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: isSelected
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          left: 6.0,
                                        ),
                                        child: Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.clip,
                                          style: const TextStyle(
                                            color: Color(0xFF1E88E5),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
