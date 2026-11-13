import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/theme/app_theme.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/pages/home/home_page.dart';
import 'package:uniswap_app/pages/discover/discover_page.dart';
import 'package:uniswap_app/pages/publish/publish_entry_page.dart';
import 'package:uniswap_app/pages/messages/messages_page.dart';
import 'package:uniswap_app/pages/profile/profile_page.dart';
import 'package:uniswap_app/pages/product/product_detail_page.dart';
import 'package:uniswap_app/pages/search/search_page.dart';
import 'package:uniswap_app/pages/transaction/transaction_intent_page.dart';
import 'package:uniswap_app/pages/transaction/appointment_page.dart';
import 'package:uniswap_app/pages/transaction/transaction_detail_page.dart';
import 'package:uniswap_app/pages/seller/seller_profile_page.dart';
import 'package:uniswap_app/pages/chat/chat_page.dart';
import 'package:uniswap_app/pages/settings/settings_page.dart';
import 'package:uniswap_app/pages/profile/profile_edit_page.dart';
import 'package:uniswap_app/pages/campus/campus_map_page.dart';
import 'package:flutter/cupertino.dart';

class UniSwapApp extends StatelessWidget {
  const UniSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DataRepository.instance,
      child: MaterialApp(
        title: 'UniSwap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainShell(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/search':
              return _cupertinoRoute(const SearchPage());
            case '/product':
              final args = settings.arguments as String?;
              return _cupertinoRoute(ProductDetailPage(productId: args ?? ''));
            case '/seller':
              final args = settings.arguments as String?;
              return _cupertinoRoute(SellerProfilePage(sellerId: args ?? ''));
            case '/intent':
              final args = settings.arguments as String?;
              return _bottomSheetRoute(TransactionIntentPage(productId: args ?? ''));
            case '/appointment':
              final args = settings.arguments as TransactionIntentPageArgs?;
              return _cupertinoRoute(AppointmentPage(args: args));
            case '/tx_detail':
              final args = settings.arguments as String?;
              return _cupertinoRoute(TransactionDetailPage(transactionId: args ?? ''));
            case '/chat':
              final args = settings.arguments as String?;
              return _cupertinoRoute(ChatPage(sessionId: args ?? ''));
            case '/settings':
              return _cupertinoRoute(const SettingsPage());
            case '/profile_edit':
              return _cupertinoRoute(const ProfileEditPage());
            case '/campus':
              return _cupertinoRoute(const CampusMapPage());
            default:
              return null;
          }
        },
      ),
    );
  }

  // 用 CupertinoPageRoute 自带 iOS 左滑返回手势
  Route _cupertinoRoute(Widget page) {
    return CupertinoPageRoute(builder: (_) => page);
  }

  Route _bottomSheetRoute(Widget page) {
    return PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: offset, child: child);
      },
    );
  }
}

// ============ Main Shell ============
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(),
    DiscoverPage(),
    PublishEntryPage(),
    MessagesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              _navItem(0, Icons.home_outlined, Icons.home_rounded, '首页'),
              _navItem(1, Icons.search_rounded, Icons.search_rounded, '发现'),
              const SizedBox(width: 2),
              _publishButton(),
              const SizedBox(width: 2),
              _navItem(3, Icons.chat_bubble_outline, Icons.chat_bubble_rounded, '消息'),
              _navItem(4, Icons.person_outline, Icons.person_rounded, '我的'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final selected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                selected ? activeIcon : icon,
                key: ValueKey('$index-$selected'),
                color: selected ? AppColors.primary : const Color(0xFFB0B5B1),
                size: 21,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                color: selected ? AppColors.primary : const Color(0xFFB0B5B1),
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                height: 1.1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _publishButton() {
    final selected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: AnimatedScale(
        scale: selected ? 1.04 : 1,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
