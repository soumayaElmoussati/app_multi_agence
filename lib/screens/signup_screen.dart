import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multi_agences_app/config/env.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _acceptTerms = false;

  // Contrôleurs pour les champs de formulaire
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                      Icons.person_add,
                      color: AppTheme.white,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 32),

                  Text(
                    'Créer un compte',
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

                  // Prénom
                  TextFormField(
                    controller: _firstnameController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      prefixIcon: Icon(
                        Icons.person,
                        color: AppTheme.primaryRed,
                      ),
                      hintText: 'Entrez votre prénom',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.primaryRed),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre prénom';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Nom
                  TextFormField(
                    controller: _lastnameController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppTheme.primaryRed,
                      ),
                      hintText: 'Entrez votre nom',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.primaryRed),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: AppTheme.primaryRed),
                      hintText: 'exemple@email.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.primaryRed),
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
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock, color: AppTheme.primaryRed),
                      hintText: 'Minimum 8 caractères',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.primaryRed),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 8) {
                        return 'Le mot de passe doit contenir au moins 8 caractères';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Confirmation mot de passe
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppTheme.primaryRed,
                      ),
                      hintText: 'Répétez votre mot de passe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.primaryRed),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Conditions d'utilisation
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value!;
                          });
                        },
                        activeColor: AppTheme.primaryRed,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptTerms = !_acceptTerms;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(text: "J'accepte les "),
                                TextSpan(
                                  text: 'conditions d\'utilisation',
                                  style: TextStyle(
                                    color: AppTheme.primaryRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: ' et la '),
                                TextSpan(
                                  text: 'politique de confidentialité',
                                  style: TextStyle(
                                    color: AppTheme.primaryRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Bouton d'inscription
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
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
                              'S\'INSCRIRE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Lien vers la connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte? ',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Se connecter',
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

  // Méthode pour l'inscription
  Future<void> _signup() async {
    if (!_acceptTerms) {
      _showSnackBar('Veuillez accepter les conditions d\'utilisation');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Préparation des données
        final Map<String, dynamic> data = {
          'firstname': _firstnameController.text.trim(),
          'lastname': _lastnameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
        };

        // Appel à l'API
        final response = await http.post(
          Uri.parse('${Env.baseUrl}/api/register'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(data),
        );

        final responseData = json.decode(response.body);

        if (response.statusCode == 201) {
          // Succès - Redirection directe vers le login avec snackbar
          _redirectToLoginWithSuccess();
        } else {
          // Erreur
          final errors = responseData['errors'] ?? {};
          String errorMessage = 'Erreur lors de l\'inscription';

          if (errors.isNotEmpty) {
            // Prendre le premier message d'erreur
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first;
            } else if (firstError is String) {
              errorMessage = firstError;
            }
          } else if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          }

          _showSnackBar(errorMessage);
        }
      } catch (e) {
        String errorMessage = 'Erreur de connexion';
        if (e is http.ClientException) {
          errorMessage = 'Erreur réseau. Vérifiez votre connexion internet.';
        } else if (e is FormatException) {
          errorMessage = 'Erreur de format de réponse du serveur.';
        } else {
          errorMessage = 'Erreur: ${e.toString()}';
        }
        _showSnackBar(errorMessage);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Méthode pour rediriger vers le login avec un message de succès
  void _redirectToLoginWithSuccess() {
    // Naviguer vers le login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );

    // Montrer un snackbar de succès après un court délai
    Future.delayed(Duration(milliseconds: 300), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Inscription réussie ! Vous pouvez maintenant vous connecter.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    });
  }

  // Alternative: message toast temporaire avant redirection
  void _showSuccessAndRedirect() {
    // Montrer un message temporaire
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inscription réussie... Redirection...'),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 800),
      ),
    );

    // Rediriger après un court délai
    Future.delayed(Duration(milliseconds: 800), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );

      // Montrer un autre snackbar sur l'écran de login
      Future.delayed(Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Compte créé avec succès ! Connectez-vous maintenant.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      });
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryRed,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
