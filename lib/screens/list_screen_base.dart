import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:work_log_fit/models/hive_entity.dart';

const themeColor = Color.fromRGBO(15, 59, 42, 1);
const themeColor2 = Color.fromRGBO(80, 200, 120, 1);

abstract class BaseListScreen<T> extends StatefulWidget {
  final String title;
  final String boxName;
  final String emptyList;
  final String button1Name;
  final String button1Icon;
  bool enableDeleteButton;
  bool enableFirstButton;

  BaseListScreen({
    required this.title,
    required this.boxName,
    required this.emptyList,
    this.button1Name = 'Settings',
    this.button1Icon = 'Settings',
    this.enableDeleteButton = true,
    this.enableFirstButton = true,
  });

  @override
  State<BaseListScreen<T>> createState();
}

abstract class BaseListScreenState<T extends HiveEntity>
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
        leading: ClipOval(
          child: Container(
            color: Colors.transparent,
            width: 50.0,
            height: 50.0,
            child: Image.asset(
              item.getImageIcon(),
              fit: BoxFit.cover,
            ),
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

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'Settings':
        return Icons.settings;
      case 'Monitoring':
        return Icons.show_chart;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    int deleteIndex;
    int addIndex;

    if (widget.enableFirstButton && widget.enableDeleteButton) {
      deleteIndex = 1;
      addIndex = 2;
    } else if (!widget.enableFirstButton && widget.enableDeleteButton) {
      deleteIndex = 0;
      addIndex = 1;
    } else {
      deleteIndex = -1;
      addIndex = 0;
    }

    List<Widget> itemList = buildItemList(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: themeColor2)),
      ),
      body: itemList.isEmpty
          ? Center(child: Text(widget.emptyList))
          : ListView(
              children: itemList,
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          if (widget.enableFirstButton)
            BottomNavigationBarItem(
              icon: Icon(_getIconFromString(widget.button1Icon)),
              label: widget.button1Name,
            ),
          if (widget.enableDeleteButton)
            BottomNavigationBarItem(
              icon: Icon(Icons.delete),
              label: 'Delete',
            ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
                backgroundColor: themeColor,
                child: Icon(Icons.add, color: Colors.white)),
            label: 'Add',
          ),
        ],
        onTap: (index) {
          if (index == deleteIndex) {
            setState(() {
              showDelete = !showDelete;
            });
          } else if (index == addIndex) {
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
