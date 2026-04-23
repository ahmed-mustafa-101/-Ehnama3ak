import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon_back.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/utils/responsive.dart';
import 'package:ehnama3ak/core/widgets/main_layout.dart';
import 'presentation/controllers/auth_cubit.dart';
import 'presentation/controllers/auth_state.dart';

class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  State<DoctorSignupScreen> createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends State<DoctorSignupScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  int _currentStep = 1;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController pass2Ctrl = TextEditingController();

  final TextEditingController nationalNumCtrl = TextEditingController();
  final TextEditingController specializationCtrl = TextEditingController();
  final TextEditingController experienceCtrl = TextEditingController();
  final TextEditingController aboutCtrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    nationalNumCtrl.dispose();
    specializationCtrl.dispose();
    experienceCtrl.dispose();
    aboutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = Responsive.getMaxContentWidth(context);

    return Theme(
      data: ThemeData.light(),
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainLayout()),
                  (route) => false,
                );
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              final step = state is AuthLoading ? 2 : _currentStep;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: Responsive.spacing(context, 70)),
                        // HEADER
                        SizedBox(
                          height: Responsive.height(context, 0.30),
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/Frame 62.png',
                                  width: Responsive.width(context, 0.7),
                                  height: Responsive.height(context, 0.25),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              AppIconBack(
                                top: 0,
                                left: Responsive.spacing(context, 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 40)),
                        Text(
                          'Create an doctor account',
                          style: TextStyle(
                            color: const Color(0xff335777),
                            fontSize: Responsive.fontSize(context, 22),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 20)),

                        // ANIMATED STEPS
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: step == 1
                              ? _buildStep1(context)
                              : _buildStep2(context, state is AuthLoading),
                        ),
                        SizedBox(height: Responsive.spacing(context, 20)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return Padding(
      key: const ValueKey(1),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.valueByDevice(
          context: context,
          mobile: 30,
          tablet: 80,
          desktop: 120,
        ),
      ),
      child: Form(
        key: _step1FormKey,
        child: Column(
          children: [
            // Name
            AppTextField(
              controller: nameCtrl,
              hintText: 'Name',
              prefixIcon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter name' : null,
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            // Email
            AppTextField(
              controller: emailCtrl,
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter email';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim()))
                  return 'Enter valid email';
                return null;
              },
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            // Password
            AppTextField(
              controller: passCtrl,
              hintText: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscure1,
              showObscureToggle: true,
              onObscureToggle: () => setState(() => _obscure1 = !_obscure1),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter password';
                if (v.length < 6) return 'Password must be >= 6 chars';
                return null;
              },
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            // Confirm Password
            AppTextField(
              controller: pass2Ctrl,
              hintText: 'Retype password',
              prefixIcon: Icons.refresh,
              obscureText: _obscure2,
              showObscureToggle: true,
              onObscureToggle: () => setState(() => _obscure2 = !_obscure2),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Retype password';
                if (v != passCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),
            SizedBox(height: Responsive.spacing(context, 30)),

            AppButton(
              width: double.infinity,
              height: Responsive.height(context, 0.065).clamp(48, 60),
              radius: Responsive.borderRadius(context, 12),
              textStyle: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                color: Colors.white,
              ),
              onPressed: () {
                if (_step1FormKey.currentState?.validate() ?? false) {
                  setState(() => _currentStep = 2);
                }
              },
              label: 'Next',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(BuildContext context, bool isLoading) {
    return Padding(
      key: const ValueKey(2),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.valueByDevice(
          context: context,
          mobile: 30,
          tablet: 80,
          desktop: 120,
        ),
      ),
      child: Form(
        key: _step2FormKey,
        child: Column(
          children: [
            // National Number
            AppTextField(
              controller: nationalNumCtrl,
              hintText: 'National number',
              prefixIcon: Icons.badge_outlined,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter national number'
                  : null,
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            // Specialization
            AppTextField(
              controller: specializationCtrl,
              hintText: 'Specialization',
              prefixIcon: Icons.person_search_outlined,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter specialization'
                  : null,
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            // Years of Experience
            AppTextField(
              controller: experienceCtrl,
              hintText: 'Years of experience',
              prefixIcon: Icons.calendar_month_outlined,
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter years of experience'
                  : null,
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            // About Me
            AppTextField(
              controller: aboutCtrl,
              hintText: 'About me',
              prefixIcon: Icons.info_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter about you' : null,
            ),
            SizedBox(height: Responsive.spacing(context, 30)),

            if (isLoading)
              const CircularProgressIndicator()
            else
              AppButton(
                width: double.infinity,
                height: Responsive.height(context, 0.065).clamp(48, 60),
                radius: Responsive.borderRadius(context, 12),
                textStyle: TextStyle(
                  fontSize: Responsive.fontSize(context, 18),
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_step2FormKey.currentState?.validate() ?? false) {
                    final years =
                        int.tryParse(experienceCtrl.text.trim());
                    if (years == null || years < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid number for years of experience'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    context.read<AuthCubit>().registerDoctor(
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          password: passCtrl.text.trim(),
                          confirmPassword: pass2Ctrl.text.trim(),
                          specialization: specializationCtrl.text.trim(),
                          yearsOfExperience: years,
                          nationalNumber: nationalNumCtrl.text.trim(),
                          bio: aboutCtrl.text.trim(),
                        );
                  }
                },
                label: 'Signup',
              ),

            TextButton(
              onPressed: () => setState(() => _currentStep = 1),
              child: Text(
                'Back to step 1',
                style: TextStyle(
                  color: const Color(0xff335777),
                  fontSize: Responsive.fontSize(context, 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
