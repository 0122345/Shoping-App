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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Item {
  String name;
  bool sold;
  Item(this.name, this.sold);
}

class _HomeScreenState extends State<HomeScreen> {

  final List<Item> items = [
    Item('Milk', false),
    Item('Bread', false),
    Item('Rice', false),
  ];

  final controller = TextEditingController();

  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Type an item first')));
      return;
    }
    setState(() {
      items.add(Item(text, false));
    });
    controller.clear();
  }

  void deleteItem(index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void editItem(index) {
    setState((){

    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void markSold(index) {
    var item = items.elementAt(index);
    setState(() {
      item.sold = !item.sold;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 164, 215, 236),
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(color: Color.fromARGB(255, 229, 255, 136)))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Add an item',
               ),
              onSubmitted: (_) => addItem(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.shopping_basket),
                  title: Text(
                    items[index].name,
                    style: items[index].sold
                        ? TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red,
                          )
                        : TextStyle(decoration: TextDecoration.none),
                  ),
                  trailing: IconButton(
                    onPressed: () => deleteItem(index),
                    icon: Icon(Icons.delete, color: Colors.red),
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