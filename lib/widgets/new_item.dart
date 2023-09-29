import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http; // Functionalities bundled as 'http'

class NewItem extends StatefulWidget {
  const NewItem({Key? key}) : super(key: key);

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  // <> is called state annotation which provides extra type checking and auto-complete suggestions.
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _saveitem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
        'flutter-shopping-list-dacf0-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      // Second way to work with Futures using async and await
      // Using await dart adds then() method behind the scenes
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // How the data will be formatted
        },
        // encode converts data to json-formatted text
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
          },
        ),
      );
      /*.then((response) { // First way to work with futures
        // work with the response
      })*/

      // print(response.body);
      // print(response.statusCode);

      // To get the Firebase Id
      final Map<String, dynamic> resData = json.decode(response.body);

      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );

      // Navigator.of(context).pop(GroceryItem(
      //   id: DateTime.now().toString(),
      //   name: _enteredName,
      //   quantity: _enteredQuantity,
      //   category: _selectedCategory,
      // ));
    }
  }

  // Creating Form to add New Item
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              maxLength: 50,
              decoration: const InputDecoration(
                label: Text('Name'),
              ),
              // Feature in TextFormField and not in TextField
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value.trim().length <= 1 ||
                    value.trim().length > 50) {
                  return 'Must be between 1 and 50 characters.';
                }
                return null;
              },
              onSaved: (value) {
                // if (value == null) {
                //   return;
                // }
                _enteredName = value!;
              },
            ), // instead of TextField()
            Row(
              // To align the children
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  // Without Expanded we will get an error as both Row and TextFormField are unrestricted horizontally
                  child: TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Quantity'),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _enteredQuantity.toString(),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.tryParse(value)! <= 0) {
                        return 'Must be valid positive number.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredQuantity = int.parse(value!);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color),
                                const SizedBox(width: 6),
                                Text(category.value.title)
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value! as Category;
                        });
                      }),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _formKey.currentState!.reset();
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: _saveitem,
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
