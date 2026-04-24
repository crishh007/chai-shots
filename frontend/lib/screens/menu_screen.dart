import 'package:flutter/material.dart';
import '../widgets/chai_card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return const ChaiCard(
            name: 'Special Chai',
            price: '₹30',
            rating: '4.9',
            imageUrl: '',
          );
        },
      ),
    );
  }
}
