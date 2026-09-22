import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';

class QuoteService {
  final Dio _dio = Dio();
  static const String _cacheKey = 'cached_quote';
  static const String _apiUrl = 'https://dummyjson.com/quotes/random';

  Future<Quote?> getCachedQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    if (cachedData != null) {
      return Quote.fromJson(jsonDecode(cachedData));
    }
    return null;
  }

  Future<Quote> fetchNewQuote() async {
    try {
      final response = await _dio.get(_apiUrl);
      final quote = Quote.fromJson(response.data);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(quote.toJson()));
      
      return quote;
    } catch (e) {
      throw Exception('Failed to fetch quote. Please check your internet connection.');
    }
  }
}