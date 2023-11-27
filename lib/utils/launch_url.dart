import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(String uri) async {
  final url = Uri.parse(uri);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
