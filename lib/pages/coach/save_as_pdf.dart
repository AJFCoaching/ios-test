import 'package:flutter/material.dart';
import 'package:matchday/widgets/goal_scorers.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SaveAsPDFPage extends StatelessWidget {
  final Map<String, dynamic> matchStats;

  SaveAsPDFPage({required this.matchStats});

  Future<void> generatePDF(BuildContext context) async {
    // Create a PDF document
    final PdfDocument document = PdfDocument();
    final page = document.pages.add();

    // Add title
    page.graphics.drawString(
      'Match Statistics - ${matchStats['oppTeam'] ?? 'Unknown Team'}',
      PdfStandardFont(PdfFontFamily.helvetica, 18),
      bounds: const Rect.fromLTWH(0, 0, 500, 30),
    );

    // Add date
    page.graphics.drawString(
      'Date: ${matchStats['matchDate'] ?? 'Unknown Date'}',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: const Rect.fromLTWH(0, 30, 500, 20),
    );

    // Add match info
    double yOffset = 60; // Starting y position for match details
    page.graphics.drawString(
      'Pitch Address: ${matchStats['Address'] ?? 'N/A'}',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: Rect.fromLTWH(0, yOffset, 500, 20),
    );
    yOffset += 20;
    page.graphics.drawString(
      'Kick-off Time: ${matchStats['kickOffTime'] ?? 'N/A'}',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: Rect.fromLTWH(0, yOffset, 500, 20),
    );
    yOffset += 20;
    page.graphics.drawString(
      'Match Type: ${matchStats['matchType'] ?? 'Unknown'}',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: Rect.fromLTWH(0, yOffset, 500, 20),
    );

    // Save the PDF to a file
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/MatchStats_${matchStats['oppTeam'] ?? 'Unknown'}.pdf');
    await file.writeAsBytes(await document.save());

    // Dispose of the document
    document.dispose();

    // Notify user about file save
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved at ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Stats'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opposition: ${matchStats['opposition'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Match Date: ${matchStats['matchDate'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    "assets/main_logo.png",
                    height: 50,
                    width: 50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Match Details',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pitch Address: ${matchStats['pitchAddress'] ?? 'N/A'}'),
                  Text('Kick-off Time: ${matchStats['kickOffTime'] ?? 'N/A'}'),
                  Text('Match Type: ${matchStats['matchType'] ?? 'N/A'}'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Match Stats',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(matchStats['teamName'] ?? 'Team A'),
                    Spacer(),
                    Text(matchStats['oppName'] ?? 'Team B'),
                  ]),
                  Text('Pitch Address: ${matchStats['pitchAddress'] ?? 'N/A'}'),
                  Text('Kick-off Time: ${matchStats['kickOffTime'] ?? 'N/A'}'),
                  Text('Match Type: ${matchStats['matchType'] ?? 'N/A'}'),
                ],
              ),
            ),
//            Goalscorers(),
            ..._buildStatBars(matchStats),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                generatePDF(context);
              },
              child: const Text('Save as PDF'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatBars(Map<String, dynamic> stats) {
    final List<Widget> bars = [];

    for (var statEntry in stats.entries) {
      if (statEntry.key.startsWith('stat')) {
        bars.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${statEntry.key.replaceFirst('stat_', '').toUpperCase()}: ${statEntry.value}%',
                style: const TextStyle(fontSize: 14),
              ),
              LinearProgressIndicator(
                value: (statEntry.value as int) / 100,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      }
    }

    return bars;
  }
}
