import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, size: 40, color: Color(0xFF6F4E37)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #CS-1234', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Text('Placed on 12 Oct, 10:30 AM'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildStep(context, 'Order Confirmed', 'Your order has been received', true, true),
            _buildStep(context, 'Preparing', 'Your chai is being brewed with love', true, true),
            _buildStep(context, 'Out for Delivery', 'The delivery partner is on the way', false, true),
            _buildStep(context, 'Delivered', 'Enjoy your ChaiShots!', false, false),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Back to Home',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String title, String subtitle, bool isCompleted, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF6F4E37) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            if (showLine)
              Container(
                width: 2,
                height: 50,
                color: isCompleted ? const Color(0xFF6F4E37) : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isCompleted ? Colors.black : Colors.grey)),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
