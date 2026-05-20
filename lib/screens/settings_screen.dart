import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';

/// Settings screen, gated behind a 4-digit parental PIN (default: 1234).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _unlocked = false;
  final _pinCtrl = TextEditingController();
  String? _pinError;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _unlocked ? _buildSettings(context) : _buildPinGate(context);
  }

  // ── PIN Gate ────────────────────────────────────────────────────────────

  Widget _buildPinGate(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<VideoProvider>().isDarkMode
          ? const Color(0xFF0F0F0F)
          : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 56, color: Color(0xFFFF0000)),
              const SizedBox(height: 16),
              const Text(
                'Parental Controls',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter your 4-digit PIN to continue.',
                style: TextStyle(color: Color(0xFF606060)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 12),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'PIN',
                  counterText: '',
                  errorText: _pinError,
                ),
                onChanged: (val) {
                  if (_pinError != null) setState(() => _pinError = null);
                  if (val.length == 4) _checkPin(val);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _checkPin(_pinCtrl.text),
                  child: const Text('Unlock', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Default PIN: 1234',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkPin(String pin) {
    if (context.read<VideoProvider>().validatePin(pin)) {
      setState(() => _unlocked = true);
    } else {
      setState(() {
        _pinError = 'Incorrect PIN';
        _pinCtrl.clear();
      });
    }
  }

  // ── Settings content ────────────────────────────────────────────────────

  Widget _buildSettings(BuildContext context) {
    final provider = context.watch<VideoProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF0000),
        title:
            const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // ── Playback ──────────────────────────────────────────────────
          _sectionHeader('Playback'),
          SwitchListTile(
            title: const Text('Autoplay'),
            subtitle: const Text('Play next video automatically'),
            value: provider.autoplay,
            activeColor: const Color(0xFFFF0000),
            onChanged: provider.setAutoplay,
          ),
          SwitchListTile(
            title: const Text('Shuffle'),
            subtitle: const Text('Play videos in random order'),
            value: provider.shuffle,
            activeColor: const Color(0xFFFF0000),
            onChanged: provider.setShuffle,
          ),

          // ── Appearance ────────────────────────────────────────────────
          _sectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: provider.isDarkMode,
            activeColor: const Color(0xFFFF0000),
            onChanged: provider.setDarkMode,
          ),

          // ── Collection Management ────────────────────────────────────
          _sectionHeader('Collection Management'),
          ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Color(0xFFFF0000)),
            title: const Text('Manage Approved Videos'),
            subtitle: const Text('Select which videos appear in Kid Mode'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _ManageVideosScreen()),
            ),
          ),

          // ── Parental Controls ─────────────────────────────────────────
          _sectionHeader('Parental Controls'),
          ListTile(
            leading: const Icon(Icons.pin),
            title: const Text('Change PIN'),
            subtitle: const Text('Update the 4-digit parental PIN'),
            onTap: () => _showChangePinDialog(context, provider),
          ),
          ListTile(
            leading: const Icon(Icons.folder_off),
            title: const Text('Hidden Folders'),
            subtitle: Text(
              provider.hiddenFolders.isEmpty
                  ? 'No folders hidden'
                  : provider.hiddenFolders.join(', '),
            ),
            onTap: () => _showHiddenFoldersDialog(context, provider),
          ),

          // ── Library ───────────────────────────────────────────────────
          _sectionHeader('Library'),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Library'),
            subtitle: const Text('Rescan device for videos'),
            onTap: () {
              provider.refreshLibrary();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Scanning for videos...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Thumbnail Cache'),
            subtitle: const Text('Frees disk space; thumbnails regenerate'),
            onTap: () {
              provider.refreshLibrary();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Cache cleared. Regenerating thumbnails...')),
              );
            },
          ),

          // ── About ─────────────────────────────────────────────────────
          _sectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('KidsTube'),
            subtitle: Text('v1.0.0  •  Local video player for kids'),
          ),
          const ListTile(
            leading: Icon(Icons.wifi_off),
            title: Text('Fully Offline'),
            subtitle: Text('No internet connection required'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF606060),
            letterSpacing: 1.2,
          ),
        ),
      );

  void _showChangePinDialog(BuildContext context, VideoProvider provider) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change PIN'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'New 4-digit PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (ctrl.text.length == 4) {
                provider.updatePin(ctrl.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN updated.')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHiddenFoldersDialog(
      BuildContext context, VideoProvider provider) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Hidden Folders'),
          content: provider.hiddenFolders.isEmpty
              ? const Text('No folders are currently hidden.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: provider.hiddenFolders
                        .map((f) => ListTile(
                              title: Text(f),
                              trailing: IconButton(
                                icon: const Icon(Icons.visibility,
                                    color: Color(0xFFFF0000)),
                                tooltip: 'Unhide',
                                onPressed: () {
                                  provider.toggleFolderVisibility(f);
                                  setDialogState(() {});
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageVideosScreen extends StatelessWidget {
  const _ManageVideosScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoProvider>();
    final videosByFolder = provider.videosByFolder;
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        title: const Text('Approve Videos'),
        backgroundColor: isDark ? const Color(0xFF202020) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: videosByFolder.isEmpty
          ? const Center(child: Text('No videos found on device.'))
          : ListView.builder(
              itemCount: videosByFolder.length,
              itemBuilder: (context, index) {
                final folderName = videosByFolder.keys.elementAt(index);
                final videos = videosByFolder[folderName]!;
                final allApproved = videos.every((v) => v.isApproved);
                final someApproved = videos.any((v) => v.isApproved) && !allApproved;

                return ExpansionTile(
                  title: Text(folderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${videos.length} videos'),
                  leading: Checkbox(
                    value: allApproved,
                    tristate: someApproved,
                    activeColor: const Color(0xFFFF0000),
                    onChanged: (val) => provider.toggleFolderApproval(folderName, val ?? false),
                  ),
                  children: videos.map((video) {
                    return CheckboxListTile(
                      title: Text(video.title),
                      subtitle: Text(video.formattedDuration),
                      value: video.isApproved,
                      activeColor: const Color(0xFFFF0000),
                      onChanged: (_) => provider.toggleApproval(video.id),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
