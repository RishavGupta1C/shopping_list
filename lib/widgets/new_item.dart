import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

class NewItem extends StatefulWidget {
  const NewItem({Key? key}) : super(key: key);

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
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
                    initialValue: '1',
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.tryParse(value)! <= 0) {
                        return 'Must be valid positive number.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField(items: [
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
                  ], onChanged: (value) {}),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {},
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
