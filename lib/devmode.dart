import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:warp_api/warp_api.dart';

import 'main.dart';

class DevPage extends StatefulWidget {
  DevPageState createState() => DevPageState();
}

class DevPageState extends State<DevPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Developer Menu')),
        body: ListView(padding: EdgeInsets.all(8), children: [
          ListTile(
              title: Text('Sync Stats'),
              trailing: Icon(Icons.chevron_right),
              onTap: _syncStats),
          ListTile(
              title: Text('Reset Scan State'),
              trailing: Icon(Icons.chevron_right),
              onTap: _resetScan),
          ListTile(
              title: Text('Reset App'),
              trailing: Icon(Icons.chevron_right),
              onTap: resetApp),
          ListTile(
              title: Text('Trigger Reorg'),
              trailing: Icon(Icons.chevron_right),
              onTap: _reorg),
          ListTile(
              title: Text('Mark as Synced'),
              trailing: Icon(Icons.chevron_right),
              onTap: _markAsSynced),
          ListTile(
              title: Text('Clear Tx Details'),
              trailing: Icon(Icons.chevron_right),
              onTap: _clearTxDetails),
          ListTile(
              title: Text('Import YFVK'),
              trailing: Icon(Icons.chevron_right),
              onTap: _importYFVK),
          ListTile(
              title: Text('Bind/Unbind from Ledger'),
              trailing: Icon(Icons.chevron_right),
              onTap: _toggleLedgerBinding),
          ListTile(
              title: Text('Revoke Dev mode'),
              trailing: Icon(Icons.chevron_right),
              onTap: _resetDevMode),
        ]));
  }

  void _syncStats() {
    Navigator.of(context).pushNamed('/syncstats');
  }

  void _resetScan() {
    WarpApi.truncateSyncData();
    syncStatus.reset();
  }

  void _reorg() async {
    await syncStatus.reorg();
  }

  void _markAsSynced() {
    WarpApi.skipToLastHeight(active.coin);
  }

  void _clearTxDetails() {
    WarpApi.clearTxDetails(active.coin, active.id);
  }

  Future<void> _importYFVK() async {
    final nameController = TextEditingController();
    final keyController = TextEditingController();
    final formKey = GlobalKey<FormBuilderState>();
    final mq = MediaQuery.of(context);
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
            title: Text("Import YFVK"),
            insetPadding: EdgeInsets.all(64),
            content: FormBuilder(
                key: formKey,
                child: Container(
                  width: mq.size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Account Name'),
                          controller: nameController,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Key'),
                          controller: keyController,
                          minLines: 16,
                          maxLines: null,
                          validator: (k) =>
                              _validateYFVK(nameController.text, k),
                        ),
                      ],
                    ),
                  ),
                )),
            actions: confirmButtons(context, () {
              final form = formKey.currentState!;
              if (form.validate()) Navigator.of(context).pop();
            })));
  }

  String? _validateYFVK(String name, String? key) {
    try {
      WarpApi.importYFVK(active.coin, name, key!);
    } catch (e) {
      return "Invalid key: $e";
    }
    return null;
  }

  void _toggleLedgerBinding() {
    WarpApi.ledgerToggleBinding(active.coin, active.id);
  }

  _resetDevMode() {
    showSnackBar('Dev mode disabled');
    settings.resetDevMode();
  }
}
