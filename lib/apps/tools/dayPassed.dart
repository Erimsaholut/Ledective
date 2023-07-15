import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayPassed extends StatelessWidget {
  final String? customText;
  final int day;

  const DayPassed({Key? key, this.customText, this.day = 0}) : super(key: key);

  Future<String> calculateDisplayText() async {
    if (customText != null) {
      return customText!;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? firstOpenDay = prefs.getInt('firstOpenDay');
    final int? firstOpenMonth = prefs.getInt('firstOpenMonth');
    final int? firstOpenYear = prefs.getInt('firstOpenYear');

    if (firstOpenDay != null && firstOpenMonth != null && firstOpenYear != null) {
      final DateTime firstOpenDate = DateTime(firstOpenYear, firstOpenMonth, firstOpenDay);
      final DateTime currentDate = DateTime.now();
      final int daysPassed = currentDate.difference(firstOpenDate).inDays;
      return (daysPassed + day == 0) ? 'Bugün' : '${daysPassed + day} gün önce';
    } else {
      return 'Bugün';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: calculateDisplayText(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Hata oluştu: ${snapshot.error}');
        } else {
          final String displayText = snapshot.data!;
          return Column(
            children: [
              Center(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        }
      },
    );
  }
}
