import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bounce_button.dart';
import '../models/article_model.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  /// Artikel lain untuk bagian "Read Next". Kosong = bagian disembunyikan.
  final List<Article> relatedArticles;

  const ArticleDetailScreen({
    Key? key,
    required this.article,
    this.relatedArticles = const [],
  }) : super(key: key);

  static const double _heroHeight = 300;
  static const double _cardOverlap = 28;

  int get _readingMinutes {
    final words = article.content.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Hero image: diam di belakang
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.cycleRingTrack),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: AppColors.cycleRingTrack);
                    },
                  ),
                  // Gradasi tipis supaya tombol kembali tetap terlihat
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.25),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Konten: scroll di atas gambar
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: _heroHeight - _cardOverlap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContentCard(),
                  if (relatedArticles.isNotEmpty) _buildReadNext(context),
                  SizedBox(height: 24 + media.padding.bottom),
                ],
              ),
            ),

            // Tombol kembali
            Positioned(
              top: media.padding.top + 8,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    article.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPink,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.subText),
                const SizedBox(width: 4),
                Text(
                  '$_readingMinutes min read',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
                letterSpacing: -0.5,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: AppColors.cycleRingTrack),
            const SizedBox(height: 18),
            ..._buildContent(article.content),
            const SizedBox(height: 12),
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  /// Bagian rekomendasi artikel berikutnya (maksimal 3).
  Widget _buildReadNext(BuildContext context) {
    final items = relatedArticles.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Read Next',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((next) => _buildRelatedCard(context, next)),
        ],
      ),
    );
  }

  Widget _buildRelatedCard(BuildContext context, Article next) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BounceButton(
        onTap: () {
          // Daftar rekomendasi artikel baru: semua kecuali dirinya, termasuk artikel ini
          final others = [...relatedArticles, article]
              .where((a) => a != next)
              .toList();
          // pushReplacement supaya tombol kembali tetap ke layar asal, bukan menumpuk
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(
                article: next,
                relatedArticles: others,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(AppColors.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  next.imageUrl,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 76,
                    height: 76,
                    color: AppColors.cycleRingTrack,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        next.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      next.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.subText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mengubah string content menjadi widget: subjudul, bullet, dan paragraf.
  List<Widget> _buildContent(String content) {
    final numbered = RegExp(r'^(\d+)\.\s+(.*)$');
    final blocks = content.split(RegExp(r'\n\s*\n'));
    final widgets = <Widget>[];

    for (final block in blocks) {
      final lines = block
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;

      final first = lines.first;
      final isHeading = lines.length > 1 &&
          !first.startsWith('- ') &&
          (numbered.hasMatch(first) || (first.length <= 50 && !first.endsWith('.')));

      List<String> bodyLines = lines;
      if (isHeading) {
        widgets.add(_buildHeading(first, numbered));
        bodyLines = lines.sublist(1);
      }

      for (final line in bodyLines) {
        if (line.startsWith('- ')) {
          widgets.add(_buildBullet(line.substring(2)));
        } else {
          widgets.add(_buildParagraph(line));
        }
      }
    }
    return widgets;
  }

  Widget _buildHeading(String text, RegExp numbered) {
    final match = numbered.firstMatch(text);

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (match != null)
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                match.group(1)!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryPink,
                ),
              ),
            )
          else
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryPink,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              match != null ? match.group(2)! : text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 9, right: 12, left: 4),
            decoration: const BoxDecoration(
              color: AppColors.primaryPink,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.55,
                color: AppColors.darkerSubText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.65,
          color: AppColors.darkerSubText,
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryPurple),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This is general information, not medical advice. If symptoms persist or feel severe, talk to a doctor.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.darkerSubText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
