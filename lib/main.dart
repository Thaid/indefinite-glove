import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

/// The Indefinite Glove, lets you delete half your contacts at random.
/// Author: https://github.com/Thaid
void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Indefinite Glove',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'The Indefinite Glove'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return inflateView(context);
  }

  _snapContacts() async {
    var permissions = await PermissionHandler()
        .requestPermissions([PermissionGroup.contacts]);

    if (permissions[PermissionGroup.contacts] == PermissionStatus.granted) {
      var contacts = await ContactsService.getContacts();

      if (contacts.isNotEmpty) {
        var half = (contacts.length ~/ 2);
        var rng = new Random();
        var toPurge = new Set<int>();
        while (toPurge.length <= half) {
          toPurge.add(rng.nextInt(contacts.length - 1));
        }
        toPurge.forEach(
            (item) => ContactsService.deleteContact(contacts.elementAt(item)));
      }
    }
  }

  _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure you want to purge your contacts?"),
          content:
              const Text("Half of your contacts will be deleted at random"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: const Text("Yes"),
              onPressed: () {
                _snapContacts();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Scaffold inflateView(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: const Text(
                  "\"The hardest choices require the strongest wills.\"\n\n- Purpleman"),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 8),
              child: FlatButton(
                onPressed: _showWarningDialog,
                child: Image(image: AssetImage("assets/images/the_glove.png")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
