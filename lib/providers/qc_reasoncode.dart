import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils.dart';
//models
import '../models/http_exceptions.dart';
//provider

class QCReasonCode {
  String qcReasonCode;
  String status;

  QCReasonCode({required this.qcReasonCode, required this.status});
}

class QCReasonCodes with ChangeNotifier {
  List<QCReasonCode> qcReasonCode = [];
  final String? authToken;
  QCReasonCodes(this.authToken, this.qcReasonCode);

  String? _selectedItem;
  List<QCReasonCode> get qcReasonCodes => qcReasonCode;
  String? get selected => _selectedItem;

  void setSelectedItem(String s) {
    _selectedItem = s;
  }

  //Load qcReasonCode
  Future<List<QCReasonCode>> loadqcReasonCode() async {
    clear();
    final url = Uri.parse('${Utils.apiBase}/api/get_ValidValues');
    try {
      final res = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": authToken.toString()
          },
          body: json.encode(
              {"TableID": "@MIS_MEMOPACKL", "AliasID": "QCReasonCode"}));
      final result = json.decode(res.body);

      if (res.statusCode >= 400) {
        throw HttpExceptions(message: 'Please Try Again');
      }
      qcReasonCode = [];
      Map<String, dynamic> listJSon = result;
      for (var item in listJSon['recordsets'][0]) {
        qcReasonCode.add(QCReasonCode(
            qcReasonCode: item['FldValue'], status: item['Descr']));
      }
      notifyListeners();
      qcReasonCode.removeWhere((item) => item.qcReasonCode == '0');
      return qcReasonCode;
    } catch (err) {
      throw err;
    }
  }

  void removeItem(qcReasonCode) {
    qcReasonCode.removeWhere((item) => item.qcReasonCode == qcReasonCode);
    notifyListeners();
  }

  //Clear qcReasonCode
  void clear() {
    qcReasonCode.clear();
    notifyListeners();
  }
}
