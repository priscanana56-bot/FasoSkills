import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/artisan_profile.dart';
import '../providers/auth_provider.dart';
import '../services/artisan_service.dart';
import '../theme/theme.dart';
import 'home_screen.dart';

class ArtisanOnboardingScreen extends StatefulWidget {
  const ArtisanOnboardingScreen({super.key});

  @override
  State<ArtisanOnboardingScreen> createState() =>
      _ArtisanOnboardingScreenState();
}

class _ArtisanOnboardingScreenState extends State<ArtisanOnboardingScreen> {
  final _step2Key = GlobalKey<FormState>();
  final _artisanService = ArtisanService();
  final _picker = ImagePicker();

  int _currentStep = 0;
  bool _isBusy = false;
  XFile? _selectedPhoto;
  ArtisanProfile? _profile;
  final _professionController = TextEditingController();
  final _specialtyController = TextEditingController();

  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _availabilityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isBusy = true);
    try {
      _profile = await _artisanService.getCurrentArtisanProfile();
      _professionController.text =
          _profile?.specialty ?? _profile?.profession ?? '';
      _specialtyController.text = '';
      _cityController.text = _profile?.city ?? '';
      _bioController.text = _profile?.bio ?? '';
      _experienceController.text = (_profile?.experienceYears ?? 0).toString();
      _availabilityController.text = _profile?.availability ?? '';
      _currentStep =
          (_profile?.specialty?.isEmpty ?? true) ||
              (_profile?.city.isEmpty ?? true)
          ? 0
          : 1;
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _professionController.dispose();
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
      setState(() => _selectedPhoto = photo);
    }
  }

  Future<void> _saveStep2() async {
    if (!_step2Key.currentState!.validate()) return;
    setState(() => _isBusy = true);
    try {
      _profile = await _artisanService.updateCurrentArtisanProfile(
        specialty: _professionController.text.trim().isEmpty
            ? null
            : _professionController.text.trim(),
        city: _cityController.text.trim(),
      );
      if (mounted) setState(() => _currentStep = 1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de sauvegarder l’étape 2: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _saveStep3() async {
    setState(() => _isBusy = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await _artisanService.updateCurrentArtisanProfile(
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        experienceYears: _experienceController.text.trim().isEmpty
            ? null
            : int.tryParse(_experienceController.text.trim()),
        availability: _availabilityController.text.trim().isEmpty
            ? null
            : _availabilityController.text.trim(),
        profilePicture: _selectedPhoto != null
            ? File(_selectedPhoto!.path)
            : null,
        profileStatus: 'complete',
      );
      await authProvider.refreshCurrentUser();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('La finalisation a échoué: $e')));
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _currentStep == 0
              ? 'Bienvenue ! Quel est votre domaine d’activité ?'
              : 'Complétez votre profil',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: _isBusy && _profile == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_currentStep == 0)
                      _step2Form(context)
                    else
                      _step3Form(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _step2Form(BuildContext context) {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _professionController,
            decoration: const InputDecoration(
              labelText: 'Type de métier',
              hintText: 'Ex: plombier, électricien, menuisier...',
              prefixIcon: Icon(Icons.work_outline_rounded),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Veuillez saisir votre métier'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _specialtyController,
            decoration: const InputDecoration(
              labelText: 'Spécialité',
              hintText: 'Optionnelle',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'Ville ou zone d’intervention',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Veuillez saisir une ville ou zone'
                : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isBusy ? null : _saveStep2,
            child: const Text('Sauvegarder et continuer'),
          ),
        ],
      ),
    );
  }

  Widget _step3Form(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _pickPhoto,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Center(
              child: Text(
                _selectedPhoto?.name ?? 'Ajouter une photo de profil',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Description professionnelle (optionnelle)',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _experienceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Années d’expérience (optionnel)',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _availabilityController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Disponibilités (optionnel)',
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isBusy ? null : _saveStep3,
          child: const Text('Terminer et accéder au dashboard'),
        ),
      ],
    );
  }
}
