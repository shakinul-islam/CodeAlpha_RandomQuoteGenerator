import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quote_model.dart';
import '../services/quote_service.dart';

final quoteServiceProvider = Provider((ref) => QuoteService());

final quoteNotifierProvider = AsyncNotifierProvider<QuoteNotifier, Quote?>(() {
  return QuoteNotifier();
});

class QuoteNotifier extends AsyncNotifier<Quote?> {
  @override
  FutureOr<Quote?> build() async {
    final service = ref.read(quoteServiceProvider);
    final cachedQuote = await service.getCachedQuote();

    if (cachedQuote != null) {
      _fetchBackground();
      return cachedQuote;
    }
    return await service.fetchNewQuote();
  }

  Future<void> _fetchBackground() async {
    try {
      final newQuote = await ref.read(quoteServiceProvider).fetchNewQuote();
      state = AsyncData(newQuote);
    } catch (e) {
      // Ignore error silently in background
    }
  }

  Future<void> getNewQuote() async {
    try {
      final newQuote = await ref.read(quoteServiceProvider).fetchNewQuote();
      state = AsyncData(newQuote);
    } catch (e, st) {
      if (!state.hasValue || state.value == null) {
        state = AsyncError(e, st);
      }
    }
  }
}
