enum Campus {
  kemanggisan('Kemanggisan', 'Jakarta Barat'),
  alamSutera('Alam Sutera', 'Tangerang'),
  bekasi('Bekasi', 'Bekasi'),
  bandung('Bandung', 'Bandung'),
  malang('Malang', 'Malang'),
  semarang('Semarang', 'Semarang'),
  online('BINUS Online', 'Online'),
  unknown('Unknown', '');

  final String label;
  final String city;

  const Campus(this.label, this.city);

  static Campus fromNim(String nim) {
    if (nim.length < 4) return Campus.unknown;

    final prefix = nim.substring(0, 4);
    switch (prefix) {
      case '2501':
      case '2502':
        return Campus.kemanggisan;
      case '2503':
      case '2540':
        return Campus.alamSutera;
      case '2504':
        return Campus.bekasi;
      case '2505':
        return Campus.bandung;
      case '2506':
        return Campus.malang;
      case '2507':
        return Campus.semarang;
      default:
        return Campus.unknown;
    }
  }
}
