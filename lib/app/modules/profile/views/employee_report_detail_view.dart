import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/services/auth_service.dart';
import '../../../shared/theme/theme_controller.dart';

class EmployeeReportDetailView extends StatefulWidget {
  const EmployeeReportDetailView({super.key});

  @override
  State<EmployeeReportDetailView> createState() =>
      _EmployeeReportDetailViewState();
}

class _EmployeeReportDetailViewState extends State<EmployeeReportDetailView> {
  static const _blue = Color(0xFF14558B);
  static const _lightPanel = Color(0xFFF3F5FF);

  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  late _ReportDetailData _detail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final initial = _asMap(Get.arguments) ?? const <String, dynamic>{};
    _detail = _ReportDetailData.fromMaps([initial]);
    _loadDetail(initial);
  }

  Future<void> _loadDetail(Map<String, dynamic> initial) async {
    final id = _reportId(initial);
    if (id == null) return;

    setState(() => _isLoading = true);
    final response = await _authService.getUserReportDetail(id);
    if (!mounted) return;

    final detailMap = _asMap(response?['data']) ?? response;
    setState(() {
      _detail = _ReportDetailData.fromMaps([
        if (detailMap != null) detailMap,
        initial,
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : _blue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        title: Text(
          'Detail Laporan'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              final initial = _asMap(Get.arguments) ?? const <String, dynamic>{};
              await _loadDetail(initial);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 22),
              children: [
                _MainDetailCard(detail: _detail),
                const SizedBox(height: 10),
                _PhotoAndNoteCard(detail: _detail),
              ],
            ),
          ),
          if (_isLoading)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }

  String? _reportId(Map<String, dynamic> source) {
    final rawId =
        _firstText(source, const ['raw_id', 'laporan_id', 'report_id', 'id']);
    if (rawId == null) return null;
    final normalized = rawId.startsWith('#') ? rawId.substring(1) : rawId;
    final text = normalized.trim();
    return text.isEmpty ? null : text;
  }
}

class _MainDetailCard extends StatelessWidget {
  const _MainDetailCard({required this.detail});

  final _ReportDetailData detail;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusPill(status: detail.status),
              const Spacer(),
              Text(
                detail.timeLabel,
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF4B5563),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            detail.title.tr,
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: Color(0xFF064BFF),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  detail.location.tr,
                  style: const TextStyle(
                    color: Color(0xFF064BFF),
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 28,
            color: isDark ? AppDarkColors.border : const Color(0xFFE8EDF3),
          ),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Dilaporkan Oleh',
            value: detail.reporter,
          ),
          const SizedBox(height: 11),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Lokasi',
            value: detail.location,
          ),
          const SizedBox(height: 11),
          _InfoRow(
            icon: Icons.cleaning_services_outlined,
            label: 'Kategori',
            value: detail.category,
          ),
          const SizedBox(height: 11),
          _InfoRow(
            icon: Icons.priority_high_rounded,
            label: 'Prioritas',
            value: detail.priority,
          ),
        ],
      ),
    );
  }
}

class _PhotoAndNoteCard extends StatelessWidget {
  const _PhotoAndNoteCard({required this.detail});

  final _ReportDetailData detail;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor = isDark
        ? AppDarkColors.surface
        : _EmployeeReportDetailViewState._lightPanel;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFBDEBFF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bukti Foto'.tr,
            style: TextStyle(
              color: titleColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          _PhotoPreview(photos: detail.photos, location: detail.location),
          if (detail.photos.length > 1) ...[
            const SizedBox(height: 30),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: detail.photos
                  .map((photo) => _PhotoThumb(photo: photo))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Catatan'.tr,
            style: TextStyle(
              color: titleColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 106),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppDarkColors.surfaceVariant : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              detail.description.tr,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF263244),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white60 : const Color(0xFF6B7280);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _EmployeeReportDetailViewState._blue,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.tr,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.tr,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 10, color: style.foreground),
          const SizedBox(width: 4),
          Text(
            style.label.tr,
            style: TextStyle(
              color: style.foreground,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.photos,
    required this.location,
  });

  final List<String> photos;
  final String location;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        width: double.infinity,
        height: 174,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EDF4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Foto belum ada'.tr,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          _ReportImage(path: photos.first, height: 174, width: double.infinity),
          Positioned(
            left: 10,
            right: 10,
            bottom: 9,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    location.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.photo});

  final String photo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: _ReportImage(path: photo, width: 38, height: 38),
    );
  }
}

class _ReportImage extends StatelessWidget {
  const _ReportImage({
    required this.path,
    required this.width,
    required this.height,
  });

  final String path;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final value = path.trim();
    final isNetwork = value.startsWith('http') || value.startsWith('blob:');
    final image = isNetwork || kIsWeb
        ? Image.network(
            value,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                _ImageFallback(width: width, height: height),
          )
        : Image.file(
            File(value),
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                _ImageFallback(width: width, height: height),
          );

    return image;
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8EDF4),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: Color(0xFF7C8694),
      ),
    );
  }
}

class _ReportDetailData {
  const _ReportDetailData({
    required this.title,
    required this.location,
    required this.description,
    required this.priority,
    required this.status,
    required this.reporter,
    required this.category,
    required this.photos,
    required this.timeLabel,
  });

  final String title;
  final String location;
  final String description;
  final String priority;
  final String status;
  final String reporter;
  final String category;
  final List<String> photos;
  final String timeLabel;

  factory _ReportDetailData.fromMaps(List<Map<String, dynamic>> maps) {
    final sources = maps.expand(_sourceMaps).toList();
    final title = _firstTextFromSources(sources, const [
          'title',
          'judul',
          'nama_laporan',
          'nama_kategori_laporan',
          'nama_kategori',
          'kategori',
          'category',
        ]) ??
        'Laporan';
    final category = _firstTextFromSources(sources, const [
          'categoryName',
          'category_name',
          'nama_kategori_laporan',
          'nama_kategori',
          'kategori_laporan',
          'kategori',
          'category',
        ]) ??
        title;
    final description = _firstTextFromSources(sources, const [
          'description',
          'deskripsi',
          'deskripsi_kendala',
          'catatan',
          'keluhan',
          'keterangan',
        ]) ??
        '-';
    final createdAt = _firstTextFromSources(sources, const [
      'created_at',
      'createdAt',
      'tanggal',
      'date',
      'tanggal_laporan',
      'waktu_laporan',
    ]);

    return _ReportDetailData(
      title: title,
      location: _locationFromSources(sources),
      description: description,
      priority: _priorityLabel(
        _firstTextFromSources(sources, const [
              'priority',
              'prioritas',
              'urgency',
              'urgensi',
            ]) ??
            'STANDARD',
      ),
      status: _statusLabel(
        _firstTextFromSources(sources, const ['status', 'status_laporan']) ??
            'Pending',
      ),
      reporter: _firstTextFromSources(sources, const [
            'nama_pelapor',
            'pelapor',
            'reporter',
            'reported_by',
            'reportedBy',
            'karyawan',
            'pegawai',
            'user',
            'nama',
            'name',
          ]) ??
          'Karyawan',
      category: category,
      photos: _photosFromSources(sources),
      timeLabel: _timeAgo(createdAt),
    );
  }
}

class _PillStyle {
  const _PillStyle({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
}

List<Map<String, dynamic>> _sourceMaps(Map<String, dynamic> source) {
  final result = <Map<String, dynamic>>[source];
  for (final key in const [
    'data',
    'laporan',
    'report',
    'raw',
    'detail',
    'item',
  ]) {
    final nested = _asMap(source[key]);
    if (nested != null) result.add(nested);
  }
  return result;
}

String _locationFromSources(List<Map<String, dynamic>> sources) {
  final direct = _firstTextFromSources(sources, const [
    'location',
    'lokasi',
    'detail_lokasi',
    'alamat',
    'area',
  ]);
  if (direct != null) return direct;

  final building = _firstTextFromSources(sources, const [
    'nama_gedung',
    'gedung',
    'building',
  ]);
  final floor = _firstTextFromSources(sources, const [
    'nama_lantai',
    'nomor_lantai',
    'lantai',
    'floor',
  ]);
  final room = _firstTextFromSources(sources, const [
    'nama_ruangan',
    'ruangan',
    'room',
  ]);
  final parts = [building, floor, room]
      .whereType<String>()
      .where((part) => part.trim().isNotEmpty)
      .toList();
  return parts.isEmpty ? '-' : parts.toSet().join(', ');
}

List<String> _photosFromSources(List<Map<String, dynamic>> sources) {
  final photos = <String>[];
  const keys = [
    'photos',
    'foto',
    'foto_laporan',
    'foto_masalah',
    'bukti_foto',
    'gambar',
    'images',
  ];

  for (final source in sources) {
    for (final key in keys) {
      final value = source[key];
      if (value is List) {
        photos.addAll(value.map(_photoValue).whereType<String>());
      } else {
        final photo = _photoValue(value);
        if (photo != null) photos.add(photo);
      }
    }
  }

  return photos
      .map(AuthService.resolveMediaUrl)
      .where((photo) => photo.trim().isNotEmpty)
      .toSet()
      .toList();
}

String? _photoValue(Object? value) {
  if (value == null) return null;
  final map = _asMap(value);
  if (map != null) {
    return _firstText(map, const [
      'url',
      'path',
      'file',
      'filename',
      'foto',
      'image',
      'name',
    ]);
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String _priorityLabel(String value) {
  final normalized = value.trim().toUpperCase();
  if (normalized.contains('URGENT') ||
      normalized.contains('HIGH') ||
      normalized.contains('TINGGI')) {
    return 'URGENT';
  }
  return 'STANDARD';
}

String _statusLabel(String status) {
  final normalized = status.trim().toLowerCase().replaceAll('_', ' ');
  if (normalized.contains('selesai') ||
      normalized.contains('resolved') ||
      normalized.contains('done')) {
    return 'Selesai';
  }
  if (normalized.contains('tolak') || normalized.contains('reject')) {
    return 'Ditolak';
  }
  if (normalized.contains('proses') ||
      normalized.contains('progress') ||
      normalized.contains('diproses')) {
    return 'Proses';
  }
  return 'Pending';
}

_PillStyle _statusStyle(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized.contains('selesai')) {
    return const _PillStyle(
      label: 'Selesai',
      icon: Icons.check_circle_outline,
      background: Color(0xFFDDF8E9),
      foreground: Color(0xFF2BAE66),
    );
  }
  if (normalized.contains('tolak')) {
    return const _PillStyle(
      label: 'Ditolak',
      icon: Icons.cancel_outlined,
      background: Color(0xFFFFE2E5),
      foreground: Color(0xFFC72535),
    );
  }
  if (normalized.contains('proses')) {
    return const _PillStyle(
      label: 'Proses',
      icon: Icons.sync_rounded,
      background: Color(0xFFE3F0FF),
      foreground: Color(0xFF1976D2),
    );
  }
  return const _PillStyle(
    label: 'Pending',
    icon: Icons.schedule_outlined,
    background: Color(0xFFFFF2C8),
    foreground: Color(0xFFFFA000),
  );
}

String _timeAgo(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;

  final diff = DateTime.now().difference(parsed.toLocal());
  if (diff.inMinutes < 1) return 'baru saja';
  if (diff.inHours < 1) return '${diff.inMinutes} menit yang lalu';
  if (diff.inDays < 1) return '${diff.inHours} jam yang lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

  final date = parsed.toLocal();
  return '${date.day}/${date.month}/${date.year}';
}

String? _firstTextFromSources(
  List<Map<String, dynamic>> sources,
  List<String> keys,
) {
  for (final source in sources) {
    final value = _firstText(source, keys);
    if (value != null) return value;
  }
  return null;
}

String? _firstText(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value == null) continue;

    final nested = _asMap(value);
    if (nested != null) {
      final nestedValue = _firstText(nested, const [
        'nama_lengkap',
        'nama_kategori_laporan',
        'nama_kategori',
        'nama_lokasi',
        'nama_lantai',
        'nomor_lantai',
        'nama_ruangan',
        'nama',
        'name',
        'title',
        'label',
        'alamat',
      ]);
      if (nestedValue != null) return nestedValue;
      continue;
    }

    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}
