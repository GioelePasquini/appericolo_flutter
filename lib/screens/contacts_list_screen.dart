import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({Key? key}) : super(key: key);

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsListScreen> {
  List<Contact>? contacts;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContact();
  }

  void getContact() async {
    if (await FlutterContacts.requestPermission()) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      print(contacts);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Contacts List",
            style: TextStyle(color: Colors.blue),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: (contacts) == null
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: contacts!.length,
          itemBuilder: (BuildContext context, int index) {
            Uint8List? image = contacts![index].photo;
            String num = (contacts![index].phones.isNotEmpty) ? (contacts![index].phones.first.number) : "--";
            return ListTile(
                leading: (contacts![index].photo == null)
                    ? const CircleAvatar(child: Icon(Icons.person))
                    : CircleAvatar(backgroundImage: MemoryImage(image!)),
                title: Text(
                    "${contacts![index].name.first} ${contacts![index].name.last}"),
                subtitle: Text(num),
                onTap: () {
                  var name = contacts![index].displayName;
                  var number = contacts![index].phones.first.number.toString();
                  var contact = FavContact(name, number);
                  addFavContact("Are you sure you want to add $name to Favorite contact list?", contact);
                });
          },
        ));
  }
  
  Future<bool> addFavContact(String text,FavContact contact) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(text),
        actions: [
          TextButton(
              child: Text("no", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          TextButton(
              child: Text("yes!", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                _saveContact(contact);
                Navigator.of(context, rootNavigator: true).pop('dialog');
                Navigator.pop(context, true);
              })
        ],
      ),
    );
  }

  _saveContact(FavContact contact) {
    FirebaseFirestore.instance.collection("contacts").add({
      "name" : contact.name,
      "number": contact.number
    });
  }
}

class FavContact {
  String name = "";
  String number = "";

  FavContact(this.name, this.number);
}