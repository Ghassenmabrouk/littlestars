import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/kg_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // User info
  String _login = '';
  String _password = '';
  String _confirmPassword = '';
  String _email = '';
  String _nomComplet = '';
  
  // Parent info
  String _parentPrenom = '';
  String _parentNom = '';
  String _parentTelephone = '';
  String _parentRelation = 'Père';
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Compte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4, height: 20,
                    decoration: BoxDecoration(
                      color: KG.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Informations du Compte',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: KG.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Identifiant',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.person, color: KG.primary),
                ),
                onChanged: (value) => _login = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'L\'identifiant est requis';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('📧', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => _email = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'L\'email est requis';
                  if (!value!.contains('@')) return 'Email invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nom Complet',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('👤', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                onChanged: (value) => _nomComplet = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Le nom complet est requis';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mot de Passe',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('🔒', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                obscureText: true,
                onChanged: (value) => _password = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Le mot de passe est requis';
                  if ((value?.length ?? 0) < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirmer le Mot de Passe',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('🔒', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                obscureText: true,
                onChanged: (value) => _confirmPassword = value,
                validator: (value) {
                  if (value != _password) return 'Les mots de passe ne correspondent pas';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Container(
                    width: 4, height: 20,
                    decoration: BoxDecoration(
                      color: KG.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Informations du Parent',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: KG.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('👨\u2d43👩', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                onChanged: (value) => _parentPrenom = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Le prénom est requis';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('👤', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Le nom est requis';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Numéro de Téléphone',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('📱', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => _parentTelephone = value,
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                value: _parentRelation.isEmpty ? 'Père' : _parentRelation,
                items: const [
                  DropdownMenuItem(value: 'Père', child: Text('Père')),
                  DropdownMenuItem(value: 'Mère', child: Text('Mère')),
                  DropdownMenuItem(value: 'Tuteur', child: Text('Tuteur')),
                  DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                ],
                onChanged: (value) {
                  setState(() {
                    _parentRelation = value ?? 'Père';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une relation';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Relation avec l\'Enfant',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('👨\u2d43👩\u2d43👧', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              const SizedBox(height: 24),
              
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[900], fontSize: 14),
                  ),
                ),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer un Compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Avez-vous déjà un compte? '),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Se Connecter',
                      style: TextStyle(color: KG.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userData = {
      'login': _login,
      'password': _password,
      'email': _email,
      'nom_complet': _nomComplet,
      'prenom': _parentPrenom,
      'nom': _parentNom,
      'telephone': _parentTelephone,
      'relation': _parentRelation,
    };

    final response = await ApiService.register(userData);

    setState(() => _isLoading = false);

    if (response['success'] ?? false) {
      // Show success message and go back to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Compte créé avec succès! Veuillez vous connecter.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'Fermer', onPressed: () {}),
        ),
      );
      Navigator.of(context).pop();
    } else {
      setState(() => _errorMessage = response['message'] ?? 'Échec de l\'inscription');
    }
  }
}
