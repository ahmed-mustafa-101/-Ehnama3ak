import 'package:flutter/services.dart';
import 'package:ehnama3ak/core/utils/validators.dart';
import 'package:ehnama3ak/core/widgets/app_background.dart';
import 'package:ehnama3ak/core/widgets/app_icon_back.dart' show AppIconBack;
import 'package:flutter/material.dart';
import 'package:ehnama3ak/core/widgets/main_layout.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/utils/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/controllers/auth_cubit.dart';
import 'presentation/controllers/auth_state.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController pass2Ctrl = TextEditingController();
  final TextEditingController nationalNumCtrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    nationalNumCtrl.dispose();
    super.dispose();
  }

  void _onSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().registerPatient(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        confirmPassword: pass2Ctrl.text.trim(),
        nationalNumber: nationalNumCtrl.text.trim(),
      );
    }
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
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: Responsive.spacing(context, 70)),
                        SizedBox(
                          height: Responsive.height(context, 0.38),
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/Frame 61.png',
                                  width: Responsive.width(context, 0.7),
                                  height: Responsive.height(context, 0.35),
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
                        SizedBox(height: Responsive.spacing(context, 30)),
                        Text(
                          'Create a patient account',
                          style: TextStyle(
                            color: const Color(0xff335777),
                            fontSize: Responsive.fontSize(context, 20),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 20)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.valueByDevice(
                              context: context,
                              mobile: 30,
                              tablet: 80,
                              desktop: 120,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Name
                                AppTextField(
                                  controller: nameCtrl,
                                  hintText: 'Name',
                                  prefixIcon: Icons.person_outline,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Enter name'
                                          : null,
                                ),
                                SizedBox(height: Responsive.spacing(context, 14)),

                                // National Number
                                AppTextField(
                                  controller: nationalNumCtrl,
                                  hintText: 'National Number',
                                  prefixIcon: Icons.badge_outlined,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(14),
                                  ],
                                  validator: validateEgyptianNationalId,
                                ),
                                SizedBox(height: Responsive.spacing(context, 14)),

                                // Email
                                AppTextField(
                                  controller: emailCtrl,
                                  hintText: 'Email',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Enter email';
                                    }
                                    if (!RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    ).hasMatch(v.trim())) {
                                      return 'Enter valid email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                    height: Responsive.spacing(context, 14)),

                                // Password
                                AppTextField(
                                  controller: passCtrl,
                                  hintText: 'Password',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: _obscure1,
                                  showObscureToggle: true,
                                  onObscureToggle: () =>
                                      setState(() => _obscure1 = !_obscure1),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Enter password';
                                    }
                                    if (v.length < 6) {
                                      return 'Password must be >= 6 chars';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                    height: Responsive.spacing(context, 14)),

                                // Retype Password
                                AppTextField(
                                  controller: pass2Ctrl,
                                  hintText: 'Retype password',
                                  prefixIcon: Icons.refresh,
                                  obscureText: _obscure2,
                                  showObscureToggle: true,
                                  onObscureToggle: () =>
                                      setState(() => _obscure2 = !_obscure2),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Retype password';
                                    }
                                    if (v != passCtrl.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                    height: Responsive.spacing(context, 22)),

                                // Signup button
                                if (state is AuthLoading)
                                  const CircularProgressIndicator()
                                else
                                  AppButton(
                                    width: double.infinity,
                                    height: Responsive.height(context, 0.065)
                                        .clamp(48, 60),
                                    radius:
                                        Responsive.borderRadius(context, 12),
                                    textStyle: TextStyle(
                                      fontSize: Responsive.fontSize(context, 18),
                                      color: Colors.white,
                                    ),
                                    onPressed: _onSignup,
                                    label: 'Signup',
                                  ),
                                SizedBox(
                                    height: Responsive.spacing(context, 18)),
                              ],
                            ),
                          ),
                        ),
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
}
