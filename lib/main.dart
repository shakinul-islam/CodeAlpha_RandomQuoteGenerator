import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import 'splash_screen.dart';
import 'providers/quote_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/favorites_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PremiumQuoteApp()));
}

class PremiumQuoteApp extends ConsumerWidget {
  const PremiumQuoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Daily Zen',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C3E50),
          brightness: Brightness.light,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF2C3E50)),
          bodyMedium: TextStyle(color: Color(0xFF7F8C8D)),
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF94A3B8),
          brightness: Brightness.dark,
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE2E8F0)),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFF8FAFC)),
          bodyMedium: TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class QuoteScreen extends ConsumerWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteState = ref.watch(quoteNotifierProvider);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    final textColor = Theme.of(context).textTheme.bodyLarge!.color;
    final authorColor = Theme.of(context).textTheme.bodyMedium!.color;

    return Scaffold(
      body: Stack(
        children: [
          // Background Watermark Icon
          Positioned(
            top: -50,
            left: -20,
            child: Icon(
              Icons.format_quote_rounded,
              size: 350,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.02)
                  : Colors.black.withOpacity(0.03),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar Options
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bookmark_outline_rounded),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showFavoritesBottomSheet(context, ref);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),

                // Main Content (Scrollable for overflow fix)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                              ),
                              child: quoteState.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                error: (err, stack) => Center(
                                  child: _buildErrorState(err.toString(), ref),
                                ),
                                data: (quote) {
                                  if (quote == null) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  }

                                  final favoritesState = ref.watch(
                                    favoritesProvider,
                                  );
                                  final isFavorite =
                                      favoritesState.value?.any(
                                        (q) => q.text == quote.text,
                                      ) ??
                                      false;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Spacer(),

                                      // Quote Text (Animates only when text changes)
                                      Text(
                                            '"${quote.text}"',
                                            key: ValueKey(quote.text),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.playfairDisplay(
                                              fontSize: 28,
                                              height: 1.4,
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                          )
                                          .animate()
                                          .fade(duration: 800.ms)
                                          .slideY(
                                            begin: 0.1,
                                            end: 0,
                                            curve: Curves.easeOutQuad,
                                          ),

                                      const SizedBox(height: 30),

                                      // Author Text
                                      Text(
                                            '— ${quote.author}',
                                            key: ValueKey(quote.author),
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 1.2,
                                              color: authorColor,
                                            ),
                                          )
                                          .animate(delay: 300.ms)
                                          .fade(duration: 600.ms),

                                      const SizedBox(height: 40),

                                      // Actions Row (Favorite, Copy, Share)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite_rounded
                                                  : Icons
                                                        .favorite_border_rounded,
                                              color: isFavorite
                                                  ? Colors.redAccent
                                                  : Theme.of(
                                                      context,
                                                    ).iconTheme.color,
                                            ),
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              ref
                                                  .read(
                                                    favoritesProvider.notifier,
                                                  )
                                                  .toggleFavorite(quote);
                                            },
                                          ),
                                          const SizedBox(width: 15),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.copy_rounded,
                                            ),
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              Clipboard.setData(
                                                ClipboardData(
                                                  text:
                                                      '"${quote.text}"\n— ${quote.author}',
                                                ),
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Quote copied to clipboard',
                                                    style: GoogleFonts.inter(),
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  backgroundColor: isDarkMode
                                                      ? Colors.grey[800]
                                                      : Colors.grey[900],
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 15),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.share_rounded,
                                            ),
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              Share.share(
                                                '"${quote.text}"\n— ${quote.author}\n\nShared via Daily Zen App',
                                              );
                                            },
                                          ),
                                        ],
                                      ).animate(delay: 500.ms).fadeIn(),

                                      const Spacer(),

                                      // Premium "New Quote" Button
                                      _buildPremiumButton(ref, textColor!),
                                      const SizedBox(height: 40),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumButton(WidgetRef ref, Color color) {
    return OutlinedButton(
      key: const ValueKey(
        'PremiumButton',
      ), // বাটনটি স্ক্রিনে স্থির রাখার জন্য Key
      onPressed: () {
        HapticFeedback.mediumImpact();
        ref.read(quoteNotifierProvider.notifier).getNewQuote();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        side: BorderSide(color: color, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        foregroundColor: color,
        splashFactory: NoSplash.splashFactory,
      ),
      child: Text(
        'Breathe & Renew',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.wifi_off_rounded, size: 48, color: Colors.red[200]),
        const SizedBox(height: 16),
        Text(
          'A connection to tranquility could not be established.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.grey[500]),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(quoteNotifierProvider.notifier).getNewQuote();
          },
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  void _showFavoritesBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final favoritesState = ref.watch(favoritesProvider);
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Saved Quotes',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: favoritesState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      const Center(child: Text('Error loading favorites')),
                  data: (favorites) {
                    if (favorites.isEmpty) {
                      return Center(
                        child: Text(
                          'No saved quotes yet.',
                          style: GoogleFonts.inter(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: favorites.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final quote = favorites[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '"${quote.text}"',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '— ${quote.author}',
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(favoritesProvider.notifier)
                                  .toggleFavorite(quote);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
