import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _musicProvider = 'local';
  int _sensitivity = 5;
  bool _permissionsGranted = false;
  late final TextEditingController _sensitivityController;

  @override
  void initState() {
    super.initState();
    _sensitivityController = TextEditingController(text: '$_sensitivity');
  }

  @override
  void dispose() {
    _sensitivityController.dispose();
    super.dispose();
  }

  void _updateSensitivity(int value) {
    final clamped = value < 1 ? 1 : value;
    setState(() {
      _sensitivity = clamped;
      _sensitivityController.text = '$_sensitivity';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Music Provider',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Local Library'),
                  value: 'local',
                  groupValue: _musicProvider,
                  onChanged: (value) => setState(() {
                    _musicProvider = value ?? 'local';
                  }),
                ),
                RadioListTile<String>(
                  title: const Text('Spotify'),
                  value: 'spotify',
                  groupValue: _musicProvider,
                  onChanged: (value) => setState(() {
                    _musicProvider = value ?? 'spotify';
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sensitivity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _updateSensitivity(_sensitivity - 1),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _sensitivityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Sensitivity',
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          _sensitivity = parsed;
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _updateSensitivity(_sensitivity + 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Permissions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: CheckboxListTile(
              title: const Text('Permissions granted'),
              subtitle: const Text('Enable access to required device features'),
              value: _permissionsGranted,
              onChanged: (value) {
                setState(() {
                  _permissionsGranted = value ?? false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
