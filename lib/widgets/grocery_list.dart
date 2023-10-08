import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
// import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({Key? key}) : super(key: key);

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  // var _isLoading = true;
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
      'flutter-shopping-list-dacf0-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    // print(response.statusCode);
    // print(response.body);

    // try {
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      // setState(() {
      //   _error = 'Failed to fetch data. Please try again later!';
      // });
      // Throw exception to reject the future produced by async automatically
      throw Exception('Failed to fetch data. Please try again later!');
    }

    // Firebase returns string null if no data is present
    if (response.body == 'null') {
      // setState(() {
      //   _isLoading = false;
      // });
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    return loadedItems;

    // setState(() {
    //   _groceryItems = loadedItems;
    //   _isLoading = false;
    // });
    // } catch (error) {
    //   setState(() {
    //     _error = 'Something went wrong. Please try again later!';
    //   });
    // }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });

    // _loadItems();
  }

  // for deletion we don't need to use async-await as the deletion is done in the background
  // and we don't need to wait for this request to finish to update my local list
  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    // deleting a specific item using Firebase-Id in the shopping list
    // ${} injection syntax
    final url = Uri.https(
      'flutter-shopping-list-dacf0-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url);
    // Optional: Show Error Meassage using SnackBar or something.
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget content = const Center(
    //   child: Text('No items added yet!'),
    // );

    // if (_isLoading) {
    //   content = const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    if (_groceryItems.isNotEmpty) {
      // content = ListView.builder(
      //   itemCount: _groceryItems.length,
      //   itemBuilder: (ctx, index) => Dismissible(
      //     onDismissed: (direction) => _removeItem(_groceryItems[index]),
      //     key: ValueKey(_groceryItems[index].id),
      //     child: ListTile(
      //       title: Text(_groceryItems[index].name),
      //       leading: Container(
      //         width: 24,
      //         height: 24,
      //         color: _groceryItems[index].category.color,
      //       ),
      //       trailing: Text(
      //         '${_groceryItems[index].quantity}',
      //       ),
      //     ),
      //   ),
      // );
    }

    // if (_error != null) {
    //   content = Center(
    //     child: Text(_error!),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      // body: content,
      // FutureBuilder needs a future to which it listens and
      // builder that wants a function that will be executed whenever the future produces data
      // FutureBuilder is not good for this app
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // When exception is thrown hasError will be true
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          List<dynamic> dataList = [];
          if (snapshot.data == null) {
            // Handle the case where snapshot.data is null
            return const Center(
              child: Text('No items added yet!'),
            );
          } else if (snapshot.data is List) {
            dataList = snapshot.data as List<dynamic>;
            if (dataList.isEmpty) {
              // Handle the case where snapshot.data is an empty list
              return const Center(
                child: Text('No items added yet!'),
              );
            }
          }
          print(dataList);
          // Handle the case where snapshot.data is a non-empty list
          // putting dataList in place of _groceryItems
          return ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (ctx, index) => Dismissible(
              onDismissed: (direction) => _removeItem(dataList[index]),
              key: ValueKey(dataList[index].id),
              child: ListTile(
                title: Text(dataList[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: dataList[index].category.color,
                ),
                trailing: Text(
                  '${dataList[index].quantity}',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
