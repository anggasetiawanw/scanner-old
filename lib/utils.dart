import 'package:intl/intl.dart';

class Utils {
  static formatPrice(double price) => '\$ ${price.toStringAsFixed(2)}';
  static formatDate(DateTime date) => DateFormat.yMd().format(date);
  // static String apiBase = 'https://114.119.191.126:50000';
  //static String apiBase = 'https://diamond-api-test.herokuapp.com';
  static String apiBase = 'http://20.212.64.14';
}
