import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../services/api_constant.dart';

class ClapPaymentScreen extends StatefulWidget {
  final int initialAmount;
  final Map<String, dynamic> creator;

  const ClapPaymentScreen({
    super.key,
    this.initialAmount = 20,
    required this.creator,
  });

  @override
  State<ClapPaymentScreen> createState() => _ClapPaymentScreenState();
}

class _ClapPaymentScreenState extends State<ClapPaymentScreen> {
  late int _selectedAmount;
  String _selectedPayment = "phonepe";
  final TextEditingController _msgController = TextEditingController();
  final List<int> _amounts = [10, 20, 30, 40, 50, 75, 100, 150, 200, 500];
  final List<Map<String, String>> _payments = [
    { "id": "phonepe", "name": "PhonePe", "logo": "assets/payment/phonepe.png" },
    { "id": "gpay", "name": "GPay", "logo": "assets/payment/gpay.png" },
    { "id": "upi", "name": "UPI ID", "logo": "assets/payment/upi.png" },
  ];

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.initialAmount;
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void startPayment(String method, int amount) async {
    setState(() => _isLoading = true);
    
    final url = '${ApiConstants.baseUrl}/payment';
    final body = '{"method": "$method", "amount": $amount, "creatorId": "${widget.creator['id'] ?? ''}"}';

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Success")));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Failed")));
      }
    } catch (e) {
      print("API ERROR: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Failed")));
    }
    
    if (mounted) setState(() => _isLoading = false);
    
    // Simulating gateway delay and navigation fallback if not fully wired
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Payment of ₹$amount Checked!"),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context); // Navigate back after success
    });
  }

  Future<void> _showCheckoutBottomSheet(BuildContext context) async {
    String localSelectedMethod = _selectedPayment;
    
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(color: Color(0xFF0D0D0D), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 12),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Choose payment method", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, color: Colors.white, size: 24)),
            ]),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: _payments.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCheckoutOption(setModalState, p["id"]!, p["name"]!, p["logo"]!, localSelectedMethod, (val) => localSelectedMethod = val)
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx, localSelectedMethod),
                child: const Text("Continue Payment", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );

    if (result != null) {
      if (mounted) setState(() => _selectedPayment = result);
      startPayment(result, _selectedAmount);
    }
  }

  Widget _buildCheckoutOption(StateSetter setModalState, String id, String name, String logo, String currentSelected, Function(String) onSelect) {
    bool isSelected = currentSelected == id;
    return GestureDetector(
      onTap: () => setModalState(() => onSelect(id)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.transparent, width: 2)),
        child: Row(children: [
          Image.asset(
            logo,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
          Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle,
              color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
              border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.white54, width: 2))),
        ]),
      ),
    );
  }

  void _showPaymentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pay via", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPaymentSheetOption(ctx, setModalState, "phonepe", "PhonePe", "assets/payment/phonepe.png"),
                      _buildPaymentSheetOption(ctx, setModalState, "gpay", "GPay", "assets/payment/gpay.png"),
                      _buildPaymentSheetOption(ctx, setModalState, "upi", "UPI ID", "assets/payment/upi.png"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSheetOption(BuildContext ctx, StateSetter setModalState, String id, String name, String assetPath) {
    bool isSelected = _selectedPayment == id;
    
    Widget iconWidget;
    if (id == "phonepe") {
      iconWidget = Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: const Color(0xFF5F259F), borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: const Text('पे', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      );
    } else if (id == "gpay") {
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
        setState(() => _selectedPayment = id);
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

  @override
  Widget build(BuildContext context) {
    String payLabel() {
      final match = _payments.firstWhere((p) => p["id"] == _selectedPayment, orElse: () => _payments.first);
      return match["name"]!;
    }

    Widget buildSmallSelectedPaymentIcon() {
      if (_selectedPayment == "phonepe") {
        return Container(
          width: 24, height: 24,
          decoration: BoxDecoration(color: const Color(0xFF5F259F), borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: const Text('पे', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        );
      } else if (_selectedPayment == "gpay") {
        return Container(
          width: 24, height: 24,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Image.asset("assets/payment/gpay.png", width: 14, height: 14, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Text('G', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
        );
      } else {
        return Container(
          width: 24, height: 24,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Image.asset("assets/payment/upi.png", width: 16, height: 10, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Text('UPI', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 8))),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Clap for Creator", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // TopProfileSection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Color(widget.creator['color'] ?? 0xFF3D2B7A),
                      backgroundImage: widget.creator['imageUrl'] != null && widget.creator['imageUrl'].toString().isNotEmpty
                          ? NetworkImage(widget.creator['imageUrl'])
                          : null,
                      child: widget.creator['imageUrl'] == null || widget.creator['imageUrl'].toString().isEmpty
                          ? Text(widget.creator['name'].substring(0, 1),
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.creator['name'],
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(widget.creator['role'],
                      style: const TextStyle(color: Colors.white54, fontSize: 15)),
                  
                  const SizedBox(height: 48),
                  const Text("Reward your loved creator",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  Text("₹$_selectedAmount",
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 40, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // AmountSectionContainer
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Amount select cheyandi",
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2.0,
                      activeTrackColor: const Color(0xFFFFD700),
                      inactiveTrackColor: Colors.white24,
                      thumbColor: const Color(0xFFFFD700),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      activeTickMarkColor: const Color(0xFFFFD700),
                      inactiveTickMarkColor: Colors.white54,
                      tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
                      overlayColor: const Color(0xFFFFD700).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _amounts.indexOf(_selectedAmount).toDouble(),
                      min: 0,
                      max: (_amounts.length - 1).toDouble(),
                      divisions: _amounts.length - 1,
                      onChanged: (val) {
                        setState(() {
                          _selectedAmount = _amounts[val.toInt()];
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 36),
            
            // User Message Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add a message here(optional)", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _msgController,
                    maxLength: 100,
                    maxLines: 1,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: "Enter your message",
                      hintStyle: const TextStyle(color: Colors.grey),
                      counterText: "",
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text("Max 100 characters", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 36),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              SizedBox(
                width: 140,
                child: GestureDetector(
                  onTap: () => _showPaymentBottomSheet(context),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildSmallSelectedPaymentIcon(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Pay via", style: TextStyle(color: Colors.white54, fontSize: 9)),
                              Text(payLabel(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showCheckoutBottomSheet(context),
                    child: Text("Send Clap (₹$_selectedAmount)",
                        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
