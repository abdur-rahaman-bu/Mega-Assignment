import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/category_provider.dart';
import '../providers/menu_item_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart';

import '../utils/constants.dart';
import '../widgets/category_pill.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _banners = [
    {
      'title': 'Free Delivery Today! 🚀',
      'subtitle': 'On orders above ৳500 — limited time offer',
      'image':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=900&q=80',
    },
    {
      'title': 'Lunch Special 30% OFF 🍱',
      'subtitle': 'Available 12 PM – 3 PM every day',
      'image':
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=900&q=80',
    },
    {
      'title': 'New! Sizzling Burgers 🍔',
      'subtitle': 'Crafted with love, delivered hot',
      'image':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=900&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    final catProv = context.read<CategoryProvider>();
    final menuProv = context.read<MenuItemProvider>();
    final favProv = context.read<FavoriteProvider>();
    final cartProv = context.read<CartProvider>();

    await Future.wait([
      catProv.fetchCategories(),
      menuProv.fetchMenuItems(categoryId: catProv.selectedCategoryId),
      favProv.fetchFavorites(),
      cartProv.fetchCart(),
    ]);
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % _banners.length;
        _bannerController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _onSearch(String query) async {
    final catProv = context.read<CategoryProvider>();
    await context.read<MenuItemProvider>().fetchMenuItems(
          categoryId: catProv.selectedCategoryId,
          search: query.trim().isEmpty ? null : query.trim(),
        );
  }

  Future<void> _onCategoryTap(int index) async {
    final catProv = context.read<CategoryProvider>();
    catProv.selectCategory(index);
    await context.read<MenuItemProvider>().fetchMenuItems(
          categoryId: catProv.selectedCategoryId,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final menuProvider = context.watch<MenuItemProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadData(forceRefresh: true),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Text(
                          'What are you\ncooking today?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/profile')
                              .catchError((_) => null);
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.iconCircle,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search Bar ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search any food',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded,
                                    color: AppColors.textSecondary, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearch('');
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 4),
                      ),
                      onTap: () => setState(() {}),
                    ),
                  ),
                ),
              ),

              // ── Promotional Banner ──────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  height: 180,
                  margin: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _bannerController,
                        onPageChanged: (index) =>
                            setState(() => _currentBannerIndex = index),
                        itemCount: _banners.length,
                        itemBuilder: (context, index) {
                          return _PromoBannerCard(banner: _banners[index]);
                        },
                      ),
                      Positioned(
                        bottom: 12,
                        child: Row(
                          children: List.generate(
                            _banners.length,
                            (idx) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentBannerIndex == idx ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentBannerIndex == idx
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.45),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Categories ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (categoryProvider.selectedIndex != 0)
                        GestureDetector(
                          onTap: () => _onCategoryTap(0),
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 42,
                  child: categoryProvider.isLoading
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: 5,
                          itemBuilder: (_, __) => const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: ShimmerBox(
                                width: 90, height: 36, borderRadius: 20),
                          ),
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            CategoryPill(
                              isAll: true,
                              isSelected: categoryProvider.selectedIndex == 0,
                              onTap: () => _onCategoryTap(0),
                            ),
                            ...List.generate(
                              categoryProvider.categories.length,
                              (i) {
                                final cat = categoryProvider.categories[i];
                                final listIndex = i + 1;
                                return CategoryPill(
                                  category: cat,
                                  isSelected:
                                      categoryProvider.selectedIndex == listIndex,
                                  onTap: () => _onCategoryTap(listIndex),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),

              // ── Quick & Easy Header ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categoryProvider.selectedIndex == 0
                            ? 'Quick & Easy'
                            : categoryProvider
                                .categories[categoryProvider.selectedIndex - 1]
                                .name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'View all',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Menu Items Grid ─────────────────────────────────────
              if (menuProvider.isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const ShimmerBox(
                          width: double.infinity,
                          height: 220,
                          borderRadius: 18),
                      childCount: 6,
                    ),
                  ),
                )
              else if (menuProvider.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          menuProvider.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (menuProvider.menuItems.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_menu_rounded,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'No Items Found',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try a different category or search term',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          MenuItemCard(item: menuProvider.menuItems[index]),
                      childCount: menuProvider.menuItems.length,
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

// ── Promo Banner Card ──────────────────────────────────────────────────────────

class _PromoBannerCard extends StatelessWidget {
  final Map<String, String> banner;

  const _PromoBannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Solid primary gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.primary,
                    Color(0xFFBF0020),
                  ],
                ),
              ),
            ),

            // Food image bleeding off right edge
            Positioned(
              right: -16,
              top: 0,
              bottom: 0,
              width: 185,
              child: ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.96),
                  ],
                  stops: const [0.0, 0.35],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: CachedNetworkImage(
                  imageUrl: banner['image']!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Text + CTA on left
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 140, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: const Text(
                      'Order Now',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

