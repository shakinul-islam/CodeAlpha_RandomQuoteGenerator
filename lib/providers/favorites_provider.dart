import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<Quote>>(
  () => FavoritesNotifier(),
);

class FavoritesNotifier extends AsyncNotifier<List<Quote>> {
  static const _key = 'favorite_quotes';

  @override
  Future<List<Quote>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => Quote.fromJson(jsonDecode(e))).toList();
  }

  Future<void> toggleFavorite(Quote quote) async {
    final currentList = state.value ?? [];
    final isExist = currentList.any((q) => q.text == quote.text);

    List<Quote> newList;
    if (isExist) {
      newList = currentList.where((q) => q.text != quote.text).toList();
    } else {
      newList = [...currentList, quote];
    }

    final prefs = await SharedPreferences.getInstance();
    final stringList = newList.map((q) => jsonEncode(q.toJson())).toList();
    await prefs.setStringList(_key, stringList);

    state = AsyncData(newList);
  }
}
