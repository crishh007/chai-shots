import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "How it works",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Get full access - save the most with the Annual Super Saver.",
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            const Text(
              "Unlock Everything on Chai Shots",
              style: TextStyle(color: Colors.black, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _bulletPoint("Enjoy 100+ shows, unlimited short episodes, and new releases every week."),
            _bulletPoint("Don't miss the 9PM Live Show - play and win daily."),
            const SizedBox(height: 24),
            const Text(
              "Choose Your Plan (Most users go Annual)",
              style: TextStyle(color: Colors.black, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _bulletPointWithTitle("Annual Super Saver – ₹499/year", "Best value for regular viewers - watch all year at a much lower price."),
            _bulletPointWithTitle("Starter Plan – ₹99/month", "Pay monthly, cancel anytime."),
            const SizedBox(height: 24),
            const Text(
              "Apply Coupons if You Have One",
              style: TextStyle(color: Colors.black, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _bulletPoint("Enter your coupon code at checkout for extra savings."),
            const SizedBox(height: 24),
            const Text(
              "Seamless Access & Full Control",
              style: TextStyle(color: Colors.black, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _bulletPoint("Your plan renews automatically for uninterrupted viewing."),
            _bulletPoint("Cancel anytime - quick and hassle-free."),
          ],
        ),
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletPointWithTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
