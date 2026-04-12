import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  String _selectedPreset = '';
  bool _isSaving = false;

  final List<Map<String, String>> _presets = [
    {'name': 'Physical Device (Home WiFi)', 'url': 'http://192.168.1.21/jardin_enfant_ghofrane'},
    {'name': 'BlueStacks', 'url': 'http://10.0.0.2/jardin_enfant_ghofrane'},
    {'name': 'Custom', 'url': ''},
  ];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiService.baseUrl);
    _selectedPreset = _getSelectedPreset();
  }

  String _getSelectedPreset() {
    final currentUrl = ApiService.baseUrl;
    for (var preset in _presets) {
      if (preset['url'] == currentUrl) {
        return preset['name']!;
      }
    }
    return 'Custom';
  }

  void _handlePresetChange(String? value) {
    if (value == null) return;
    
    setState(() {
      _selectedPreset = value;
      final preset = _presets.firstWhere((p) => p['name'] == value);
      if (preset['url']!.isNotEmpty) {
        _urlController.text = preset['url']!;
      } else {
        _urlController.clear();
      }
    });
  }

  Future<void> _saveSettings() async {
    final url = _urlController.text.trim();
    
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL')),
      );
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL must start with http:// or https://')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await SettingsService.setBaseUrl(url);
      ApiService.baseUrl = url;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Settings saved! Base URL: $url')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _resetToDefault() async {
    await SettingsService.resetToDefault();
    ApiService.baseUrl = SettingsService.getDefaultBaseUrl();
    
    if (mounted) {
      setState(() {
        _urlController.text = ApiService.baseUrl;
        _selectedPreset = _getSelectedPreset();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset to default: ${ApiService.baseUrl}')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Settings'),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Configure Backend Server',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• BlueStacks: Use 10.0.0.2 (default)\n'
                      '• Physical Phone: Use your machine\'s WiFi IP (e.g., 192.168.1.21)\n'
                      '• For this to work, XAMPP must be running',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Current URL display
            Text(
              'Current Server URL:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: Text(
                ApiService.baseUrl,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Preset selector
            Text(
              'Quick Presets:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedPreset,
              items: _presets
                  .map((preset) => DropdownMenuItem(
                        value: preset['name'],
                        child: Text(preset['name']!),
                      ))
                  .toList(),
              onChanged: _handlePresetChange,
            ),
            const SizedBox(height: 20),
            
            // Custom URL input
            Text(
              'Custom Server URL:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'e.g., http://192.168.1.21/jardin_enfant_ghofrane',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Text('🔗', style: const TextStyle(fontSize: 20)),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                enabled: !_isSaving,
              ),
              enabled: !_isSaving,
            ),
            const SizedBox(height: 20),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Settings',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Reset button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSaving ? null : _resetToDefault,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFFF6B35)),
                ),
                child: const Text(
                  'Reset to Default (BlueStacks)',
                  style: TextStyle(fontSize: 16, color: Color(0xFFFF6B35)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
