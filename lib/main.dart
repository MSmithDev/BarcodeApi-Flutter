import 'dart:io';
import 'dart:typed_data';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcodeapi_flutter/helpers/barcodeMeta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
//Todo check if api is working
  print('getting json string');
  var jstring = await http.read('https://barcodeapi.org/types');
  BarcodeApiTypes meta = new BarcodeApiTypes(jstring);
  List types = meta.getTypes();

  types.forEach((element) {
    print('$element');
  });
  //Grab List of supported

  runApp(MyApp(types));
}

class MyApp extends StatelessWidget {
  List codeTypeList;

  MyApp(List codeTypeList) {
    this.codeTypeList = codeTypeList;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
          codeTypeList: codeTypeList, title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.codeTypeList}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final List codeTypeList;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(codeTypeList);
}

enum ShareMenu { image, text, contents }

class _MyHomePageState extends State<MyHomePage> {
  List codeTypeList;

  _MyHomePageState(List codeTypeList) {
    this.codeTypeList = codeTypeList;
  }

  Future<String> _getBarcode(String code) async {
    var response = await http.get('http://barcodeapi.org/api/A_Barcode');
    if (response.statusCode == 200) {
      // OK
      //print(response.body);
      return response.body;
    } else {
      throw Exception('failed to fetch');
    }
  }

//Text controllers
  final inputController = TextEditingController();

  //
  Uint8List debug;
  String codeImage = 'Try Me!';
  String codeString = '';
  final Widget svgLogo = Container(
    height: 40,
    alignment: Alignment.center,
    margin: EdgeInsets.all(0.0),
    child: SvgPicture.asset('res/barcodeapi-logo.svg'),
  );
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.

        title: svgLogo,
        centerTitle: true,
        backgroundColor: Colors.white,

        leading: IconButton(
          icon: Icon(
            Icons.open_in_browser,
            color: Colors.black,
            size: 50.0,
          ),
          onPressed: () {
            print('todo OPEN SITE');
            _barcodeapiURL();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.camera,
              color: Colors.black,
              size: 50.0,
            ),
            onPressed: () async {
              print('todo CAMERA');
              var temp = await _LaunchCodeReader();
              codeImage = temp.format + '/' + temp.rawContent;
              codeString = temp.rawContent;
              inputController.text = codeString;
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
        child: Column(
          children: [
            Center(
              child: TextField(
                decoration: InputDecoration(hintText: 'Try Me!'),
                textAlign: TextAlign.center,
                controller: inputController,
                onChanged: (String value) async {
                  print('Value: $value');
                  if (value != '') {
                    codeImage = value;
                    var testGet = await http
                        .readBytes('https://barcodeapi.org/api/$codeImage');
                    debug = testGet;
                  } else {
                    debug = await http
                        .readBytes('https://barcodeapi.org/api/Try Me!');
                  }
                  //codeImage = await _getBarcode(value);
                  setState(() {});
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
            ),
            Center(
              child: Builder(builder: (context) {
                if (debug != null) {
                  return Image.memory(debug);
                } else {
                  return Image.network('https://barcodeapi.org/api/Try Me!');
                }
              }),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.save,
                      color: Colors.black,
                      size: 50.0,
                    ),
                    onPressed: () {
                      print('todo SAVE');
                      _saveBarcode(debug);
                    },
                  ),
                  PopupMenuButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.black,
                      size: 50.0,
                    ),
                    onSelected: (selection) {
                      switch (selection) {
                        case ShareMenu.text:
                          {
                            print('share text');
                            Share.share(
                                "https://barcodeapi.org/api/${codeImage}");

                            break;
                          }
                        case ShareMenu.contents:
                          {
                            print('share contents');
                            Share.share("${codeImage}");
                            break;
                          }
                        case ShareMenu.image:
                          {
                            print('share image');
                          }
                      }

                      //Share.
                    },
                    itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<ShareMenu>>[
                      const PopupMenuItem<ShareMenu>(
                        value: ShareMenu.image,
                        child: Text('Image'),
                      ),
                      const PopupMenuItem<ShareMenu>(
                        value: ShareMenu.text,
                        child: Text('Link'),
                      ),
                      const PopupMenuItem<ShareMenu>(
                        value: ShareMenu.contents,
                        child: Text('Contents'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_barcodeapiURL() async {
  const url = 'https://barcodeapi.org/';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_saveBarcode(Uint8List image) async {
  Directory dir = await getExternalStorageDirectory();

  print(dir.path);

  final res = new File(dir.path + '/Pictures/barcodeapi.png')
    ..writeAsBytesSync(image);
//print(res);
}

Future<Barcode> _LaunchCodeReader() async {
  var result = await BarcodeScanner.scan();
  if (result.type.toString() == 'Cancelled') {
    print('was cancled');
  } else {
    Barcode bcode = new Barcode(
        result.type.toString(), result.format.toString(), result.rawContent);
    print(result.type);
    print(result.format);
    print(result.rawContent);
    print(result.formatNote);
    return bcode;
  }
}

class Barcode {
  String type;
  String format;
  String rawContent;

  Barcode(String type, String format, String rawContent) {
    this.type = type;
    this.format = format;
    this.rawContent = rawContent;
  }
}
