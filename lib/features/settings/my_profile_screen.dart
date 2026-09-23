import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/services/auth_service.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

// Firestore documents cap out at 1 MiB total, and base64 inflates raw bytes
// by ~4/3 — this leaves comfortable room for the rest of the user doc's
// fields once the photo is encoded.
const _maxPhotoBytes = 750 * 1024;

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _authService = AuthService();
  late final _nameController = TextEditingController(
    text: FirebaseAuth.instance.currentUser?.displayName ?? '',
  );

  bool _isUploadingPhoto = false;
  bool _isSavingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 90,
    );
    if (picked == null) return;

    // Let the user choose exactly which part of the photo becomes the
    // avatar, rather than always using its center.
    if (!mounted) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Choose photo frame',
          cropStyle: CropStyle.circle,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(title: 'Choose photo frame', cropStyle: CropStyle.circle),
      ],
    );
    if (cropped == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final bytes = await File(cropped.path).readAsBytes();
      if (bytes.length > _maxPhotoBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'That photo is too large — please choose one under 1MB.',
            ),
          ),
        );
        return;
      }

      final base64 = base64Encode(bytes);
      if (!mounted) return;
      await context.read<TransactionsRepository>().updatePhotoBase64(base64);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update photo: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _isUploadingPhoto = true);
    try {
      await context.read<TransactionsRepository>().updatePhotoBase64(null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not remove photo: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _showPhotoOptions() async {
    final hasPhoto = context.read<TransactionsRepository>().photoBase64 != null;
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('View photo'),
                onTap: () => Navigator.pop(sheetContext, _PhotoAction.view),
              ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.gallery),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(sheetContext, _PhotoAction.remove),
              ),
          ],
        ),
      ),
    );

    switch (action) {
      case _PhotoAction.view:
        _viewPhoto();
      case _PhotoAction.camera:
        await _pickAndUploadPhoto(ImageSource.camera);
      case _PhotoAction.gallery:
        await _pickAndUploadPhoto(ImageSource.gallery);
      case _PhotoAction.remove:
        await _removePhoto();
      case null:
        break;
    }
  }

  void _viewPhoto() {
    final photoBase64 = context.read<TransactionsRepository>().photoBase64;
    if (photoBase64 == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _PhotoViewerScreen(imageBytes: base64Decode(photoBase64)),
      ),
    );
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSavingName = true);
    try {
      await _authService.updateDisplayName(name);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update name: $e')));
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoBase64 = context.watch<TransactionsRepository>().photoBase64;
    final cardColor = Theme.of(context).cardColor;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          Center(
            child: GestureDetector(
              onTap: _isUploadingPhoto ? null : _showPhotoOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: primary,
                    backgroundImage: photoBase64 != null
                        ? MemoryImage(base64Decode(photoBase64))
                        : null,
                    child: _isUploadingPhoto
                        ? const CircularProgressIndicator(color: Colors.white)
                        : (photoBase64 == null
                              ? const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Colors.white,
                                )
                              : null),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: cardColor, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Name', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isSavingName ? null : _saveName,
                  child: _isSavingName
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Email', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              user?.email ?? 'No email on this account',
              style: TextStyle(color: onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PhotoAction { view, camera, gallery, remove }

class _PhotoViewerScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const _PhotoViewerScreen({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(child: InteractiveViewer(child: Image.memory(imageBytes))),
    );
  }
}
