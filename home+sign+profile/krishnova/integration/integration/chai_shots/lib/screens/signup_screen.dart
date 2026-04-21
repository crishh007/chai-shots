import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'main_screen.dart';
import '../globals.dart';
import '../language_manager.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _formController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _formController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _bgController.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _logoController.forward());
    Future.delayed(const Duration(milliseconds: 500), () => _formController.forward());
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _formController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    if (_phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.sendOtp(_phoneController.text);
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showOtpBottomSheet(context, _phoneController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: API Unreachable. $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showOtpBottomSheet(BuildContext context, String phoneNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OtpBottomSheet(phoneNumber: phoneNumber),
    );
  }

  void _showTermsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TermsBottomSheet(),
    );
  }

  void _showPrivacyPolicyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PrivacyPolicyBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final lm = LanguageManager.instance;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _bgController,
              child: SizedBox(
                height: screenHeight * 0.45,
                child: Image.asset(
                  'assets/images/image.jpeg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
                ),
              ),
            ),
          ),
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.2, 0.4, 0.6],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.38),

                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: ScaleTransition(
                        scale: CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
                        child: FadeTransition(
                          opacity: _logoController,
                          child: Image.asset(
                            'assets/chai_logo_new.jpg',
                            height: 100,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_cafe, color: Color(0xFFC9A227), size: 100),
                          ),
                        ),
                      ),
                    ),

                    SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOut)),
                      child: FadeTransition(
                        opacity: _formController,
                        child: Text(
                          lm.get('Sign Up'),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Form(
                      key: _formKey,
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("+91", style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                            Container(width: 1, height: 25, color: Colors.white30),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                                decoration: InputDecoration(
                                  hintText: lm.get("Phone number"),
                                  hintStyle: const TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  errorStyle: const TextStyle(height: 0),
                                ),
                                validator: (value) => null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9A227),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text(lm.get("Send OTP"), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text.rich(
                      TextSpan(
                        text: lm.get("By continuing, you accept our "),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        children: [
                          TextSpan(
                            text: lm.get("T&C"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () => _showTermsBottomSheet(context),
                          ),
                          TextSpan(text: " ${lm.get("and")} "),
                          TextSpan(
                            text: lm.get("Privacy Policy"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () => _showPrivacyPolicyBottomSheet(context),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Text(
                  lm.get("Skip"),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TermsBottomSheet extends StatelessWidget {
  const TermsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Terms & Conditions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "TERMS OF USE",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle("A) INTRODUCTION"),
                  _bodyText("Welcome to the mobile application ‘Chai Shots’, owned, operated, managed, and distributed by Chai Shots Private Limited, Plot no. 206, House No.3, Kavuri Hills, Hyderabad, Telangana, India - 500033 IN. Conditioning upon Your acceptance of all terms, conditions, policies and notices stated here."),
                  _bodyText("For the purpose of these Terms, “Content” refers to any and all audio-visual content including videos, short series, trailers, and texts made available through the App."),
                  _sectionTitle("B) ELIGIBILITY & REGISTRATION"),
                  _bodyText("The services offered by the App are intended for individuals who have reached the age of majority. You understand and agree to provide accurate details (mobile number) for creating an account."),
                  _sectionTitle("C) ACCESS OF CONTENT"),
                  _bodyText("Users may stream content on up to two (2) devices simultaneously per Account. Credential sharing or unauthorized access may result in termination."),
                  _sectionTitle("D) FEATURES"),
                  _subTitle("Clap feature"),
                  _bodyText("Allows Users to show appreciation to cast and crew with short notes and monetary contributions. Claps are final and non-refundable."),
                  _sectionTitle("E) ACCESS PLANS"),
                  _bodyText("Users may access Content by subscribing to a Streaming Plan. Streaming Fees, once paid, provide access for a defined Viewing Period."),
                  _sectionTitle("F) PAYMENT"),
                  _bodyText("Content becomes available once Fee is successfully received. App is not responsible for misused information by third-party processors."),
                  _sectionTitle("G) REFUNDS & CANCELLATION"),
                  _bodyText("Refunds are only processed specifically in the event of failure to access Content despite successful payment due to a direct issue with the App. Request must be sent within 72 hours."),
                  _sectionTitle("H) HOLDBACK / RESTRICTIONS"),
                  _bodyText("Users agree not to exploit content, bypass protections, or use the app for unlawful conduct. Capture screens or recordings is strictly prohibited."),
                  _sectionTitle("I) CONTENT & OWNERSHIP"),
                  _bodyText("All rights and title in the App and Content are owned by Chai Shots Private Limited and protected by IP laws."),
                  _sectionTitle("J) SUPPORT & GRIEVANCE"),
                  _bodyText("Grievance Officer: Ms. Nairmalya Suryadevara. Email: nairmalya@chaishots.in. Address: Plot no. 206, House No.3, Kavuri Hills, Hyderabad, Telangana."),
                  _sectionTitle("K) MISCELLANEOUS"),
                  _bodyText("These Terms shall be governed by the laws of India and subject to the exclusive jurisdiction of the courts of Hyderabad."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      ),
    );
  }

  Widget _subTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
      ),
    );
  }

  Widget _bodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
      ),
    );
  }
}

class PrivacyPolicyBottomSheet extends StatelessWidget {
  const PrivacyPolicyBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Privacy Policy",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "PRIVACY POLICY",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Last Updated: 18-09-2025",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _bodyText("Chai Shots Private Limited (“we”, “our”, or “us”) is committed to protecting your privacy and safeguarding your information in compliance with applicable Indian data protection laws."),
                  _sectionTitle("1. Consent"),
                  _bodyText("By registering for or using the Chai Shots App, you expressly consent to the collection, processing, storage, and sharing of your personal data in accordance with this Privacy Policy."),
                  _sectionTitle("2. Information We Collect"),
                  _bodyText("We collect personal information (Name, mobile number, payment details) and automatically collected technical information (IP address, usage patterns)."),
                  _sectionTitle("3. Use of Information"),
                  _bodyText("Used to provide and maintain the App, manage your account, enable content access, process payments, and personalize your experience."),
                  _sectionTitle("4. Data Sharing"),
                  _bodyText("We do not sell your personal data. We share information with trusted third-party providers (Payment Processors, Analytics, CDNs) to ensure App functionality."),
                  _sectionTitle("5. User’s Rights"),
                  _bodyText("You have the right to access, request corrections, or request deletion of your personal information from our systems. Contact: support@chaishots.in."),
                  _sectionTitle("6. Security"),
                  _bodyText("We implement reasonable security practices, including encryption and access controls, to protect your personal data."),
                  _sectionTitle("7. Grievance Officer"),
                  _bodyText("Ms. Nairmalya Suryadevara. Email: nairmalya@chaishots.in. Address: Plot no. 206, House No.3, Kavuri Hills, Hyderabad, Telangana."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      ),
    );
  }
}

class OtpBottomSheet extends StatefulWidget {
  final String phoneNumber;
  const OtpBottomSheet({super.key, required this.phoneNumber});
  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  final ApiService _apiService = ApiService();
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) { setState(() => _secondsRemaining--); } else { _timer?.cancel(); }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) { controller.dispose(); }
    for (var node in _focusNodes) { node.dispose(); }
    super.dispose();
  }

  void _verifyOtp() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 6) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.verifyOtp(widget.phoneNumber, otp);
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_mobile', widget.phoneNumber);
      isAuthenticated = true;
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wrong OTP"), backgroundColor: Colors.red));
    }
  }

  void _resendOtp() async {
    if (_secondsRemaining > 0) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.sendOtp(widget.phoneNumber);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _startTimer();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP Sent Successfully")));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to resend OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(color: Color(0xFF1C1C1E), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
              Text(lm.get("Enter OTP"), style: const TextStyle(color: Colors.white, fontSize: 16)),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(6, (i) => _buildOtpBox(i))),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: _secondsRemaining > 0 
                ? Text("${lm.get("Resend in ")}${_secondsRemaining}s", style: const TextStyle(color: Colors.grey, fontSize: 12))
                : TextButton(onPressed: _resendOtp, child: Text(lm.get("Resend OTP"), style: const TextStyle(color: Color(0xFFC9A227), fontSize: 12))),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A227), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : Text(lm.get("Verify OTP"), style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45, height: 50, margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _controllers[index], focusNode: _focusNodes[index],
        keyboardType: TextInputType.number, textAlign: TextAlign.center, maxLength: 1,
        style: const TextStyle(color: Colors.white, fontSize: 20),
        decoration: InputDecoration(counterText: "", filled: true, fillColor: const Color(0xFF2C2C2E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (v) { if (v.isNotEmpty && index < 5) _focusNodes[index+1].requestFocus(); else if (v.isEmpty && index > 0) _focusNodes[index-1].requestFocus(); },
      ),
    );
  }
}
