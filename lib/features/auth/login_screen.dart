import 'package:ehnama3ak/core/widgets/app_icon_back.dart';
import 'package:ehnama3ak/core/widgets/main_layout.dart';
import 'package:flutter/material.dart';
import '../welcome/welcome_screen.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/utils/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/controllers/auth_cubit.dart';
import 'presentation/controllers/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool _remember = false;
  bool _obscure = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(emailCtrl.text.trim(), passCtrl.text.trim());
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
          body: SafeArea(
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainLayout()),
                    (route) => false,
                  );
                } else if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red),
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
                          SizedBox(
                            height: Responsive.height(context, 0.36),
                            width: double.infinity,
                            child: Stack(
                              children: [
                                Center(
                                  child: Image.asset(
                                    'assets/images/image_patient.png',
                                    width: Responsive.width(context, 0.8),
                                    height: Responsive.height(context, 0.25),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                AppIconBack(
                                  top: Responsive.spacing(context, 10),
                                  left: Responsive.spacing(context, 12),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 16)),
                          Text(
                            'Enter your email & password',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: Responsive.fontSize(context, 20),
                            ),
                          ),
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
                                  // Email
                                  AppTextField(
                                    controller: emailCtrl,
                                    hintText: 'Email',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    borderRadius: Responsive.borderRadius(
                                        context, 18.0),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: Responsive.padding(context, 20),
                                      vertical: Responsive.padding(context, 18),
                                    ),
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF9FB9CF),
                                      fontSize: Responsive.fontSize(context, 16),
                                    ),
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
                                      height: Responsive.spacing(context, 20)),

                                  // Password
                                  AppTextField(
                                    controller: passCtrl,
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscure,
                                    showObscureToggle: true,
                                    onObscureToggle: () =>
                                        setState(() => _obscure = !_obscure),
                                    borderRadius: Responsive.borderRadius(
                                        context, 18.0),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: Responsive.padding(context, 20),
                                      vertical: Responsive.padding(context, 18),
                                    ),
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF9FB9CF),
                                      fontSize: Responsive.fontSize(context, 16),
                                    ),
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
                                      height: Responsive.spacing(context, 12)),

                                  // Remember + Forgot row
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => setState(
                                            () => _remember = !_remember),
                                        child: Container(
                                          width: Responsive.iconSize(context, 20),
                                          height:
                                              Responsive.iconSize(context, 20),
                                          decoration: BoxDecoration(
                                            color: _remember
                                                ? const Color(0xFF1E88E5)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                                Responsive.borderRadius(
                                                    context, 4)),
                                            border: Border.all(
                                              color: Colors.blueGrey.shade200,
                                            ),
                                          ),
                                          child: _remember
                                              ? Icon(
                                                  Icons.check,
                                                  size: Responsive.iconSize(
                                                      context, 16),
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                      SizedBox(
                                          width: Responsive.spacing(context, 8)),
                                      Text(
                                        'Remember Me',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              Responsive.fontSize(context, 14),
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: const Color(0xFF1E88E5),
                                            fontSize:
                                                Responsive.fontSize(context, 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: Responsive.spacing(context, 18)),

                                  // Login Button
                                  if (state is AuthLoading)
                                    const CircularProgressIndicator()
                                  else
                                    AppButton(
                                      width: double.infinity,
                                      height: Responsive.height(context, 0.065)
                                          .clamp(48, 60),
                                      radius: Responsive.borderRadius(
                                          context, 12),
                                      textStyle: TextStyle(
                                        fontSize:
                                            Responsive.fontSize(context, 18),
                                        color: Colors.white,
                                      ),
                                      onPressed: _onLogin,
                                      label: 'Login',
                                    ),
                                  SizedBox(
                                      height: Responsive.spacing(context, 40)),

                                  // bottom text
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              Responsive.fontSize(context, 14),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const WelcomeScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Create new one",
                                          style: TextStyle(
                                            color: const Color(0xFF1E88E5),
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                Responsive.fontSize(context, 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: Responsive.spacing(context, 20)),
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
      ),
    );
  }
}
