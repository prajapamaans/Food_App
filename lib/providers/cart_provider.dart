import 'package:flutter/material.dart';
import '../models/food_item.dart';

// ── CartItem ─────────────────────────────────────────────────────────────────
// Wraps a FoodItem with a mutable quantity.
// We keep it separate from FoodItem so the model stays immutable.

class CartItem {
  final FoodItem food;
  int quantity;

  CartItem({required this.food, required this.quantity});

  // Subtotal for this line item
  double get subtotal => food.price * quantity;
}

// ── CartProvider ──────────────────────────────────────────────────────────────
// Single source of truth for everything cart-related.
// Registered in MultiProvider → available across the whole app.

class CartProvider extends ChangeNotifier {
  // Map<foodId, CartItem> — O(1) lookups by id
  final Map<String, CartItem> _items = {};

  // ── Read-only accessors ───────────────────────────────────────────────────

  // All cart items as a list (for ListView rendering)
  List<CartItem> get items => _items.values.toList();

  // Total number of individual units across all items
  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  // Raw food cost before fees
  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  // Fixed delivery fee
  double get deliveryFee => totalItems > 0 ? 2.99 : 0.0;

  // 8% tax on subtotal only
  double get tax => subtotal * 0.08;

  // Final amount customer pays
  double get grandTotal => subtotal + deliveryFee + tax;

  // True if cart has at least one item
  bool get isEmpty => _items.isEmpty;

  // ── Mutations ─────────────────────────────────────────────────────────────

  // Add one unit. If already in cart, increment quantity.
  void addItem(FoodItem food) {
    if (_items.containsKey(food.id)) {
      _items[food.id]!.quantity++;
    } else {
      _items[food.id] = CartItem(food: food, quantity: 1);
    }
    notifyListeners(); // triggers Consumer rebuilds
  }

  // Remove one unit. If quantity hits 0, remove the entry entirely.
  void decrementItem(String foodId) {
    if (!_items.containsKey(foodId)) return;
    if (_items[foodId]!.quantity <= 1) {
      _items.remove(foodId);
    } else {
      _items[foodId]!.quantity--;
    }
    notifyListeners();
  }

  // Remove entire line item regardless of quantity
  void removeItem(String foodId) {
    _items.remove(foodId);
    notifyListeners();
  }

  // Wipe cart — called after order is placed
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Convenience: check how many of a specific item are in cart
  int quantityOf(String foodId) => _items[foodId]?.quantity ?? 0;
}