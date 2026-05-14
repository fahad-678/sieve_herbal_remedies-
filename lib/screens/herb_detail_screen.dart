import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/herbs_data.dart';
import '../models/herb.dart';
import '../theme/app_colors.dart';
import '../utils/storage.dart';
import '../widgets/educational_disclaimer_card.dart';
import '../widgets/optimized_herb_image.dart';

class HerbDetailScreen extends StatefulWidget {
  final String herbId;

  const HerbDetailScreen({super.key, required this.herbId});

  @override
  State<HerbDetailScreen> createState() => _HerbDetailScreenState();
}

class _HerbDetailScreenState extends State<HerbDetailScreen> {
  bool _isFavorite = false;
  bool _isExportingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await Storage.isFavorite(widget.herbId);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await Storage.toggleFavorite(widget.herbId);
    if (mounted) {
      setState(() {
        _isFavorite = newStatus;
      });
    }
  }

  Future<void> _exportToPdf(Herb herb) async {
    if (_isExportingPdf) {
      return;
    }

    setState(() {
      _isExportingPdf = true;
    });

    try {
      final bytes = await _buildHerbPdf(herb);
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${_buildPdfFileName(herb.name)}.pdf',
      );
    } catch (e, st) {
      debugPrint('PDF export failed: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to create the PDF right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
        });
      }
    }
  }

  Future<Uint8List> _buildHerbPdf(Herb herb) async {
    final unicodeFont = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'))
          .buffer
          .asByteData(),
    );
    final document = pw.Document(
      theme: pw.ThemeData.withFont(
        base: unicodeFont,
        bold: unicodeFont,
        italic: unicodeFont,
        boldItalic: unicodeFont,
      ),
    );

    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(28),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(16),
              color: PdfColors.green50,
              border: pw.Border.all(color: PdfColors.green200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  herb.name,
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  herb.scientificName,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.green700,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  herb.briefDescription,
                  style: const pw.TextStyle(fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          _pdfSection(title: 'About', content: herb.detailedInformation),
          _pdfSection(title: 'Traditional Uses', content: herb.traditionalUses),
          _pdfSection(
              title: 'Modern Applications', content: herb.modernApplications),
          _pdfBulletSection(
              title: 'Primary Benefits', items: herb.primaryBenefits),
          _pdfBulletSection(title: 'Common Names', items: herb.commonNames),
          _pdfBulletSection(
              title: 'Active Compounds', items: herb.activeCompounds),
          _pdfSection(title: 'How to Use', content: herb.howToUse),
          _pdfSection(title: 'Dosage', content: herb.dosage),
          _pdfSection(title: 'Best Time to Take', content: herb.bestTimeToTake),
          _pdfSection(title: 'Duration', content: herb.duration),
          _pdfSection(
              title: 'Contraindications', content: herb.contraindications),
          _pdfSection(title: 'Side Effects', content: herb.sideEffects),
          _pdfSection(
              title: 'Drug Interactions', content: herb.drugInteractions),
          _pdfSection(
              title: 'Pregnancy Warning', content: herb.pregnancyWarning),
          _pdfSection(title: 'Nursing Warning', content: herb.nursingWarning),
          _pdfSection(title: 'Storage', content: herb.storage),
          _pdfSection(title: 'Shelf Life', content: herb.shelfLife),
          _pdfBulletSection(title: 'Related Herbs', items: herb.relatedHerbs),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _pdfSection({required String title, required String content}) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            content,
            style: const pw.TextStyle(fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfBulletSection({
    required String title,
    required List<String> items,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 8),
          ...items.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 11)),
                  pw.Expanded(
                    child: pw.Text(
                      item,
                      style: const pw.TextStyle(fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildPdfFileName(String input) {
    final sanitized = input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return sanitized.isEmpty ? 'herb_details' : sanitized;
  }

  @override
  Widget build(BuildContext context) {
    final herb = HerbsData.getHerbById(widget.herbId);

    if (herb == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Herb Not Found'),
        ),
        body: const Center(
          child: Text('Herb not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: _isExportingPdf
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
                tooltip: 'Export to PDF',
                onPressed: _isExportingPdf ? null : () => _exportToPdf(herb),
              ),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  OptimizedHerbImage(
                    herb: herb,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    showPlaceholder: true,
                    pixelRatio: 2.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          herb.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          herb.scientificName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EducationalDisclaimerCard(),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'About',
                    content: herb.detailedInformation,
                  ),
                  const SizedBox(height: 16),
                  _buildListCard(
                    title: 'Primary Benefits',
                    items: herb.primaryBenefits,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'How to Use',
                    content: herb.howToUse,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Dosage',
                    content: herb.dosage,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Best Time to Take',
                    content: herb.bestTimeToTake,
                  ),
                  const SizedBox(height: 16),
                  _buildListCard(
                    title: 'Active Compounds',
                    items: herb.activeCompounds,
                    icon: Icons.science_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildListCard(
                    title: 'Contraindications',
                    items: [herb.contraindications],
                    icon: Icons.warning_amber_outlined,
                    isWarning: true,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Side Effects',
                    content: herb.sideEffects,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Drug Interactions',
                    content: herb.drugInteractions,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Pregnancy Warning',
                    content: herb.pregnancyWarning,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Storage',
                    content: herb.storage,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.foreground.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required List<String> items,
    required IconData icon,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFEF2F2) : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning ? const Color(0xFFFEE2E2) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isWarning)
                const Icon(
                  Icons.warning_amber,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              if (isWarning) const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isWarning
                      ? const Color(0xFFDC2626)
                      : AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isWarning
                          ? const Color(0xFFDC2626)
                          : AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: isWarning
                              ? const Color(0xFFDC2626)
                              : AppColors.foreground.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
