import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils.dart';
//models
import '../models/http_exceptions.dart';
//provider

class QCStatus {
  String qcStatusCode;
  String status;

  QCStatus({required this.qcStatusCode, required this.status});
}

class QCStatuss with ChangeNotifier {
  List<QCStatus> qcStatus = [];
  final String? authToken;
  QCStatuss(this.authToken, this.qcStatus);

  String? _selectedItem;
  List<QCStatus> get qcStatuss => qcStatus;
  String? get selected => _selectedItem;

  void setSelectedItem(String s) {
    _selectedItem = s;
  }

  //Load qcStatus
  Future<List<QCStatus>> loadQCStatus() async {
    clear();
    final url = Uri.parse('${Utils.apiBase}/api/get_ValidValues');
    try {
      final res = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": authToken.toString()
          },
          body: json
              .encode({"TableID": "@MIS_MEMOPACKL", "AliasID": "QCStatus"}));
      final result = json.decode(res.body);

      if (res.statusCode >= 400) {
        throw HttpExceptions(message: 'Please Try Again');
      }
      qcStatus = [];
      Map<String, dynamic> listJSon = result;
      for (var item in listJSon['recordsets'][0]) {
        qcStatus.add(
            QCStatus(qcStatusCode: item['FldValue'], status: item['Descr']));
      }
      notifyListeners();
      return qcStatus;
    } catch (err) {
      throw err;
    }
  }

  //Clear QCStatus
  void clear() {
    qcStatus.clear();
    notifyListeners();
  }
}
