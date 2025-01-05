import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchday/pages/normal_pages/event_data.dart';
import 'package:matchday/modal/fixture_add/add_fixture_main.dart';
import 'package:matchday/supabase/notifier/match_add.dart';
import 'package:matchday/supabase/notifier/player_positions_notifier.dart';
import 'package:matchday/supabase/notifier/user_info.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FixturePage extends StatefulWidget {
  const FixturePage({super.key});

  @override
  State<FixturePage> createState() => _FixturePageState();
}

String selectedEvent = '';

void _addFixture(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return AddEventModel();
    },
  );
}

class _FixturePageState extends State<FixturePage> {
  List<dynamic>? fixtureList;

  @override
  void initState() {
    super.initState();
    fetchFixtures();
  }

  Future<void> fetchFixtures() async {
    final userInfo = Provider.of<UserInfo>(context, listen: false);

    final response = await Supabase.instance.client
        .from('fixtures')
        .select()
        .eq('team_code', userInfo.teamCode)
        .order('date', ascending: false);

    setState(() {
      fixtureList = response as List<dynamic>;
    });
  }

  Future<void> _refresh() async {
    await fetchFixtures(); // Re-fetch fixtures when user pulls to refresh
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        SizedBox(height: 10),
        addFixtureButton(),
        listOfFixtures(),
      ],
    );
  }

  Widget listOfFixtures() {
    if (fixtureList == null) {
      return const Center(child: CircularProgressIndicator()); // Loading state
    } else if (fixtureList!.isEmpty) {
      return const Center(child: Text('No fixtures available')); // Empty state
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: fixtureList!.length,
              itemBuilder: (context, index) {
                final event = fixtureList![index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.black, width: 1.0),
                  ),
                  child: ListTile(
                    leading: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Align items to the start
                        children: [
                          const Spacer(),
                          _buildLeadingIcon(event),
                          const Spacer(),

                          // This will display the event date
                          Text(
                            _formatEventDate(
                                event['event_date']), // Formatted date
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                        ]),

                    // match details
                    title:
                        // This will display the event type (name) above the opponent
                        Text(
                      event['Type'], // Event name (type)
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle:
                        // This will display the opponent name
                        Text(
                      event['Opp'], // Opponent name
                      style: const TextStyle(fontSize: 15),
                    ),
                    trailing: Wrap(
                      spacing: 2,
                      children: [
                        // Delete event button
                        IconButton(
                          onPressed: () async {
                            final matchData =
                                Provider.of<MatchAdd>(context, listen: false);

                            // Get selected event and delete it
                            final selectedEvent = event['fixture_ref'];
                            await _deleteFixture(selectedEvent);

                            // Optionally reset match data
                            matchData.resetMatchAdd();
                          },
                          icon: const Icon(Icons.delete_forever),
                          color: Colors.red,
                        ),

                        // View event details button
                        IconButton(
                          onPressed: () {
                            final matchData =
                                Provider.of<MatchAdd>(context, listen: false);

                            // Get the full event data instead of just the reference
                            final selectedEvent =
                                event; // Assuming 'event' contains all necessary data

                            // Update match data with selected event
                            matchData.updateMatchDataFromEvent(selectedEvent);

                            // Update match data with selected event (fixture_ref)
                            matchData.updateFixtureRef(selectedEvent[
                                'fixture_ref']); // Update fixture_ref

                            final playerPositions =
                                Provider.of<PlayerPositionsNotifier>(context,
                                    listen: false);
                            playerPositions.setMatchCode(matchData.matchCode);

                            // Navigate to EventDataPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventDataPage(),
                              ),
                            );
                            print(selectedEvent['fixture_ref']);
                            print(matchData.matchCode);
                          },
                          icon: const Icon(Icons.arrow_forward_ios_outlined),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  Widget _buildLeadingIcon(Map<String, dynamic> event) {
    Color iconColor;

    // Determine the icon color based on the result
    switch (event['final_result']) {
      case 'Win':
        iconColor = Colors.green; // Win color
        break;
      case 'Lost':
        iconColor = Colors.red; // Lost color
        break;
      case 'Draw':
        iconColor = Colors.amber; // Draw color
        break;
      default:
        iconColor = Colors.black; // Default color if no result is found
    }

    // Determine the icon based on event type
    IconData iconData;
    switch (event['Type']) {
      case 'League':
        iconData = Icons.sports_soccer; // League icon
        break;
      case 'Friendly':
        iconData = Icons.handshake; // Friendly match icon
        break;
      case 'Cup':
        iconData = Icons.emoji_events_outlined; // Cup icon
        break;
      case 'Training':
        iconData = Icons.event; // Training icon
        break;
      default:
        iconData = Icons.event; // Default event icon
    }

    return Icon(
      iconData,
      color: iconColor, // Set the icon color based on result
    );
  }

// Example method for "Add Fixture" button
  Widget addFixtureButton() {
    return ElevatedButton(
      onPressed: () => _addFixture(context), // Call _addFixture when pressed
      style: ElevatedButton.styleFrom(
        // Use ElevatedButton.styleFrom to set the button style
        backgroundColor: Colors.green, // Set background color to green
        foregroundColor: Colors.white, // Optional: set text color
        padding: const EdgeInsets.symmetric(
            horizontal: 24.0, vertical: 12.0), // Optional: set padding
        shape: RoundedRectangleBorder(
          // Optional: set button shape
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text('Add Fixture'), // Button text
    );
  }

  Future<void> _deleteFixture(String fixtureRef) async {
    try {
      await Supabase.instance.client
          .from('fixtures')
          .delete()
          .eq('fixture_ref', fixtureRef);
      await _refresh(); // Refresh fixture list after deletion
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting fixture: $error')),
      );
    }
  }

// Method to format the event date from DD/MM/YYYY to the desired format
  String _formatEventDate(String eventDate) {
    // First, we need to parse the date from the format 'DD/MM/YYYY'
    List<String> parts = eventDate.split('/');
    if (parts.length == 3) {
      // Create a DateTime object from the parsed parts
      DateTime dateTime = DateTime(
        int.parse(parts[2]), // Year
        int.parse(parts[1]), // Month
        int.parse(parts[0]), // Day
      );
      // Now format the DateTime object to 'dd MMM' (e.g., '18 Oct')
      return DateFormat('dd MMM').format(dateTime);
    } else {
      throw FormatException('Invalid date format: $eventDate');
    }
  }
}
