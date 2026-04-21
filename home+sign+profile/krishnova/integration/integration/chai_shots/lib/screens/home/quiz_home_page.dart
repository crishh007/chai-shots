import 'dart:async';
import 'package:flutter/material.dart';

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  late Timer _timer;
  int _secondsRemaining = 46619; // 12:56:59 in seconds (approx)

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000814),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Help',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Logo & Prize
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFFFD700)),
                color: Colors.black.withOpacity(0.3),
              ),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: 'Prize money: ', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    TextSpan(text: '₹10,000', style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Next Game Timer Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text('Next game starts in', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Hint Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lightbulb, size: 12, color: Colors.black),
                              SizedBox(width: 4),
                              Text('FREE HINT', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Watch to find the hidden answer.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Text('WATCH NOW', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
                          label: const Icon(Icons.arrow_forward, color: Color(0xFFFFD700), size: 16),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Play Quiz Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Play Quiz', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Ee questions ki answer cheppu chudham?', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Movie Quiz Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Movie Quiz', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Test your Tollywood knowledge', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 24),
                  _ruleRow('1', 'Show goes live at 9 PM'),
                  _ruleRow('2', 'Answer 10 movie trivia questions'),
                  _ruleRow('3', 'Get all right to win the prize'),
                  const SizedBox(height: 12),
                  const Center(child: Text('Live every night · Real cash prizes', style: TextStyle(color: Colors.white38, fontSize: 12))),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent Winners Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Winners', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  const Text('More than ₹5 Lakhs in prizes given out', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (_, i) {
                        final names = ['Veeraveni', 'Venkat', 'Lunavath', 'Rammmm'];
                        final initials = ['V', 'V', 'LR', 'R'];
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white10,
                                child: Text(initials[i], style: const TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 10),
                              Text(names[i], style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                              const Text('4 days ago', style: TextStyle(color: Colors.white24, fontSize: 10)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Text('View all winners', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold)),
                      label: const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white60),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer Links
            _footerLink(Icons.info_outline, 'How to play', () => _showGameInstructions(context)),
            _footerLink(Icons.description_outlined, 'Terms & Conditions', () => _showTermsAndConditions(context)),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.circle, color: Colors.green, size: 10),
            const SizedBox(width: 8),
            const Text('Connected', style: TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: Colors.red, size: 8),
                  SizedBox(width: 6),
                  Text('2 waiting', style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ruleRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(radius: 12, backgroundColor: Colors.white10, child: Text(num, style: const TextStyle(color: Colors.white70, fontSize: 12))),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _footerLink(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  void _showGameInstructions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Game Instructions',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _instructionItem('The game has 10 questions.'),
              _instructionItem('Answers cannot be changed after selection.'),
              _instructionItem('One wrong answer disqualifies you from winning.'),
              _instructionItem('Joining after first question makes you a spectator only.'),
              _instructionItem('Answer all 10 questions correctly to win.'),
              _instructionItem('The total prize pool will be announced before the game.'),
              _instructionItem('The prize is shared equally among all winners.'),
              _instructionItem('31.25% tax will be deducted from the prize money.'),
            ],
          ),
        );
      },
    );
  }

  Widget _instructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Icon(Icons.circle, size: 4, color: Colors.white24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Terms & Conditions',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 32),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'graphics, photographs, texts (including comments and scripts), branding (including trade names, trademarks, service marks or logos), software, metrics and other materials made available through the App, whether owned by the Company or licensed from third parties, including without limitation, short series, clips, trailers, promotional videos, or similar content.',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      _tncBullet("For entertainment and recreational purposes only, 'Chai Shots' offers various interactive features and services which are collectively categorised as \"Application Services\" and populated hereinbelow."),
                      _tncBullet("To contact us please write to us at support@chaishots.in."),
                      const SizedBox(height: 24),
                      const Text('• CONTRACT', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _tncBullet("We offer this App and the Application Services including all information, tools and ancilliary services available from this mobile application to You, the user (\"User\" or \"You\" \"Your\") conditioned upon Your acceptance of all terms, conditions, policies and notices stated here (which shall be amended from time to time) within the Territory. For the purposes of the terms, Territory shall mean the entire world including India."),
                      _tncBullet("By downloading, installing, registering on, accessing, or using the App, creating an account (\"Your Account\") within the App, and / or accessing or using our Application Services (described below) in any manner and to any extent, You are agreeing to enter into a legally binding contract with Us and you confirm that you accept these terms of use (hereinafter referred to as \"Terms\") and agree to comply with them."),
                      _tncBullet("You expressly acknowledge that You have read, understood, and agreed to be bound by these Terms, our Privacy Policy available here, and any additional guidelines, rules, terms, or disclaimers posted on the App or otherwise notified to You from time to time (collectively, the \"Agreement\", \"Contract\" or \"ToU\"). We may amend the terms of this Agreement as well as our Privacy Policy from time to time. If we make any material changes to this Agreement, either proactively or in compliance with the mandate of applicable laws and regulations, we will provide you notice thereof and allow you the opportunity to review the changes and render your consent thereto. If you object to any of these changes, you may..."),
                      _tncBullet("If you do not agree to this Agreement, You must stop using or accessing the App. Continued use of any feature or Application Service implies that You accept the Terms, including any changes we may make. Unauthorized use may lead to suspension, termination, or legal action. If you wish to terminate this Contract at any time, you may do so by deleting Your Account and no longer accessing or using our Services."),
                      _tncBullet("These Terms are an electronic record and governed by and in accordance with the provisions of the Information Technology Act, 2000, the Information Technology (Amendment) Act, 2008, and the rules framed thereunder as applicable including the Information Technology (Intermediary Guidelines and Digital Media Ethics Code) Rules, 2021 (\"IT Act\"), and amended from time to time. This electronic record is generated by a computer system and does not require any physical or digital signatures."),
                      _tncBullet("We may update and change our App (and/or its Content) from time to time to reflect changes to our Services, changes in law and our business priorities. We may also take down any Content or limit access to any Content at our own discretion. All Content which we have decided to take down will be tagged as \"Leaving Soon\" for a period of one (1) month before the Content is officially taken down, unless by an order of a court of law or a requirement of statute we are required to take-down certain Content on an immediate basis. We do not guarantee that our Application, or any content on it, will be available permanently, uninterrupted or be error-free. We may suspend or withdraw or restrict the availability of all or any part of our Services for business, operational and compliance reasons. We will try to give you reasonable notice of any suspension or withdrawal on a best effort basis."),
                      _tncBullet("You agree that we will provide notices and messages to you in the following ways: (1) as a pop-up on your registered mobile device or (2) sent as an instant message or WhatsApp message to the mobile number you have provided at the time of creation of Your Account..."),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD152),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Close', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tncBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white70, fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
