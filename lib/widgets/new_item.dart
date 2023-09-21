import 'package:flutter/material.dart';

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
                return 'Invalid..';
              },
            ), // instead of TextField()
            Row(
              children: [
                TextFormField(),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
