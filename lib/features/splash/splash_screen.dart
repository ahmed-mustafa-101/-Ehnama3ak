import 'package:ehnama3ak/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/core/widgets/main_layout.dart';
import '../auth/presentation/controllers/auth_cubit.dart';
import '../auth/presentation/controllers/auth_state.dart';
import '../welcome/welcome_screen.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/splash_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        }
      },
      child: Scaffold(
        body: SplashBackground(
          useSafeArea: true,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: Responsive.spacing(context, 40)),

                    // Logo
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.padding(context, 20),
                        ),
                        child: Image.asset(
                          'assets/images/image_started1.png',
                          width: Responsive.width(context, 0.7),
                          height: Responsive.height(context, 0.35),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: Responsive.spacing(context, 300)),
                    // const Spacer(),

                    // Bottom section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.padding(context, 20),
                        vertical: Responsive.padding(context, 30),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.padding(context, 20),
                            ),
                            child: Text(
                              'Get Ready For The World Of\nPsychosocial Support.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 20),
                                height: 1.3,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 40)),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.valueByDevice(
                                context: context,
                                mobile: 40,
                                tablet: 100,
                                desktop: 150,
                              ),
                            ),
                            child: AppButton(
                              height: Responsive.height(
                                context,
                                0.05,
                              ).clamp(45, 60),
                              width: Responsive.width(context, 0.5),
                              radius: Responsive.borderRadius(context, 18),
                              textStyle: TextStyle(
                                fontSize: Responsive.fontSize(context, 16),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const WelcomeScreen(),
                                  ),
                                );
                              },
                              label: 'Get Started',
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 30)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
