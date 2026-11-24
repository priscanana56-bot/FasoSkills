import 'package:flutter/material.dart';
import '../models/artisan_profile.dart';
import '../models/category.dart';
import '../services/artisan_service.dart';
import '../services/category_service.dart';
import '../theme/theme.dart';
import '../widgets/glass_bottom_nav_bar.dart';
import '../providers/auth_provider.dart';
import 'artisan_profile_screen.dart';
import 'request_quote_screen.dart';
import 'my_requests_screen.dart';
import 'messages_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'artisan_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'artisan_requests_screen.dart';
import 'category_artisans_feed_screen.dart';
import 'artisan_onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isArtisan = authProvider.user?.role == "artisan";

    if (isArtisan && authProvider.user?.isArtisanProfileComplete == false) {
      return const ArtisanOnboardingScreen();
    }

    final List<Widget> clientScreens = [
      const _HomeTab(),
      const SearchScreen(),
      const MyRequestsScreen(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];

    final List<Widget> artisanScreens = [
      const ArtisanDashboardScreen(),
      const SearchScreen(),
      const ArtisanRequestsScreen(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];

    final List<Widget> screens = isArtisan ? artisanScreens : clientScreens;

    final List<GlassBottomNavItem> navItems = isArtisan
        ? const [
            GlassBottomNavItem(
              icon: Icons.dashboard_outlined,
              label: 'Accueil',
            ),
            GlassBottomNavItem(icon: Icons.search, label: 'Recherche'),
            GlassBottomNavItem(
              icon: Icons.description_outlined,
              label: 'Demandes',
            ),
            GlassBottomNavItem(icon: Icons.message_outlined, label: 'Messages'),
            GlassBottomNavItem(icon: Icons.person_outline, label: 'Profil'),
          ]
        : const [
            GlassBottomNavItem(icon: Icons.home, label: 'Accueil'),
            GlassBottomNavItem(icon: Icons.search, label: 'Recherche'),
            GlassBottomNavItem(
              icon: Icons.description_outlined,
              label: 'Demandes',
            ),
            GlassBottomNavItem(icon: Icons.message_outlined, label: 'Messages'),
            GlassBottomNavItem(icon: Icons.person_outline, label: 'Profil'),
          ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: GlassBottomNavBar.reservedHeight(context),
                ),
                child: screens[_currentIndex],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom:
                MediaQuery.paddingOf(context).bottom +
                GlassBottomNavBar.bottomMargin,
            child: GlassBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: navItems,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _categoryService = CategoryService();
  final _artisanService = ArtisanService();
  List<Category> _categories = [];
  List<ArtisanProfile> _artisans = [];
  bool _isLoading = true;
  int? _selectedCategoryId;
  String _selectedCategoryLabel = 'Tout';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _categoryService.getCategories(),
        _artisanService.getArtisans(ordering: '-rating'),
      ]);
      if (mounted) {
        setState(() {
          _categories = results[0] as List<Category>;
          _artisans = (results[1] as List<ArtisanProfile>).take(5).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ArtisanProfile> get _filteredArtisans {
    if (_selectedCategoryId == null) return _artisans;
    return _artisans
        .where((artisan) => artisan.category?.id == _selectedCategoryId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.backgroundColor, AppTheme.primaryTint(0.04)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.shadowPrimary,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            color: AppTheme.onPrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            children: [
                              TextSpan(
                                text: 'Faso',
                                style: TextStyle(color: AppTheme.textColor),
                              ),
                              TextSpan(
                                text: 'Skills',
                                style: TextStyle(color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.textColor,
                            size: 22,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.notificationBadgeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.borderColor),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppTheme.textMuted,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Quel service recherchez-vous ?',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTint(0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSm,
                            ),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryPill(
                        label: 'Tout',
                        isSelected: _selectedCategoryId == null,
                        onTap: () => setState(() {
                          _selectedCategoryId = null;
                          _selectedCategoryLabel = 'Tout';
                        }),
                      ),
                      ..._categories
                          .take(4)
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: _CategoryPill(
                                label: c.name,
                                categoryId: c.id,
                                isSelected: _selectedCategoryId == c.id,
                                onTap: () => setState(() {
                                  _selectedCategoryId = c.id;
                                  _selectedCategoryLabel = c.name;
                                }),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowPrimary,
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Besoin d\'un pro ?',
                              style: TextStyle(
                                color: AppTheme.onPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Trouvez le bon artisan\nau bon moment',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppTheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Des professionnels qualifiés\nprès de chez vous',
                              style: TextStyle(
                                color: AppTheme.onPrimary.withValues(
                                  alpha: 0.9,
                                ),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RequestQuoteScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.surfaceColor,
                                foregroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                ),
                              ),
                              child: const Text('Réserver maintenant'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Image.network(
                          'https://coresg-normal.trae.ai/api/v1/text_to_image?prompt=friendly%20african%20handyman%20in%20yellow%20hard%20hat%20and%20uniform&image_size=square',
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                size: 100,
                                color: AppTheme.onPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catégories populaires',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: _categories.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.take(5).length,
                          separatorBuilder: (_, _) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            return _PopularCategoryItem(
                              icon: Icons.handyman,
                              label: cat.name,
                              categoryId: cat.id,
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategoryId == null
                          ? 'Artisans recommandés'
                          : 'Artisans $_selectedCategoryLabel',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredArtisans.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun artisan disponible',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filteredArtisans.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final artisan = _filteredArtisans[index];
                            return _ArtisanCard(
                              name: artisan.displayName,
                              profession: artisan.profession,
                              rating: artisan.rating,
                              reviews: artisan.completedJobs,
                              distance: artisan.city,
                              avatarUrl: artisan.avatarUrl,
                              isVerified: artisan.user.isVerified,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArtisanProfileScreen(
                                      artisanId: artisan.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final int? categoryId;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    this.categoryId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.onPrimary : AppTheme.textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PopularCategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int categoryId;

  const _PopularCategoryItem({
    required this.icon,
    required this.label,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryArtisansFeedScreen(
              category: label,
              categoryId: categoryId,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtisanCard extends StatelessWidget {
  final String name;
  final String profession;
  final double rating;
  final int reviews;
  final String distance;
  final String avatarUrl;
  final bool isVerified;
  final VoidCallback onTap;

  const _ArtisanCard({
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.avatarUrl,
    required this.isVerified,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isVerified)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.all(4),
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
              profession,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: AppTheme.ratingColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$rating',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($reviews avis)',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.primaryColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  distance,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
