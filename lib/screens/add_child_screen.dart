import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/kg_theme.dart';

class AddChildScreen extends StatefulWidget {
  final String userEmail;
  final VoidCallback onChildAdded;

  const AddChildScreen({
    Key? key,
    required this.userEmail,
    required this.onChildAdded,
  }) : super(key: key);

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _prenom = '';
  String _nom = '';
  String _dateNaissance = '';
  String _groupeAge = 'Toute Petite Section';
  String _sexe = 'M';
  
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _groupes = [
    'Toute Petite Section',
    'Petite Section',
    'Moyenne Section',
    'Grande Section',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Enfant'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('⬅️', style: TextStyle(fontSize: 24)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('👤', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                onChanged: (value) => _prenom = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Le prénom est obligatoire';
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
                ),
                onChanged: (value) => _nom = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Le nom est obligatoire';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date de Naissance',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('📅', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: 'AAAA-MM-JJ',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _selectDate(),
                      child: Text('📅', style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                controller: TextEditingController(text: _dateNaissance),
                readOnly: true,
                onChanged: (value) => _dateNaissance = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'La date de naissance est obligatoire';
                  // Validate date format
                  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value!)) {
                    return 'La date doit être au format AAAA-MM-JJ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField(
                value: _groupeAge,
                items: _groupes.map((groupe) {
                  return DropdownMenuItem(
                    value: groupe,
                    child: Text(groupe),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _groupeAge = value ?? _groupeAge),
                decoration: InputDecoration(
                  labelText: 'Niveau',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('🏫', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ),
                isExpanded: true,
                isDense: false,
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField(
                value: _sexe,
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Garçon')),
                  DropdownMenuItem(value: 'F', child: Text('Fille')),
                ]
                    .map((e) => e)
                    .toList(),
                onChanged: (value) => setState(() => _sexe = value ?? _sexe),
                decoration: InputDecoration(
                  labelText: 'Sexe',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text('🚽', style: const TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ),
                isExpanded: true,
                isDense: false,
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
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addChild,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Ajouter un Enfant', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addChild() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final childData = {
      'prenom': _prenom,
      'nom': _nom,
      'date_naissance': _dateNaissance,
      'groupe_age': _groupeAge,
      'sexe': _sexe,
    };

    final response = await ApiService.addChild(widget.userEmail, childData);

    setState(() => _isLoading = false);

    if (response['success'] ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enfant ajouté avec succès!'),
          duration: const Duration(seconds: 1),
          action: SnackBarAction(label: 'Fermer', onPressed: () {}),
        ),
      );
      // Call the callback which handles navigation and refresh
      widget.onChildAdded();
    } else {
      setState(() => _errorMessage = response['message'] ?? 'Échec de l\'ajout de l\'enfant');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Format as YYYY-MM-DD
        _dateNaissance = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }
}
