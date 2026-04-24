import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../language_manager.dart';
import '../services/api_constant.dart';
import 'how_it_works_screen.dart';
import 'terms_conditions_screen.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlan = 0; // 0 = 12 months, 1 = 1 month
  String _selectedPayment = "PhonePe";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HERO BANNER with back button ──
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 340,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1A0A2E),
                        Color(0xFF0A0A14),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Floating icons (crowns, lightning)
                      const Positioned(top: 60, left: 20, child: Text('👑', style: TextStyle(fontSize: 28))),
                      const Positioned(top: 40, right: 30, child: Text('👑', style: TextStyle(fontSize: 22))),
                      const Positioned(top: 100, right: 60, child: Text('⚡', style: TextStyle(fontSize: 20))),
                      const Positioned(top: 80, left: 60, child: Text('⚡', style: TextStyle(fontSize: 18))),
                      const Positioned(bottom: 120, left: 30, child: Text('👑', style: TextStyle(fontSize: 20))),
                      const Positioned(bottom: 130, right: 20, child: Text('⚡', style: TextStyle(fontSize: 24))),
                      const Positioned(top: 50, left: 150, child: Text('👑', style: TextStyle(fontSize: 16))),
                      const Positioned(top: 130, right: 100, child: Text('👑', style: TextStyle(fontSize: 14))),
                      // Center avatar placeholder
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 160,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF2A1A4E), Color(0xFF1A0A2E)],
                              ),
                            ),
                            child: Center(
                              child: Image.asset('assets/subscription_hero.png', fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.person, size: 80, color: Colors.white24)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Back button
                Positioned(
                  top: 40,
                  left: 12,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    ),
                  ),
                ),
                // Volume icon
                Positioned(
                  top: 40,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.volume_up, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),

            // ── UNLOCK ALL FEATURES ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                LanguageManager.instance.get('Unlock All Features'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Feature list
            _buildFeatureItem(LanguageManager.instance.get('Access to 100+ Shows')),
            const SizedBox(height: 12),
            _buildFeatureItem(LanguageManager.instance.get('New Shows Every Week')),
            const SizedBox(height: 12),
            _buildFeatureItem('Play 9PM Live Show and Win'),
            const SizedBox(height: 32),

            // ── PRICING CARDS ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                   Expanded(child: _buildPlanCard(
                    index: 0,
                    title: LanguageManager.instance.get('12 Months'),
                    badge: LanguageManager.instance.get('Super Saver'),
                    savings: LanguageManager.instance.get('Save ₹689'),
                    price: '₹499',
                    oldPrice: '₹1188',
                    subtitle: LanguageManager.instance.get('Just ₹42 /Month'),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPlanCard(
                    index: 1,
                    title: LanguageManager.instance.get('1 Month'),
                    badge: null,
                    savings: null,
                    price: '₹149',
                    oldPrice: null,
                    subtitle: LanguageManager.instance.get('Starter Plan'),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── COUPON CODE ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎟️ ', style: TextStyle(fontSize: 18)),
                GestureDetector(
                  onTap: () => _showCouponDialog(),
                  child: Text(
                    LanguageManager.instance.get('Have a coupon code?'),
                    style: TextStyle(
                      color: Colors.purple.shade300,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.purple.shade300,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── PHONEPE + SUBSCRIBE ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Pay via button
                  Expanded(
                    flex: 5,
                    child: GestureDetector(
                      onTap: _showPaymentBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414), // Darker box
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            _buildSelectedPaymentIcon(),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pay via', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                  Text(_selectedPayment, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Subscribe button
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () => _showSubscribeDialog(),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            LanguageManager.instance.get('Subscribe'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── AUTO RENEWAL NOTE ──
            Text(
              LanguageManager.instance.get('Auto-renewal. Cancel anytime.'),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // ── FOOTER LINKS ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HowItWorksScreen()));
                  },
                  child: const Text('How it works ›', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                const Text('|', style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsScreen()));
                  },
                  child: const Text('Terms & Conditions ›', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFFFFD700), size: 24),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    String? badge,
    String? savings,
    required String price,
    String? oldPrice,
    required String subtitle,
  }) {
    final isSelected = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: badge != null ? 24 : 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                if (savings != null) ...[
                  const SizedBox(height: 6),
                  Text(savings, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                ] else ...[
                  const SizedBox(height: 18), // Spacer to align prices horizontally
                ],
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price, style: TextStyle(color: isSelected ? const Color(0xFFFFD700) : Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    if (oldPrice != null) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          oldPrice,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Overlapping Top-Left Checkmark
          if (isSelected)
            Positioned(
              top: -8,
              left: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 16, weight: 800),
              ),
            ),
          // Overlapping Top-Right Badge
          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50), // Green for Super Saver
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedPaymentIcon() {
    if (_selectedPayment == "PhonePe") {
      return Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: const Color(0xFF5F259F), borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: const Text('पे', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      );
    } else if (_selectedPayment == "GPay") {
      return Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Image.asset("assets/payment/gpay.png", width: 24, height: 24, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Text('G', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20))),
      );
    } else {
      // UPI ID
      return Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Image.asset("assets/payment/upi.png", width: 30, height: 20, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Text('UPI', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14))),
      );
    }
  }

  void _showPaymentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(color: Color(0xFF1A1A1E), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 40),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Pay via", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, color: Colors.white, size: 24)),
            ]),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPaymentOption(ctx, setModalState, "PhonePe", "assets/payment/phonepe.png"),
                    _buildPaymentOption(ctx, setModalState, "GPay", "assets/payment/gpay.png"),
                    _buildPaymentOption(ctx, setModalState, "UPI ID", "assets/payment/upi.png"),
                  ],
                ),
              ),
            ),
          ])
        )
      )
    );
  }

  Widget _buildPaymentOption(BuildContext ctx, StateSetter setModalState, String name, String assetPath) {
    bool isSelected = _selectedPayment == name;
    
    Widget iconWidget;
    if (name == "PhonePe") {
      iconWidget = Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: const Color(0xFF5F259F), borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: const Text('पे', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      );
    } else if (name == "GPay") {
      iconWidget = Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Image.asset(assetPath, width: 20, height: 20, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Text('G', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
      );
    } else {
      iconWidget = Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Image.asset(assetPath, width: 24, height: 16, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Text('UPI', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPayment = name);
        setModalState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2E), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.transparent, width: 2)
        ),
        child: Row(children: [
          iconWidget,
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
              border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.white54, width: 2)
            ),
            child: isSelected ? const Icon(Icons.circle, size: 12, color: Colors.black) : null,
          ),
        ])
      )
    );
  }

  void _showSubscribeDialog() {
    String planName = _selectedPlan == 0 ? "12 Months plan for 499" : "1 Month plan for 149";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1E),
        title: const Text("Confirm Subscription", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("You selected $planName\nPay via $_selectedPayment", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subscription Successful!"), backgroundColor: Colors.green));
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  void _showCouponDialog() {
    final TextEditingController couponController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1E),
        title: const Text("Enter Coupon Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: couponController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter code here",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
            onPressed: () async {
              final code = couponController.text.trim();
              if (code.isEmpty) return;
              Navigator.pop(ctx);
              try {
                final url = '${ApiConstants.baseUrl}/coupon/apply';
                final body = '{"coupon": "$code"}';
                final response = await http.post(
                  Uri.parse(url),
                  headers: {'Content-Type': 'application/json'},
                  body: body,
                ).timeout(const Duration(seconds: 10));
                
                if (response.statusCode == 200) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Success! Coupon applied with discount."), backgroundColor: Colors.green));
                } else {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: invalid coupon"), backgroundColor: Colors.red));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: invalid coupon"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Apply", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }
}
