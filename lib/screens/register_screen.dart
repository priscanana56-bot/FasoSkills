import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/auth_provider.dart';
import '../services/api_exception.dart';
import '../services/artisan_service.dart';
import '../services/category_service.dart';
import '../theme/theme.dart';
import '../widgets/role_badge.dart';
import 'artisan_onboarding_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String initialRole;

  const RegisterScreen({super.key, this.initialRole = 'client'});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  final _specialtyController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _availabilityController = TextEditingController();

  final _artisanService = ArtisanService();
  final _categoryService = CategoryService();
  final _picker = ImagePicker();

  int _currentStep = 0;
  bool _isBusy = false;
  List<Category> _categories = [];
  Category? _selectedCategory;
  XFile? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    if (widget.initialRole == 'artisan') {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          if (_categories.isNotEmpty && _selectedCategory == null) {
            _selectedCategory = _categories.first;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _categories = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _specialtyController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo != null && mounted) {
      setState(() {
        _selectedPhoto = photo;
      });
    }
  }

  Future<void> _createClientAccount() async {
    if (!_step1Key.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.register(
      fullName: _fullNameController.text.trim(),
      emailOrPhone: _emailOrPhoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmationController.text,
      userType: widget.initialRole,
    );

    if (mounted && authProvider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès !')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(initialRole: widget.initialRole),
        ),
      );
    }
  }

  Future<void> _createArtisanAccount() async {
    if (!_step1Key.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _isBusy = true);
    try {
      await authProvider.register(
        fullName: _fullNameController.text.trim(),
        emailOrPhone: _emailOrPhoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
        userType: widget.initialRole,
      );
      if (authProvider.errorMessage != null) return;

      await authProvider.login(
        _emailOrPhoneController.text.trim(),
        _passwordController.text,
      );

      await _artisanService.getCurrentArtisanProfile();
      if (mounted) {
        setState(() {
          _currentStep = 1;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _saveStep2() async {
    if (!_step2Key.currentState!.validate()) return;
    setState(() => _isBusy = true);
    try {
      await _artisanService.updateCurrentArtisanProfile(
        categoryId: _selectedCategory?.id,
        specialty: _specialtyController.text.trim().isEmpty
            ? null
            : _specialtyController.text.trim(),
        city: _cityController.text.trim(),
      );
      if (mounted) {
        setState(() => _currentStep = 2);
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _saveStep3() async {
    if (!_step3Key.currentState!.validate()) return;
    setState(() => _isBusy = true);
    try {
      await _artisanService.updateCurrentArtisanProfile(
        bio: _bioController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
        availability: _availabilityController.text.trim(),
        profilePicture: _selectedPhoto != null
            ? File(_selectedPhoto!.path)
            : null,
        profileStatus: 'complete',
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ArtisanOnboardingScreen()),
        );
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialRole != 'artisan') {
      return _buildClientRegister(context);
    }
    return _buildArtisanRegister(context);
  }

  Widget _buildClientRegister(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    RoleBadge(role: widget.initialRole),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Form(
                    key: _step1Key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Créer un compte',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Remplissez vos informations',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        _fullNameField(),
                        const SizedBox(height: 16),
                        _emailField(),
                        const SizedBox(height: 16),
                        _passwordField(),
                        const SizedBox(height: 16),
                        _passwordConfirmationField(),
                        const SizedBox(height: 24),
                        _authError(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isBusy ? null : _createClientAccount,
                            child: const Text('Créer mon compte'),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Déjà un compte ?',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Se connecter'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtisanRegister(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    RoleBadge(role: widget.initialRole),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 3,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.accentColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_currentStep == 0) _step1View(context),
                      if (_currentStep == 1) _step2View(context),
                      if (_currentStep == 2) _step3View(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step1View(BuildContext context) {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Créer votre compte artisan',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Étape 1 sur 3',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _fullNameField(),
          const SizedBox(height: 16),
          _emailField(),
          const SizedBox(height: 16),
          _passwordField(),
          const SizedBox(height: 16),
          _passwordConfirmationField(),
          const SizedBox(height: 20),
          _authError(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isBusy ? null : _createArtisanAccount,
              child: _isBusy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step2View(BuildContext context) {
    final categories = _categories;
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bienvenue ! Quel est votre domaine d’activité ?',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Étape 2 sur 3',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          DropdownButtonFormField<Category>(
            initialValue: _selectedCategory,
            items: categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            decoration: const InputDecoration(
              labelText: 'Type de métier',
              prefixIcon: Icon(Icons.work_outline_rounded),
            ),
            validator: (value) =>
                value == null ? 'Veuillez choisir un métier' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _specialtyController,
            decoration: const InputDecoration(
              labelText: 'Spécialité',
              prefixIcon: Icon(Icons.star_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'Ville ou zone d’intervention',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Veuillez saisir une ville ou zone'
                : null,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isBusy ? null : _saveStep2,
              child: _isBusy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sauvegarder et continuer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step3View(BuildContext context) {
    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Complétez votre profil',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Étape 3 sur 3',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Center(
                child: _selectedPhoto == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_outlined,
                            color: AppTheme.primaryColor,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          const Text('Photo de profil optionnelle'),
                        ],
                      )
                    : Text(_selectedPhoto!.name, textAlign: TextAlign.center),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description professionnelle',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Années d’expérience',
              prefixIcon: Icon(Icons.timelapse_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _availabilityController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Disponibilités',
              prefixIcon: Icon(Icons.schedule_rounded),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isBusy ? null : _saveStep3,
              child: _isBusy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Terminer et accéder au dashboard'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isBusy ? null : () => setState(() => _currentStep = 1),
            child: const Text('Retour à l’étape précédente'),
          ),
        ],
      ),
    );
  }

  Widget _fullNameField() {
    return TextFormField(
      controller: _fullNameController,
      decoration: const InputDecoration(
        labelText: 'Nom complet',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
      validator: (value) => value == null || value.isEmpty
          ? 'Veuillez entrer votre nom complet'
          : null,
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailOrPhoneController,
      decoration: const InputDecoration(
        labelText: 'Email ou Téléphone',
        prefixIcon: Icon(Icons.contact_mail_outlined),
      ),
      validator: (value) => value == null || value.isEmpty
          ? 'Veuillez entrer votre email ou téléphone'
          : null,
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: Icon(Icons.lock_outline_rounded),
      ),
      validator: (value) =>
          value == null || value.length < 8 ? 'Minimum 8 caractères' : null,
    );
  }

  Widget _passwordConfirmationField() {
    return TextFormField(
      controller: _passwordConfirmationController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Confirmer le mot de passe',
        prefixIcon: Icon(Icons.lock_rounded),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez confirmer votre mot de passe';
        }
        if (value != _passwordController.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
    );
  }

  Widget _authError() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.errorMessage == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.destructiveColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Text(
            authProvider.errorMessage!,
            style: const TextStyle(
              color: AppTheme.destructiveColor,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
