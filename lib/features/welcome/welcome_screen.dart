import 'package:ehnama3ak/core/widgets/app_icon_back.dart';
import 'package:ehnama3ak/features/auth/signup_patient.dart';
import 'package:flutter/material.dart';
import '../auth/signup_doctor.dart';
import '../auth/login_screen.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_button.dart';
import '../../core/utils/responsive.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = Responsive.getMaxContentWidth(context);

    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: [
            AppIconBack(
              top: Responsive.spacing(context, 70),
              left: Responsive.spacing(context, 12),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: Responsive.spacing(context, 90)),
                        Center(
                          child: Image.asset(
                            'assets/images/Frame 6.png',
                            width: Responsive.width(context, 0.8),
                            height: Responsive.height(context, 0.25),
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 40)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.padding(context, 18),
                            vertical: Responsive.padding(context, 12),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: Responsive.spacing(context, 40)),
                              Text(
                                'Continue as:',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 26),
                                  color: const Color(0xff335777),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 30)),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.valueByDevice(
                                    context: context,
                                    mobile: 20,
                                    tablet: 100,
                                    desktop: 150,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _roleButton(
                                      context,
                                      'Patient (user)',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const PatientSignupScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: Responsive.spacing(context, 20),
                                    ),
                                    _roleButton(
                                      context,
                                      'Doctor',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const DoctorSignupScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 40)),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: Responsive.fontSize(
                                        context,
                                        15,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Responsive.fontSize(
                                          context,
                                          16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.spacing(context, 20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(
    BuildContext context,
    String label, {
    required VoidCallback onTap,
  }) {
    return AppButton(
      width: Responsive.width(context, 0.5),
      height: Responsive.height(context, 0.06).clamp(50, 70),
      radius: Responsive.borderRadius(context, 18),
      elevation: 6,
      textStyle: TextStyle(
        fontSize: Responsive.fontSize(context, 18),
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      onPressed: onTap,
      label: label,
    );
  }
}
