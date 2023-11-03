import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

const brightPurple = Color.fromRGBO(60, 0, 128, 1);
const brightPurple2 = Color.fromRGBO(191, 64, 191, 1);

abstract class BaseListScreen<T> extends StatefulWidget {
  final String title;
  final String boxName;
  final String emptyList;

  BaseListScreen(
      {required this.title, required this.boxName, required this.emptyList});

  @override
  State<BaseListScreen<T>> createState();
}

abstract class BaseListScreenState<T extends HiveObject>
    extends State<BaseListScreen<T>> {
  List<T> baseItemList = [];
  late Box<dynamic> baseItemBox;
  bool showDelete = false;

  // to be overriden
  void itemSelected(BuildContext context, T item);
  String getItemString(T item);

  @override
  void initState() {
    super.initState();
    _initializeBoxAndLoadItems();
  }

  void _initializeBoxAndLoadItems() async {
    var box = await Hive.openBox(widget.boxName);
    var items = await loadItems(box);
    setState(() {
      baseItemBox = box;
      baseItemList = items;
    });
  }

  @override
  Future<List<T>> loadItems(Box<dynamic> box) async {
    return box.values.cast<T>().toList().reversed.toList();
  }

  void addItem(T item) {
    baseItemBox.add(item);
    setState(() {
      baseItemList.insert(0, item);
    });
  }

  void _deleteItem(T item) {
    baseItemBox.delete(item.key);
    setState(() {
      baseItemList.remove(item);
    });
  }

  @override
  T? createItem(String name) {
    return null;
  }

  @override
  void showAddItemDialog(BuildContext context) {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Program'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Program Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('ADD'),
              onPressed: () {
                if (_textFieldController.text.isNotEmpty) {
                  T? item = createItem(_textFieldController.text);
                  if (item != null) {
                    addItem(item);
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> buildItemList(BuildContext context) {
    return baseItemList.map((item) {
      int index = baseItemList.indexOf(item);
      return ListTile(
        leading: Container(
          color: Theme.of(context).canvasColor,
          child: Image.asset(
            'assets/program_icon.png',
            width: 50.0,
            height: 50.0,
          ),
        ),
        title: Text(getItemString(item)),
        trailing: showDelete
            ? IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteItem(item),
              )
            : null,
        onTap: () {
          if (!showDelete) {
            itemSelected(context, item);
          }
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> itemList = buildItemList(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: itemList.isEmpty
          ? Center(child: Text(widget.emptyList))
          : ListView(
              children: itemList,
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Delete',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
                backgroundColor: brightPurple,
                child: Icon(Icons.add, color: Colors.white)),
            label: 'Add',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            // Toggle delete button visibility
            setState(() {
              showDelete = !showDelete;
            });
          } else if (index == 2) {
            // Show add dialog
            showAddItemDialog(context);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    baseItemBox.close(); // Don't forget to close the Hive box
    super.dispose();
  }
}
