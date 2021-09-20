import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

const int historySize = 50;

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key, required this.prefs}) : super(key: key);

  final SharedPreferences prefs;

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
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
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
    final scans = prefs.getStringList('scans')!;
    final dates = prefs.getStringList('dates')!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView(
        children: [
          for (int i = 0; i < scans.length; i++)
            Dismissible(
              key: Key(dates[i]),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                color: Colors.red,
                padding: const EdgeInsets.only(right: 10.0),
                child: const Icon(MdiIcons.trashCanOutline, color: Colors.white, size: 28.0),
              ),
              confirmDismiss: (direction) => _confirmDelete(context),
              onDismissed: (direction) {
                scans.removeAt(i);
                dates.removeAt(i);
                prefs.setStringList('scans', scans);
                prefs.setStringList('dates', dates);
              },
              child: ListTile(
                title: Text(scans[i]),
                subtitle: Text(DateFormat.yMd().add_jm().format(DateTime.parse(dates[i]))),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => DataScreen(data: scans[i], date: DateTime.parse(dates[i])),
                  ));
                },
              ),
            ),
          if (scans.isEmpty)
            ListTile(
              title: Text(
                'Nothing scanned yet.',
                style: Theme.of(context).textTheme.caption,
              ),
            )
          else if (scans.length == historySize)
            ListTile(
              title: Text(
                'History only stores the $historySize most recent scans.',
                style: Theme.of(context).textTheme.caption,
              ),
            ),
        ],
      ),
    );
  }
}
