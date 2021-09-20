import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({Key? key, required this.data}) : super(key: key);

  final String data;

  void _copyData(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Data copied to clipboard'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
    ));
  }

  void _openURL(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to launch URL'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Scan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyData(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Linkify(
              text: data,
              style: const TextStyle(fontSize: 20.0),
              options: const LinkifyOptions(humanize: false),
              onOpen: (link) => _openURL(context, link.url),
            ),
          ],
        ),
      ),
    );
  }
}
