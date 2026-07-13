String checklistTranslationKey(String value) {
  final normalized = _normalizeChecklistText(value);

  return _checklistTranslationKeys[normalized] ?? value;
}

String _normalizeChecklistText(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('&', ' dan ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

const _checklistTranslationKeys = {
  'area kerja utama dan koridor': 'checklist_section_main_work_area',
  'main work area and corridor': 'checklist_section_main_work_area',
  'area toilet krusial dan harus dicek berkala':
      'checklist_section_toilet_area',
  'toilet area critical and must be checked periodically':
      'checklist_section_toilet_area',
  'manajemen sampah dan utilitas fasilitas':
      'checklist_section_waste_utilities',
  'waste and utility management facilities':
      'checklist_section_waste_utilities',

  'mengepel dan menyapu': 'checklist_task_mop_sweep',
  'mopping and sweeping': 'checklist_task_mop_sweep',
  'dusting mengelap debu': 'checklist_task_dusting',
  'dusting': 'checklist_task_dusting',
  'restocking isi ulang': 'checklist_task_restocking',
  'restocking': 'checklist_task_restocking',
  'pembersihan area basah': 'checklist_task_wet_area_cleaning',
  'wet area cleaning': 'checklist_task_wet_area_cleaning',
  'cek drainase': 'checklist_task_drainage_check',
  'drainage check': 'checklist_task_drainage_check',
  'pengosongan tempat sampah': 'checklist_task_empty_trash',
  'emptying trash bins': 'checklist_task_empty_trash',
  'pengecekan lampu dan ac': 'checklist_task_lights_ac_check',
  'lights and ac check': 'checklist_task_lights_ac_check',
  'menyiram tanaman': 'checklist_task_water_plants',
  'watering plants': 'checklist_task_water_plants',
  'bersihkan ruang meeting a': 'checklist_task_clean_meeting_room_a',
  'clean meeting room a': 'checklist_task_clean_meeting_room_a',
  'cek toilet lantai 2': 'checklist_task_check_toilet_floor_2',
  'check toilet floor 2': 'checklist_task_check_toilet_floor_2',
  'tugas harian': 'Checklist Harian',
  'daily task': 'Checklist Harian',

  'membersihkan seluruh lantai area kerja dan koridor':
      'checklist_desc_mop_sweep',
  'clean all floors in the work area and corridor':
      'checklist_desc_mop_sweep',
  'mengelap meja kerja meja meeting kursi rak buku dan ambang jendela':
      'checklist_desc_dusting',
  'wipe desks meeting tables chairs bookshelves and window sills':
      'checklist_desc_dusting',
  'memastikan sabun cuci tangan tisu toilet dan tisu wastafel selalu terisi penuh':
      'checklist_desc_restocking',
  'ensure hand soap toilet tissue and sink tissue are fully stocked':
      'checklist_desc_restocking',
  'lantai kloset urinal dan wastafel': 'checklist_desc_wet_area_cleaning',
  'floors toilets urinals and sinks': 'checklist_desc_wet_area_cleaning',
  'memastikan tidak ada sumbatan pada saluran air dan air mengalir dengan lancar':
      'checklist_desc_drainage_check',
  'ensure there are no clogs in drains and water flows smoothly':
      'checklist_desc_drainage_check',
  'mengosongkan seluruh tempat sampah': 'checklist_desc_empty_trash',
  'empty all trash bins': 'checklist_desc_empty_trash',
  'matikan saat pulang nyalakan saat pagi':
      'checklist_desc_lights_ac_check',
  'turn off when leaving and turn on in the morning':
      'checklist_desc_lights_ac_check',
  'menyiram tanaman hias yang ada di dalam maupun di area depan kantor':
      'checklist_desc_water_plants',
  'water ornamental plants inside and in front of the office':
      'checklist_desc_water_plants',
};
