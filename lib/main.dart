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
  String filter = 'All';

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

  List<Item> get shownItems {
    if (filter == 'To buy') {
      return items.where((item) => !item.sold).toList();
    }

    if (filter == 'Bought') {
      return items.where((item) => item.sold).toList();
    }

    final toBuy = items.where((item) => !item.sold);
    final bought = items.where((item) => item.sold);

    return [...toBuy, ...bought];
  }

void openDetails(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(item: item),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final shown = shownItems;
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
           const SizedBox(height: 12),
           Wrap(
                  spacing: 8,
                  children: ['All', 'To buy', 'Bought'].map((choice) {
                    return ChoiceChip(
                      label: Text(choice),
                      selected: filter == choice,
                      onSelected: (_) {
                        setState(() {
                          filter = choice;
                        });
                      },
                    );
                  }).toList(),
                ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'List is empty',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : shown.isEmpty
                  ? const Center(
                      child: Text(
                        'Nothing here. ',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ) 
                : ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (context, index) {
                      final item = shown[index];

                      final details = [
                        if (item.category.isNotEmpty) item.category,
                            if (item.note.trim().isNotEmpty)
                              item.note.trim(),
                      ].join(' . ');

                      return ListTile(
                        leading: const Icon(Icons.shopping_basket),
                        title: Text(
                          item.name,
                          style:  
                              TextStyle(
                                  decoration: item.sold
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: item.sold ? Colors.red : null,),
                        ),
                       subtitle: Text(details),
                            onTap: () => markSold(items.indexOf(item)),
                            onLongPress: () => openDetails(item),
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

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.item});

  final Item item;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final nameController = TextEditingController();
  final noteController = TextEditingController();

  String category = 'Food';

  @override
  void initState() {
    super.initState();

    // Fill the fields with the current item values.
    nameController.text = widget.item.name;
    noteController.text = widget.item.note;
    category = widget.item.category;
  }

  void saveDetails() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item name cannot be empty'),
        ),
      );
      return;
    }

    // Only save changes when Save is pressed.
    widget.item.name = name;
    widget.item.note = noteController.text.trim();
    widget.item.category = category;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Item name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'For example, the 1 litre bottle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Food', 'Drinks', 'Home'].map((choice) {
                return ChoiceChip(
                  label: Text(choice),
                  selected: category == choice,
                  onSelected: (_) {
                    setState(() {
                      category = choice;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveDetails,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}