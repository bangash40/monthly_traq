import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/auth_service.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/ui.dart';

// Firestore documents cap out at 1 MiB total, and base64 inflates raw bytes
// by ~4/3 — this leaves comfortable room for the rest of the user doc's
// fields once the photo is encoded.
const _maxPhotoBytes = 750 * 1024;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _authService = AuthService();
  late final _nameController = TextEditingController(
    text: FirebaseAuth.instance.currentUser?.displayName ?? '',
  );
  late final _emailController = TextEditingController(
    text: FirebaseAuth.instance.currentUser?.email ?? '',
  );

  bool _isUploadingPhoto = false;
  bool _isSaving = false;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;

    // Let the user choose exactly which part of the photo becomes the
    // avatar, rather than always using its center.
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
        _toast('That photo is too large — please choose one under 1MB.');
        return;
      }
      if (!mounted) return;
      await context.read<TransactionsRepository>().updatePhotoBase64(
        base64Encode(bytes),
      );
    } catch (e) {
      _toast('Could not update photo: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _isUploadingPhoto = true);
    try {
      await context.read<TransactionsRepository>().updatePhotoBase64(null);
    } catch (e) {
      _toast('Could not remove photo: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _showPhotoOptions() async {
    final c = context.colors;
    final photo = context.read<TransactionsRepository>().photoBase64;
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (photo != null)
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
              if (photo != null)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: c.spending),
                  title: Text(
                    'Remove photo',
                    style: TextStyle(color: c.spending),
                  ),
                  onTap: () => Navigator.pop(sheetContext, _PhotoAction.remove),
                ),
            ],
          ),
        ),
      ),
    );

    switch (action) {
      case _PhotoAction.view:
        if (photo != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  _PhotoViewerScreen(imageBytes: base64Decode(photo)),
            ),
          );
        }
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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Enter your name');
      return;
    }
    setState(() {
      _nameError = null;
      _isSaving = true;
    });
    try {
      if (name != FirebaseAuth.instance.currentUser?.displayName) {
        await _authService.updateDisplayName(name);
      }
      if (!mounted) return;
      _toast('Profile saved');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _toast('Could not save: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = FirebaseAuth.instance.currentUser;
    final photo = context.watch<TransactionsRepository>().photoBase64;

    return SubPageScaffold(
      title: 'Edit profile',
      bottom: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: ButtonLabel('Save changes', loading: _isSaving),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        children: [
          Center(
            child: Semantics(
              button: true,
              label: 'Change photo',
              child: GestureDetector(
                onTap: _isUploadingPhoto ? null : _showPhotoOptions,
                child: Stack(
                  children: [
                    ProfileAvatar(
                      photoBase64: photo,
                      initials: initialsFor(_nameController.text, user?.email),
                      size: 116,
                    ),
                    if (_isUploadingPhoto)
                      const Positioned.fill(
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.hairline),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          color: c.ink,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: _isUploadingPhoto ? null : _showPhotoOptions,
              child: const Text('Change photo'),
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Name',
            field: TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Your name',
                errorText: _nameError,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Email',
            field: TextField(
              controller: _emailController,
              readOnly: true,
              enableInteractiveSelection: false,
              style: AppText.body.copyWith(color: c.muted),
              decoration: InputDecoration(
                filled: true,
                fillColor: c.surfaceHigh,
                suffixIcon: Icon(Icons.lock_outline, color: c.muted),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide(color: c.hairline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide(color: c.hairline),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your sign-in email can\'t be changed here.',
            style: AppText.label.copyWith(color: c.muted),
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
