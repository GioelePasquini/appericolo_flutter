import 'package:appericolo_flutter/screens/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'fav_contacts_list_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Location currentLocation = Location();
  Set<Marker> _markers={};


  void getLocation() async{
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc){

      _controller?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        target: LatLng(loc.latitude ?? 0.0,loc.longitude?? 0.0),
        zoom: 12.0,
      )));
      setState(() {
        _markers.add(Marker(markerId: MarkerId('Home'),
            position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)
        ));
      });
    });
  }

  @override
  void initState(){
    super.initState();
    setState(() {
      getLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child:GoogleMap(
          zoomControlsEnabled: false,
          initialCameraPosition:CameraPosition(
            target: LatLng(48.8561, 2.2930),
            zoom: 12.0,
          ),
          onMapCreated: (GoogleMapController controller){
            _controller = controller;
          },
          markers: _markers,
        ) ,
      ),

        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                child: Icon(
                    Icons.logout
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  });
                  FirebaseFirestore.instance.collection("contacts").get().then((snapshot){
                    for (DocumentSnapshot contact in snapshot.docs){
                      contact.reference.delete();
                    }
                  });
                },
                heroTag: null,

              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                child: Icon(
                    Icons.account_circle
                ),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FavContactsListScreen())
                  );
                },
                heroTag: null,

              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                child: Icon(
                    Icons.location_searching
                ),
                onPressed: () {
                  getLocation();
                },
                heroTag: null,
              )
            ]
        )
    );
  }
}