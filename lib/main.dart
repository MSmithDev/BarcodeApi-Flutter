import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<String> _getBarcode(String code) async {
    var response = await http.get('http://barcodeapi.org/api/A_Barcode');
    if (response.statusCode == 200) {
      // OK
      //print(response.body);
      return response.body;
    }
    else {
      throw Exception('failed to fetch');
    }
  }

//Text controllers
  final inputController = TextEditingController();

//

  String codeImage = 'Try Me!';

  final Widget svgLogo = Container(
    height: 40,
    alignment: Alignment.centerLeft,
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

        leading: Icon(
          Icons.open_in_browser,
          color: Colors.black,
          size: 50.0,
        ),
        actions: [
          Icon(
            Icons.camera,
            color: Colors.black,
            size: 50.0,
          ),

        ],

      ),
      body: Column(

        children: [

          Center(
            child: TextField(
              decoration: InputDecoration(

                  hintText: 'Try Me!'
              ),
              textAlign: TextAlign.center,
              controller: inputController,
              onChanged: (String value) async {
                print('Value: $value');
                if (value != '') {
                  codeImage = value;
                }
                else {
                  codeImage = 'Try Me!';
                }
                //codeImage = await _getBarcode(value);
                setState(() {

                });
              },
            ),
          ),
          Padding(padding: EdgeInsets.all(20),),
          Center(

            child: Image.network('http://barcodeapi.org/api/$codeImage'),
            // child: FutureBuilder<String>(
            //   future: _getBarcode(),
            //   builder: (BuildContext context, AsyncSnapshot<String> snapshot){
            //     if(snapshot.hasData) {
            //       //todo Display Barcode here
            //       return Text(snapshot.data);
            //     } else if (snapshot.hasError) {
            //       //todo display error picture
            //       return null;
            //     } else {
            //       //todo return loading indicator
            //       return CircularProgressIndicator();
            //     }
            //   },
            // ),

            //child: Text('Rec: $codeImage'),


          ),

        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


}

