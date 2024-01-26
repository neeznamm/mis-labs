import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ClothingApp(),
    );
  }
}

class ClothingApp extends StatefulWidget {
  const ClothingApp({Key? key});

  @override
  _ClothingAppState createState() => _ClothingAppState();
}

class _ClothingAppState extends State<ClothingApp> {
  List<List<String>> clothingCategories = [
    ["T-Shirts", "Jeans", "Hats"],
    ["Sneakers", "Dresses", "Jackets"],
    ["Socks", "Shorts", "Scarves"],
  ];

  Map<String, List<String>> clothingItems = {
    "T-Shirts": ["T-Shirt 1", "T-Shirt 2", "T-Shirt 3"],
    "Jeans": ["Jeans 1", "Jeans 2", "Jeans 3"],
    "Hats": ["Hat 1", "Hat 2", "Hat 3"],
    "Sneakers": ["Sneakers 1", "Sneakers 2", "Sneakers 3"],
    "Dresses": ["Dress 1", "Dress 2", "Dress 3"],
    "Jackets": ["Jacket 1", "Jacket 2", "Jacket 3"],
    "Socks": ["Socks 1", "Socks 2", "Socks 3"],
    "Shorts": ["Shorts 1", "Shorts 2", "Shorts 3"],
    "Scarves": ["Scarf 1", "Scarf 2", "Scarf 3"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: clothingCategories.length * clothingCategories[0].length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              int rowIndex = index ~/ 3;
              int colIndex = index % 3;
              return GestureDetector(
                onTap: () {
                  _showClothingItems(clothingCategories[rowIndex][colIndex]);
                },
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.lime,
                  child: Center(
                    child: Text(
                      clothingCategories[rowIndex][colIndex],
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClothingItems(String category) {
    List<String>? items = clothingItems[category];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(category),
          content: Column(
            children: [
              for (String item in items!)
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item,
                        style: const TextStyle(color: Colors.blue),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _showEditDialog(category, item);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              _deleteItem(category, item);
                              Navigator.of(context).pop();
                              _showClothingItems(category);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _showAddDialog(category);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(String category) {
    String itemName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $category'),
          content: TextField(
            onChanged: (value) {
              itemName = value;
            },
            decoration: const InputDecoration(
              labelText: 'Item Name',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (itemName.isNotEmpty) {
                  _addItem(category, itemName);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  _showClothingItems(category);
                }
              },
              child: const Text('Add'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(String category, String itemName) {
    String newName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $category - $itemName'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: const InputDecoration(
              labelText: 'New Name',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (newName.isNotEmpty) {
                  _editItem(category, itemName, newName);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  _showClothingItems(category);
                }
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addItem(String category, String itemName) {
    setState(() {
      clothingItems[category]?.add(itemName);
    });
  }

  void _editItem(String category, String oldName, String newName) {
    setState(() {
      clothingItems[category]?.remove(oldName);
      clothingItems[category]?.add(newName);
    });
  }

  void _deleteItem(String category, String item) {
    setState(() {
      clothingItems[category]?.remove(item);
    });
  }
}
