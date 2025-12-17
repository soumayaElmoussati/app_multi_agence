import 'package:flutter/material.dart';
import 'package:multi_agences_app/screens/select_agency_screen.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Contrôleurs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Services
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Charger les identifiants sauvegardés
  Future<void> _loadSavedCredentials() async {
    final rememberMe = await _authService.getRememberMe();
    if (rememberMe) {
      final userData = await _authService.getUserData();
      if (userData != null) {
        setState(() {
          _rememberMe = true;
          _emailController.text = userData['email'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.white, AppTheme.background],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business,
                      color: AppTheme.white,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 32),

                  Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gestion Multi-Agences',
                    style: TextStyle(fontSize: 16, color: AppTheme.textLight),
                  ),
                  SizedBox(height: 32),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: AppTheme.primaryRed),
                      hintText: 'exemple@email.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryRed),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Format d\'email invalide';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Mot de passe
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock, color: AppTheme.primaryRed),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppTheme.primaryRed,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryRed),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Remember me & Mot de passe oublié
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                        activeColor: AppTheme.primaryRed,
                      ),
                      Text(
                        'Se souvenir de moi',
                        style: TextStyle(color: AppTheme.textDark),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Implémenter la réinitialisation du mot de passe
                          _showSnackBar('Fonctionnalité à venir');
                        },
                        child: Text(
                          'Mot de passe oublié?',
                          style: TextStyle(color: AppTheme.primaryRed),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Bouton Connexion
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.white,
                                ),
                              ),
                            )
                          : Text(
                              'SE CONNECTER',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Lien vers l'inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte? ',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'S\'inscrire',
                          style: TextStyle(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Appel au service API
      final result = await _apiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result['success'] == true) {
        // Succès de la connexion
        final data = result['data'];
        final token = data['token'];
        final userData = data['user'];

        // Sauvegarder les données d'authentification
        await _authService.saveAuthData(
          token: token,
          userData: userData,
          rememberMe: _rememberMe,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SelectAgencyScreen(userData: userData, token: token),
          ),
        );

        // Message de bienvenue
        _showSnackBar('Bienvenue ${userData['firstname']} !', isSuccess: true);
      } else {
        // Erreur
        final errorMessage = result['message'] ?? 'Erreur de connexion';
        _showSnackBar(errorMessage);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : AppTheme.primaryRed,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
