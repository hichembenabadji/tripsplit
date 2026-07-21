import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'app_colors.dart';
import 'auth_ui.dart';
import 'trip_store.dart';
import 'user_profile_widgets.dart';

final RegExp _profileEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Uint8List? _profileImageBytes;
  bool _didLoadProfile = false;
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_handleFormChanged);
    _lastNameController.addListener(_handleFormChanged);
    _emailController.addListener(_handleFormChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didLoadProfile) {
      return;
    }

    final AppUserProfile currentUser = TripStoreScope.read(context).currentUser;
    _firstNameController.text = currentUser.firstName;
    _lastNameController.text = currentUser.lastName ?? '';
    _emailController.text = currentUser.email;
    _profileImageBytes = currentUser.profileImageBytes == null
        ? null
        : Uint8List.fromList(currentUser.profileImageBytes!);
    _didLoadProfile = true;
  }

  @override
  void dispose() {
    _firstNameController
      ..removeListener(_handleFormChanged)
      ..dispose();
    _lastNameController
      ..removeListener(_handleFormChanged)
      ..dispose();
    _emailController
      ..removeListener(_handleFormChanged)
      ..dispose();
    super.dispose();
  }

  String get _trimmedFirstName => _firstNameController.text.trim();
  String get _trimmedLastName => _lastNameController.text.trim();
  String get _trimmedEmail => _emailController.text.trim();

  bool get _isEmailValid => _profileEmailPattern.hasMatch(_trimmedEmail);

  bool get _canSave =>
      _trimmedFirstName.isNotEmpty && _trimmedEmail.isNotEmpty && _isEmailValid;

  String? get _emailSupportingText {
    if (_trimmedEmail.isEmpty || _isEmailValid) {
      return null;
    }

    return 'Enter a valid email address to save your profile.';
  }

  void _handleFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickProfileImage() async {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isPickingPhoto = true;
    });

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1440,
        requestFullMetadata: false,
      );

      if (pickedFile == null) {
        return;
      }

      final Uint8List bytes = await pickedFile.readAsBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _profileImageBytes = bytes;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open your photo library.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingPhoto = false;
        });
      }
    }
  }

  void _removeProfileImage() {
    setState(() {
      _profileImageBytes = null;
    });
  }

  void _saveProfile() {
    if (!_canSave) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    TripStoreScope.read(context).updateCurrentUserProfile(
      firstName: _trimmedFirstName,
      lastName: _trimmedLastName.isEmpty ? null : _trimmedLastName,
      email: _trimmedEmail,
      profileImageBytes: _profileImageBytes,
      removeProfileImage: _profileImageBytes == null,
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final AuthColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.auth;

    return TripSplitAuthPage(
      onBack: () => Navigator.of(context).maybePop(),
      card: TripSplitAuthCard(
        title: 'Edit Profile',
        description:
            'Keep your TripSplit profile current so your travel details stay easy to recognize.',
        children: <Widget>[
          TripSplitLabeledTextField(
            label: 'FIRST NAME',
            hintText: 'Alex',
            controller: _firstNameController,
            autofillHints: const <String>[AutofillHints.givenName],
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 24),
          TripSplitLabeledTextField(
            label: 'LAST NAME',
            hintText: 'Rivera',
            controller: _lastNameController,
            autofillHints: const <String>[AutofillHints.familyName],
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 24),
          TripSplitLabeledTextField(
            label: 'EMAIL ADDRESS',
            hintText: 'name@trip.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.email],
            textInputAction: TextInputAction.done,
            supportingText: _emailSupportingText,
            supportingTextColor: colors.error,
            borderColor: _emailSupportingText == null
                ? colors.fieldBorder
                : colors.error,
          ),
          const SizedBox(height: 24),
          TripSplitProfilePhotoField(
            label: 'PROFILE PICTURE',
            description:
                'Add a profile picture now, or swap it out whenever you need to.',
            imageBytes: _profileImageBytes,
            isBusy: _isPickingPhoto,
            onPickImage: _pickProfileImage,
            onRemoveImage: _profileImageBytes == null
                ? null
                : _removeProfileImage,
          ),
          const SizedBox(height: 24),
          TripSplitPrimaryButton(
            label: 'Save Changes',
            buttonKey: const ValueKey<String>('edit_profile_save_button'),
            onPressed: _canSave ? _saveProfile : null,
          ),
        ],
      ),
    );
  }
}
