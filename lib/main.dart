import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: const HomeScreen(title: 'Shopping List'),
    );
  }
}

class Item {
  String name;
  bool sold;
  int quantity;
  String note;
  String category;

  Item(
    this.name,
    this.sold, {
    this.quantity = 1,
    this.note = '',
    this.category = 'Food',
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Item> items = [
    Item('Milk', false, category: 'Drinks'),
    Item('Bread', false),
    Item('Rice', false),
  ];

  final controller = TextEditingController();

  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Type an item first')));
      return;
    }

    final matches = items.where(
      (item) => item.name.trim().toLowerCase() == text.toLowerCase(),
    );

    if (matches.isNotEmpty) {
      final existing = matches.first;

      setState(() {
        existing.quantity++;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${existing.name} is already on the list: '
              'now ×${existing.quantity}',
            ),
          ),
        );
    } else {
      setState(() {
        items.add(Item(text, false));
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$text added')));
    }
    controller.clear();
  }

  void deleteItem(Item item) {

    final position = items.indexOf(item);
    if (position == -1) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    setState(() {
      items.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              items.insert(position, item);
            });
          },
        ),
      ),
    );
  }

  void editItem(int index) {
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void markSold(int index) {
    var item = items.elementAt(index);
    setState(() {
      item.sold = !item.sold;
    });
  }

  void changeQuantity(Item item, int change) {
    setState(() {
      if (change > 0) {
        item.quantity++;
      } else if (item.quantity > 1) {
        item.quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 180, 255, 240),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Color.fromARGB(255, 6, 64, 255)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Add an item',
                focusColor: Colors.white,
              ),
              onSubmitted: (_) => addItem(),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'List is empty',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: const Icon(Icons.shopping_basket),
                        title: Text(
                          item.name,
                          style: items[index].sold
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.red,
                                )
                              : TextStyle(decoration: TextDecoration.none),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Decrease quantity',
                              onPressed: () => changeQuantity(item, -1),
                              icon: const Icon(Icons.remove),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              tooltip: 'Increase quantity',
                              onPressed: () => changeQuantity(item, 1),
                              icon: const Icon(Icons.add),
                            ),

                            IconButton(
                              onPressed: () => deleteItem(item),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                        onTap: () => markSold(index),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
