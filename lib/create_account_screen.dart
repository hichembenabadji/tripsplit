import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'app_auth_controller.dart';
import 'app_colors.dart';
import 'app_routes.dart';
import 'auth_service.dart';
import 'auth_ui.dart';
import 'trip_store.dart';
import 'user_profile_widgets.dart';

final RegExp _accountEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  static final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Uint8List? _profileImageBytes;
  bool _isPickingPhoto = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_handleFormChanged);
    _lastNameController.addListener(_handleFormChanged);
    _emailController.addListener(_handleFormChanged);
    _passwordController.addListener(_handleFormChanged);
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
    _passwordController
      ..removeListener(_handleFormChanged)
      ..dispose();
    super.dispose();
  }

  String get _trimmedFirstName => _firstNameController.text.trim();
  String get _trimmedLastName => _lastNameController.text.trim();
  String get _trimmedEmail => _emailController.text.trim();
  String get _password => _passwordController.text;

  bool get _isEmailValid => _accountEmailPattern.hasMatch(_trimmedEmail);

  bool get _canContinue {
    return _trimmedFirstName.isNotEmpty &&
        _trimmedEmail.isNotEmpty &&
        _password.trim().isNotEmpty &&
        _isEmailValid;
  }

  String? get _emailSupportingText {
    if (_trimmedEmail.isEmpty || _isEmailValid) {
      return null;
    }

    return 'Enter a valid email address to continue.';
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

  void _returnToSignIn() {
    FocusManager.instance.primaryFocus?.unfocus();

    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushNamedAndRemoveUntil(
      TripSplitRoutes.signIn,
      (Route<dynamic> route) => false,
    );
  }

  String get _displayName {
    final String trimmedLastName = _trimmedLastName;
    if (trimmedLastName.isEmpty) {
      return _trimmedFirstName;
    }

    return '$_trimmedFirstName $trimmedLastName';
  }

  void _showMessage(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleNext() async {
    if (!_canContinue || _isSubmitting) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final AppAuthController authController = AppAuthScope.read(context);
      await authController.createUserWithEmailAndPassword(
        _trimmedEmail,
        _password,
      );
      await authController.updateDisplayName(_displayName);

      if (!mounted) {
        return;
      }

      TripStoreScope.read(context).saveCurrentUserAccount(
        firstName: _trimmedFirstName,
        lastName: _trimmedLastName.isEmpty ? null : _trimmedLastName,
        email: _trimmedEmail,
        password: _password,
        profileImageBytes: _profileImageBytes,
      );

      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        TripSplitRoutes.dashboard,
        (Route<dynamic> route) => false,
      );
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.auth;

    return TripSplitAuthPage(
      card: TripSplitAuthCard(
        title: 'Create Account',
        description:
            'Set up your TripSplit profile to keep trips, expenses, and settlements close at hand.',
        footer: TripSplitFooterPrompt(
          prompt: 'Already have an account?',
          actionLabel: 'Sign in',
          onAction: _returnToSignIn,
        ),
        children: <Widget>[
          AutofillGroup(
            child: Column(
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
                  textInputAction: TextInputAction.next,
                  supportingText: _emailSupportingText,
                  supportingTextColor: colors.error,
                  borderColor: _emailSupportingText == null
                      ? colors.fieldBorder
                      : colors.error,
                ),
                const SizedBox(height: 24),
                TripSplitLabeledTextField(
                  label: 'PASSWORD',
                  hintText: '********',
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const <String>[AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  enableSuggestions: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TripSplitProfilePhotoField(
            label: 'PROFILE PICTURE',
            description:
                'Choose a photo from your device now, or add one later from Edit Profile.',
            imageBytes: _profileImageBytes,
            isBusy: _isPickingPhoto,
            onPickImage: _pickProfileImage,
            onRemoveImage: _profileImageBytes == null
                ? null
                : _removeProfileImage,
          ),
          const SizedBox(height: 24),
          TripSplitPrimaryButton(
            label: 'Next',
            buttonKey: const ValueKey<String>('create_account_next_button'),
            onPressed: _canContinue && !_isSubmitting ? _handleNext : null,
          ),
        ],
      ),
      footer: const TripSplitPrivacyFooter(),
    );
  }
}
