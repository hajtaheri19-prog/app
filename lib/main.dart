import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;
import 'favorites_service.dart';

// Conditional imports
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChehelHadithApp());
}

class ChehelHadithApp extends StatelessWidget {
  const ChehelHadithApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF5E35B1), // بنفش شیک
      fontFamily: 'Vazirmatn',
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'چهل حدیث',
      locale: const Locale('fa'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: baseTheme.copyWith(
        // textTheme: GoogleFonts.vazirmatnTextTheme(baseTheme.textTheme),
        scaffoldBackgroundColor: const Color(0xFFF5F3FF),
        appBarTheme: baseTheme.appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF1F2933),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // کنترلر اصلی برای انیمیشن آیکون
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // کنترلر برای fade in متن‌ها
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // کنترلر برای pulse effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    // شروع انیمیشن‌ها
    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });

    // انتقال به صفحه اصلی
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const HadithHomePage(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF7C4DFF),
                Color(0xFF5E35B1),
                Color(0xFF311B92),
                Color(0xFF1A0E4E),
              ],
              stops: [0.0, 0.4, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // پس‌زمینه انیمیشن‌دار
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: _pulseAnimation.value * 1.2,
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // محتوای اصلی
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // آیکون کتاب با انیمیشن
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, -10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 96,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // نام برنامه
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            Text(
                              'چهل حدیث',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 120,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'گزیده‌ای از احادیث اهل‌بیت (ع)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'با شرح و تفسیر کاربردی',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Progress indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SizedBox(
                        width: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            minHeight: 6,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // نام برنامه‌نویس
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.code_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'برنامه‌نویس: حسین طاهری کندر',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HadithHomePage extends StatefulWidget {
  const HadithHomePage({super.key});

  @override
  State<HadithHomePage> createState() => _HadithHomePageState();
}

class _HadithHomePageState extends State<HadithHomePage> {
  late Future<List<Hadith>> _hadithsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _hadithsFuture = _loadHadiths();
  }

  Future<List<Hadith>> _loadHadiths() async {
    final jsonStr = await rootBundle.loadString('assets/hadiths.json');
    final list = json.decode(jsonStr) as List<dynamic>;
    return list.map((e) => Hadith.fromJson(e as Map<String, dynamic>)).toList();
  }

  void _openRandomHadith(List<Hadith> hadiths) {
    if (hadiths.isEmpty) return;
    // انتخاب تصادفی بدون تغییر ترتیب لیست اصلی
    final randomIndex =
        (hadiths.length * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)
            .floor();
    final random = hadiths[randomIndex];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HadithDetailPage(hadith: random),
      ),
    );
  }

  void _openAboutPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AboutPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _AppDrawer(
        onAboutTap: _openAboutPage,
        onRandomTapFromHome: () async {
          final hadiths = await _hadithsFuture;
          _openRandomHadith(hadiths);
        },
        onFavoritesTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const FavoritesPage(),
            ),
          );
        },
      ),
      appBar: AppBar(
        title: const Text('چهل حدیث'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 12),
              _buildSearchField(),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Hadith>>(
                  future: _hadithsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'خطا در بارگذاری احادیث.\nلطفاً فایل hadiths.json را بررسی کنید.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.red.shade700),
                        ),
                      );
                    }

                    final data = snapshot.data ?? [];
                    final filtered = data.where((h) {
                      if (_searchQuery.trim().isEmpty) return true;
                      final q = _searchQuery.trim();
                      return h.title.contains(q) ||
                          h.shortText.contains(q) ||
                          h.body.contains(q) ||
                          (h.category?.contains(q) ?? false);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'حدیثی با این جستجو پیدا نشد.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemBuilder: (context, index) {
                        final hadith = filtered[index];
                        return _HadithCard(
                          hadith: hadith,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    HadithDetailPage(hadith: hadith),
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: filtered.length,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FutureBuilder<List<Hadith>>(
        future: _hadithsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return const SizedBox.shrink();
          }
          final list = snapshot.data!;
          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFF5E35B1),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('حدیث تصادفی'),
            onPressed: () => _openRandomHadith(list),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF7C4DFF),
            Color(0xFF5E35B1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'چهل حدیث منتخب',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'احادیث اخلاقی و تربیتی با شرح مفهومی، نکات کاربردی و نگاه امروزی.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'جستجو در عنوان، متن یا موضوع حدیث...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }
}

class Hadith {
  final int id;
  final String title;
  final String shortText;
  final String source;
  final String body;
  final String tafseer;
  final String? category;
  final String? practicalTip;
  final String? practicalChallenge;
  final String? speaker;

  Hadith({
    required this.id,
    required this.title,
    required this.shortText,
    required this.source,
    required this.body,
    required this.tafseer,
    this.category,
    this.practicalTip,
    this.practicalChallenge,
    this.speaker,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'] as int,
      title: json['title'] as String,
      shortText: json['shortText'] as String,
      source: json['source'] as String,
      body: json['body'] as String,
      tafseer: json['tafseer'] as String,
      category: json['category'] as String?,
      practicalTip: json['practicalTip'] as String?,
      practicalChallenge: json['practicalChallenge'] as String?,
      speaker: json['speaker'] as String?,
    );
  }
}

class _HadithCard extends StatelessWidget {
  final Hadith hadith;
  final VoidCallback onTap;

  const _HadithCard({
    required this.hadith,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFF3E8FF),
              ],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF5E35B1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hadith.id.toString(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hadith.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2933),
                          ),
                    ),
                    if (hadith.speaker != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Color(0xFF5E35B1),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hadith.speaker!,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: const Color(0xFF5E35B1),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      hadith.shortText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF4B5563),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hadith.source,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                        ),
                        const Spacer(),
                        if (hadith.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              hadith.category!,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: const Color(0xFF5E35B1),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HadithDetailPage extends StatefulWidget {
  final Hadith hadith;

  const HadithDetailPage({super.key, required this.hadith});

  @override
  State<HadithDetailPage> createState() => _HadithDetailPageState();
}

class _HadithDetailPageState extends State<HadithDetailPage> {
  bool _isFavorite = false;
  bool _showOnlyTranslation = false;
  final FavoritesService _favoritesService = FavoritesService();
  bool _isLoadingFavorite = true;
  double _textScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.hadith.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _isLoadingFavorite = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    final success = await _favoritesService.toggleFavorite(widget.hadith.id);
    if (success && mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite
              ? 'به علاقه‌مندی‌ها اضافه شد'
              : 'از علاقه‌مندی‌ها حذف شد'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareHadith() async {
    // نمایش dialog برای انتخاب نوع اشتراک‌گذاری
    final shareType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'نوع اشتراک‌گذاری',
          style: TextStyle(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: Text('اشتراک تصویر', style: TextStyle()),
              onTap: () => Navigator.of(context).pop('image'),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: Text('اشتراک متن', style: TextStyle()),
              onTap: () => Navigator.of(context).pop('text'),
            ),
          ],
        ),
      ),
    );

    if (shareType == null) return;

    try {
      if (shareType == 'image') {
        // نمایش پیام در حال پردازش
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('در حال ایجاد تصویر...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        // ایجاد تصویر از محتوای حدیث
        final imageBytes = await _generateHadithImage();
        if (imageBytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('خطا در ایجاد تصویر'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        // اشتراک‌گذاری تصویر
        if (kIsWeb) {
          // برای وب: فقط متن را اشتراک می‌گذاریم
          final text =
              '${widget.hadith.title}\n\n${widget.hadith.shortText}\n\n${widget.hadith.body}\n\n${widget.hadith.source}';
          await Share.share(text);
        } else {
          // برای موبایل: ذخیره در فایل موقت
          final tempDir = await getTemporaryDirectory();
          final file =
              io.File('${tempDir.path}/hadith_${widget.hadith.id}.png');
          await file.writeAsBytes(imageBytes);
          final xFile = XFile(file.path);
          await Share.shareXFiles([xFile]);
        }
      } else {
        // اشتراک‌گذاری متن
        final text =
            '${widget.hadith.title}\n\n${widget.hadith.shortText}\n\n${widget.hadith.body}\n\n${widget.hadith.source}';
        await Share.share(text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا در اشتراک‌گذاری'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<Uint8List?> _generateHadithImage() async {
    try {
      // ابعاد تصویر
      const width = 1080;
      const height = 1920;

      // ایجاد تصویر با پس‌زمینه گرادیان بنفش
      final image = img.Image(width: width, height: height);

      // رسم پس‌زمینه گرادیان
      for (int y = 0; y < height; y++) {
        final ratio = y / height;
        final r = (0x7C + (0x5E - 0x7C) * ratio).toInt();
        final g = (0x4D + (0x35 - 0x4D) * ratio).toInt();
        final b = (0xFF + (0xB1 - 0xFF) * ratio).toInt();
        for (int x = 0; x < width; x++) {
          image.setPixelRgb(x, y, r, g, b);
        }
      }

      // اضافه کردن یک مستطیل سفید در وسط برای متن
      final textAreaY = (height * 0.15).toInt();
      final textAreaHeight = (height * 0.7).toInt();
      final textAreaX = (width * 0.1).toInt();
      final textAreaWidth = (width * 0.8).toInt();

      // رسم مستطیل سفید
      for (int y = textAreaY; y < textAreaY + textAreaHeight; y++) {
        for (int x = textAreaX; x < textAreaX + textAreaWidth; x++) {
          image.setPixelRgb(x, y, 0xFF, 0xFF, 0xFF);
        }
      }

      // تبدیل به PNG
      final pngBytes = img.encodePng(image);
      return Uint8List.fromList(pngBytes);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hadith.title),
        actions: [
          // دکمه بزرگ‌نمایی
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                if (_textScale < 2.0) {
                  _textScale += 0.2;
                }
              });
            },
            tooltip: 'بزرگ‌نمایی',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                if (_textScale > 0.8) {
                  _textScale -= 0.2;
                }
              });
            },
            tooltip: 'کوچک‌نمایی',
          ),
          if (!_isLoadingFavorite)
            IconButton(
              icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: _toggleFavorite,
              tooltip: 'ذخیره در علاقه‌مندی‌ها',
            ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareHadith,
            tooltip: 'اشتراک‌گذاری',
          ),
        ],
      ),
      body: SafeArea(
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(_textScale)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(context),
                const SizedBox(height: 20),

                // Arabic Text and Translation
                _buildHadithText(context),
                const SizedBox(height: 20),

                // Conceptual Explanation
                _buildConceptualExplanation(context),
                const SizedBox(height: 20),

                // Practical Application
                if (widget.hadith.practicalTip != null) ...[
                  _buildPracticalApplication(context),
                  const SizedBox(height: 20),
                ],

                // Practical Challenge
                if (widget.hadith.practicalChallenge != null) ...[
                  _buildPracticalChallenge(context),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.hadith.category != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(widget.hadith.category!),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.hadith.category!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.hadith.speaker != null)
            Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.hadith.speaker!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          if (widget.hadith.speaker != null) const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.menu_book_outlined,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.hadith.source,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHadithText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'متن حدیث',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2933),
                  ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showOnlyTranslation = !_showOnlyTranslation;
                });
              },
              icon: Icon(
                _showOnlyTranslation ? Icons.visibility : Icons.visibility_off,
                size: 18,
              ),
              label: Text(_showOnlyTranslation ? 'نمایش عربی' : 'فقط ترجمه'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5E35B1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_showOnlyTranslation)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SelectableText(
              widget.hadith.shortText,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.8,
                color: const Color(0xFF1F2933),
              ),
            ),
          ),
        if (!_showOnlyTranslation) const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SelectableText(
            widget.hadith.body,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConceptualExplanation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline,
                color: Color(0xFF5E35B1), size: 24),
            const SizedBox(width: 8),
            Text(
              'شرح مفهومی',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2933),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SelectableText(
            widget.hadith.tafseer,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPracticalApplication(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.eco_outlined, color: Color(0xFF10B981), size: 24),
            const SizedBox(width: 8),
            Text(
              'کاربرد در زندگی امروز',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2933),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFECFDF5),
                Color(0xFFD1FAE5),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: SelectableText(
            widget.hadith.practicalTip!,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPracticalChallenge(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Color(0xFF5E35B1), size: 24),
            const SizedBox(width: 8),
            Text(
              'تمرین امروز',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2933),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF5E35B1).withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4, left: 8),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Color(0xFF5E35B1),
                ),
              ),
              Expanded(
                child: SelectableText(
                  widget.hadith.practicalChallenge!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: const Color(0xFF1F2933),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'خودسازی':
        return Icons.self_improvement;
      case 'خانواده':
        return Icons.family_restroom;
      case 'اخلاق اجتماعی':
        return Icons.people;
      case 'عبادات':
        return Icons.mosque;
      default:
        return Icons.menu_book;
    }
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();
  late Future<List<Hadith>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites();
  }

  Future<List<Hadith>> _loadFavorites() async {
    final favoriteIds = await _favoritesService.getFavoriteIds();
    if (favoriteIds.isEmpty) {
      return [];
    }

    final jsonStr = await rootBundle.loadString('assets/hadiths.json');
    final list = json.decode(jsonStr) as List<dynamic>;
    final allHadiths =
        list.map((e) => Hadith.fromJson(e as Map<String, dynamic>)).toList();

    // فیلتر کردن احادیث علاقه‌مندی
    return allHadiths.where((h) => favoriteIds.contains(h.id)).toList();
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('علاقه‌مندی‌ها'),
      ),
      body: FutureBuilder<List<Hadith>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'خطا در بارگذاری علاقه‌مندی‌ها',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
              ),
            );
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'هنوز حدیثی به علاقه‌مندی‌ها اضافه نشده',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'برای افزودن حدیث به علاقه‌مندی‌ها،\nروی آیکون قلب در صفحه جزئیات حدیث کلیک کنید',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshFavorites,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemBuilder: (context, index) {
                final hadith = favorites[index];
                return _HadithCard(
                  hadith: hadith,
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HadithDetailPage(hadith: hadith),
                      ),
                    );
                    // در صورت بازگشت، لیست را رفرش می‌کنیم
                    if (result == true) {
                      _refreshFavorites();
                    }
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: favorites.length,
            ),
          );
        },
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _shareApp(BuildContext context) async {
    const text = 'چهل حدیث - همراهی آرام برای رشد اخلاقی و خودسازی\n\n'
        'برنامه‌نویس: حسین طاهری کندر';
    await Clipboard.setData(const ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('متن کپی شد'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درباره ما'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _shareApp(context),
            tooltip: 'اشتراک‌گذاری برنامه',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // نام برنامه‌نویس در اول
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'برنامه‌نویس',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'حسین طاهری کندر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5E35B1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF7C4DFF),
                      Color(0xFF5E35B1),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'درباره «چهل حدیث»',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2933),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'چهل حدیث تلاشی است برای نزدیک‌تر کردن کلام نورانی اهل‌بیت (ع) به زندگی امروز ما؛',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'نه فقط برای خواندن،',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'بلکه برای فهمیدن، تأمل کردن و زندگی کردن.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'در دنیایی که سرعت، شلوغی و فشارهای ذهنی ما را از خودمان دور کرده‌اند،',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'این برنامه طراحی شده تا با زبانی ساده، نگاهی کاربردی و تفسیری کوتاه،',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'احادیث را از کتاب‌ها به دل زندگی روزمره بیاورد.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'هر حدیث در این برنامه:',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF5E35B1),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _bullet('انتخاب‌شده و هدفمند است'),
                          _bullet('با توضیح مفهومی و کاربردی همراه شده'),
                          _bullet(
                              'و تلاش می‌کند پاسخی باشد به یکی از نیازهای واقعی انسان امروز'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🌱 این برنامه نه یک مجموعه صرفاً مذهبی است',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'و نه یک محتوای سنگین علمی؛',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'بلکه همراهی آرام برای رشد اخلاقی، خودسازی و بهتر زیستن است.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: Text(
                        '**اگر حتی یک حدیث باعث تغییر کوچک در نگاه یا رفتار ما شود،\nهدف این برنامه محقق شده است.**',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'تمام حقوق معنوی برای سازنده محفوظ است.\nاستفاده و نشر با ذکر منبع بلامانع است.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, left: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF5E35B1),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final VoidCallback onAboutTap;
  final VoidCallback onRandomTapFromHome;
  final VoidCallback onFavoritesTap;

  const _AppDrawer({
    required this.onAboutTap,
    required this.onRandomTapFromHome,
    required this.onFavoritesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // هدر منو
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF7C4DFF),
                    Color(0xFF5E35B1),
                    Color(0xFF311B92),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'چهل حدیث',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'نسخه آفلاین',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'با شرح و تفسیر کامل',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // آیتم‌های منو
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerMenuItem(
                    icon: Icons.list_alt_rounded,
                    title: 'فهرست احادیث',
                    subtitle: 'مشاهده همه احادیث',
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.auto_awesome_rounded,
                    title: 'حدیث تصادفی',
                    subtitle: 'الهام لحظه‌ای',
                    color: const Color(0xFF5E35B1),
                    onTap: () {
                      Navigator.of(context).pop();
                      onRandomTapFromHome();
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.favorite_rounded,
                    title: 'علاقه‌مندی‌ها',
                    subtitle: 'احادیث ذخیره شده',
                    color: Colors.red.shade400,
                    onTap: () {
                      Navigator.of(context).pop();
                      onFavoritesTap();
                    },
                  ),
                  const Divider(height: 32, indent: 24, endIndent: 24),
                  _DrawerMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'درباره ما',
                    subtitle: 'اطلاعات برنامه',
                    onTap: () {
                      Navigator.of(context).pop();
                      onAboutTap();
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.share_rounded,
                    title: 'اشتراک‌گذاری',
                    subtitle: 'به اشتراک بگذار',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: اضافه کردن قابلیت اشتراک‌گذاری
                    },
                  ),
                ],
              ),
            ),
            // Footer منو
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.code_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'حسین طاهری کندر',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'نسخه 1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
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

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: themeColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2933),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
