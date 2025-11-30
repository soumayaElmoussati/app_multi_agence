import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _isLoading = false;

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
                  child: Icon(Icons.business, color: AppTheme.white, size: 50),
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

                // Sélection Agence
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'Agence',
                    prefixIcon: Icon(
                      Icons.business,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: '1',
                      child: Text('Agence Principale'),
                    ),
                    DropdownMenuItem(
                      value: '2',
                      child: Text('Agence Secondaire'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                SizedBox(height: 16),

                // Email
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: AppTheme.primaryRed),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Mot de passe
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock, color: AppTheme.primaryRed),
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
                    Text('Se souvenir de moi'),
                    Spacer(),
                    TextButton(
                      onPressed: () {},
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
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
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
                        : Text('SE CONNECTER'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(Duration(seconds: 2));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    }
  }
}
