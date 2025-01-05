import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:provider/provider.dart';

class SelectAddress extends StatefulWidget {
  const SelectAddress({super.key});

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
          // Retrieve the EventNotifier from the context
          final eventNotifier = Provider.of<MatchAdd>(context, listen: false);

          // Set the selected address details in the notifier
          eventNotifier.address = pickedData.addressName; // Update address
          eventNotifier.addressLat =
              pickedData.latLong.latitude; // Update latitude
          eventNotifier.addressLong =
              pickedData.latLong.longitude; // Update longitude

          // Optionally, pass the address details back to the previous screen
          Navigator.pop(context, {
            'address': pickedData.addressName,
            'lat': pickedData.latLong.latitude,
            'long': pickedData.latLong.longitude,
          });
        },
      ),
    );
  }
}
