import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_hadiths';

  // دریافت لیست علاقه‌مندی‌ها
  Future<List<int>> getFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      if (favoritesJson == null) {
        return [];
      }
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.cast<int>();
    } catch (e) {
      return [];
    }
  }

  // بررسی اینکه آیا حدیث در علاقه‌مندی‌ها است یا نه
  Future<bool> isFavorite(int hadithId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(hadithId);
  }

  // افزودن به علاقه‌مندی‌ها
  Future<bool> addFavorite(int hadithId) async {
    try {
      final favorites = await getFavoriteIds();
      if (!favorites.contains(hadithId)) {
        favorites.add(hadithId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_favoritesKey, json.encode(favorites));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // حذف از علاقه‌مندی‌ها
  Future<bool> removeFavorite(int hadithId) async {
    try {
      final favorites = await getFavoriteIds();
      if (favorites.contains(hadithId)) {
        favorites.remove(hadithId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_favoritesKey, json.encode(favorites));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // تغییر وضعیت علاقه‌مندی
  Future<bool> toggleFavorite(int hadithId) async {
    final isFav = await isFavorite(hadithId);
    if (isFav) {
      return await removeFavorite(hadithId);
    } else {
      return await addFavorite(hadithId);
    }
  }

  // پاک کردن همه علاقه‌مندی‌ها
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}

