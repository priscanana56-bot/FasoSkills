import 'package:flutter/material.dart';
import '../models/artisan_profile.dart';
import '../services/api_exception.dart';
import '../services/artisan_service.dart';
import '../services/category_service.dart';
import '../theme/theme.dart';
import 'artisan_profile_screen.dart';

class CategoryArtisansScreen extends StatefulWidget {
  final String category;
  final int? categoryId;

  const CategoryArtisansScreen({
    super.key,
    required this.category,
    this.categoryId,
  });

  @override
  State<CategoryArtisansScreen> createState() => _CategoryArtisansScreenState();
}

class _CategoryArtisansScreenState extends State<CategoryArtisansScreen> {
  final _artisanService = ArtisanService();
  final _categoryService = CategoryService();

  bool _isLoading = true;
  String? _error;
  List<ArtisanProfile> _artisans = [];

  @override
  void initState() {
    super.initState();
    _loadArtisans();
  }

  Future<int?> _resolveCategoryId() async {
    if (widget.categoryId != null) return widget.categoryId;
    if (widget.category == 'Tout') return null;

    final categories = await _categoryService.getCategories();
    final normalized = widget.category.toLowerCase();
    for (final cat in categories) {
      if (cat.name.toLowerCase() == normalized) return cat.id;
    }
    return null;
  }

  Future<void> _loadArtisans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final categoryId = await _resolveCategoryId();
      final artisans = await _artisanService.getArtisans(
        categoryId: categoryId,
        ordering: '-rating',
      );
      if (mounted) {
        setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category,
          style: const TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: AppTheme.destructiveColor),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadArtisans,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadArtisans,
                child: _artisans.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(
                            child: Text(
                              'Aucun artisan dans cette catégorie',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        itemCount: _artisans.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ArtisanCard(artisan: _artisans[index]),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}

class ArtisanCard extends StatelessWidget {
  final ArtisanProfile artisan;

  const ArtisanCard({super.key, required this.artisan});

  @override
  Widget build(BuildContext context) {
    final avatar = artisan.avatarUrl;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtisanProfileScreen(artisanId: artisan.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          artisan.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (artisan.user.isVerified)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTint(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: AppTheme.primaryColor,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artisan.profession,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.ratingColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(artisan.rating.toStringAsFixed(1)),
                      const SizedBox(width: 4),
                      Text(
                        '(${artisan.completedJobs} prestations)',
                        style: const TextStyle(color: AppTheme.textSecondary),
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
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTint(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Voir profil',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
