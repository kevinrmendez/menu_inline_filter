import 'package:flutter/material.dart';
import 'package:menu_inline_filter/menu_inline_filter.dart';
import 'data.dart';

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

  List<Item> items = itemsData;

  List<Item> _filteredItems;
  String _currentCategory;
  String _currentSubCategory;

  @override
  void initState() {
    super.initState();
    _currentCategory = _mainCategories[0];
    _currentSubCategory = _subcategories[0][0];
    _filteredItems = _filterItemsCategory(_currentCategory);
  }

  void _updateCategory(value) {
    setState(() {
      _currentCategory = value;
      _filteredItems = _filterItemsCategory(value);
    });
  }

  void _updateSubCategory(value) {
    setState(() {
      _currentSubCategory = value;
      _filteredItems = _filterItemsSubCategory(_currentSubCategory);
    });
  }

  List<Item> _filterItemsCategory(String category) {
    return items.where((element) => element.category == category).toList();
  }

  List<Item> _filterItemsSubCategory(String subcategory) {
    return items
        .where((element) => element.subcategory == subcategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MenuInlineFilter(
              animationDuration: 500,
              updateCategory: _updateCategory,
              updateSubCategory: _updateSubCategory,
              categories: _mainCategories,
              subcategories: _subcategories,
            ),
            Expanded(
              child: ListView(
                children: _filteredItems
                    .map((e) => ListTile(title: Text(e.name)))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final String category;
  final String subcategory;
  Item({
    @required this.name,
    @required this.category,
    @required this.subcategory,
  });
}
