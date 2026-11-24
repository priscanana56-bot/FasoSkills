import 'package:flutter/material.dart';
import '../models/artisan_profile.dart';
import '../models/category.dart';
import '../services/api_exception.dart';
import '../services/artisan_service.dart';
import '../services/category_service.dart';
import '../theme/theme.dart';
import 'artisan_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _artisanService = ArtisanService();
  final _categoryService = CategoryService();

  int? _selectedCategoryId;
  String? _selectedLocation;
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;
  List<Category> _categories = [];
  List<ArtisanProfile> _artisans = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final categories = await _categoryService.getCategories();
      final artisans = await _artisanService.getArtisans(ordering: '-rating');
      if (mounted) {
        setState(() {
          _categories = categories;
          _artisans = artisans;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    _fetchArtisans();
  }

  Future<void> _showLocationPicker() async {
    final controller = TextEditingController(text: _selectedLocation ?? '');
    final location = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choisir une ville',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    hintText: 'Ex: Ouagadougou',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, ''),
                        child: const Text('Effacer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, controller.text.trim()),
                        child: const Text('Appliquer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();

    if (!mounted) return;
    setState(() {
      _selectedLocation = location == null || location.isEmpty
          ? null
          : location;
    });
    await _fetchArtisans();
  }

  Future<void> _fetchArtisans() async {
    setState(() => _isSearching = true);
    try {
      final artisans = await _artisanService.getArtisans(
        categoryId: _selectedCategoryId,
        city: _selectedLocation,
        search: _searchController.text.trim(),
        ordering: '-rating',
      );
      if (mounted) {
        setState(() {
          _artisans = artisans;
          _isSearching = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          onSubmitted: (_) => _fetchArtisans(),
          decoration: InputDecoration(
            hintText: 'Rechercher un artisan ou un service',
            prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppTheme.destructiveColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: const Text('Tout'),
                                selected: _selectedCategoryId == null,
                                onSelected: (_) {
                                  setState(() => _selectedCategoryId = null);
                                  _fetchArtisans();
                                },
                                selectedColor: AppTheme.primaryColor,
                                checkmarkColor: AppTheme.onPrimary,
                                labelStyle: TextStyle(
                                  color: _selectedCategoryId == null
                                      ? AppTheme.onPrimary
                                      : AppTheme.textColor,
                                ),
                                backgroundColor: AppTheme.surfaceColor,
                              ),
                            );
                          }
                          final category = _categories[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category.name),
                              selected: _selectedCategoryId == category.id,
                              onSelected: (selected) {
                                setState(
                                  () => _selectedCategoryId = selected
                                      ? category.id
                                      : null,
                                );
                                _fetchArtisans();
                              },
                              selectedColor: AppTheme.primaryColor,
                              checkmarkColor: AppTheme.onPrimary,
                              labelStyle: TextStyle(
                                color: _selectedCategoryId == category.id
                                    ? AppTheme.onPrimary
                                    : AppTheme.textColor,
                              ),
                              backgroundColor: AppTheme.surfaceColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedLocation ?? 'Toutes les villes',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _showLocationPicker,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.tune,
                              color: AppTheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isSearching) const LinearProgressIndicator(minHeight: 2),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchArtisans,
                      child: _artisans.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 80),
                                Center(
                                  child: Text(
                                    'Aucun artisan trouvé',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: _artisans.length,
                              itemBuilder: (context, index) {
                                return ArtisanResultCard(
                                  artisan: _artisans[index],
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ArtisanResultCard extends StatelessWidget {
  final ArtisanProfile artisan;
  const ArtisanResultCard({super.key, required this.artisan});

  @override
  Widget build(BuildContext context) {
    final avatar = artisan.avatarUrl;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtisanProfileScreen(artisanId: artisan.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                child: avatar.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artisan.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artisan.profession,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppTheme.ratingColor,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${artisan.rating.toStringAsFixed(1)} (${artisan.completedJobs} prestations)',
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.textMuted,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          artisan.city,
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTint(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Voir profil',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
