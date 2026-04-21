import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import '../services/api_constant.dart';
import 'how_it_works_screen.dart';
import 'terms_conditions_screen.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});
  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  String _selectedPlan    = "12months";
  String _selectedPayment = "phonepe";
  
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    )..initialize().then((_) {
        _videoController.setVolume(0);
        _videoController.setLooping(true);
        _videoController.play();
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Widget buildPaymentIcon(String type) {
    if (type == "phonepe") {
      return Image.asset("assets/payment/phonepe.png", width: 32, height: 32, fit: BoxFit.contain);
    } else if (type == "gpay") {
      return Image.asset("assets/payment/gpay.png", width: 32, height: 32, fit: BoxFit.contain);
    } else {
      return Image.asset("assets/payment/upi.png", width: 32, height: 32, fit: BoxFit.contain);
    }
  }

  void _showPaymentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(color: Color(0xFF0D0D0D), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Pay via", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, color: Colors.white, size: 24)),
            ]),
            const SizedBox(height: 16),
            // PhonePe
            GestureDetector(
              onTap: () { setState(() => _selectedPayment = "phonepe"); setModalState(() {}); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedPayment == "phonepe" ? const Color(0xFFFFD700) : Colors.transparent, width: 2)),
                child: Row(children: [
                  buildPaymentIcon("phonepe"),
                  const SizedBox(width: 12),
                  const Text("PhonePe", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle,
                      color: _selectedPayment == "phonepe" ? const Color(0xFFFFD700) : Colors.transparent,
                      border: Border.all(color: _selectedPayment == "phonepe" ? const Color(0xFFFFD700) : Colors.white54, width: 2))),
                ]),
              ),
            ),
            // GPay
            GestureDetector(
              onTap: () { setState(() => _selectedPayment = "gpay"); setModalState(() {}); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedPayment == "gpay" ? const Color(0xFFFFD700) : Colors.transparent, width: 2)),
                child: Row(children: [
                  buildPaymentIcon("gpay"),
                  const SizedBox(width: 12),
                  const Text("GPay", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle,
                      color: _selectedPayment == "gpay" ? const Color(0xFFFFD700) : Colors.transparent,
                      border: Border.all(color: _selectedPayment == "gpay" ? const Color(0xFFFFD700) : Colors.white54, width: 2))),
                ]),
              ),
            ),
            // UPI
            GestureDetector(
              onTap: () { setState(() => _selectedPayment = "upi"); setModalState(() {}); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedPayment == "upi" ? const Color(0xFFFFD700) : Colors.transparent, width: 2)),
                child: Row(children: [
                  buildPaymentIcon("upi"),
                  const SizedBox(width: 12),
                  const Text("UPI ID", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle,
                      color: _selectedPayment == "upi" ? const Color(0xFFFFD700) : Colors.transparent,
                      border: Border.all(color: _selectedPayment == "upi" ? const Color(0xFFFFD700) : Colors.white54, width: 2))),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String payLabel() {
      switch (_selectedPayment) {
        case "gpay": return "GPay";
        case "upi":  return "UPI ID";
        default:     return "PhonePe";
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        Expanded(flex: 5, child: Stack(fit: StackFit.expand, children: [
          // Background Video Layer
          if (_videoController.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),
          // Dark Fade Gradient Overlay over Video
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [const Color(0xFF2D1B69).withOpacity(0.5), const Color(0xFF1A0A3D).withOpacity(0.7), Colors.black]))),
          
          const Positioned(top: 80, left: 30,  child: Text("⚡", style: TextStyle(fontSize: 28, color: Color(0xFFFFD700)))),
          const Positioned(top: 60, right: 40, child: Text("⚡", style: TextStyle(fontSize: 22, color: Color(0xFFFFD700)))),
          const Positioned(top: 160, left: 50, child: Text("⚡", style: TextStyle(fontSize: 20, color: Color(0xFFFFD700)))),
          const Positioned(top: 170, right: 30,child: Text("⚡", style: TextStyle(fontSize: 26, color: Color(0xFFFFD700)))),
          const Positioned(top: 120, left: 100,child: Text("📦", style: TextStyle(fontSize: 22, color: Color(0xFFFFD700)))),
          const Positioned(top: 100, right: 90,child: Text("📦", style: TextStyle(fontSize: 20, color: Color(0xFFFFD700)))),
          const Positioned(top: 200, right: 60,child: Text("📦", style: TextStyle(fontSize: 18, color: Color(0xFFFFD700)))),
          Positioned(top: 44, left: 16,
              child: GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22))),
          const Positioned(top: 44, right: 16, child: Icon(Icons.volume_up, color: Colors.white, size: 24)),
          Positioned(bottom: 55, left: 0, right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Unlock All Features",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _featureRow("Access to 100+ Shows"),
                        const SizedBox(height: 10),
                        _featureRow("New Shows Every Week"),
                        const SizedBox(height: 10),
                        _featureRow("Play 9PM Live Show and Win"),
                      ]
                    ),
                  ),
                ],
              )),
        ])),
        Expanded(flex: 4, child: Container(color: Colors.black, padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SingleChildScrollView(
            child: Column(children: [
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _selectedPlan = "12months"),
                child: Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _selectedPlan == "12months" ? const Color(0xFFFFD700) : Colors.transparent, width: 2)),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 20, height: 20,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: _selectedPlan == "12months" ? const Color(0xFFFFD700) : Colors.grey),
                            child: const Icon(Icons.check, color: Colors.black, size: 14)),
                        const SizedBox(width: 8),
                        const Text("12 Months", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 6),
                      const Text("Save ₹689", style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12)),
                      const SizedBox(height: 6),
                      const Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text("₹499", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Text("₹1188", style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
                      ]),
                      const SizedBox(height: 6),
                      const Row(children: [
                        Text("😊", style: TextStyle(fontSize: 12)), SizedBox(width: 4),
                        Text("Just ₹42 /Month", style: TextStyle(color: Colors.white70, fontSize: 11))
                      ]),
                    ]),
                    Positioned(top: -20, right: -8, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(6)),
                        child: const Text("Super Saver", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                  ]),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _selectedPlan = "1month"),
                child: Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _selectedPlan == "1month" ? const Color(0xFFFFD700) : Colors.transparent, width: 2)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 20, height: 20,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: _selectedPlan == "1month" ? const Color(0xFFFFD700) : Colors.grey),
                          child: const Icon(Icons.check, color: Colors.black, size: 14)),
                      const SizedBox(width: 8),
                      const Text("1 Month", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 22),
                    const Text("₹149", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Row(children: [
                      Text("😊", style: TextStyle(fontSize: 12)), SizedBox(width: 4),
                      Text("Starter Plan", style: TextStyle(color: Colors.white70, fontSize: 11))
                    ]),
                  ]),
                ),
              )),
            ]),
            const SizedBox(height: 20),
            
            // 🎫 HAVE A COUPON CODE? (Moved higher up)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.confirmation_number_outlined, color: Color(0xFFFFD700), size: 14),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: const CouponSheet(),
                    ),
                  );
                },
                child: const Text("Have a coupon code?", 
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
              ),
            ]),
            
            const SizedBox(height: 20),
            
            // 💳 PAYMENT AND SUBSCRIBE ROW
            Row(children: [
              // PAY VIA PHONEPE BUTTON
              GestureDetector(
                onTap: () => _showPaymentBottomSheet(context),
                child: Container(
                  width: 110, height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5)),
                  child: Row(
                    children: [
                      buildPaymentIcon(_selectedPayment),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Text("Pay via", style: TextStyle(color: Colors.white54, fontSize: 9)),
                          Text(payLabel(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 10),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // SUBSCRIBE BUTTON
              Expanded(child: GestureDetector(
                onTap: () async {
                  // Simulate Subscribe API
                  final url = '${ApiConstants.baseUrl}/subscription';
                  final body = '{"plan": "$_selectedPlan", "payment": "${payLabel()}"}';
                  try {
                    final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: body).timeout(const Duration(seconds: 10));
                    if (response.statusCode == 200 || response.statusCode == 201) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Success")));
                    } else {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Failed")));
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Failed")));
                  }
                },
                child: Container(height: 65,
                    decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(15)),
                    child: const Center(child: Text("Subscribe",
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)))),
              )),
            ]),
            
            const SizedBox(height: 16),
            
            // 🔄 AUTO-RENEWAL TEXT
            const Text("Auto-renewal. Cancel anytime.", style: TextStyle(color: Colors.white38, fontSize: 11)),
            
            const SizedBox(height: 4),
            
            // 📑 TERMS LINKS
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HowItWorksScreen())),
                  child: const Text("How it works", style: TextStyle(color: Colors.white54, fontSize: 10, decoration: TextDecoration.underline))),
              const SizedBox(width: 20),
              GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsScreen())),
                  child: const Text("Terms & Conditions", style: TextStyle(color: Colors.white54, fontSize: 10, decoration: TextDecoration.underline))),
            ]),
            const SizedBox(height: 16),
          ]),
          ),
        )),
      ]),
    );
  }

  Widget _featureRow(String text) {
    return Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
      const Icon(Icons.check, color: Colors.yellow, size: 20),
      const SizedBox(width: 12),
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
    ]);
  }
}

class CouponSheet extends StatefulWidget {
  const CouponSheet({super.key});

  @override
  State<CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends State<CouponSheet> {
  String coupon = "";

  bool _isLoading = false;

  void applyCoupon() async {
    setState(() => _isLoading = true);
    
    final url = '${ApiConstants.baseUrl}/coupon/apply';
    final body = '{"coupon": "$coupon"}';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      print("API URL: $url");
      print("REQUEST: $body");
      print("RESPONSE: ${response.body}");
      print("STATUS CODE: ${response.statusCode}");
      
      try {
        print("Parsed Data: ${json.decode(response.body)}");
      } catch (_) {}

      if (response.statusCode == 200) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Success")));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Failed")));
      }
    } catch (e) {
      print("API ERROR: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Failed")));
    }
    
    if (mounted) setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Offers", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter your Coupon",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {
                      coupon = value.trim();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: coupon.isNotEmpty ? applyCoupon : null,
                style: TextButton.styleFrom(
                  backgroundColor: coupon.isNotEmpty ? const Color(0xFFFFD700) : Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Apply", style: TextStyle(color: coupon.isNotEmpty ? Colors.black : Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
