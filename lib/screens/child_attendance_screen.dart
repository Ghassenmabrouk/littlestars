import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/kg_theme.dart';

class ChildAttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> child;

  const ChildAttendanceScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ChildAttendanceScreen> createState() => _ChildAttendanceScreenState();
}

class _ChildAttendanceScreenState extends State<ChildAttendanceScreen> {
  late Future<Map<String, dynamic>> _attendanceFuture;
  late Future<Map<String, dynamic>> _todayStatusFuture;

  @override
  void initState() {
    super.initState();
    final childId = widget.child['enfant_id'] ?? widget.child['id'];
    _attendanceFuture = ApiService.getAttendanceSummary(int.parse(childId.toString()));
    _todayStatusFuture = ApiService.getChildTodayStatus(int.parse(childId.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final childId = widget.child['enfant_id'] ?? widget.child['id'];
    final childName = '${widget.child['prenom']} ${widget.child['nom']}';
    final groupeAge = widget.child['groupe_age'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text(childName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Child info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      childName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Niveau: $groupeAge', style: const TextStyle(fontSize: 14)),
                    Text('ID: $childId', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Today's Status
            const Text(
              'État d\'Aujourd\'hui',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: _todayStatusFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final data = snapshot.data ?? {};
                final isPresent = data['present'] ?? false;

                return Card(
                  color: isPresent ? Colors.green[50] : Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPresent ? Icons.check_circle : Icons.cancel,
                              color: isPresent ? Colors.green : Colors.red,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isPresent ? 'Présent' : 'Absent',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isPresent ? Colors.green[800] : Colors.red[800],
                              ),
                            ),
                          ],
                        ),
                        if (isPresent && data['data'] != null) ...[
                          const SizedBox(height: 12),
                          Text('Arrivée: ${data['data']['heure_arrivee'] ?? 'N/A'}'),
                          if (data['data']['heure_depart'] != null)
                            Text('Départ: ${data['data']['heure_depart']}'),
                          if (data['data']['est_en_retard'])
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Retard',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Attendance Summary (Last 7 days)
            const Text(
              'Résumé de Présence (Les 7 Derniers Jours)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final data = snapshot.data ?? {};
                final summary = data['summary'] as Map<String, dynamic>? ?? {};
                final attendance = data['attendance'] as List? ?? [];

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryCard('Présent', summary['present'] ?? 0, Colors.green),
                        _summaryCard('Retard', summary['late'] ?? 0, Colors.orange),
                        _summaryCard('Absent', summary['absent'] ?? 0, Colors.red),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Historique Détaillé',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (attendance.isEmpty)
                      const Text('Aucun enregistrement de présence')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: attendance.length,
                        itemBuilder: (context, index) {
                          final record = attendance[index] as Map<String, dynamic>;
                          final isLate = record['est_en_retard'] == true || record['est_en_retard'] == 't';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(record['date'] ?? 'Date inconnue'),
                              subtitle: Text(
                                'Arrivée: ${record['heure_arrivee'] ?? 'N/A'}',
                                style: TextStyle(
                                  color: isLate ? Colors.orange : Colors.green,
                                  fontWeight: isLate ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              trailing: isLate
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Retard',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    )
                                  : const Icon(Icons.check, color: Colors.green),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
