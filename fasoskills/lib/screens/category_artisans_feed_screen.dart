import 'package:flutter/material.dart';
import '../models/artisan_profile.dart';
import '../services/api_exception.dart';
import '../services/artisan_service.dart';
import '../services/category_service.dart';
import '../theme/theme.dart';
import 'artisan_profile_screen.dart';

class CategoryArtisansFeedScreen extends StatefulWidget {
  final String category;
  final int? categoryId;

  const CategoryArtisansFeedScreen({
    super.key,
    required this.category,
    this.categoryId,
  });

  @override
  State<CategoryArtisansFeedScreen> createState() =>
      _CategoryArtisansFeedScreenState();
}

class _CategoryArtisansFeedScreenState
    extends State<CategoryArtisansFeedScreen> {
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
      if (categoryId == null) {
        if (mounted) {
          setState(() {
            _artisans = [];
            _isLoading = false;
          });
        }
        return;
      }
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
        foregroundColor: AppTheme.textColor,
        title: Text(
          widget.category,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
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
            : _artisans.isEmpty
            ? _EmptyCategory(category: widget.category)
            : RefreshIndicator(
                onRefresh: _loadArtisans,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: _artisans.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _FeedHeader(
                        category: widget.category,
                        count: _artisans.length,
                      );
                    }
                    return _ArtisanFeedCard(artisan: _artisans[index - 1]);
                  },
                ),
              ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  final String category;
  final int count;

  const _FeedHeader({required this.category, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primaryTint(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dynamic_feed_outlined,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actualité $category',
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count artisan${count > 1 ? 's' : ''} disponible${count > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: AppTheme.textTint(0.58),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtisanFeedCard extends StatelessWidget {
  final ArtisanProfile artisan;

  const _ArtisanFeedCard({required this.artisan});

  @override
  Widget build(BuildContext context) {
    final avatar = artisan.avatarUrl;
    return Material(
      color: AppTheme.backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryTint(0.12),
                    backgroundImage: avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : null,
                    child: avatar.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: AppTheme.primaryColor,
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                artisan.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (artisan.user.isVerified)
                              const Icon(
                                Icons.verified,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          artisan.profession,
                          style: TextStyle(
                            color: AppTheme.textTint(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (artisan.bio != null && artisan.bio!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  artisan.bio!,
                  style: TextStyle(
                    color: AppTheme.textTint(0.72),
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.star, color: AppTheme.ratingColor, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${artisan.rating.toStringAsFixed(1)} (${artisan.completedJobs} prestations)',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    artisan.city,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  _AvailabilityBadge(available: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool available;
  const _AvailabilityBadge({required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: available ? AppTheme.primaryTint(0.12) : AppTheme.inputFillColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        available ? 'Disponible' : 'Occupé',
        style: TextStyle(
          color: available ? AppTheme.primaryColor : AppTheme.textSecondary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  final String category;
  const _EmptyCategory({required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: AppTheme.textTint(0.35), size: 54),
            const SizedBox(height: 12),
            Text(
              'Aucun artisan trouvé',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'La catégorie $category ne contient pas encore d\'artisans.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textTint(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
