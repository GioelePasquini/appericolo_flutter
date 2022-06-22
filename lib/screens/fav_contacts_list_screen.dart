import 'package:appericolo_flutter/screens/contacts_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavContactsListScreen extends StatefulWidget{

  @override
  _MyFavContactsListState createState() => _MyFavContactsListState();

}

class _MyFavContactsListState extends State<FavContactsListScreen> {
  Widget _buildList(QuerySnapshot<Object?>? snapshot) {
    return ListView.builder(
        itemCount: snapshot!.docs.length,
        itemBuilder: (context, index) {
          final doc = snapshot.docs[index];

          return Dismissible(
            key: Key(doc.id),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text(doc["name"]),
              subtitle: Text(doc["number"]),
              onTap: (){
                deleteDialog( "Are you sure you want to delete ${doc["name"]}?", doc);
              },
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Favorite Contacts List",
            style: TextStyle(color: Colors.blue),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
            StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("contacts")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();
                    return Expanded(
                        child: _buildList(snapshot.data)
                    );
                  }
              ),
              FlatButton(
                  child: Text('Add Contact', style: TextStyle(fontSize: 20.0),),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ContactsListScreen())
                    );}
              ),
            ],
            )
        )
    );
  }

  Future<bool> deleteDialog(String text,QueryDocumentSnapshot<Object?> doc) async {
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
                deleteContact(doc);
                Navigator.of(context, rootNavigator: true).pop('dialog');
              })
        ],
      ),
    );
  }

  deleteContact(QueryDocumentSnapshot<Object?> doc) {
    return FirebaseFirestore.instance.collection("contacts")
        .doc(doc.id)
        .delete();
  }
}

