import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';    
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'home_screen.dart';
import 'cart_screen.dart'; 
import 'profile_screen.dart';
import 'order_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // IndexedStack keeps all screens alive — doesn't rebuild on tab switch
 final List<Widget> _screens = const [
  HomeScreen(),           
  CartScreen(),          
  OrdersScreen(),  
  ProfileScreen(),       
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    // Consumer watches CartProvider — rebuilds badge when cart changes
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textHint,
            selectedLabelStyle: AppTextStyles.caption
                .copyWith(color: AppColors.primary),
            unselectedLabelStyle: AppTextStyles.caption,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),

              // Cart tab with live item count badge
              BottomNavigationBarItem(
                icon: _cartIcon(cart.totalItems, false),
                activeIcon: _cartIcon(cart.totalItems, true),
                label: 'Cart',
              ),

              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  // Cart icon with an orange badge showing item count
  Widget _cartIcon(int count, bool isActive) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          isActive
              ? Icons.shopping_cart_rounded
              : Icons.shopping_cart_outlined,
        ),
        if (count > 0)
          Positioned(
            top: -6,
            right: -8,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Placeholder for unbuilt screens
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(label, style: AppTextStyles.h1),
      ),
    );
  }
}