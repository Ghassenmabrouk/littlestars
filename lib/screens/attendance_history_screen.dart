import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attendance_model.dart';
import '../models/models.dart';
import '../localization/app_strings.dart';
import '../services/api_service.dart';
import '../theme/kg_theme.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final Child child;

  const AttendanceHistoryScreen({required this.child});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late Future<List<AttendanceRecord>> _attendanceHistory;

  @override
  void initState() {
    super.initState();
    _attendanceHistory = _fetchAttendanceHistory();
  }

  Future<List<AttendanceRecord>> _fetchAttendanceHistory() async {
    final response = await ApiService.getAttendanceHistory(widget.child.id);
    
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data
          .map((record) => AttendanceRecord.fromJson(record as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load attendance history');
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

  Color _getStatusColor(AttendanceRecord record) {
    if (record.statut == 'retard') {
      return Colors.orange;
    } else if (record.statut == 'absent') {
      return Colors.red;
    }
    return Colors.green;
  }

  String _getStatusLabel(AttendanceRecord record) {
    if (record.statut == 'retard') {
      return 'En Retard';
    } else if (record.statut == 'absent') {
      return 'Absent';
    }
    return 'Présent';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique de Présence'),
        elevation: 0,
      ),
      body: FutureBuilder<List<AttendanceRecord>>(
        future: _attendanceHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Erreur lors du chargement'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _attendanceHistory = _fetchAttendanceHistory();
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
                  const Icon(Icons.calendar_today, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Pas d\'historique de présence'),
                ],
              ),
            );
          }

          final records = snapshot.data!;
          
          // Calculate summary by statut field
          int totalDays = records.length;
          int presentDays = records.where((r) => r.statut == 'present').length;
          int lateDays = records.where((r) => r.statut == 'retard').length;
          int absentDays = records.where((r) => r.statut == 'absent').length;
          double attendanceRate = totalDays > 0 ? ((presentDays + lateDays) / totalDays * 100) : 0;

          // Calculate monthly statistics (current month)
          final now = DateTime.now();
          final currentMonthRecords = records.where((r) {
            try {
              final recordDate = DateTime.parse(r.date);
              return recordDate.year == now.year && recordDate.month == now.month;
            } catch (e) {
              return false;
            }
          }).toList();

          int monthlyPresentDays = currentMonthRecords.where((r) => r.statut == 'present').length;
          int monthlyLateDays = currentMonthRecords.where((r) => r.statut == 'retard').length;
          int monthlyAbsentDays = currentMonthRecords.where((r) => r.statut == 'absent').length;
          int monthlyTotalDays = currentMonthRecords.length;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Summary Cards - First Row
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              label: 'Jours',
                              value: totalDays.toString(),
                              color: KG.accentBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              label: 'Présent',
                              value: presentDays.toString(),
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              label: 'En Retard',
                              value: lateDays.toString(),
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              label: 'Absent',
                              value: absentDays.toString(),
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: SizedBox.shrink()),
                          const SizedBox(width: 8),
                          Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Attendance Rate
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE0CC), Color(0xFFFFF8F0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: KG.divider),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Taux de Présence',
                          style: TextStyle(fontSize: 14, color: KG.textMuted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${attendanceRate.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: KG.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Monthly Summary Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Présences ce mois',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              label: 'Présent',
                              value: monthlyPresentDays.toString(),
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              label: 'Retard',
                              value: monthlyLateDays.toString(),
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              label: 'Absent',
                              value: monthlyAbsentDays.toString(),
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // History List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'Historique',
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
                    return _buildAttendanceItem(record);
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

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(AttendanceRecord record) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
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
                color: _getStatusColor(record),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 12),

            // Date and Time
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
                  if (record.heure_arrivee != null)
                    Text(
                      'Arrivée: ${record.heure_arrivee}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  if (record.heure_depart != null)
                    Text(
                      'Départ: ${record.heure_depart}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),

            // Status Badge
            Container(
              decoration: BoxDecoration(
                color: _getStatusColor(record).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor(record).withOpacity(0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    record.statut == 'absent' ? Icons.cancel : (record.statut == 'retard' ? Icons.schedule : Icons.check_circle),
                    size: 14,
                    color: _getStatusColor(record),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getStatusLabel(record),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(record),
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
