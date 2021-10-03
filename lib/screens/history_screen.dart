import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qrscanner/models/scan.dart';
import 'package:qrscanner/screens/data_screen.dart';
import 'package:qrscanner/widgets/buttons.dart';

const int historySize = 50;

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scan'),
        content: const Text('Are you sure you want to delete this scan for your history?'),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        leading: const FaBackButton(),
      ),
      body: ValueListenableBuilder<Box<Scan>>(
        valueListenable: Hive.box<Scan>('history').listenable(),
        builder: (context, box, _) => ListView(
          children: [
            for (var scan in box.values)
              Dismissible(
                key: Key('${scan.date}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  color: Colors.redAccent,
                  padding: const EdgeInsets.only(right: 10.0),
                  child: const FaIcon(FontAwesomeIcons.trashAlt, color: Colors.white),
                ),
                confirmDismiss: (direction) => _confirmDelete(context),
                onDismissed: (direction) {
                  scan.delete();
                },
                child: ListTile(
                  title: Text(scan.data),
                  subtitle: Text(DateFormat.yMd().add_jm().format(scan.date)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => DataScreen(scan: scan),
                    ));
                  },
                ),
              ),
            if (box.isEmpty)
              ListTile(
                title: Text(
                  'Nothing scanned yet.',
                  style: Theme.of(context).textTheme.caption,
                ),
              )
            else if (box.length == historySize)
              ListTile(
                title: Text(
                  'History only stores the $historySize most recent scans.',
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
