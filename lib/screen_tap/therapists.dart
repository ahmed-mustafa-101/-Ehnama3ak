import 'package:flutter/material.dart';

class TherapistsPage extends StatefulWidget {
  const TherapistsPage({super.key});

  @override
  State<TherapistsPage> createState() => _TherapistsPageState();
}

class _TherapistsPageState extends State<TherapistsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 150,
                width: 400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: Theme.of(context).brightness == Brightness.dark
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
                            'Search a doctor',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: Image.asset(
                        'assets/images/therapy.png',
                        width: 250,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
