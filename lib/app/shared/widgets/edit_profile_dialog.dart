import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/theme_controller.dart';

typedef EditProfileSaveCallback = Future<bool> Function(
  String firstName,
  String lastName,
  String? avatarPath,
);

class EditProfileDialog extends StatefulWidget {
  EditProfileDialog({
    super.key,
    required this.avatarUrl,
    required this.firstName,
    required this.lastName,
    required this.onSave,
  })  : _firstNameController = TextEditingController(text: firstName),
        _lastNameController = TextEditingController(text: lastName);

  static const _navy = Color(0xFF15598D);

  final String avatarUrl;
  final String firstName;
  final String lastName;
  final EditProfileSaveCallback onSave;
  final TextEditingController _firstNameController;
  final TextEditingController _lastNameController;

  static Future<void> show(
    BuildContext context, {
    required String avatarUrl,
    required String firstName,
    required String lastName,
    required EditProfileSaveCallback onSave,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup'.tr,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, _) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
            child: EditProfileDialog(
              avatarUrl: avatarUrl,
              firstName: firstName,
              lastName: lastName,
              onSave: onSave,
            ),
          ),
        );
      },
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedAvatarPath;
  bool _isSaving = false;

  @override
  void dispose() {
    widget._firstNameController.dispose();
    widget._lastNameController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceSheet() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? AppDarkColors.surface : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2A3A);
    final iconColor = isDark ? AppDarkColors.accent : EditProfileDialog._navy;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: sheetColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  tileColor: sheetColor,
                  leading: Icon(Icons.photo_camera_outlined, color: iconColor),
                  title: Text(
                    'Ambil dari kamera'.tr,
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  tileColor: sheetColor,
                  leading: Icon(Icons.photo_library_outlined, color: iconColor),
                  title: Text(
                    'Pilih dari galeri'.tr,
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 900,
      );
      if (image == null) return;

      setState(() => _selectedAvatarPath = image.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto. Coba lagi.'.tr)),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    final firstName = widget._firstNameController.text.trim();
    final lastName = widget._lastNameController.text.trim();
    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama depan wajib diisi.'.tr)),
      );
      return;
    }

    setState(() => _isSaving = true);
    final saved = await widget.onSave(firstName, lastName, _selectedAvatarPath);
    if (!mounted) return;

    setState(() => _isSaving = false);
    if (saved) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogColor = isDark ? AppDarkColors.surface : Colors.white;
    final titleColor = isDark ? Colors.white : EditProfileDialog._navy;
    final accentColor = isDark ? AppDarkColors.accent : EditProfileDialog._navy;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430, maxHeight: 600),
        child: Container(
          decoration: BoxDecoration(
            color: dialogColor,
            borderRadius: BorderRadius.circular(10),
            border: isDark ? Border.all(color: AppDarkColors.border) : null,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 26, 32, 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 34),
                      Expanded(
                        child: Text(
                          'Edit Profil'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: accentColor,
                        iconSize: 32,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 34,
                          minHeight: 34,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isSaving ? null : _showImageSourceSheet,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _AvatarPreview(
                            avatarUrl: widget.avatarUrl,
                            selectedAvatarPath: _selectedAvatarPath,
                          ),
                          Container(
                            width: 136,
                            height: 136,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.34),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.white,
                            size: 42,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _isSaving ? null : _showImageSourceSheet,
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: Text('Ganti foto'.tr),
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _EditField(
                    label: 'Nama depan',
                    isRequired: true,
                    controller: widget._firstNameController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  _EditField(
                    label: 'Nama belakang(opsional)',
                    controller: widget._lastNameController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 42),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF052C58)
                            : EditProfileDialog._navy,
                        foregroundColor:
                            isDark ? AppDarkColors.accent : Colors.white,
                        elevation: 3,
                        shadowColor:
                            EditProfileDialog._navy.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Simpan'.tr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.avatarUrl,
    required this.selectedAvatarPath,
  });

  final String avatarUrl;
  final String? selectedAvatarPath;

  bool get _hasLocalAvatar {
    final path = selectedAvatarPath ?? avatarUrl;
    return path.isNotEmpty && !path.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    final path = selectedAvatarPath ?? avatarUrl;

    if (path.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return CircleAvatar(
        radius: 68,
        backgroundColor:
            isDark ? AppDarkColors.surfaceVariant : Colors.grey.shade200,
        child: Icon(
          Icons.person,
          size: 64,
          color: isDark ? Colors.white54 : Colors.grey,
        ),
      );
    }

    if (_hasLocalAvatar) {
      return ClipOval(
        child: Image.file(
          File(path),
          width: 136,
          height: 136,
          fit: BoxFit.cover,
        ),
      );
    }

    return CircleAvatar(
      radius: 68,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.surfaceVariant
          : Colors.grey.shade200,
      backgroundImage: NetworkImage(path),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    required this.isDark,
    this.isRequired = false,
  });

  final String label;
  final TextEditingController controller;
  final bool isDark;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? Colors.white70 : const Color(0xFF164E7D);
    final inputTextColor = isDark ? Colors.white : const Color(0xFF1E2A3A);
    final fieldColor =
        isDark ? AppDarkColors.surfaceVariant : const Color(0xFFF8FAFD);
    final borderColor = isDark ? AppDarkColors.border : EditProfileDialog._navy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.tr,
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: Color(0xFFD11C25)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 45,
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: inputTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: fieldColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: borderColor, width: 1.4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: borderColor, width: 1.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
