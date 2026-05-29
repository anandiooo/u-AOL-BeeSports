import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('ScaffoldMessenger.of(context).showSnackBar')) {
      // It's a bit complex to regex replace properly since multi-line and different types (success vs error)
      // I'll just print them out for manual replacement via replace_file_content if regex is too risky.
      print(file.path);
    }
  }
}
