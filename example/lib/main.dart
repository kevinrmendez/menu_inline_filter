import 'package:flutter/material.dart';
import 'package:menu_inline_filter/menu_inline_filter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Inline Filter example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _mainCategories = ['category1', 'category2', 'category3'];
  List<List<String>> _subcategories = [
    ['subcategory1.1', 'subcategory1.2', 'subcategory1.3'],
    ['subcategory2.1', 'subcategory2.2', 'subcategory3.3'],
    ['subcategory3.1', 'subcategory3.2', 'subcategory3.3'],
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            // height: 50,
            color: Colors.black,
            child: MenuInlineFilter(
              // backgroundColor: Colors.red,
              categories: _mainCategories,
              subcategories: _subcategories,
            ),
          ),
        ],
      ),
    );
  }
}
