import 'package:flutter/material.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:provider/provider.dart';

class DropdownEventBar extends StatefulWidget {
  final String initialEventType;
  final ValueChanged<bool> onEventTypeChanged;

  const DropdownEventBar({
    super.key,
    this.initialEventType = 'Training',
    required this.onEventTypeChanged,
  });

  @override
  _DropdownEventBarState createState() => _DropdownEventBarState();
}

class _DropdownEventBarState extends State<DropdownEventBar> {
  late String _selectedEventType;

  @override
  void initState() {
    super.initState();
    _selectedEventType = widget.initialEventType;
    widget.onEventTypeChanged(_selectedEventType == 'Training');
  }

  @override
  Widget build(BuildContext context) {
    final matchInfoProvider = Provider.of<MatchAdd>(context, listen: false);

    return DropdownButtonFormField<String>(
      value: _selectedEventType,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedEventType = value;

            matchInfoProvider.matchType = value;
          });
          // Notify the parent widget about the change
          widget.onEventTypeChanged(value == 'Training');
        }
      },
      items: ['Training', 'Friendly', 'League', 'Cup'].map((eventType) {
        return DropdownMenuItem(
          value: eventType,
          child: Text(eventType),
        );
      }).toList(),
      decoration: const InputDecoration(labelText: 'Event Type'),
    );
  }
}
