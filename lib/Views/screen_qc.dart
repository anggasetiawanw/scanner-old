import 'package:firts_app/Views/menu_screen.dart';
import 'package:firts_app/providers/qc_reasoncode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils.dart';
import '../models/http_exceptions.dart';
import 'package:http/io_client.dart' as ioClient;

//models
import '../models/transaction_theme.dart';
import '../models/error_label_fg.dart';
import '../models/keyboard_visibility.dart';
//Providers
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/qc_status.dart';
import '../providers/qc_reasoncode.dart';
import '../providers/rwsta.dart';

//Widget
import '../widgets/loading_indicator.dart';

class QCScreen extends StatefulWidget {
  const QCScreen({Key? key}) : super(key: key);
  static const routeName = '/QC-screen';
  @override
  _QCScreenState createState() => _QCScreenState();
}

class _QCScreenState extends State<QCScreen> with WidgetsBindingObserver {
  final _qcFormKey = GlobalKey<FormState>();
  final DateFormat formatDate = DateFormat('dd-MM-yyyy');
  final TransactionTheme transTheme =
      TransactionTheme(color: Colors.indigo, title: 'QC');
  final _qcDescFocusNode = FocusNode();
  final _scanFGFocusNode = FocusNode();
  final _scanPalletFocusNode = FocusNode();
  final TextEditingController _wcTextFieldController = TextEditingController();
  final TextEditingController _scanPalletTextFieldController =
      TextEditingController();
  final TextEditingController _scanFGTextFieldController =
      TextEditingController();
  final TextEditingController _errorTextFieldController =
      TextEditingController();
  final TextEditingController _qcReasonDescTextFieldController =
      TextEditingController();
  final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
  final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
  final VerticalDirection verticalDirection = VerticalDirection.down;
  final EdgeInsetsGeometry padding = EdgeInsets.zero;
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? chosenRwSta = '01';
  String? chosenQCStatus = 'R';
  String? chosenQCReasonCode = '';
  String _currentProgress = 'Loading';
  List<ErrorLabelFG> listErrLabel = [];
  bool isKeyboarVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Show SnackBar
  void showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  @override
  Widget build(BuildContext context) {
    final _scrennWidth = MediaQuery.of(context).size.width;
    //SystemChannels.textInput.invokeMethod('TextInput.hide');
    var cart = Provider.of<Cart>(context);
    RwStas listRwSta = Provider.of<RwStas>(context);
    QCStatuss listQCStatus = Provider.of<QCStatuss>(context);
    QCReasonCodes listQCReasonCode = Provider.of<QCReasonCodes>(context);
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: WillPopScope(
            onWillPop: () {
              cart.clear();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  MenuScreen.routeName, (Route<dynamic> route) => false);
              return Future.value(false);
            },
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                    backgroundColor: transTheme.color,
                    title: Text(
                      transTheme.title,
                      style: Theme.of(context).textTheme.headline3,
                    )),
                body: _isLoading
                    ? Center(
                        child: LoadingIndicator(
                        desc: _currentProgress,
                      ))
                    : Center(child: LayoutBuilder(builder:
                        (BuildContext context,
                            BoxConstraints viewportConstraints) {
                        return Stack(
                            fit: StackFit
                                .expand, // StackFit.expand fixes the issue
                            children: <Widget>[
                              SingleChildScrollView(
                                  //reverse: true,
                                  child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              //minHeight: viewportConstraints.maxHeight,
                                              minHeight:
                                                  _qcDescFocusNode.hasFocus
                                                      ? (isKeyboarVisible
                                                          ? viewportConstraints
                                                              .maxHeight
                                                          : viewportConstraints
                                                              .maxHeight)
                                                      : viewportConstraints
                                                          .maxHeight),
                                          child: Form(
                                              key: _qcFormKey,
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    // Padding(
                                                    //   padding:
                                                    //       const EdgeInsets.symmetric(
                                                    //           vertical: 10),
                                                    //   child: Row(
                                                    //     mainAxisAlignment:
                                                    //         MainAxisAlignment
                                                    //             .spaceBetween,
                                                    //     children: <Widget>[
                                                    //       const Text('Posting Date:'),
                                                    //       Text(formatDate
                                                    //           .format(DateTime.now()))
                                                    //     ],
                                                    //   ),
                                                    // ),
                                                    // Padding(
                                                    //     padding:
                                                    //         const EdgeInsets.symmetric(
                                                    //             vertical: 10),
                                                    //     child: TextFormField(
                                                    //         decoration:
                                                    //             const InputDecoration(
                                                    //                 labelText:
                                                    //                     'Work Center',
                                                    //                 border:
                                                    //                     OutlineInputBorder()),
                                                    //         controller:
                                                    //             _wcTextFieldController
                                                    //               ..text = 'QC-1',
                                                    //         onChanged: (text) => {},
                                                    //         enabled: false)),
                                                    // Padding(
                                                    //     padding:
                                                    //         const EdgeInsets.symmetric(
                                                    //             vertical: 10),
                                                    //     child: TextFormField(
                                                    //         maxLength: 7,
                                                    //         autofocus: true,
                                                    //         textInputAction:
                                                    //             TextInputAction.next,
                                                    //         keyboardType:
                                                    //             TextInputType.text,
                                                    //         minLines: 1,
                                                    //         maxLines: 1,
                                                    //         expands: false,
                                                    //         focusNode:
                                                    //             _scanPalletFocusNode,
                                                    //         textAlignVertical:
                                                    //             TextAlignVertical.top,
                                                    //         controller:
                                                    //             _scanPalletTextFieldController,
                                                    //         decoration: InputDecoration(
                                                    //             labelText:
                                                    //                 'Scan Pallet',
                                                    //             border: const OutlineInputBorder(
                                                    //                 borderRadius:
                                                    //                     BorderRadius
                                                    //                         .all(Radius
                                                    //                             .circular(
                                                    //                                 0)),
                                                    //                 gapPadding: 0,
                                                    //                 borderSide:
                                                    //                     BorderSide()),
                                                    //             suffixIcon: IconButton(
                                                    //                 onPressed: () {
                                                    //                   _scanQRPallet();
                                                    //                 },
                                                    //                 icon: const Icon(Icons
                                                    //                     .document_scanner_outlined))),
                                                    //         validator: (value) {
                                                    //           if (value != null) {
                                                    //             return value.length != 7
                                                    //                 ? 'Pallet must be 7 characters'
                                                    //                 : null;
                                                    //           } else if (value ==
                                                    //               null) {
                                                    //             return 'Please enter Pallet';
                                                    //           }
                                                    //         })),
                                                    Padding(
                                                        padding: const EdgeInsets
                                                                .symmetric(
                                                            vertical: 10),
                                                        child: TextFormField(
                                                            // enableInteractiveSelection:
                                                            //     false,
                                                            onChanged: (value) {
                                                              _scanFGChange(
                                                                  value);
                                                            },
                                                            autofocus: true,
                                                            textInputAction:
                                                                TextInputAction
                                                                    .go,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            minLines: 1,
                                                            maxLines: 1,
                                                            expands: false,
                                                            focusNode:
                                                                _scanFGFocusNode,
                                                            onTap: () {
                                                              setState(() {
                                                                SystemChannels
                                                                    .textInput
                                                                    .invokeMethod(
                                                                        'TextInput.hide');
                                                              });
                                                            },
                                                            textAlignVertical:
                                                                TextAlignVertical
                                                                    .top,
                                                            controller:
                                                                _scanFGTextFieldController,
                                                            onFieldSubmitted:
                                                                (value) {
                                                              _scanFGChange(
                                                                  value);
                                                            },
                                                            decoration: InputDecoration(
                                                                labelText: 'Scan FG',
                                                                border: const OutlineInputBorder(),
                                                                suffixIcon: IconButton(
                                                                    onPressed: () {
                                                                      _scanQRFG();
                                                                    },
                                                                    icon: const Icon(Icons.document_scanner_outlined))),
                                                            validator: (value) {
                                                              if (value !=
                                                                  null) {
                                                              } else if (value ==
                                                                  null) {
                                                                return 'Please enter label FG';
                                                              }
                                                            })),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text('Label Fg Scan: ' +
                                                              ((cart.cart
                                                                      .isEmpty)
                                                                  ? '0'
                                                                  : cart.cart
                                                                      .length
                                                                      .toString())),
                                                          IconButton(
                                                            onPressed: () {
                                                              _clearCart();
                                                            },
                                                            icon: const Icon(
                                                                Icons.delete),
                                                            tooltip: 'Clear',
                                                          )
                                                        ]),
                                                    SizedBox(
                                                        height: 80,
                                                        width:
                                                            _scrennWidth - 100,
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                    border: Border
                                                                        .all()),
                                                            child: ListView
                                                                .separated(
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                final item =
                                                                    cart.cart[
                                                                        index];
                                                                return Dismissible(
                                                                    key:
                                                                        UniqueKey(),
                                                                    background:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          right:
                                                                              20),
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      color: Colors
                                                                          .red,
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                    direction:
                                                                        DismissDirection
                                                                            .endToStart,
                                                                    onDismissed:
                                                                        (direction) {
                                                                      cart.removeItem(cart
                                                                          .cart[
                                                                              index]
                                                                          .id);
                                                                    },
                                                                    child: ListTile(
                                                                        tileColor: cart.cart[index].isValid
                                                                            ? Colors
                                                                                .white10
                                                                            : Colors
                                                                                .pinkAccent,
                                                                        title: Text(cart
                                                                            .cart[
                                                                                index]
                                                                            .scanData),
                                                                        trailing: Text(cart
                                                                            .cart[index]
                                                                            .quantity
                                                                            .toString())));
                                                              },
                                                              itemCount: cart
                                                                  .cart.length,
                                                              shrinkWrap: true,
                                                              separatorBuilder:
                                                                  (BuildContext
                                                                              context,
                                                                          int index) =>
                                                                      const Divider(
                                                                thickness: 1,
                                                              ),
                                                            ))),
                                                    // Padding(
                                                    //     padding:
                                                    //         const EdgeInsets.symmetric(
                                                    //             vertical: 10),
                                                    //     child: DropdownButtonFormField<
                                                    //             String>(
                                                    //         isExpanded: true,
                                                    //         items: listQCStatus.qcStatus
                                                    //             .map<
                                                    //                     DropdownMenuItem<
                                                    //                         String>>(
                                                    //                 (item) {
                                                    //           return DropdownMenuItem<
                                                    //                   String>(
                                                    //               value:
                                                    //                   item.qcStatusCode,
                                                    //               child: Text(
                                                    //                   item.status));
                                                    //         }).toList(),
                                                    //         value: chosenQCStatus == ''
                                                    //             ? listQCStatus
                                                    //                 .qcStatus[0]
                                                    //                 .qcStatusCode
                                                    //             : chosenQCStatus,
                                                    //         selectedItemBuilder:
                                                    //             (BuildContext context) {
                                                    //           return listQCStatus
                                                    //               .qcStatus
                                                    //               .map<Widget>((item) {
                                                    //             return Text(
                                                    //                 item.status);
                                                    //           }).toList();
                                                    //         },
                                                    //         onChanged: (val) {
                                                    //           chosenQCStatus = val;
                                                    //           if (val == 'P') {
                                                    //             chosenQCReasonCode =
                                                    //                 '0';
                                                    //           }
                                                    //         },
                                                    //         onSaved: (val) {
                                                    //           chosenQCStatus = val;
                                                    //         },
                                                    //         decoration:
                                                    //             const InputDecoration(
                                                    //                 labelText:
                                                    //                     'QC Status',
                                                    //                 border:
                                                    //                     OutlineInputBorder()),
                                                    //         validator: (value) {
                                                    //           if (value == null) {
                                                    //             return 'Choose a Status';
                                                    //           }
                                                    //         })),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 10),
                                                        child: DropdownButtonFormField<
                                                                String>(
                                                            isExpanded: true,
                                                            items: listRwSta.rwSta.map<
                                                                    DropdownMenuItem<
                                                                        String>>(
                                                                (item) {
                                                              return DropdownMenuItem<
                                                                      String>(
                                                                  value: item
                                                                      .rwStaCode,
                                                                  child: Text(item
                                                                      .status));
                                                            }).toList(),
                                                            value: chosenQCReasonCode ==
                                                                    ''
                                                                ? listRwSta
                                                                    .rwSta[0]
                                                                    .rwStaCode
                                                                : chosenRwSta,
                                                            selectedItemBuilder:
                                                                (BuildContext
                                                                    context) {
                                                              return listRwSta
                                                                  .rwSta
                                                                  .map<Widget>(
                                                                      (item) {
                                                                return Text(item
                                                                    .status);
                                                              }).toList();
                                                            },
                                                            onChanged: (val) {
                                                              chosenRwSta = val;
                                                            },
                                                            onSaved: (val) {
                                                              chosenRwSta = val;
                                                            },
                                                            decoration: const InputDecoration(
                                                                labelText:
                                                                    'QC Rework Status',
                                                                border:
                                                                    OutlineInputBorder()))),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 10),
                                                        child: DropdownButtonFormField<
                                                                String>(
                                                            isExpanded: true,
                                                            items: listQCReasonCode
                                                                .qcReasonCode
                                                                .map<DropdownMenuItem<String>>(
                                                                    (item) {
                                                              return DropdownMenuItem<
                                                                      String>(
                                                                  value: item
                                                                      .qcReasonCode,
                                                                  child: Text(item
                                                                      .status));
                                                            }).toList(),
                                                            value: chosenQCReasonCode == ''
                                                                ? listQCReasonCode
                                                                    .qcReasonCode[
                                                                        0]
                                                                    .qcReasonCode
                                                                : chosenQCReasonCode,
                                                            selectedItemBuilder:
                                                                (BuildContext
                                                                    context) {
                                                              return listQCReasonCode
                                                                  .qcReasonCode
                                                                  .map<Widget>(
                                                                      (item) {
                                                                return Text(item
                                                                    .status);
                                                              }).toList();
                                                            },
                                                            onChanged: (val) {
                                                              chosenQCReasonCode =
                                                                  val;
                                                            },
                                                            onSaved: (val) {
                                                              chosenQCReasonCode =
                                                                  val;
                                                            },
                                                            decoration: const InputDecoration(
                                                                labelText:
                                                                    'QC Reason',
                                                                border:
                                                                    OutlineInputBorder()),
                                                            validator: (value) {
                                                              if (value ==
                                                                  null) {
                                                                return 'Choose a Status';
                                                              }
                                                              if (chosenQCStatus !=
                                                                      'P' &&
                                                                  chosenQCReasonCode ==
                                                                      '0') {
                                                                return 'QC Reason cannot Pass';
                                                              }
                                                            })),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 10),
                                                        child: SizedBox(
                                                            height: 100,
                                                            child:
                                                                TextFormField(
                                                                    onChanged:
                                                                        (value) {},
                                                                    autofocus:
                                                                        true,
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .newline,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .multiline,
                                                                    minLines:
                                                                        null,
                                                                    maxLines:
                                                                        null,
                                                                    expands:
                                                                        true,
                                                                    maxLength:
                                                                        254,
                                                                    focusNode:
                                                                        _qcDescFocusNode,
                                                                    onTap:
                                                                        () {},
                                                                    textAlignVertical:
                                                                        TextAlignVertical
                                                                            .top,
                                                                    controller:
                                                                        _qcReasonDescTextFieldController,
                                                                    onFieldSubmitted:
                                                                        (value) {},
                                                                    decoration: const InputDecoration(
                                                                        labelText:
                                                                            'QC Reason Desc',
                                                                        border:
                                                                            const OutlineInputBorder()),
                                                                    validator:
                                                                        (value) {
                                                                      if (chosenQCReasonCode ==
                                                                              '8' &&
                                                                          chosenQCStatus !=
                                                                              'P') {
                                                                        if (value ==
                                                                            "") {
                                                                          return 'Please enter QC Reason Desc';
                                                                        }
                                                                      }
                                                                    }))),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          // mainAxisSize:
                                                          //     MainAxisSize.max,
                                                          children: <Widget>[
                                                            SizedBox(
                                                              height:
                                                                  _scrennWidth /
                                                                      8,
                                                              width:
                                                                  _scrennWidth /
                                                                          2 -
                                                                      20,
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  _wcTextFieldController
                                                                          .text =
                                                                      'QC-1';
                                                                  _saveQC();
                                                                },
                                                                child: const Text(
                                                                    'Submit'),
                                                                style: ElevatedButton
                                                                    .styleFrom(),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    _scrennWidth /
                                                                        8,
                                                                width:
                                                                    _scrennWidth /
                                                                            2 -
                                                                        20,
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    _wcTextFieldController
                                                                            .text =
                                                                        'QC-1';
                                                                    _fixScanFG();
                                                                  },
                                                                  child: const Text(
                                                                      'Auto Fix Scan QC'),
                                                                  style: ElevatedButton
                                                                      .styleFrom(),
                                                                ))
                                                          ]),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10),
                                                      child: TextFormField(
                                                          controller:
                                                              _errorTextFieldController,
                                                          showCursor: true,
                                                          readOnly: true,
                                                          enableInteractiveSelection:
                                                              false,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                    ),
                                                    const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                              'Powered By Mitra Inti Solusindo'),
                                                        )),
                                                    KeyboardVisibilityBuilder(
                                                        builder: (context,
                                                            child,
                                                            isKeyboardVisible) {
                                                      isKeyboarVisible =
                                                          isKeyboardVisible;
                                                      if (isKeyboardVisible) {
                                                        if (_scanFGFocusNode
                                                            .hasFocus) {
                                                          SystemChannels
                                                              .textInput
                                                              .invokeMethod(
                                                                  'TextInput.hide');
                                                          isKeyboarVisible =
                                                              false;
                                                        }
                                                      }
                                                      return const SizedBox();
                                                    })
                                                  ])))))
                            ]);
                      })),
                bottomNavigationBar: BottomNavigationBar(
                    backgroundColor: transTheme.color,
                    unselectedLabelStyle: const TextStyle(color: Colors.white),
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                          icon: Icon(Icons.book, color: Colors.blue),
                          activeIcon: Icon(Icons.book, color: Colors.amber),
                          label: ('History')),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.clear, color: Colors.blue),
                          activeIcon: Icon(Icons.clear, color: Colors.amber),
                          label: 'Clear')
                    ],
                    currentIndex: _selectedIndex,
                    unselectedItemColor: Colors.cyan,
                    selectedItemColor: Colors.amber[800],
                    onTap: (value) async {
                      setState(() {
                        _selectedIndex = value;
                      });
                      if (value == 1) {
                        bool _confirm = await _showQuestionDialog(
                            'Clear All Scan Label FG?', 'Question');
                        if (_confirm) {
                          cart.clear();
                          _scanFGTextFieldController.text = '';
                          _errorTextFieldController.text = '';
                          chosenQCReasonCode = '';
                          chosenRwSta = '01';
                          _qcReasonDescTextFieldController.text = '';
                        }
                      }
                    }))));
  }

  Future<void> _clearCart() async {
    var cart = Provider.of<Cart>(context, listen: false);
    if (cart.cart.isEmpty) {
      return;
    }
    bool _confirm =
        await _showQuestionDialog('Clear All Scan Label FG?', 'Question');
    if (_confirm) {
      cart.clear();
      _errorTextFieldController.text = '';
    }
  }

  Future<void> _scanQRPallet() async {
    String qrCodeVal = "";
    try {
      if (qrCodeVal == "") {
        qrCodeVal = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.QR);

        if (qrCodeVal == '-1') {
          return;
        }
      }

      print(String.fromCharCodes([0x07]));
      if (qrCodeVal.length == 7) {
        if (_scanPalletTextFieldController.text.contains(qrCodeVal) != true) {
          _scanPalletTextFieldController.text =
              _scanPalletTextFieldController.text + qrCodeVal;
          final val = TextSelection.collapsed(
              offset: _scanPalletTextFieldController.text.length);
          _scanPalletTextFieldController.selection = val;
        }
      } else {
        showSnackBar('Invalid Pallet Lenght!');
      }
    } catch (err) {
      showSnackBar('Please Try Again');
    }
    if (!mounted) {
      return;
    }
  }

  Future<void> _scanQRFG() async {
    String qrCodeVal = "";
    try {
      if (qrCodeVal == "") {
        qrCodeVal = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.QR);

        if (qrCodeVal == '-1') {
          return;
        }
      }
      _scanFGChange(qrCodeVal);
    } on PlatformException {
      qrCodeVal = 'Invalid QR';
      showSnackBar(qrCodeVal);
    } catch (err) {
      showSnackBar('Please Try Again');
    }
    if (!mounted) {
      print(String.fromCharCodes([0x07]));
      return;
    }
  }

  void _addCart(String value) {
    var cart = Provider.of<Cart>(context, listen: false);
    _scanFGTextFieldController.text = "";
    final val =
        TextSelection.collapsed(offset: _scanFGTextFieldController.text.length);
    _scanFGTextFieldController.selection = val;
    if (cart.cart.length == 1) {
      _showMsgDialog('Only 1 Label FG for QC', 'Info');
      _scanFGFocusNode.requestFocus();
      return;
    }
    setState(() {
      if (cart.isDuplicate(value)) {
        _showMsgDialog('You have scanned this item before', 'Duplicate Item');
        _scanFGFocusNode.requestFocus();
        return;
      }
      String quantity = value.substring(
          value.indexOf("#", value.indexOf("#", value.indexOf("#", 3) + 1)) + 1,
          value.indexOf(
              "#",
              value.indexOf(
                  "#", value.indexOf("#", value.indexOf("#", 3) + 1) + 1)));

      cart.add(CartItem(
          id: value,
          quantity: double.parse(quantity),
          scanData: value,
          itemCode: value));
    });

    _scanFGFocusNode.requestFocus();
    return;
  }

  //Save
  Future<void> _saveQC() async {
    var cart = Provider.of<Cart>(context, listen: false);
    String label = '';
    for (var item in cart.cart.toList()) {
      label += item.scanData.toString() + ';\n';
    }

    _qcFormKey.currentState?.save();
    if (!_qcFormKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _currentProgress = 'Saving QC';
    });
    final currentUser = Provider.of<Auth>(context, listen: false);
    final url = Uri.parse('${Utils.apiBase}/api/MemoPackSave');
    try {
      final res = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": currentUser.token.toString()
          },
          body: json.encode({
            "WC": _wcTextFieldController.text,
            "Pallet": '',
            "ScanFG": label,
            "QCStatus": chosenQCStatus,
            "QCReasonCode": int.tryParse(chosenQCReasonCode!),
            "QCReasonDesc": _qcReasonDescTextFieldController.text,
            "USERMB": currentUser.userId,
            "RwSta": chosenRwSta,
            "Version": currentUser.version
          }));
      final resData = json.decode(res.body);
      //Check for response status code >= 400 means error
      if (res.statusCode >= 400) {
        throw HttpExceptions(message: resData['errors'][0]['msg']);
      }
      setState(() {
        _isLoading = false;
      });
      if (resData["recordsets"][0][0]['Cek'] == 0) {
        _showMsgDialog(resData["recordsets"][0][0]["Message"], 'Info');
        _scanPalletTextFieldController.text = '';
        _scanFGTextFieldController.text = '';
        setState(() {
          cart.clear();
        });
        _scanPalletFocusNode.requestFocus();
      } else {
        var errorMessage = 'Error';
        errorMessage = resData["recordsets"][0][0]["Message"].toString();
        _showMsgDialog(errorMessage, 'Error');
        _errorTextFieldController.text =
            resData["recordsets"][0][0]["Cek"].toString() + ' ' + errorMessage;
        _scanFGFocusNode.requestFocus();
      }
    } catch (err) {
      var errorMessage = 'Invalid Credentials';
      errorMessage = err.toString();
      setState(() {
        _isLoading = false;
      });
      _showMsgDialog(errorMessage, 'Error');
    }
    return;
  }

  void _showMsgDialog(String message, String title) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Ok'))
              ],
            ));
  }

  Future<bool> _showQuestionDialog(String message, String title) async {
    return await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text('Ok')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text('Cancel'))
              ],
            ));
  }

  void _scanFGChange(String value) {
    String oldText = value;
    value = value.replaceAll('\n', '');
    oldText = value.replaceAll('#', '').replaceAll(' ', '');
    // if (isNumeric(oldText) != true) {
    //   _scanFGTextFieldController.text = '';
    //   _showMsgDialog(value, 'Invalid Label FG(1)');
    //   return;
    // }
    if (((value).substring(0, 1) == '2') != true) {
      _scanFGTextFieldController.text = '';
      _showMsgDialog(value, 'Invalid Label FG(1)');
      return;
    }
    if ((('#').allMatches(value).length == 6) != true) {
      _scanFGTextFieldController.text = '';
      _showMsgDialog(value, 'Invalid Label FG(2)');
      return;
    }
    if ((value.length - (value.lastIndexOf('#') + 1) == 3) != true) {
      _scanFGTextFieldController.text = '';
      _showMsgDialog(value, 'Invalid Label FG(3)');
      return;
    }
    if ((value.length >= 40) != true) {
      _scanFGTextFieldController.text = '';
      _showMsgDialog(value, 'Invalid Label FG(4)');
      return;
    }
    _addCart(value);

    final val =
        TextSelection.collapsed(offset: _scanFGTextFieldController.text.length);
    _scanFGTextFieldController.selection = val;
    //}
  }

  Future<List<ErrorLabelFG>> _fixScanFG() async {
    var cart = Provider.of<Cart>(context, listen: false);
    String label = '';
    for (var item in cart.cart.toList()) {
      label += item.scanData.toString() + ';\n';
    }
    listErrLabel = [];
    ErrorLabelFGs? errorLabelFGs =
        ErrorLabelFGs(Provider.of<Auth>(context, listen: false).token, []);
    while (listErrLabel.isEmpty) {
      setState(() {
        _isLoading = true;
        _currentProgress = 'Fixing Error QC';
      });
      listErrLabel = await errorLabelFGs.loadErrorLabelFG(
          _wcTextFieldController.text,
          _scanPalletTextFieldController.text,
          label);
    }
    if (listErrLabel.isNotEmpty) {
      if (listErrLabel[0].cek == '0') {
        _showMsgDialog(listErrLabel[0].label, 'Info');
      } else {
        setState(() {
          for (var item in listErrLabel) {
            cart.removeItem(item.label);
          }
        });
        _errorTextFieldController.text = '';
        _showMsgDialog(
            'Finish Fixing Error QC ' + listErrLabel.length.toString(),
            'Finish');
      }
    } else {
      _showMsgDialog('Cant Fix Error', 'Error');
    }
    errorLabelFGs = null;
    setState(() {
      _isLoading = false;
    });
    _scanFGFocusNode.requestFocus();
    return listErrLabel;
  }

  bool isNumeric(String s) {
    if (s is double) {
      return true;
    }
    if (s is int) {
      return true;
    }
    return false;
  }
}
