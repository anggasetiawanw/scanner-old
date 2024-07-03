import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils.dart';
//models
import 'http_exceptions.dart';
//provider

class ErrorLabelFG {
  String cek;
  String label;

  ErrorLabelFG({required this.cek, required this.label});
}

class ErrorLabelFGs {
  List<ErrorLabelFG> errorLabelFG = [];
  final String? authToken;
  ErrorLabelFGs(this.authToken, this.errorLabelFG);

  String? _selectedItem;
  List<ErrorLabelFG> get errorLabelFGs => errorLabelFG;
  String? get selected => _selectedItem;

  void setSelectedItem(String s) {
    _selectedItem = s;
  }

  //Load ErrorLabelFG
  Future<List<ErrorLabelFG>> loadErrorLabelFG(
      String wc, String pallet, String label) async {
    clear();
    final url = Uri.parse('${Utils.apiBase}/api/get_ErrorScanLabelFG');
    try {
      final res = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": authToken.toString()
          },
          body: json.encode({"WC": wc, "Pallet": pallet, "ScanFG": label}));
      final result = json.decode(res.body);

      if (res.statusCode >= 400) {
        throw HttpExceptions(message: 'Please Try Again');
      }
      errorLabelFG = [];
      Map<String, dynamic> listJSon = result;
      for (var item in listJSon['recordsets'][0]) {
        errorLabelFG
            .add(ErrorLabelFG(cek: item['Cek'], label: item['Message']));
      }
      return errorLabelFG;
    } catch (err) {
      throw err;
    }
  }

  //Clear ErrorLabelFG
  void clear() {
    errorLabelFG.clear();
  }
}
