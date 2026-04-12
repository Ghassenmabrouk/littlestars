import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/kg_theme.dart';

class AbsenceHistoryScreen extends StatefulWidget {
  final Child child;

  const AbsenceHistoryScreen({required this.child});

  @override
  State<AbsenceHistoryScreen> createState() => _AbsenceHistoryScreenState();
}

class _AbsenceHistoryScreenState extends State<AbsenceHistoryScreen> {
  late Future<List<AbsenceRecord>> _absenceHistory;

  @override
  void initState() {
    super.initState();
    _absenceHistory = _fetchAbsenceHistory();
  }

  Future<List<AbsenceRecord>> _fetchAbsenceHistory() async {
    final response = await ApiService.getAttendanceHistory(widget.child.id);
    
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      // Filter only records with statut == 'absent'
      final absences = data
          .where((record) => (record as Map<String, dynamic>)['statut'] == 'absent')
          .map((record) => AbsenceRecord.fromJson(record as Map<String, dynamic>))
          .toList();
      return absences;
    } else {
      throw Exception('Failed to load absence history');
    }
  }

  String _formatDate(String date) {
    try {
      final DateTime parsed = DateTime.parse(date);
      return "${parsed.day}/${parsed.month}/${parsed.year}";
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique d\'absence'),
        elevation: 0,
      ),
      body: FutureBuilder<List<AbsenceRecord>>(
        future: _absenceHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('❌', style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  const Text('Erreur lors du chargement'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _absenceHistory = _fetchAbsenceHistory();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✅', style: const TextStyle(fontSize: 48, color: Colors.green)),
                  const SizedBox(height: 16),
                  const Text('Super! Pas d\'absence'),
                  const SizedBox(height: 8),
                  const Text(
                    'Votre enfant n\'a eu aucune absence',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final records = snapshot.data!;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Summary Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade100, Colors.red.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Total d\'absences',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          records.length.toString(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // History List Label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'Détails des absences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _buildAbsenceItem(record);
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAbsenceItem(AbsenceRecord record) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Status Indicator
            Container(
              width: 8,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 12),

            // Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(record.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (record.notes != null && record.notes!.isNotEmpty)
                    Text(
                      'Notes: ${record.notes}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Status Badge
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cancel,
                    size: 14,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Absent',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AbsenceRecord {
  final int id;
  final int enfantId;
  final String date;
  final String? notes;
  final String? heure_arrivee;

  AbsenceRecord({
    required this.id,
    required this.enfantId,
    required this.date,
    this.notes,
    this.heure_arrivee,
  });

  factory AbsenceRecord.fromJson(Map<String, dynamic> json) {
    return AbsenceRecord(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      enfantId: json['enfant_id'] is int ? json['enfant_id'] : int.parse(json['enfant_id'].toString()),
      date: json['date'] ?? '',
      notes: json['notes'],
      heure_arrivee: json['heure_arrivee'],
    );
  }
}
