import 'package:http/http.dart' as http;
import 'package:pc_app/main.dart';
import 'dart:convert';

import 'package:pc_app/models/qr_scann_model.dart';
// import 'package:edumarshals/modules/student_attendance_data_model.dart';

//..............repository to call the Attendance Api through Model Structure ............//

class QrFetchDataRepository {
  static const String apiUrl = 'https://pc.anaskhan.site/api/fetch_qr';

  Future<List<QrScannModel>?> FetchQrData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl),
//............. giving AccessToken through Cookie to the GET API.........................//
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': '${PreferencesManager().token}'
          },
          
        
         );
         
      if (response.statusCode == 200) {
        print('api intigrated successfully');
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<QrScannModel> InfoDataList =
            jsonData.map((data) => QrScannModel.fromJson(data)).toList();
        return InfoDataList;
      } else {
        print('Failed to load data. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during API call: $e');
      return null;
    }
  }
}
