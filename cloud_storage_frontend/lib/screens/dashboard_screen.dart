import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:deceptra/models/file_model.dart';
import 'package:deceptra/providers/wallet_state.dart';
import 'package:deceptra/services/pinata_service.dart';
import 'package:deceptra/services/notification_service.dart';
import 'package:deceptra/services/ipfs_gateway_service.dart';
import 'package:deceptra/services/custom_mime_service.dart';
import 'package:deceptra/services/custom_date_formatter.dart';
import 'package:deceptra/screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WalletState.of(context).fetchMyFiles();
      NotificationService.requestPermissions();
    });
  }
  Future<void> _uploadFile() async {
    final PlatformFile? result = await FilePicker.pickFile();

    if (result == null || result.path == null) {
      return;
    }

    final File file = File(result.path!);
    final String fileName = result.name;
    final int fileSize = await result.length();
    final String fileType = CustomMimeService.lookupMimeType(file.path);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Uploading to IPFS...'),
          ],
        ),
      ),
    );

    try {
      final cid = await PinataService.uploadFileToIPFS(file);
      
      if (cid == null) throw Exception('Failed to upload file to IPFS');

      if (!mounted) return;
      Navigator.of(context).pop(); 
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Recording on Blockchain...'),
            ],
          ),
        ),
      );

      final provider = WalletState.of(context);
      await provider.blockchainService.uploadFile(cid, fileName, fileSize, fileType);

      if (!mounted) return;
      Navigator.of(context).pop(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded securely!')),
      );

      // Trigger local notification
      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: 'Upload Successful',
        body: 'File "\$fileName" is now stored on the decentralized cloud.',
      );

      provider.fetchMyFiles();
      
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: \$e'), backgroundColor: Colors.red),
      );
    }
  }

  void _shareFile(FileModel file) {
    final TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Share File Securely'),
          content: TextField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Recipient Ethereum Address',
              hintText: '0x...',
              prefixIcon: Icon(Icons.share),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final address = addressController.text.trim();
                if (address.isEmpty || !address.startsWith('0x') || address.length != 42) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid Ethereum address format.')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(); 

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (progressContext) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text('Granting Access on Chain...'),
                      ],
                    ),
                  ),
                );

                try {
                  final provider = WalletState.of(context);
                  await provider.blockchainService.shareFile(file.cid, address);
                  
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Access granted successfully!')),
                  );
                  
                  await NotificationService.showNotification(
                    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                    title: 'File Shared',
                    body: 'You shared "\${file.fileName}" with \${address.substring(0,6)}...\${address.substring(address.length - 4)}',
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sharing failed: \$e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Share Access'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleFileTap(FileModel file) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('Open in Browser (IPFS Gateway)'),
                onTap: () async {
                  Navigator.pop(context);
                  await IpfsGatewayService.openInBrowser(file.cid);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download to Device'),
                onTap: () async {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading file...')),
                  );
                  try {
                    final downloadedPath = await IpfsGatewayService.downloadFile(file.cid, file.fileName);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloaded to \$downloadedPath'), duration: const Duration(seconds: 4)),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '\$bytes B';
    if (bytes < 1024 * 1024) return '\${(bytes / 1024).toStringAsFixed(1)} KB';
    return '\${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  IconData _getIconForType(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('zip') || mimeType.contains('tar')) return Icons.folder_zip;
    return Icons.insert_drive_file;
  }

  Widget _buildFileList(List<FileModel> files, bool isSharedWithMe) {
    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              isSharedWithMe ? 'No shared files' : 'No files yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isSharedWithMe ? 'Files shared with you will appear here' : 'Upload your first file to decentralized storage',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: WalletState.of(context).fetchMyFiles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          final dateStr = CustomDateFormatter.formatDate(file.uploadTime.toLocal());
          
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _handleFileTap(file),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForType(file.fileType),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    file.fileName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatSize(file.fileSize),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• \$dateStr',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        if (isSharedWithMe)
                           Padding(
                             padding: const EdgeInsets.only(top: 4.0),
                             child: Text(
                               'Owner: \${file.owner.substring(0,6)}...',
                               style: Theme.of(context).textTheme.bodySmall,
                             ),
                           ),
                      ],
                    ),
                  ),
                  trailing: isSharedWithMe 
                      ? null 
                      : IconButton(
                          icon: const Icon(Icons.share_rounded),
                          color: Theme.of(context).colorScheme.secondary,
                          tooltip: 'Share Access',
                          onPressed: () => _shareFile(file),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Deceptra', 'Shared With Me', 'Profile & Settings'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
      ),
      body: Builder(
        builder: (context) {
          final provider = WalletState.of(context);
          if (provider.isLoading && provider.myFiles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_selectedIndex == 2) {
            return const SettingsScreen();
          }

          return IndexedStack(
            index: _selectedIndex,
            children: [
              _buildFileList(provider.myFiles, false),
              _buildFileList(provider.sharedFiles, true),
            ],
          );
        },
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton.extended(
        onPressed: _uploadFile,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Upload'),
      ) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'My Files',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Shared',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
