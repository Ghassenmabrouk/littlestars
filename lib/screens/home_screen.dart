import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/notification_provider.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../theme/kg_theme.dart';
import 'child_details_screen.dart';
import 'add_child_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedChildIndex = 0;
  Map<String, dynamic>? todayStatus;
  bool _loadingStatus = false;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayStatus();
      _loadNotifications();
    });
    // Refresh notifications every 30 seconds
    Future.delayed(const Duration(seconds: 30), _refreshNotifications);
    
    // Floating animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  void _loadNotifications() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<NotificationProvider>()
          .fetchNotifications(authProvider.user!.id);
    }
  }

  Future<void> _refreshNotifications() async {
    if (mounted) {
      final provider = context.read<NotificationProvider>();
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null && provider.shouldRefresh()) {
        await provider.fetchNotifications(authProvider.user!.id);
        // Schedule next refresh
        if (mounted) {
          Future.delayed(const Duration(seconds: 30), _refreshNotifications);
        }
      }
    }
  }

  Future<void> _loadTodayStatus() async {
    if (context.read<AuthProvider>().children.isEmpty) return;

    setState(() => _loadingStatus = true);

    final children = context.read<AuthProvider>().children;
    final response = await ApiService.getTodayStatus(children[_selectedChildIndex].id);

    setState(() {
      todayStatus = response['data'];
      _loadingStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        actions: [
          // Notification Bell
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, child) {
              final unreadCount = notifProvider.unreadCount;
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/notifications');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('🔔', style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/settings'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('⚙️', style: const TextStyle(fontSize: 24)),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('🚪', style: const TextStyle(fontSize: 24)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated floating decorative elements
          Positioned(
            top: 20,
            left: 20,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingController.value * 15),
                  child: Text('🎈', style: const TextStyle(fontSize: 28)),
                );
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 30,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatingController.value * 20),
                  child: Text('❤️', style: const TextStyle(fontSize: 24)),
                );
              },
            ),
          ),
          Positioned(
            bottom: 150,
            left: 25,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingController.value * 25),
                  child: Text('🧸', style: const TextStyle(fontSize: 26)),
                );
              },
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatingController.value * 18),
                  child: Text('🎀', style: const TextStyle(fontSize: 24)),
                );
              },
            ),
          ),
          
          // Main content
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.children.isEmpty) {
                return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Text('👶', style: const TextStyle(fontSize: 100, color: KG.primary)),
                      const SizedBox(height: 24),
                      Text(
                        'Bienvenue, ${authProvider.user?.nomComplet}!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Vous n\'avez pas encore ajouté d\'enfants',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: KG.divider, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Text('ℹ️', style: const TextStyle(fontSize: 32, color: KG.primary)),
                            const SizedBox(height: 12),
                            Text(
                              'Commencez par ajouter votre premier enfant',
                              style: const TextStyle(
                                fontSize: 14,
                                color: KG.primaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Vous pourrez suivre la présence, les activités et les communications de votre enfant',
                              style: TextStyle(
                                fontSize: 12,
                                color: KG.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          icon: const Text('➕', style: TextStyle(fontSize: 20)),
                          label: const Text(
                            'Ajouter un enfant',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KG.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddChildScreen(
                                  userEmail: authProvider.user?.email ?? '',
                                  onChildAdded: () {
                                    // Just pop the dialog
                                    Navigator.pop(context, true);
                                  },
                                ),
                              ),
                            );
                            
                            // If child was added, reload data
                            if (result == true) {
                              await authProvider.reloadChildren();
                              if (mounted) {
                                _loadTodayStatus();
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Besoin d\'aide?',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final selectedChild = authProvider.children[_selectedChildIndex];

          return RefreshIndicator(
            onRefresh: _loadTodayStatus,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Greeting
                Text(
                  'Bienvenue, ${authProvider.user?.nomComplet}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Child selector
                if (authProvider.children.length > 1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sélectionner un Enfant:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: authProvider.children.length,
                          itemBuilder: (context, index) {
                            final child = authProvider.children[index];
                            final isSelected = index == _selectedChildIndex;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedChildIndex = index;
                                  todayStatus = null;
                                });
                                _loadTodayStatus();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? KG.primary : const Color(0xFFFFF0E0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(color: KG.primaryDark, width: 2)
                                      : Border.all(color: KG.divider),
                                  boxShadow: isSelected ? [
                                    BoxShadow(color: KG.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))
                                  ] : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      child.sexe == 'F' ? '👧' : '👦',
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      child.prenom,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                // Child Info Card
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChildDetailsScreen(child: selectedChild.toMap()),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('👤', style: const TextStyle(color: KG.primary, fontSize: 32)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedChild.fullName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (selectedChild.groupeAge != null)
                                      Text(
                                      'Groupe d\'\u00c2ge: ${selectedChild.groupeAge}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                              Text('→', style: const TextStyle(color: KG.primary, fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Cliquez pour voir le profil complet',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Today's Status
                const Text(
                  'État d\'Aujourd\'hui',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _loadingStatus
                    ? const Center(child: CircularProgressIndicator())
                    : todayStatus != null
                        ? Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatusRow(
                                    'État',
                                    todayStatus!['statut'] ?? 'Non marqué',
                                    'ℹ️',
                                  ),
                                  const SizedBox(height: 12),
                                  if (todayStatus!['heure_arrivee'] != null)
                                    _buildStatusRow(
                                      'Heure d\'Arrivée',
                                      todayStatus!['heure_arrivee'],
                                      '📥',
                                    ),
                                  if (todayStatus!['heure_depart'] != null)
                                    _buildStatusRow(
                                      'Heure de Départ',
                                      todayStatus!['heure_depart'],
                                      '📤',
                                    ),
                                  if (todayStatus!['repas_midi'] == true ||
                                      todayStatus!['repas_midi'] == 1)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Text('🍽️',
                                              style: const TextStyle(fontSize: 18, color: Colors.orange)),
                                          SizedBox(width: 8),
                                          Text('Déjeuner: Pris'),
                                        ],
                                      ),
                                    ),
                                  if (todayStatus!['notes'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Notes:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(todayStatus!['notes']),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        : const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Aucun enregistrement pour aujourd\'hui'),
                            ),
                          ),
                const SizedBox(height: 20),

                // Quick Actions
                const Text(
                  'Actions Rapides',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildQuickActionCard(
                      'Profil Complet',
                      '👤',
                      KG.primary,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChildDetailsScreen(child: selectedChild.toMap()),
                          ),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      'Ajouter un Enfant',
                      '➕',
                      Colors.green,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddChildScreen(
                              userEmail: authProvider.user?.email ?? '',
                              onChildAdded: () async {
                                // Reload children from server
                                await authProvider.reloadChildren();
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _loadTodayStatus();
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      'Historique de Présence',
                      '📅',
                      Colors.orange,
                      () {
                        final childData = {
                          'enfant_id': selectedChild.id,
                          'id': selectedChild.id,
                          'nom': selectedChild.nom,
                          'prenom': selectedChild.prenom,
                          'groupe_age': selectedChild.groupeAge,
                          'date_naissance': selectedChild.dateNaissance,
                          'statut': selectedChild.statut,
                        };
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildDetailsScreen(child: childData),
                          ),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      'Paramètres',
                      '⚙️',
                      Colors.purple,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Paramètres bientôt disponibles'),
                          duration: const Duration(seconds: 10),
                          action: SnackBarAction(label: 'Fermer', onPressed: () {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20, color: KG.primary)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String emoji,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 40, color: color)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
