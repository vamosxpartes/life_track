import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:life_track/screens/home_screen.dart';
import 'package:life_track/main.dart';
import 'package:life_track/utils/logo_creator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isAuthenticating = false;
  String _authStatus = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    
    _checkBiometrics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      
      setState(() {
        _canCheckBiometrics = canCheckBiometrics && availableBiometrics.isNotEmpty;
      });
      
      // Esperar un poco para mostrar la animación antes de pedir autenticación
      Timer(const Duration(milliseconds: 1500), () {
        if (_canCheckBiometrics) {
          _authenticate();
        } else {
          _proceedToApp();
        }
      });
      
    } on PlatformException catch (e) {
      setState(() {
        _canCheckBiometrics = false;
        _authStatus = 'Error: ${e.message}';
      });
      
      // Si hay un error, continuar sin biometría
      Timer(const Duration(milliseconds: 2000), _proceedToApp);
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authStatus = 'Autenticando...';
      });
      
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor, autentícate para acceder a LifeTrack',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      
      setState(() {
        _isAuthenticating = false;
        _authStatus = authenticated ? 'Autenticado' : 'Autenticación fallida';
      });
      
      if (authenticated) {
        _proceedToApp();
      } else {
        // Si falla la autenticación, mostrar botón para reintentar
        setState(() {
          _authStatus = 'No se pudo autenticar, por favor intenta de nuevo';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authStatus = 'Error: ${e.message}';
      });
      
      // Si hay un error en la autenticación, continuar después de un momento
      Timer(const Duration(milliseconds: 2000), _proceedToApp);
    }
  }

  void _proceedToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: LogoWidget(
                            size: 150,
                            color: AppColors.diaryPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'LifeTrack',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: AppColors.diaryPrimary.withAlpha(125),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Mejora tu vida día a día',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_canCheckBiometrics && _authStatus.isNotEmpty && !_isAuthenticating)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            _authStatus,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!_isAuthenticating && _authStatus.contains('No se pudo autenticar'))
                            ElevatedButton.icon(
                              icon: const Icon(Icons.fingerprint),
                              label: const Text('Reintentar'),
                              onPressed: _authenticate,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (_isAuthenticating)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Autenticando...',
                            style: TextStyle(color: Colors.white70),
                          )
                        ],
                      ),
                    ),
                  ),
                if (!_canCheckBiometrics)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: TextButton(
                        onPressed: _proceedToApp,
                        child: const Text('Continuar'),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
} 