import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressMap extends StatefulWidget {
  @override
  AddressMapState createState() => AddressMapState();
}


class AddressMapState extends State<AddressMap> {
  LocationData _currentPosition;
  String _address;
  GoogleMapController mapController;
  Marker _marker;
  Location location = Location();
  GoogleMapController _controller;
  LatLng _initialcameraposition = LatLng(0.5937, 0.9629);

  // void _onMapCreated(GoogleMapController _cntlr)
  // {
  //   _controller = _cntlr;
  //   location.onLocationChanged.listen((l) {
  //     _controller.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
  //       ),
  //     );
  //   });
  //   showPinOnMap();
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Container(
          color: Colors.blueGrey.withOpacity(.8),
          child: Center(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _initialcameraposition,
                      zoom: 15),
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController _cntlr)
                  {
                    _controller = _cntlr;
                    location.onLocationChanged.listen((l) {
                      _controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
                        ),
                      );
                    });
                  },
                  markers: Set.of((_marker != null)? [_marker] : []),
                  myLocationEnabled: true,
                ),
                SizedBox(
                  height: 3,
                ),
                if (_address != null)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Text(
                            "Address: $_address",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          TextButton(onPressed: (){},
                          child: Text('EDIT',style: TextStyle(
                              color: Colors.orange),
                          )),
                        ],
                      ),
                    ),
                  ),
                SizedBox(
                  height: 3,
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }


   getLoc() async{
    Uint8List imageData = await getMarker();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    updateMarker(imageData);
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    _initialcameraposition = LatLng(_currentPosition.latitude,_currentPosition.longitude);
    location.onLocationChanged.listen((LocationData currentLocation) {
      print("${currentLocation.longitude} : ${currentLocation.longitude}");
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition = LatLng(_currentPosition.latitude,_currentPosition.longitude);
        _getAddress(_currentPosition.latitude, _currentPosition.longitude)
            .then((value) {
          setState(() {
            _address = "${value.first.addressLine}";
          });
        });
      });
    });
  }


  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);

    return add;
  }
  Future<Uint8List> getMarker() async{
    ByteData byteData = await DefaultAssetBundle.of(context).load('resources/pin.png');
    return byteData.buffer.asUint8List();
  }

  void updateMarker(Uint8List imageData) {
    this.setState(() {
      _marker =
        Marker(
          markerId: MarkerId('customIcon'),
          icon: BitmapDescriptor.fromBytes(imageData),
          anchor: Offset(0.5,0.5),
          position: LatLng(_currentPosition.latitude,_currentPosition.longitude),
          zIndex: 2,
          flat: true,
      );
    });
  }
}