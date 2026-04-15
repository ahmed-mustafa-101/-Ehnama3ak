import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon_back.dart';
import '../../core/widgets/app_text_field.dart';
import 'presentation/controllers/auth_cubit.dart';
import 'presentation/controllers/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  void _onResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passCtrl.text != _confirmPassCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      context.read<AuthCubit>().resetPassword(
        widget.email,
        _codeCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
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
          body: SafeArea(
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthResetPasswordSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // goes back to LoginScreen
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
                                height: Responsive.height(context, 0.36),
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'assets/images/resetpassword.png',
                                        width: Responsive.width(context, 0.8),
                                        height: Responsive.height(
                                          context,
                                          0.25,
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 16)),
                              // Text(
                              //   'Reset Password',
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
                                        'Enter the code sent to your email',
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
                                        controller: _codeCtrl,
                                        hintText: 'Code',
                                        prefixIcon: Icons.qr_code,
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
                                            return 'Please enter the code';
                                          return null;
                                        },
                                      ),
                                      SizedBox(
                                        height: Responsive.spacing(context, 20),
                                      ),

                                      // New Password
                                      AppTextField(
                                        controller: _passCtrl,
                                        hintText: 'New Password',
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscurePass,
                                        showObscureToggle: true,
                                        onObscureToggle: () => setState(
                                          () => _obscurePass = !_obscurePass,
                                        ),
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
                                          if (v == null || v.isEmpty)
                                            return 'Please enter a password';
                                          if (v.length < 6)
                                            return 'Password is too short';
                                          return null;
                                        },
                                      ),
                                      SizedBox(
                                        height: Responsive.spacing(context, 20),
                                      ),

                                      // Confirm New Password
                                      AppTextField(
                                        controller: _confirmPassCtrl,
                                        hintText: 'Confirm New Password',
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscureConfirm,
                                        showObscureToggle: true,
                                        onObscureToggle: () => setState(
                                          () => _obscureConfirm =
                                              !_obscureConfirm,
                                        ),
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
                                          if (v == null || v.isEmpty)
                                            return 'Please confirm the password';
                                          return null;
                                        },
                                      ),
                                      SizedBox(
                                        height: Responsive.spacing(context, 30),
                                      ),

                                      // Reset Button
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
                                          onPressed: _onResetPassword,
                                          label: 'Change Password',
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
