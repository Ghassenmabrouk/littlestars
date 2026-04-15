import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/kg_theme.dart';

class ActivitiesScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const ActivitiesScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  late Future<Map<String, dynamic>> _activitiesFuture;
  late Future<Map<String, dynamic>> _enrolledFuture;
  Set<int> _enrolledActivityIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() {
    _activitiesFuture = ApiService.getAllActivities();
    _enrolledFuture = ApiService.getChildActivities(widget.childId).then((data) {
      final activities = (data['data'] as List? ?? []).cast<Map<String, dynamic>>();
      setState(() {
        _enrolledActivityIds = activities.map<int>((a) => int.tryParse(a['id'].toString()) ?? 0).toSet();
      });
      return data;
    });
  }

  Future<void> _toggleEnrollment(int activityId, bool isEnrolled) async {
    setState(() => _isLoading = true);

    try {
      final response = isEnrolled
          ? await ApiService.unenrollChildFromActivity(activityId, widget.childId)
          : await ApiService.enrollChildInActivity(activityId, widget.childId);

      if (response['success'] == true) {
        // Refresh both futures to get latest data
        setState(() {
          _loadActivities();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEnrolled
                  ? '✅ ${widget.childName} retiré de l\'activité'
                  : '✅ ${widget.childName} inscrit à l\'activité',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${response['message'] ?? 'Erreur inconnue'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities - ${widget.childName}'),
        elevation: 0,
        backgroundColor: KG.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('❌', style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() => _loadActivities()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? {};
          final activities = (data['data'] as List? ?? []).cast<Map<String, dynamic>>();

          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎨', style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text(
                    'No activities available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check back later for new activities',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _loadActivities());
              // Wait for both futures to complete
              await Future.wait([_activitiesFuture, _enrolledFuture]);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length + 1, // +1 for enrolled header
              itemBuilder: (context, index) {
                // Show enrolled activities section first
                if (index == 0) {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: _enrolledFuture,
                    builder: (context, enrolledSnapshot) {
                      if (enrolledSnapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: SizedBox(height: 20, child: CircularProgressIndicator()),
                        );
                      }

                      final enrolledData = enrolledSnapshot.data ?? {};
                      final enrolledActivities = (enrolledData['data'] as List? ?? []).cast<Map<String, dynamic>>();

                      if (enrolledActivities.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Text(
                            'Aucune activité inscrite',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '✅ Activités Inscrites',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...enrolledActivities.map((activity) {
                              final title = activity['titre'] ?? 'Unknown';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  border: Border.all(color: Colors.green, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '• $title',
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                                ),
                              );
                            }).toList(),
                            const Divider(height: 24),
                            const Text(
                              '📚 Toutes les Activités',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
                  );
                }

                final activity = activities[index - 1];
                final activityId = int.tryParse(activity['id'].toString()) ?? 0;
                final title = activity['titre'] ?? activity['title'] ?? 'Unknown';
                final description = activity['description'] ?? '';
                final type = activity['type_activite'] ?? '';
                final dateStr = activity['date_activite'] ?? '';
                final timeStart = activity['heure_debut'] ?? '';
                final isEnrolled = _enrolledActivityIds.contains(activityId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: KG.textDark,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isEnrolled
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isEnrolled ? '✅ Enrolled' : '⭕ Available',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isEnrolled
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Description
                        if (description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        // Activity Details
                        Row(
                          children: [
                            if (type.isNotEmpty)
                              Expanded(
                                child: Row(
                                  children: [
                                    const Text('🎨 ', style: TextStyle(fontSize: 16)),
                                    Expanded(
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (dateStr.isNotEmpty)
                              Expanded(
                                child: Row(
                                  children: [
                                    const Text('📅 ', style: TextStyle(fontSize: 16)),
                                    Expanded(
                                      child: Text(
                                        dateStr.substring(0, dateStr.length > 10 ? 10 : dateStr.length),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        if (timeStart.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Text('⏰ ', style: TextStyle(fontSize: 16)),
                                Text(
                                  timeStart,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Enrollment Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _toggleEnrollment(activityId, isEnrolled),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEnrolled ? Colors.red : KG.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    isEnrolled ? 'Retirer de l\'activité' : 'Rejoindre l\'activité',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
