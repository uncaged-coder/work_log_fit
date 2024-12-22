import 'package:flutter/material.dart';
import 'package:work_log_fit/settings.dart';
import 'package:work_log_fit/data_sync_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _directoryController = TextEditingController();

  final DataSyncManager _dataSyncManager = DataSyncManager();
  bool _isSyncing = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _loadSavedDirectory();
  }

  Future<void> _loadSavedDirectory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDirectory = prefs.getString('data_folder_path');
    setState(() {
      _directoryController.text = savedDirectory ?? '';
    });
    }

  Future<void> _saveDirectory(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('data_folder_path', path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: themeColor2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Data Synchronization",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _directoryController,
              decoration: InputDecoration(
                labelText: "Data Folder Path",
                hintText: "e.g. /storage/emulated/0/Documents/wlf_data",
                suffixIcon: IconButton(
                  icon: Icon(Icons.folder),
                  onPressed: () async {
                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                    if (selectedDirectory != null) {
                      setState(() {
                        _directoryController.text = selectedDirectory;
                      });
                      await _saveDirectory(selectedDirectory);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSyncing ? null : _handleSync,
              child: Text(_isSyncing ? "Syncing..." : "Sync"),
            ),
            SizedBox(height: 16),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSync() async {
    String directoryPath = _directoryController.text.trim();
    if (directoryPath.isEmpty) {
      setState(() {
        _statusMessage = "Please specify a directory path.";
      });
      return;
    }

    setState(() {
      _isSyncing = true;
      _statusMessage = "Starting sync...";
    });

    try {
      // Import data
      await _dataSyncManager.importData(directoryPath);
      // Export data
      await _dataSyncManager.exportData(directoryPath);

      setState(() {
        _statusMessage = "Sync complete.";
      });
    } catch (e, st) {
      print("Error during sync: $e\n$st");
      setState(() {
        _statusMessage = "Error during sync: $e";
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }
}
