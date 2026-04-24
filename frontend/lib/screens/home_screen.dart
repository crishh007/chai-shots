import 'package:flutter/material.dart';
import '../widgets/chai_card.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChaiShots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'What would you like to drink?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6F4E37),
                  ),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search your favorite chai...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Now',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuScreen()),
                    );
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  ChaiCard(
                    name: 'Masala Chai',
                    price: '₹20',
                    rating: '4.8',
                    imageUrl: 'https://placeholder.com/chai1',
                  ),
                  ChaiCard(
                    name: 'Ginger Tea',
                    price: '₹25',
                    rating: '4.5',
                    imageUrl: 'https://placeholder.com/chai2',
                  ),
                  ChaiCard(
                    name: 'Elaichi Chai',
                    price: '₹25',
                    rating: '4.7',
                    imageUrl: 'https://placeholder.com/chai3',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
