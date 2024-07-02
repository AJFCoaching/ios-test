import 'package:flutter/material.dart';
import 'package:matchday/main.dart';
import 'package:matchday/modal/add_fixture.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class SelectAddress extends StatefulWidget {
  const SelectAddress({Key? key}) : super(key: key);

  @override
  State<SelectAddress> createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Address'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: OpenStreetMapSearchAndPick(
          buttonColor: Colors.blue,
          buttonText: 'Set Current Location',
          onPicked: (pickedData) {
            address = (pickedData.addressName);
            addresslat = (pickedData.latLong.latitude);
            addresslong = (pickedData.latLong.longitude);

            print(address);
            print(addresslat);
            print(addresslong);

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AddEventModel()),
            );
            Navigator.pop(context);
          }),
    );
  }
}
