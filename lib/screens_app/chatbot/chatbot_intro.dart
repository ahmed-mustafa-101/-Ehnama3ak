import 'package:ehnama3ak/core/widgets/app_button.dart';
import 'package:ehnama3ak/core/utils/responsive.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/app_icon_back.dart';
import 'chatbot_screen.dart';

class ChatbotIntroScreen extends StatelessWidget {
  final VoidCallback? onStart;
  final VoidCallback? onClose;
  const ChatbotIntroScreen({super.key, this.onStart, this.onClose});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.padding(context, 8)),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: Responsive.spacing(context, 12)),
                  child: IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 10)),
          Text(
            AppLocalizations.of(context).chatbotTitle,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 26),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E88E5),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 12)),

          // Responsive Row/Column based on screen size
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, 20),
            ),
            child: screenWidth < 400
                ? Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.padding(context, 10),
                        ),
                        child: Text(
                          AppLocalizations.of(context).chatbotDesc,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 15),
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF374957),
                            height: 1.4,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 10)),
                      SizedBox(
                        height: Responsive.height(context, 0.12),
                        width: Responsive.width(context, 0.25),
                        child: Image.asset(
                          'assets/images/chatbot.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.padding(context, 10),
                          ),
                          child: Text(
                            AppLocalizations.of(context).chatbotDesc,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 15),
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF374957),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.spacing(context, 10)),
                      Flexible(
                        flex: 1,
                        child: SizedBox(
                          height: Responsive.height(context, 0.12),
                          child: Image.asset(
                            'assets/images/chatbot.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: Responsive.spacing(context, 20)),

          // Main image
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, 20),
            ),
            child: Image.asset(
              'assets/images/imagchat.png',
              fit: BoxFit.contain,
              width: Responsive.width(context, 0.8),
              height: Responsive.height(context, 0.3),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 40)),

          // Get Started Button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.valueByDevice(
                context: context,
                mobile: 40,
                tablet: 100,
                desktop: 130,
              ),
            ),
              child: AppButton(
              label: AppLocalizations.of(context).getStarted,
              height: Responsive.height(context, 0.05).clamp(45, 55),
              width: Responsive.width(context, 0.4),
              textStyle: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              onPressed: () {
                if (onStart != null) {
                  onStart!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                  );
                }
              },
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 40)),
        ],
      ),
    );
  }
}
