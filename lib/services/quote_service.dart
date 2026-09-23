import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';

class QuoteService {
  // Dio setup with timeouts for extreme reliability
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(
        seconds: 10,
      ), // ১০ সেকেন্ডের বেশি সময় লাগলে টাইমআউট হবে
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static const String _cacheKey = 'cached_quote';
  static const String _apiUrl = 'https://dummyjson.com/quotes/random';

  Future<Quote?> getCachedQuote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        return Quote.fromJson(jsonDecode(cachedData));
      }
    } catch (e) {
      // যদি ক্যাশ ডেটা কোনো কারণে করাপ্ট হয়ে যায়, তবে অ্যাপ ক্র্যাশ না করে null রিটার্ন করবে
      return null;
    }
    return null;
  }

  Future<Quote> fetchNewQuote() async {
    try {
      // ?t=... (Timestamp) অ্যাড করা হলো যাতে ডিভাইস/নেটওয়ার্ক আগের কোট ক্যাশ করে না রাখে
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await _dio.get('$_apiUrl?t=$timestamp');

      final quote = Quote.fromJson(response.data);

      // নতুন কোটটি পরবর্তী লঞ্চের জন্য ক্যাশে সেভ করা হলো
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(quote.toJson()));

      return quote;
    } catch (e) {
      // ইন্টারনেট না থাকলে বা সার্ভার ডাউন থাকলে এই এররটি থ্রো করবে
      throw Exception(
        'Failed to fetch quote. Please check your internet connection.',
      );
    }
  }
}
