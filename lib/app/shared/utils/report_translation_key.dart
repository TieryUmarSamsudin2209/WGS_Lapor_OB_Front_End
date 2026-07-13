String reportTranslationKey(String value) {
  final normalized = _normalizeReportText(value);

  return _reportTranslationKeys[normalized] ?? value;
}

String _normalizeReportText(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('&', ' dan ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

const _reportTranslationKeys = {
  'kebersihan': 'Kebersihan',
  'cleaning': 'Kebersihan',
  'pengecekan': 'Pengecekan',
  'inspection': 'Pengecekan',
  'peralatan': 'Peralatan',
  'equipment': 'Peralatan',
  'ac dan udara': 'AC & Udara',
  'ac udara': 'AC & Udara',
  'ac air': 'AC & Udara',
  'air dan galon': 'Air & Galon',
  'air galon': 'Air & Galon',
  'water gallon': 'Air & Galon',
  'kelistrikan': 'Kelistrikan',
  'electrical': 'Kelistrikan',
  'meja dan kursi': 'Meja & Kursi',
  'meja kursi': 'Meja & Kursi',
  'desks chairs': 'Meja & Kursi',
  'lainnya': 'Lainnya',
  'others': 'Lainnya',

  'kebocoran pipa air': 'report_title_water_pipe_leak',
  'water pipe leak': 'report_title_water_pipe_leak',
  'tumpahan air di lobby': 'report_title_water_spill_lobby',
  'water spill in lobby': 'report_title_water_spill_lobby',
  'ac bocor di pantry': 'report_title_ac_leak_pantry',
  'ac leak in pantry': 'report_title_ac_leak_pantry',
  'ac bocor di ruang meeting 4': 'report_title_ac_leak_meeting_room_4',
  'ac leak in meeting room 4': 'report_title_ac_leak_meeting_room_4',
  'kertas habis di printer lt 3': 'report_title_printer_paper_empty',
  'out of paper at printer 3rd fl': 'report_title_printer_paper_empty',

  'hq tower a lantai 4 toilet pria':
      'report_location_hq_tower_a_floor_4_male_toilet',
  'building a floors 1 dan 2': 'report_location_building_a_floors_1_2',
  'gedung a lantai 1 dan 2': 'report_location_building_a_floors_1_2',
  'lobby': 'report_location_lobby',
  'ruang meeting 4': 'report_location_meeting_room_4',
  'pantry': 'report_location_pantry',
  'printer lt 3': 'report_location_printer_floor_3',

  'water pooling near the main vent in hallway b requires immediate attention before floor damage':
      'report_desc_water_pooling_hallway',
  'air menggenang di dekat ventilasi utama lorong b perlu segera ditangani sebelum merusak lantai':
      'report_desc_water_pooling_hallway',
};
