import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_provider.dart';
import '../localization/app_strings.dart';
import '../theme/kg_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
    _loadSavedCredentials();
    
    // Floating animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogin = prefs.getString('login');
    final savedPassword = prefs.getString('password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (savedLogin != null && rememberMe) {
      setState(() {
        _loginController.text = savedLogin;
        _passwordController.text = savedPassword ?? '';
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [KG.primaryDark, KG.primary, KG.primaryLight],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated floating decorative elements in background
              Positioned(
                top: 40,
                left: 20,
                child: AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingController.value * 20),
                      child: Text('🎈', style: const TextStyle(fontSize: 32)),
                    );
                  },
                ),
              ),
              Positioned(
                top: 60,
                right: 30,
                child: AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_floatingController.value * 25),
                      child: Text('❤️', style: const TextStyle(fontSize: 24)),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 250,
                left: 30,
                child: AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingController.value * 30),
                      child: Text('🧸', style: const TextStyle(fontSize: 28)),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 200,
                right: 25,
                child: AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_floatingController.value * 20),
                      child: Text('🎀', style: const TextStyle(fontSize: 26)),
                    );
                  },
                ),
              ),
              Positioned(
                top: 120,
                left: 60,
                child: AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingController.value * 35),
                      child: Text('🌟', style: const TextStyle(fontSize: 22)),
                    );
                  },
                ),
              ),
              Positioned(
                top: 200,
                right: 50,
                child: AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_floatingController.value * 28),
                      child: Text('🌸', style: const TextStyle(fontSize: 24)),
                    );
                  },
                ),
              ),
              
              // Settings button in top-left
              Positioned(
                top: 0,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                    child: Text('⚙️', style: const TextStyle(color: Colors.white, fontSize: 32)),
                  ),
                ),
              ),
              // Main login form
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  // Animated logo
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.95 + (_pulseController.value * 0.1),
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: KG.primaryDark.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('⭐', style: TextStyle(fontSize: 54)),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Little Stars',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    'Ghofrane',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🌸  Parent Portal',
                      style: TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // White card
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: KG.primaryDark.withOpacity(0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Error banner
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            if (auth.errorMessage == null) return const SizedBox.shrink();
                            return Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Text('⚠️', style: const TextStyle(color: Colors.red, fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      auth.errorMessage!,
                                      style: TextStyle(
                                          color: Colors.red.shade700, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Username field
                        TextField(
                          controller: _loginController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: KG.textDark, fontSize: 15),
                          decoration: InputDecoration(
                            labelText: AppStrings.login_field,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12, right: 12),
                              child: Text('👤', style: TextStyle(fontSize: 20)),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(color: KG.textDark, fontSize: 15),
                          decoration: InputDecoration(
                            labelText: AppStrings.password,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12, right: 12),
                              child: Text('🔒', style: TextStyle(fontSize: 20)),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Text(
                                  _obscurePassword ? '👁️' : '👁️‍🗨️',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Remember Me checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() => _rememberMe = value ?? false);
                              },
                              activeColor: KG.primary,
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                color: KG.textDark,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Login button
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () async {
                                        auth.clearError();
                                        final ok = await auth.login(
                                          _loginController.text.trim(),
                                          _passwordController.text,
                                          rememberMe: _rememberMe,
                                        );
                                        if (ok && mounted) {
                                          Navigator.of(context)
                                              .pushReplacementNamed('/home');
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        AppStrings.login,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas encore de compte? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/register'),
                        child: const Text(
                          AppStrings.signUp,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
