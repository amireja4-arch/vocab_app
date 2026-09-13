import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LeitnerVocabApp());
}

class LeitnerVocabApp extends StatelessWidget {
  const LeitnerVocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'واژه‌دان | یادگیری هوشمند',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          primary: const Color(0xFF6C5CE7),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// ----------------------------------------------------
// دیتابیس واژگان بر اساس خواندن غیرهمزمان از فایل‌های JSON
// ----------------------------------------------------
class VocabDatabase {
  static Future<List<Map<String, String>>> loadLevelWords(String level) async {
    String fileName = 'beginner.json';
    
    if (level == 'Intermediate') {
      fileName = 'intermediate.json';
    } else if (level == 'Advanced' || level == 'Master') {
      fileName = 'advanced.json';
    }

    try {
      final String response = await rootBundle.loadString('assets/$fileName');
      final List<dynamic> data = json.decode(response);

      return data.map((item) => {
        'word': item['word']?.toString() ?? '',
        'phonetic': item['phonetic']?.toString() ?? '',
        'meaning': item['meaning']?.toString() ?? '',
        'example': item['example']?.toString() ?? '',
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

// ----------------------------------------------------
// ویجت دکمه با انیمیشن فشرده‌شدن
// ----------------------------------------------------
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const AnimatedButton(
      {super.key, required this.child, required this.onPressed});

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - _controller.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------
// کارت نئونی مداوم با انیمیشن Pulse & Glow
// ----------------------------------------------------
class NeonPulsingCard extends StatefulWidget {
  final Widget child;
  const NeonPulsingCard({super.key, required this.child});

  @override
  State<NeonPulsingCard> createState() => _NeonPulsingCardState();
}

class _NeonPulsingCardState extends State<NeonPulsingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 8.0, end: 22.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5CE7).withOpacity(0.5),
                blurRadius: _glowAnimation.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// ----------------------------------------------------
// لوگوی زنده و شناور
// ----------------------------------------------------
class FloatingAppLogo extends StatefulWidget {
  final double size;
  const FloatingAppLogo({super.key, this.size = 50});

  @override
  State<FloatingAppLogo> createState() => _FloatingAppLogoState();
}

class _FloatingAppLogoState extends State<FloatingAppLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.08),
    ).animate(
        CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)]),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6C5CE7).withOpacity(0.4),
                blurRadius: 12),
          ],
        ),
        child: Icon(Icons.auto_awesome, size: widget.size, color: Colors.white),
      ),
    );
  }
}

// ----------------------------------------------------
// ۱. موشن اولیه (Splash Screen)
// ----------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _playWelcomeSound();
    _checkUserStatus();
  }

  Future<void> _playWelcomeSound() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.speak("Welcome to Vocab Master");
  }

  Future<void> _checkUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    final userLevel = prefs.getString('user_level');

    await Future.delayed(const Duration(milliseconds: 2400));

    if (!mounted) return;

    if (userEmail == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AuthScreen()));
    } else if (userLevel == null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LevelSelectionScreen()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainDashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingAppLogo(size: 70),
              SizedBox(height: 24),
              Text(
                'VOCAB MASTER',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5),
              ),
              SizedBox(height: 8),
              Text('یادگیری هوشمند و زنده واژگان',
                  style: TextStyle(color: Colors.white70, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ۲. ثبت‌نام / ورود
// ----------------------------------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً یک ایمیل معتبر وارد کنید')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', name.isEmpty ? 'کاربر عزیز' : name);

    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const LevelSelectionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(child: FloatingAppLogo(size: 60)),
              const SizedBox(height: 24),
              const Text('ورود / حساب کاربری',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('برای ذخیره عملکرد و پیشرفت، ایمیل خود را وارد کنید.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'نام شما',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'آدرس ایمیل',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedButton(
                onPressed: _submitAuth,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('ادامه و ثبت حساب',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ۳. انتخاب سطح اولیه
// ----------------------------------------------------
class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  Future<void> _selectLevel(BuildContext context, String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_level', level);
    await prefs.setInt('learned_level_count', 0);

    if (!context.mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const MainDashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(child: FloatingAppLogo(size: 50)),
              const SizedBox(height: 20),
              const Text('انتخاب سطح یادگیری اولیه',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('سطحی که بیشترین تطابق را دارد انتخاب کنید:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 35),
              _buildLevelCard(context,
                  title: 'مبتدی (Beginner)',
                  desc: 'کلمات کاربردی و پایه زبان انگلیسی روزمره',
                  icon: Icons.filter_1,
                  color: Colors.green,
                  levelKey: 'Beginner'),
              const SizedBox(height: 16),
              _buildLevelCard(context,
                  title: 'متوسط (Intermediate)',
                  desc: 'واژگان کاربردی و گفتگوهای روزمره',
                  icon: Icons.filter_2,
                  color: Colors.orange,
                  levelKey: 'Intermediate'),
              const SizedBox(height: 16),
              _buildLevelCard(context,
                  title: 'پیشرفته (Advanced)',
                  desc: 'واژگان آزمون آیلتس، تافل و متون تخصصی',
                  icon: Icons.filter_3,
                  color: Colors.redAccent,
                  levelKey: 'Advanced'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context,
      {required String title,
      required String desc,
      required IconData icon,
      required Color color,
      required String levelKey}) {
    return AnimatedButton(
      onPressed: () => _selectLevel(context, levelKey),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ۴. داشبورد اصلی
// ----------------------------------------------------
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  String _userName = 'کاربر عزیز';
  String _userLevel = 'Beginner';
  int _todayCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'کاربر عزیز';
      _userLevel = prefs.getString('user_level') ?? 'Beginner';
      _todayCount = prefs.getInt('today_count') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const FloatingAppLogo(size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('سلام، $_userName 👋',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('سطح فعلی: $_userLevel',
                              style: const TextStyle(
                                  color: Color(0xFF6C5CE7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  AnimatedButton(
                    onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileTab()))
                        .then((_) => _loadUserData()),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF6C5CE7),
                      child: Icon(Icons.person, color: Colors.white, size: 22),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 25),
              NeonPulsingCard(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF8E7CFF)]),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.amber, size: 48),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('عملکرد امروز: $_todayCount واژه',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17)),
                            const SizedBox(height: 4),
                            const Text('واژگان را مرور کن تا به سطح بعدی برسی!',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              const Text('منوی دسترسی سریع',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildMenuCard(
                title: 'شروع تمرین لایتنر',
                subtitle: 'یادگیری کلمات، صعود سطح و پخش صدا',
                icon: Icons.style,
                color: const Color(0xFF6C5CE7),
                onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LeitnerTab()))
                    .then((_) => _loadUserData()),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                title: 'تقویم و آمار پیشرفت',
                subtitle: 'بررسی دقیق ثبت فعالیت‌های روزانه',
                icon: Icons.calendar_month,
                color: const Color(0xFF00B894),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProgressCalendarTab())),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                title: 'پروفایل و تنظیمات',
                subtitle: 'تغییر سطح دستی، اطلاعات و خروج',
                icon: Icons.person_outline,
                color: const Color(0xFFE17055),
                onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ProfileTab()))
                    .then((_) => _loadUserData()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ۵. صفحه تمرین لایتنر متصل به تعداد واقعی فایل JSON
// ----------------------------------------------------
class LeitnerTab extends StatefulWidget {
  const LeitnerTab({super.key});

  @override
  State<LeitnerTab> createState() => _LeitnerTabState();
}

class _LeitnerTabState extends State<LeitnerTab> {
  final FlutterTts _flutterTts = FlutterTts();
  int _todayCount = 0;
  int _learnedInCurrentLevel = 0;
  String _currentLevel = 'Beginner';

  List<Map<String, String>> _activeVocabList = [];
  int _currentIndex = 0;
  bool _showBack = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressAndLevel();
  }

  Future<void> _loadProgressAndLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLevel = prefs.getString('user_level') ?? 'Beginner';
    final savedLearned = prefs.getInt('learned_level_count') ?? 0;
    final savedToday = prefs.getInt('today_count') ?? 0;

    final words = await VocabDatabase.loadLevelWords(savedLevel);

    setState(() {
      _currentLevel = savedLevel;
      _learnedInCurrentLevel = savedLearned;
      _todayCount = savedToday;
      _activeVocabList = words;
      _isLoading = false;
      if (_currentIndex >= _activeVocabList.length) {
        _currentIndex = 0;
      }
    });
  }

  Future<void> _onWordLearned() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _todayCount++;
      _learnedInCurrentLevel++;
    });

    await prefs.setInt('today_count', _todayCount);
    await prefs.setInt('learned_level_count', _learnedInCurrentLevel);

    if (_learnedInCurrentLevel >= _activeVocabList.length && _activeVocabList.isNotEmpty) {
      _promoteToNextLevel();
    } else {
      _nextWord();
    }
  }

  Future<void> _promoteToNextLevel() async {
    final prefs = await SharedPreferences.getInstance();
    String newLevel = 'Master';

    if (_currentLevel == 'Beginner') {
      newLevel = 'Intermediate';
    } else if (_currentLevel == 'Intermediate') {
      newLevel = 'Advanced';
    } else if (_currentLevel == 'Advanced') {
      newLevel = 'Master';
    }

    await prefs.setString('user_level', newLevel);
    await prefs.setInt('learned_level_count', 0);

    final newWords = await VocabDatabase.loadLevelWords(newLevel);

    setState(() {
      _currentLevel = newLevel;
      _learnedInCurrentLevel = 0;
      _currentIndex = 0;
      _showBack = false;
      _activeVocabList = newWords;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FloatingAppLogo(size: 60),
            const SizedBox(height: 20),
            const Text('🎉 تبریک! صعود به سطح جدید',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
                'شما تمام واژگان این سطح را مسلط شدید.\nسطح جدید شما: $newLevel',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            AnimatedButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('ادامه تمرین',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void _nextWord() {
    setState(() {
      _showBack = false;
      if (_currentIndex < _activeVocabList.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_activeVocabList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('سطح: $_currentLevel')),
        body: const Center(child: Text('هیچ کلمه‌ای در این سطح یافت نشد.')),
      );
    }

    final wordData = _activeVocabList[_currentIndex];
    final totalInLevel = _activeVocabList.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text('سطح: $_currentLevel',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_learnedInCurrentLevel / totalInLevel).clamp(0.0, 1.0),
              color: const Color(0xFF6C5CE7),
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
                'پیشرفت صعود سطح: $_learnedInCurrentLevel از $totalInLevel کلمه',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),

            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showBack = !_showBack),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: _showBack
                        ? const LinearGradient(
                            colors: [Color(0xFF6C5CE7), Color(0xFF8E7CFF)])
                        : const LinearGradient(
                            colors: [Colors.white, Colors.white]),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF6C5CE7).withOpacity(0.12),
                          blurRadius: 15)
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            wordData['word']!,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _showBack
                                  ? Colors.white
                                  : const Color(0xFF2D3436),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up_rounded,
                                color: _showBack
                                    ? Colors.white
                                    : const Color(0xFF6C5CE7)),
                            onPressed: () => _speak(wordData['word']!),
                          )
                        ],
                      ),
                      Text(wordData['phonetic']!,
                          style: TextStyle(
                              color: _showBack ? Colors.white70 : Colors.grey)),
                      const SizedBox(height: 30),
                      if (_showBack) ...[
                        const Divider(color: Colors.white30),
                        const SizedBox(height: 16),
                        Text(wordData['meaning']!,
                            style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(wordData['example']!,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontStyle: FontStyle.italic)),
                      ] else ...[
                        const Text('کلیک کنید تا معنی را ببینید',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ]
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AnimatedButton(
                    onPressed: _nextWord,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFF7675),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: Colors.white),
                          SizedBox(width: 8),
                          Text('بلد نبودم',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedButton(
                    onPressed: _onWordLearned,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          color: const Color(0xFF00B894),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.white),
                          SizedBox(width: 8),
                          Text('بلد بودم',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ۶. تقویم و عملکرد روزانه
// ----------------------------------------------------
class ProgressCalendarTab extends StatefulWidget {
  const ProgressCalendarTab({super.key});

  @override
  State<ProgressCalendarTab> createState() => _ProgressCalendarTabState();
}

class _ProgressCalendarTabState extends State<ProgressCalendarTab> {
  int _todayCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _todayCount = prefs.getInt('today_count') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('تقویم و عملکرد امروز'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_fire_department,
                      size: 50, color: Colors.orange),
                  const SizedBox(height: 10),
                  Text('کلمات یادگرفته شده امروز: $_todayCount واژه',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                      value: (_todayCount / 20).clamp(0.0, 1.0),
                      color: const Color(0xFF6C5CE7)),
                  const SizedBox(height: 8),
                  const Text('هدف روزانه: ۲۰ واژه',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('وضعیت هفته جاری',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                'شنبه',
                '۱شنبه',
                '۲شنبه',
                '۳شنبه',
                '۴شنبه',
                '۵شنبه',
                'جمعه'
              ].map((day) {
                final isToday = day == 'یکشنبه';
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isToday
                          ? const Color(0xFF6C5CE7)
                          : Colors.grey.shade200,
                      child: Icon(Icons.check,
                          size: 18,
                          color: isToday ? Colors.white : Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(day, style: const TextStyle(fontSize: 11)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ۷. پروفایل کاربر
// ----------------------------------------------------
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = '';
  String _email = '';
  String _level = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'کاربر';
      _email = prefs.getString('user_email') ?? 'نامشخص';
      _level = prefs.getString('user_level') ?? 'Beginner';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل من'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFF6C5CE7),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(_name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ListTile(
              leading:
                  const Icon(Icons.school_outlined, color: Color(0xFF6C5CE7)),
              title: const Text('سطح فعلی'),
              trailing: Text(_level,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('خروج از حساب کاربری',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
