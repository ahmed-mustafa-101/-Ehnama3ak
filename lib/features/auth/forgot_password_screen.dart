import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon_back.dart';
import '../../core/widgets/app_text_field.dart';
import 'presentation/controllers/auth_cubit.dart';
import 'presentation/controllers/auth_state.dart';
import 'reset_password_screen.dart';
import '../../core/localization/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();

  void _onSendCode() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().forgotPassword(_emailCtrl.text.trim());
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = Responsive.getMaxContentWidth(context);
    final l10n = AppLocalizations.of(context);

    return Theme(
      data: ThemeData.light(),
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthForgotPasswordSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResetPasswordScreen(email: _emailCtrl.text.trim()),
                    ),
                  );
                } else if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: Responsive.height(context, 0.35),
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'assets/images/ForgotPassword.png',
                                        width: Responsive.width(context, 0.8),
                                        height: Responsive.height(
                                          context,
                                          0.25,
                                        ),
                                        // fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Text(
                              //   l10n.forgotPassword,
                              //   style: TextStyle(
                              //     color: Colors.black,
                              //     fontSize: Responsive.fontSize(context, 20),
                              //   ),
                              // ),
                              SizedBox(height: Responsive.spacing(context, 18)),

                              // FORM
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
                                      Text(
                                        'Enter your email to receive a password reset code',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: Responsive.fontSize(
                                            context,
                                            14,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Responsive.spacing(context, 20),
                                      ),
                                      AppTextField(
                                        controller: _emailCtrl,
                                        hintText: l10n.emailHint,
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        borderRadius: Responsive.borderRadius(
                                          context,
                                          18.0,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: Responsive.padding(
                                            context,
                                            20,
                                          ),
                                          vertical: Responsive.padding(
                                            context,
                                            18,
                                          ),
                                        ),
                                        hintStyle: TextStyle(
                                          color: const Color(0xFF9FB9CF),
                                          fontSize: Responsive.fontSize(
                                            context,
                                            16,
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty)
                                            return l10n.enterEmail;
                                          if (!RegExp(
                                            r'^[^@]+@[^@]+\.[^@]+',
                                          ).hasMatch(v.trim()))
                                            return l10n.enterValidEmail;
                                          return null;
                                        },
                                      ),
                                      SizedBox(
                                        height: Responsive.spacing(context, 30),
                                      ),

                                      // Send Code Button
                                      if (state is AuthLoading)
                                        const CircularProgressIndicator()
                                      else
                                        AppButton(
                                          width: double.infinity,
                                          height: Responsive.height(
                                            context,
                                            0.065,
                                          ).clamp(48, 60),
                                          radius: Responsive.borderRadius(
                                            context,
                                            12,
                                          ),
                                          textStyle: TextStyle(
                                            fontSize: Responsive.fontSize(
                                              context,
                                              18,
                                            ),
                                            color: Colors.white,
                                          ),
                                          onPressed: _onSendCode,
                                          label: 'Send Code',
                                        ),
                                      SizedBox(
                                        height: Responsive.spacing(context, 40),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppIconBack(
                      top: Responsive.spacing(context, 50),
                      left: Responsive.spacing(context, 12),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
