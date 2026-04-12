import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../models/models.dart';
import '../theme/kg_theme.dart';
import 'attendance_history_screen.dart';
import 'absence_history_screen.dart';
import 'messaging_screen.dart';

class ChildDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> child;

  const ChildDetailsScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  int _selectedTabIndex = 0;
  int _paymentRefreshKey = 0;

  final List<String> _tabs = [
    'Aperçu',
    'Messages',
    'Activités',
    'Frais',
  ];

  @override
  Widget build(BuildContext context) {
    final childId = widget.child['enfant_id'] ?? widget.child['id'];
    final childName = '${widget.child['prenom']} ${widget.child['nom']}';

    return Scaffold(
      appBar: AppBar(
        title: Text(childName),
      ),
      body: Column(
        children: [
          // Tab navigation
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTabIndex == index ? KG.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        fontWeight: _selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
                        color: _selectedTabIndex == index ? KG.primary : KG.textMuted,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 0),
          // Tab content
          Expanded(
            child: _buildTabContent(childId),
          )
        ],
      ),
    );
  }

  Widget _buildTabContent(dynamic childId) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab(childId);
      case 1:
        return _buildMessagesTab(childId);
      case 2:
        return _buildActivitiesTab(childId);
      case 3:
        return _buildFeesTab(childId);
      default:
        return Container();
    }
  }

  Widget _buildOverviewTab(dynamic childId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getChildProfile(int.parse(childId.toString())),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data ?? {};
        final child = data['child'] as Map<String, dynamic>? ?? {};
        final parents = data['parents'] as List? ?? [];
        final attendance = data['attendance'] as Map<String, dynamic>? ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final childObj = Child(
                          id: int.parse(childId.toString()),
                          nom: widget.child['nom'],
                          prenom: widget.child['prenom'],
                          dateNaissance: widget.child['date_naissance'] ?? '',
                          groupeAge: widget.child['groupe_age'] ?? '',
                          statut: widget.child['statut'] ?? 'Actif',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceHistoryScreen(child: childObj),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      label: const Text('Présences'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final childObj = Child(
                          id: int.parse(childId.toString()),
                          nom: widget.child['nom'],
                          prenom: widget.child['prenom'],
                          dateNaissance: widget.child['date_naissance'] ?? '',
                          groupeAge: widget.child['groupe_age'] ?? '',
                          statut: widget.child['statut'] ?? 'Actif',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AbsenceHistoryScreen(child: childObj),
                          ),
                        );
                      },
                      icon: const Icon(Icons.warning, color: Colors.white),
                      label: const Text('Absences'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Informations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _infoRow('Nom:', '${widget.child['prenom']} ${widget.child['nom']}'),
              _infoRow('Date de naissance:', widget.child['date_naissance'] ?? 'N/A'),
              _infoRow('Groupe d\'âge:', widget.child['groupe_age'] ?? 'N/A'),
              _infoRow('Statut:', widget.child['statut'] ?? 'Actif'),
              const SizedBox(height: 24),
              const Text('Parent/Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...parents.map((parent) {
                final p = parent as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Nom:', '${p['prenom'] ?? ''} ${p['nom'] ?? ''}'),
                    if (p['telephone'] != null) _infoRow('Téléphone:', p['telephone']),
                    if (p['email'] != null) _infoRow('Email:', p['email']),
                    if (p['relation'] != null) _infoRow('Relation:', p['relation']),
                    const SizedBox(height: 12),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab(dynamic childId) {
    return const Center(child: Text('Attendance details coming soon'));
  }

  Widget _buildMessagesTab(dynamic childId) {
    return MessagingScreen(
      userId: int.parse(childId.toString()),
      userName: '${widget.child['prenom']} ${widget.child['nom']}',
      userRole: 'parent',
    );
  }

  Widget _buildActivitiesTab(dynamic childId) {
    return const Center(child: Text('Activities coming soon'));
  }

  Widget _buildFeesTab(dynamic childId) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _paymentRefreshKey++);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: FutureBuilder<Map<String, dynamic>>(
        key: ValueKey(_paymentRefreshKey),
        future: ApiService.getChildPayments(int.parse(childId.toString())),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? {};
          final payments = data['data'] as List? ?? [];
          final summary = data['summary'] as Map<String, dynamic>? ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résumé des Paiements',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.check_circle, color: Colors.green[700], size: 28),
                                ),
                                const SizedBox(height: 8),
                                Text('Payé', style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(height: 4),
                                Text(
                                  '${summary['total_paid'] ?? 0} DT',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
                                ),
                                Text(
                                  '${summary['paid_count'] ?? 0} factures',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.pending_actions, color: Colors.orange[700], size: 28),
                                ),
                                const SizedBox(height: 8),
                                Text('En Attente', style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(height: 4),
                                Text(
                                  '${summary['pending_amount'] ?? 0} DT',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[700]),
                                ),
                                Text(
                                  '${summary['unpaid_count'] ?? 0} factures',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Factures',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (payments.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long, size: 56, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            'Aucune facture',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index] as Map<String, dynamic>;
                    final isPaid = payment['statut'] == 'Payé' || payment['statut'] == 'payé';
                    final month = payment['month_name'] ?? 'Mois ${payment['mois']}';
                    final year = payment['annee'];
                    final amount = payment['montant'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isPaid ? Colors.green[100] : Colors.orange[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isPaid ? Icons.paid : Icons.schedule,
                                    color: isPaid ? Colors.green[700] : Colors.orange[700],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$month $year',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isPaid ? 'Payé' : 'En attente de paiement',
                                        style: TextStyle(
                                          color: isPaid ? Colors.green[700] : Colors.orange[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$amount DT',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPaid ? Colors.green[100] : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isPaid ? '✓ Payé' : '⏳ Attente',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isPaid ? Colors.green[800] : Colors.orange[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!isPaid) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _showPaymentDialog(context, int.parse(childId.toString()), int.parse((payment['id'] ?? 0).toString()), double.parse(amount.toString()), month),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: KG.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: const Text('Payer maintenant', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _downloadInvoiceReceipt(
                                      receiptNumber: 'REC-${payment['id']}-${DateTime.now().millisecondsSinceEpoch}',
                                      childName: widget.child['prenom'] + ' ' + widget.child['nom'],
                                      amount: amount.toString(),
                                      month: month,
                                      year: year.toString(),
                                      paymentDate: payment['date_paiement'] ?? DateTime.now().toString().split(' ')[0],
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  icon: const Icon(Icons.download, color: Colors.white),
                                  label: const Text('Télécharger reçu', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
        },
      ),
    );
  }

  Widget _buildContactsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getEmergencyContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data ?? {};
        final contacts = data['data'] as List? ?? [];

        return contacts.isEmpty
            ? const Center(child: Text('Aucun contact d\'urgence'))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index] as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(contact['name'] ?? 'Contact'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (contact['phone_number'] != null)
                            Text('Téléphone: ${contact['phone_number']}'),
                          if (contact['email'] != null)
                            Text('Email: ${contact['email']}'),
                        ],
                      ),
                    ),
                  );
                },
              );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext outerContext, int childId, int billId, dynamic amount, String month) {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final cardholderController = TextEditingController();
    bool isProcessing = false;

    showDialog(
      context: outerContext,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            return AlertDialog(
              title: const Text('Paiement par Carte Bancaire'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              'Montant à payer',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$amount DT - $month',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: cardholderController,
                      decoration: InputDecoration(
                        labelText: 'Nom du titulaire',
                        hintText: 'John Doe',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Numéro de carte',
                        hintText: '1234 5678 9012 3456',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.credit_card),
                      ),
                      inputFormatters: [
                        _CardNumberFormatter(),
                      ],
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: expiryController,
                            decoration: InputDecoration(
                              labelText: 'Expiration',
                              hintText: 'MM/YY',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.length == 2 && !value.contains('/')) {
                                expiryController.text = '${value.substring(0, 2)}/';
                                expiryController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: expiryController.text.length),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: cvvController,
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          if (cardholderController.text.isEmpty || cardNumberController.text.isEmpty || expiryController.text.isEmpty || cvvController.text.isEmpty) {
                            Future.microtask(() {
                              if (outerContext.mounted) {
                                ScaffoldMessenger.of(outerContext).showSnackBar(
                                  SnackBar(
                                    content: const Text('Veuillez remplir tous les champs'),
                                    duration: const Duration(seconds: 10),
                                    action: SnackBarAction(label: 'Fermer', onPressed: () {}),
                                  ),
                                );
                              }
                            });
                            return;
                          }

                          // Validate expiry date
                          final expiryValidation = _validateExpiryDate(expiryController.text);
                          if (!expiryValidation['valid']) {
                            Future.microtask(() {
                              if (outerContext.mounted) {
                                ScaffoldMessenger.of(outerContext).showSnackBar(
                                  SnackBar(
                                    content: Text(expiryValidation['message']),
                                    duration: const Duration(seconds: 10),
                                    action: SnackBarAction(label: 'Fermer', onPressed: () {}),
                                  ),
                                );
                              }
                            });
                            return;
                          }

                          setState(() => isProcessing = true);

                          try {
                            final result = await ApiService.processPayment(
                              childId: childId,
                              billId: billId,
                              amount: double.parse(amount.toString()),
                              cardNumber: cardNumberController.text.replaceAll(' ', ''),
                              expiry: expiryController.text,
                              cvv: cvvController.text,
                              cardholderName: cardholderController.text,
                            );

                            if (result['success']) {
                              Navigator.of(dialogContext).pop();
                              
                              // Show receipt
                              showDialog(
                                context: outerContext,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Reçu de Paiement'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Divider(),
                                        _receiptRow('Numéro de Reçu:', result['receipt']['receipt_number']),
                                        _receiptRow('Enfant:', result['receipt']['child_name']),
                                        _receiptRow('Montant Payé:', '${result['receipt']['montant_paye']} DT'),
                                        _receiptRow('Mois:', '${result['receipt']['month_name']} ${result['receipt']['annee']}'),
                                        _receiptRow('Mode de Paiement:', result['receipt']['mode_paiement']),
                                        _receiptRow('Date de Paiement:', result['receipt']['date_paiement']),
                                        _receiptRow('Statut:', '✓ Payé'),
                                        const Divider(),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            result['receipt']['message'] ?? 'Paiement effectué avec succès',
                                            style: TextStyle(color: Colors.green[700], fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Fermer'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _downloadReceipt(result['receipt']);
                                      },
                                      icon: const Icon(Icons.download),
                                      label: const Text('Télécharger'),
                                    ),
                                  ],
                                ),
                              );
                              
                              // Refresh the fees tab data
                              setState(() {
                                _paymentRefreshKey++;
                              });
                              
                              // Navigate to fees tab
                              setState(() => _selectedTabIndex = 3);
                            } else {
                              Future.microtask(() {
                                if (outerContext.mounted) {
                                  ScaffoldMessenger.of(outerContext).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: ${result['message']}'),
                                      duration: const Duration(seconds: 10),
                                      action: SnackBarAction(label: 'Fermer', onPressed: () {}),
                                    ),
                                  );
                                }
                              });
                            }
                          } catch (e) {
                            Future.microtask(() {
                              if (outerContext.mounted) {
                                ScaffoldMessenger.of(outerContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: $e'),
                                    duration: const Duration(seconds: 10),
                                    action: SnackBarAction(label: 'Fermer', onPressed: () {}),
                                  ),
                                );
                              }
                            });
                          } finally {
                            setState(() => isProcessing = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KG.primary,
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : const Text('Payer', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _validateExpiryDate(String expiryText) {
    try {
      if (!expiryText.contains('/')) {
        return {'valid': false, 'message': 'Format de date invalide. Utilisez MM/YY'};
      }

      final parts = expiryText.split('/');
      if (parts.length != 2) {
        return {'valid': false, 'message': 'Format de date invalide. Utilisez MM/YY'};
      }

      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);

      if (month < 1 || month > 12) {
        return {'valid': false, 'message': 'Mois invalide. Utilisez 01-12'};
      }

      // Get current date
      final now = DateTime.now();
      final currentYear = now.year % 100; // Get last 2 digits
      final currentMonth = now.month;

      // Compare expiry date with current date
      if (year < currentYear || (year == currentYear && month < currentMonth)) {
        return {'valid': false, 'message': 'La carte a expiré. Veuillez entrer une date valide'};
      }

      return {'valid': true, 'message': 'OK'};
    } catch (e) {
      return {'valid': false, 'message': 'Format de date invalide'};
    }
  }

  void _downloadInvoiceReceipt({
    required String receiptNumber,
    required String childName,
    required String amount,
    required String month,
    required String year,
    required String paymentDate,
  }) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    '✨ REÇU DE PAIEMENT ✨',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                _pdfRow('Numéro de Reçu:', receiptNumber),
                _pdfRow('Enfant:', childName),
                _pdfRow('Montant Payé:', '$amount DT'),
                _pdfRow('Mois:', '$month $year'),
                _pdfRow('Mode de Paiement:', 'Carte Bancaire'),
                _pdfRow('Date de Paiement:', paymentDate),
                _pdfRow('Statut:', '✓ Payé'),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'Paiement effectué avec succès',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      _downloadFile(bytes, 'receipt_$receiptNumber.pdf');
    } catch (e) {
      print('Erreur lors de la génération du PDF: $e');
    }
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }

  void _downloadFile(List<int> bytes, String filename) {
    // Download is only supported on web version
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF download available on web version only'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _downloadReceipt(Map<String, dynamic> receipt) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    '✨ REÇU DE PAIEMENT ✨',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                _pdfRow('Numéro de Reçu:', receipt['receipt_number']),
                _pdfRow('Enfant:', receipt['child_name']),
                _pdfRow('Montant Payé:', '${receipt['montant_paye']} DT'),
                _pdfRow('Mois:', '${receipt['month_name']} ${receipt['annee']}'),
                _pdfRow('Mode de Paiement:', receipt['mode_paiement']),
                _pdfRow('Date de Paiement:', receipt['date_paiement']),
                _pdfRow('Statut:', '✓ Payé'),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    receipt['message'] ?? 'Paiement effectué avec succès',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      _downloadFile(bytes, 'receipt_${receipt['receipt_number']}.pdf');
    } catch (e) {
      print('Erreur lors de la génération du PDF: $e');
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Extract only digits from the new value
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 16 digits (standard card number length)
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }

    // Format with spaces: XXXX XXXX XXXX XXXX
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i + 1) % 4 == 0 && i != digitsOnly.length - 1) {
        buffer.write(' ');
      }
    }

    String formattedText = buffer.toString();
    
    // Calculate cursor position
    int cursorPos = formattedText.length;
    if (oldValue.text.length > newValue.text.length) {
      // User is deleting
      cursorPos = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPos),
    );
  }
}
