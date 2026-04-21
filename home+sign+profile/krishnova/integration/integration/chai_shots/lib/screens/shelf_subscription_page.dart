import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'how_it_works_screen.dart';
import 'terms_conditions_screen.dart';
const Color kYellow = Color(0xFFFFD000);

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _selectedYearly = true;
  bool _isMuted = false;
  String _selectedPayment = 'PhonePe';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Purple gradient background ─────────────────────────────────────
          Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2D0A4E),
                  Color(0xFF1A0A2E),
                  Colors.black,
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // ── Floating decorations ───────────────────────────────────────────
          ..._buildDecorations(context),

          // ── Main scrollable content ────────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              children: [
                _buildTopBar(),
                _buildUnlockSection(),
                const SizedBox(height: 24),
                _buildPlanCards(),
                _buildCouponRow(),
                _buildPaymentButtons(),
                _buildFooter(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _isMuted = !_isMuted),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Unlock Section with Hero Image ─────────────────────────────────────────
  Widget _buildUnlockSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // ✅ Woman hero image
          Image.asset(
            'assets/subscription_hero.png',
            height: 320,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(height: 40),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock All Features',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildFeatureRow('Access to 100+ Shows'),
          _buildFeatureRow('New Shows Every Week'),
          _buildFeatureRow('Play 9PM Live Show and Win'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_rounded, color: kYellow, size: 20),
          const SizedBox(width: 12),
          Text(text,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 15)),
        ],
      ),
    );
  }

  // ── Plan Cards ─────────────────────────────────────────────────────────────
  Widget _buildPlanCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 12 Months
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedYearly = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedYearly ? kYellow : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Super Saver',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 8),
                    const Text('12 Months',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const Text('Save ₹689',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('₹499',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(width: 6),
                        Text('₹1188',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.white38,
                            )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer_rounded,
                              color: Colors.green, size: 12),
                          SizedBox(width: 4),
                          Text('Just ₹42 /Month',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (_selectedYearly)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Icon(Icons.check_circle_rounded,
                            color: kYellow, size: 20),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 1 Month
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedYearly = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_selectedYearly ? kYellow : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    const Text('1 Month',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 24),
                    const Text('₹149',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer_rounded,
                              color: Colors.green, size: 12),
                          SizedBox(width: 4),
                          Text('Starter Plan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (!_selectedYearly)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Icon(Icons.check_circle_rounded,
                            color: kYellow, size: 20),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Coupon Row ─────────────────────────────────────────────────────────────
  Widget _buildCouponRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎟️ ', style: TextStyle(fontSize: 18)),
          GestureDetector(
            onTap: _showCouponDialog,
            child: const Text(
              'Have a coupon code?',
              style: TextStyle(
                color: kYellow,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: kYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment Buttons ────────────────────────────────────────────────────────
  Widget _buildPaymentButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              // PhonePe Selection (Compact)
              GestureDetector(
                onTap: _showPaymentOptions,
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5F259F),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('Pe',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pay via',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 10)),
                          Text(_selectedPayment,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white54, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Subscribe Button (Expanded)
              Expanded(
                child: GestureDetector(
                  onTap: _showSubscribeDialog,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: kYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Subscribe',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Auto-renewal. Cancel anytime.',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HowItWorksScreen()));
            },
            child: const Text('How it works >',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
          ),
          const Text('  |  ',
              style: TextStyle(color: Colors.white24, fontSize: 13)),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsScreen()));
            },
            child: const Text('Terms & Conditions >',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ── Payment Options Bottom Sheet ───────────────────────────────────────────
  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pay via',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            color: Colors.white54, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _paymentOption(setModalState,
                      name: 'PhonePe',
                      icon: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5F259F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text('Pe',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900)),
                        ),
                      )),
                  const SizedBox(height: 12),
                  _paymentOption(setModalState,
                      name: 'GPay',
                      icon: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text('G',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18)),
                        ),
                      )),
                  const SizedBox(height: 12),
                  _paymentOption(setModalState,
                      name: 'UPI ID',
                      icon: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text('UPI',
                              style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11)),
                        ),
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _paymentOption(StateSetter setModalState,
      {required String name, required Widget icon}) {
    final selected = _selectedPayment == name;
    return GestureDetector(
      onTap: () {
        setModalState(() {});
        setState(() => _selectedPayment = name);
        Navigator.pop(context);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? kYellow : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Text(name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kYellow : Colors.white38,
                  width: 2,
                ),
                color: selected ? kYellow : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.black, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Coupon Dialog ──────────────────────────────────────────────────────────
  void _showCouponDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Enter Coupon Code',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter code here',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style:
                ElevatedButton.styleFrom(backgroundColor: kYellow),
            child: const Text('Apply',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Subscribe Dialog ───────────────────────────────────────────────────────
  void _showSubscribeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Subscription',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          _selectedYearly
              ? 'You selected 12 Months plan for ₹499\nPay via $_selectedPayment'
              : 'You selected 1 Month plan for ₹149\nPay via $_selectedPayment',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Subscription successful! 🎉');
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: kYellow),
            child: const Text('Confirm',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg), backgroundColor: Colors.grey[900]),
    );
  }

  // ── Floating Decorations ───────────────────────────────────────────────────
  List<Widget> _buildDecorations(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return [
      Positioned(left: w * 0.04, top: h * 0.08,
          child: Icon(Icons.bolt, color: kYellow.withOpacity(0.7), size: 28)),
      Positioned(left: w * 0.88, top: h * 0.12,
          child: Icon(Icons.bolt, color: kYellow.withOpacity(0.6), size: 24)),
      Positioned(left: w * 0.06, top: h * 0.32,
          child: Icon(Icons.bolt, color: kYellow.withOpacity(0.5), size: 20)),
      Positioned(left: w * 0.88, top: h * 0.35,
          child: Icon(Icons.bolt, color: kYellow.withOpacity(0.6), size: 32)),
      Positioned(left: w * 0.30, top: h * 0.04,
          child: FaIcon(FontAwesomeIcons.crown,
              color: kYellow.withOpacity(0.7), size: 28)),
      Positioned(left: w * 0.04, top: h * 0.20,
          child: FaIcon(FontAwesomeIcons.crown,
              color: kYellow.withOpacity(0.5), size: 22)),
      Positioned(left: w * 0.78, top: h * 0.22,
          child: FaIcon(FontAwesomeIcons.crown,
              color: kYellow.withOpacity(0.6), size: 26)),
      Positioned(left: w * 0.12, top: h * 0.14,
          child: Icon(Icons.movie_creation_outlined,
              color: kYellow.withOpacity(0.5), size: 24)),
      Positioned(left: w * 0.78, top: h * 0.08,
          child: Icon(Icons.movie_creation_outlined,
              color: kYellow.withOpacity(0.4), size: 20)),
      Positioned(left: w * 0.70, top: h * 0.28,
          child: Icon(Icons.movie_creation_outlined,
              color: kYellow.withOpacity(0.5), size: 22)),
    ];
  }
}