import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils.dart';
//models
import '../models/http_exceptions.dart';
//provider

class RwSta {
  String rwStaCode;
  String status;

  RwSta({required this.rwStaCode, required this.status});
}

class RwStas with ChangeNotifier {
  List<RwSta> rwSta = [];
  final String? authToken;
  RwStas(this.authToken, this.rwSta);

  String? _selectedItem;
  List<RwSta> get rwStas => rwSta;
  String? get selected => _selectedItem;

  void setSelectedItem(String s) {
    _selectedItem = s;
  }

  //Load RwSta
  Future<List<RwSta>> loadRwSta() async {
    clear();
    final url = Uri.parse('${Utils.apiBase}/api/get_ValidValues');
    try {
      final res = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": authToken.toString()
          },
          body: json
              .encode({"TableID": "@MIS_MEMOPACKL", "AliasID": "MIS_RwSta"}));
      final result = json.decode(res.body);

      if (res.statusCode >= 400) {
        throw HttpExceptions(message: 'Please Try Again');
      }
      rwSta = [];
      Map<String, dynamic> listJSon = result;
      for (var item in listJSon['recordsets'][0]) {
        rwSta.add(RwSta(rwStaCode: item['FldValue'], status: item['Descr']));
      }
      notifyListeners();
      return rwSta;
    } catch (err) {
      throw err;
    }
  }

  //Clear RwSta
  void clear() {
    rwSta.clear();
    notifyListeners();
  }
}
