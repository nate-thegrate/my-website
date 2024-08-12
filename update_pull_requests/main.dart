/// updates
library;

import 'package:dio/dio.dart';
import 'dart:io';

void main() async {
  final dio = Dio();
  final result = await dio.get('https://api.github.com/');
  File('lib/github_data/github_data.g.dart').writeAsString("""\
const data = '''\\
${result.data}
''';
""");
}
