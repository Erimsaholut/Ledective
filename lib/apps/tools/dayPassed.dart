import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayPassed extends StatelessWidget {
  final int day;

  Future<int> takeArguments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? firstOpenDay = prefs.getInt('firstOpenDay');
    final int? firstOpenMonth = prefs.getInt('firstOpenMonth');
    final int? firstOpenYear = prefs.getInt('firstOpenYear');

    if (firstOpenDay != null && firstOpenMonth != null && firstOpenYear != null) {
      final DateTime firstOpenDate = DateTime(firstOpenYear, firstOpenMonth, firstOpenDay);
      final DateTime currentDate = DateTime.now();
      final int daysPassed = currentDate.difference(firstOpenDate).inDays;
      return daysPassed + day;
    } else {
      return day;
    }
  }

  const DayPassed({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: takeArguments(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final int totalDays = snapshot.data!;
          return Column(
            children: [
              Center(
                child: Text(
                  "$totalDays gün önce",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        } else if (snapshot.hasError) {
          // Hata durumu için işlemler yapılabilir
          return Text('Hata oluştu: ${snapshot.error}');
        } else {
          // Veri henüz gelmediği durumda gösterilecek yüklenme animasyonu veya widget'ı
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
