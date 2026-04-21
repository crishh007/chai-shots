import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'premium_screen.dart';
import 'edit_profile_screen.dart';
import 'transaction_history_screen.dart';
import 'help_feedback_screen.dart';
import 'signup_screen.dart';
import '../language_page.dart';
import '../globals.dart';
import '../language_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (mounted) setState(() => isLoading = true);
    try {
      final data = await ApiService().getProfile();
      if (mounted) {
        setState(() {
          userData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load profile: $e"), backgroundColor: Colors.red),
        );
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    isAuthenticated = false; // Reset global auth state
    
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignupScreen()),
        (route) => false,
      );
    }
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
    final lm = LanguageManager.instance;
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD400)))
        : ValueListenableBuilder<String>(
            valueListenable: lm.displayLanguage,
            builder: (context, lang, child) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
                        child: Column(
                          children: [
                            // VIP Crown Section
                            Image.asset(
                              'assets/images/crown.jpeg',
                              height: 120,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.workspace_premium, color: Colors.amber, size: 80),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              lm.get("Get Unlimited Access"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Feature Row (3 feature items)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Feature Column 1
                                _buildBenefitItem(
                                  Image.asset('assets/images/unlimited.jpeg', width: 44, height: 44, fit: BoxFit.contain), 
                                  lm.get("Unlimited Binge")
                                ),
                                // Feature Column 2
                                _buildBenefitItem(
                                  Image.asset('assets/images/ads.jpeg', width: 44, height: 44, fit: BoxFit.contain), 
                                  lm.get("No Ads")
                                ),
                                // Feature Column 3
                                _buildBenefitItem(
                                  Image.asset('assets/images/quality.jpeg', width: 44, height: 44, fit: BoxFit.contain), 
                                  lm.get("1080p Quality")
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD400),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen()));
                                },
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Container(
                                    width: 26, height: 26,
                                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                    child: const Icon(Icons.workspace_premium, color: Color(0xFFFFD400), size: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(lm.get("Go Premium"), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(context, Icons.person_outline, lm.get("Account"), null, () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                        _fetchProfile();
                      }),
                      _buildMenuItem(context, Icons.receipt_long_outlined, lm.get("Transactions"), null, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()));
                      }),
                      _buildMenuItem(context, Icons.translate_outlined, lm.get("Language Settings"), lang, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguagePage()));
                      }),
                      _buildMenuItem(context, Icons.headset_mic_outlined, lm.get("Help & feedback"), null, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpFeedbackScreen()));
                      }),
                      _buildMenuItem(context, Icons.logout, lm.get("Logout"), null, () {
                        _showLogoutDialog(context, lm);
                      }),
                      const SizedBox(height: 32),
                      Text(lm.get("Follow us"), style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialIcon("https://img.icons8.com/color/96/facebook-new.png", Icons.facebook, Colors.blueAccent, "https://share.google/1XiUUEodM4X8Ur8Bh"),
                          const SizedBox(width: 24),
                          _socialIcon("https://img.icons8.com/color/96/instagram-new.png", Icons.camera_alt, Colors.pinkAccent, "https://www.instagram.com/chaishotsapp?igsh=Nnd5aDdidmF3bnk4"),
                          const SizedBox(width: 24),
                          _socialIcon("https://img.icons8.com/color/96/youtube-play.png", Icons.play_circle_fill, Colors.redAccent, "https://youtube.com/@chaishotsapp?si=LMjL_kPHcqE49hWh"),
                        ],
                      ),
                      const SizedBox(height: 48),
                      const Text("Made with 💛 in Hyderabad", style: TextStyle(color: Colors.white24, fontSize: 12)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text.rich(
                          TextSpan(
                            text: "Terms & conditions",
                            style: const TextStyle(color: Colors.white24, fontSize: 11, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()..onTap = () => _showTermsBottomSheet(context),
                            children: [
                              const TextSpan(text: "  |  ", style: TextStyle(decoration: TextDecoration.none)),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(color: Colors.white24, fontSize: 11, decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()..onTap = () => _showPrivacyPolicyBottomSheet(context),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text("v 1.0.76", style: TextStyle(color: Colors.white10, fontSize: 10)),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  // Helper for Column(Icon + Text) with center alignment
  Widget _buildBenefitItem(Widget iconWidget, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _socialIcon(String url, IconData fallback, Color color, String targetUrl) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(targetUrl);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          debugPrint("Could not launch $targetUrl");
        }
      },
      child: Image.network(url, width: 32, height: 32, errorBuilder: (context, error, stackTrace) => Icon(fallback, color: color, size: 32)),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String? value, Function() onTap) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: Colors.white, size: 28),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Text(
                value,
                style: const TextStyle(color: Colors.white38, fontSize: 14),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, LanguageManager lm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF161618),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.white, size: 24))]),
                const SizedBox(height: 4),
                Text(lm.get("Leaving so soon?"), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text(lm.get("You'll miss your fav shows and that cliffhanger ending 😁"), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD400), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    onPressed: () => Navigator.pop(context),
                    child: Text(lm.get("Nah, just kidding"), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    onPressed: () {
                      Navigator.pop(context);
                      _logout(context);
                    },
                    child: Text(lm.get("Logout"), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                  _bodyText("Welcome to the mobile application ‘Chai Shots’, an on-demand digital audio-video streaming service/platform (the “App”) owned, operated, managed, and distributed by Chai Shots Private Limited, a company incorporated under the laws of India, having its registered office at Plot no. 206, House No.3, Kavuri Hills, Hyderabad, Telangana, India - 500033 IN (hereinafter referred to as “Company”, “we”, “us”, or “our”, which shall include its successors and permitted assigns), in accordance with and subject to these terms of usage (“Terms”, “Terms of Use”). We offer this App including all information, tools and services available from this mobile application to You, the user (“User” or “You” “Your”) conditioned upon Your acceptance of all terms, conditions, policies and notices stated here (which shall be amended from time to time) within the Territory. For the purposes of the Terms, “Territory” shall mean worldwide including India."),
                  _bodyText("This document is a legally binding document entered into between the Company and the User and You agree to access the Content (defined below) as per these Terms. These Terms are an electronic record and governed by and in accordance with the provisions of the Information Technology Act, 2000, the Information Technology (Amendment) Act, 2008, and the rules framed thereunder as applicable including the Information Technology (Intermediary Guidelines and Digital Media Ethics Code) Rules, 2021 (“IT Act”), and amended from time to time. This electronic record is generated by a computer system and does not require any physical or digital signatures."),
                  _bodyText("For the purpose of these Terms, “Content” refers to any and all audio-visual content including videos, sound recordings, musical compositions, graphics, photographs, texts (including comments and scripts), branding (including trade names, trademarks, service marks or logos), software, metrics and other materials made available through the App, whether owned by the Company or licensed from third parties, including without limitation, short series, clips, trailers, promotional videos, or similar content."),
                  _bodyText("By downloading, installing, registering on, accessing, or using the App in any manner, You expressly acknowledge that You have read, understood, and agreed to be bound by these Terms of Use, our Privacy Policy available at [insert hyperlink], and any additional guidelines, rules, terms, or disclaimers posted on the App or otherwise notified to You from time to time, all of which are incorporated herein by reference (collectively, the “Agreement”)."),
                  _bodyText("If you do not agree with these Terms or our privacy policy, You must stop using the App. Continued use means You accept the Terms, including any changes we may make. Unauthorized use may lead to suspension, termination, or legal action."),
                  _sectionTitle("B) ELIGIBILITY, FREE CONTENT & REGISTRATION"),
                  _subTitle("Eligibility to Use the App"),
                  _bodyText("The services offered by the App are intended for individuals who have reached the age of majority in the Territory (“Age of Majority”). In all circumstances, only individuals who are of the Age of Majority may create an Account on the App, and such individuals will remain fully responsible for the use and management of that Account. By accessing the App, you represent and warrant that You have reached the legal Age of Majority as per Applicable Laws."),
                  _bodyText("For the purpose of the Terms Of Use, “Applicable Laws” means all laws, rules, regulations, and guidelines applicable within the Territory."),
                  _subTitle("Registration and Account creation"),
                  _bodyText("Creation of account: In order to access or view, any Content that is not classified as Free Content, You are required to mandatorily create an Account on the App (in the manner specified below). You understand and agree to provide accurate and verifiable details, specifically Your mobile number, for the purpose of creating and maintaining Your account on the App and for conducting any Know-Your-Customer (KYC) process, as applicable. You confirm that the information provided is true and accurate in all respects. Your registration shall be verified via a one-time password (OTP) sent to Your mobile number, upon which a valid “Account” shall be created and a unique user profile shall be tied to Your registered mobile number and login credentials."),
                  _sectionTitle("C) ACCESS OF CONTENT AND USER’S DISCRETION"),
                  _bodyText("Users may stream content on up to two (2) devices simultaneously per Account. Any attempt to exceed this limit through credential sharing, unauthorized access, or use of automated tools may result in suspension or termination of the Account."),
                  _bodyText("You understand that the App may include Content with explicit language, sexual material, violence, or mature themes, some of which may not be labelled or may appear in search results unintentionally. Such Content may not be suitable for all Users, and You agree to use the App at Your own risk. The App and its affiliates are not liable for any Content You may find offensive. User discretion is advised."),
                  _bodyText("Access to the App will be available to You in accordance with the Applicable Laws of the Territory."),
                  _sectionTitle("D) FEATURES"),
                  _bodyText("The App may offer various and/ or amend integrative services within the App at its sole and exclusive discretion."),
                  _subTitle("Clap feature"),
                  _bodyText("The Clap feature allows Users to show appreciation to the cast and crew of Content, as identified and made available by the Content producer to the Company, through the App. Each Clap shall consist of both (i) a short note of appreciation (up to 300 characters); and (ii) a monetary appreciation payable only in denominations specified on the App (currently ranging from INR 20 to INR 10,000) sent via the Company through the App using the available Payment Methods. Notes are designed to be shared together with a monetary appreciation, and cannot be sent on a standalone basis. All monetary rewards contributed through the Clap feature shall be directed to the intended cast or crew member(s), subject to deduction of applicable taxes and third-party charges (including payment processing fees and platform commissions). Claps, once made, are final and non-refundable under any circumstances."),
                  _subTitle("Promotions"),
                  _bodyText("From time to time, the Company may, at its sole discretion, introduce and administer promotional offers, campaigns, reward systems, gamification models, or incentive programs (“Promotions”), which may include but are not limited to the use of digital rewards such as bonus credits, or other forms of benefits. Such Promotions are designed solely for user engagement and entertainment and shall not be construed as creating any monetary or property interest in favor of the User. The availability, eligibility, duration, redemption mechanism, and value of such Promotions shall be determined exclusively by the Company and may be modified, suspended, or withdrawn at any time without prior notice. The Company’s decisions in respect of Promotions shall be final and binding. The User shall have no right to dispute, claim, or demand continuity, cash equivalence, transferability, or redemption beyond what is expressly permitted by the Company."),
                  _subTitle("Compatibility Systems/ Accessibility"),
                  _bodyText("The App is officially available for download only through the Apple App Store and Google Play Store. The App works on devices that meet system and compatibility requirements, which may change over time. A device that is compatible now may later become incompatible due to updates by us or applicable third parties, from time to time. Updates to the App (automatic or manual) and, in some cases, to Your device may be required for continued access. Playback and streaming quality depend on factors such as Your device, internet connection, and chosen settings. The App may adjust resolution automatically to prevent interruptions to Your viewing experience. While we aim to provide a high-quality experience, we cannot guarantee and be liable for specific quality or resolution, even for paid premium Content."),
                  _sectionTitle("E) ACCESS PLANS AND PAYMENTS"),
                  _bodyText("Content (excluding Free Content) shall be made available/ accessible to You via the following methods, either simultaneously, or exclusively:"),
                  _subTitle("Streaming Plan"),
                  _bodyText("Users may access Content on the App by subscribing to a plan made available by the Company (each, a “Streaming Plan”) and paying the applicable fee as displayed at the time of purchase (the “Streaming Fee”)."),
                  _bodyText("Each Streaming Plan shall provide access to all Content for a defined duration (the “Viewing Period”), which may be monthly, yearly, or as otherwise specified on the App for the respective Streaming Plan. The Streaming Fee for a Streaming Plan, once paid, shall remain fixed for the applicable Viewing Period."),
                  _bodyText("The Company reserves the right to revise Streaming Fees at its sole discretion. Any such revision shall only apply prospectively to future purchases or renewals and shall not affect the Streaming Fee already paid for an ongoing Viewing Period."),
                  _bodyText("Streaming Plans may automatically renew at the end of the applicable Viewing Period with prior notice unless cancelled by the User prior to the renewal date, in which case the User’s Payment Method shall be charged the applicable Streaming Fee."),
                  _subTitle("Other access models"),
                  _bodyText("App may, from time to time, introduce alternative Content access models, in addition to or in substitution of the existing options. Unless specifically governed by separate terms, such models shall be interpreted in accordance with the general principles laid out in the Terms of Use. Users are expected to refer to promotional pages, in-App instructions, and App notifications for specific access rules. Continued use of such access constitutes deemed acceptance of applicable conditions, even if not explicitly listed herein."),
                  _bodyText("The names and descriptions of such access models may change from time to time; however, the nature and terms applicable shall be interpreted consistently with the prevailing models outlined herein. In cases where specific terms are not expressly defined for a newly introduced model, Users are expected to exercise discretion and follow the general principles of Content access, payment usage, and conduct defined in these Terms. Access to Content ceases immediately upon cancellation or failure to renew."),
                  _bodyText("For the purpose of Terms, Streaming Fee shall be hereinafter be referred to as “Fee” and, “Payment Method” shall mean valid and active payment options made available to Users through third-party payment processors or platforms authorized by the App, including but not limited to the Apple App Store, Google Play Store, or other approved payment aggregators. The availability of specific payment methods (such as credit cards, debit cards, net banking, UPI, prepaid instruments, or other options) shall be determined by such third-party platforms and may vary from time to time. The App shall not be responsible or liable for any errors, delays, failures, or refund issues arising from or attributable to such third-party payment processors or platforms. The App, at its sole discretion, may offer the User certain discounts, concessions, markdown in Fees, if applicable, and from time to time. Any and all discounts offered by the App shall be at its sole discretion and not an obligation on the App by any means whatsoever."),
                  _sectionTitle("F) PAYMENT"),
                  _bodyText("Content on the App shall become available to You once the applicable Fee has been successfully received. Please note that payment processing may take additional time depending on the Payment Method, and certain providers of Payment Methods may also levy transaction charges."),
                  _bodyText("All Fees are inclusive of applicable taxes. Upon confirmation of payment of Fee, an electronic invoice shall be issued to You."),
                  _bodyText("In the event that Your primary Payment Method fails, the App may, where available, attempt to process the Fee through an alternate Payment Method. If no such Payment Method is available or the attempt fails, access to the Content may be denied."),
                  _bodyText("Other than confirming whether a payment has been received, the App shall not be responsible and /or liable for any delays, misuse of information, or losses by third-party processors. In case of any issues with payments, You may reach out to us via the ‘help’ section in the App or @support@chaishots.in."),
                  _bodyText("For abundant clarity, the App does not use and/ or collect information related to payments including but not limited to bank account number, one-time-passwords, credit/ debit card number, etc., and shall not be responsible or liable for any and all misuse of such information by anyone."),
                  _bodyText("The App reserves the right to modify, discontinue or update Streaming Plan, Viewing Periods, Fees or payment cycles at its sole discretion with notice as per this Terms of Use. Any such changes shall take effect once You next use the App. If You do not agree with the updated terms, it shall be Your responsibility to cancel Your access plan prior to continued use."),
                  _bodyText("All Fees are strictly non-refundable, including in cases of partial usage or cancellation of a plan. Once activated, plans shall remain in effect for their full term and cannot be altered during such period. The User cannot and shall not be able to change the Streaming Plan during an on-going Streaming Plan."),
                  _bodyText("THE COMPANY/APP RESERVES THE EXCLUSIVE RIGHT TO MODIFY, REVISE, OR DISCONTINUE ANY OF ITS MONETIZATION FEATURES — INCLUDING STREAMING PLAN PRICING, PROMOTIONAL SCHEMES, PAYMENT METHODS, OR BUNDLED OFFERS — AT ITS SOLE DISCRETION AND WITHOUT PRIOR NOTICE. SUCH CHANGES BECOME EFFECTIVE IMMEDIATELY UPON PUBLICATION ON THE APP OR NOTIFICATION THROUGH OFFICIAL COMMUNICATION CHANNELS. CONTINUED USE OF THE APP CONSTITUTES ACCEPTANCE OF THE UPDATED PAYMENT TERMS."),
                  _sectionTitle("G) REFUNDS & CANCELLATION"),
                  _bodyText("Refunds of Fee, as applicable, are processed only and specifically in the event of failure to access Content despite successful payment due to a direct issue with the App. Refund requests must be sent to support@chaishots.in or via the ‘help’ section in the App within seventy-two (72) hours of the issue and shall be dealt with by the Company as per the Terms and its policies. For clarity, the issue as detailed above may be resolved by the Company in the manner it deems fit at its sole discretion. Other reasons save and except as stated above, including without limitation dissatisfaction with Content, early exit from a show, or unused balance shall not be considered grounds for refund."),
                  _bodyText("Once refund is approved post inspection by our team, the refund will be credited to the original model of payment within 7-10 working days. For support queries contact +91 8977721966."),
                  _bodyText("The Fee paid by You shall be non-refundable under any circumstances and App shall not be liable to refund any Fee paid by You to the App for any reason including but not limited to partially utilised Streaming Plan during the Viewing Period, cancellation of the Streaming Plan, etc."),
                  _sectionTitle("H) HOLDBACK / RESTRICTIONS ON USE OF CONTENT"),
                  _bodyText("By using the App, You agree to not, directly or indirectly: Exploit Content, Bypass Protections, Unauthorized Access & Use, Unlawful or Offensive Conduct, Intellectual Property Violations, Account Misuse, Encumbrances, Public Use."),
                  _bodyText("If You violate any part of this clause, App reserves the right to restrict, suspend, or permanently terminate Your access to the app and services without notice, and may pursue legal remedies including but not limited to criminal prosecution or civil claims where applicable."),
                  _sectionTitle("I) CONTENT & OWNERSHIP"),
                  _bodyText("All rights, title, interest in the App and the Content available on the App, including but not limited to all its constituents, short series, video clips, layout, images App is owned by or licensed to the App and/ or Company and is protected by Applicable Laws Indian and international intellectual property laws. The App retains and reserves all titles in and to the Intellectual Property Rights in perpetuity around the world and for all languages."),
                  _bodyText("For the purposes of these Terms, “Intellectual Property Rights” shall mean any and all copyrights, trademarks, patents, geographical indications, design rights, trade names, software, domain name, technology, source code, database, titles, animation, servers, applications, interactive elements, data, brand names of the App, proprietary rights of the Company and/ or its respective licensors and/ or respective owners. You agree to respect and abide by all applicable laws and regulations regarding the use of copyrighted Content."),
                  _subTitle("License"),
                  _bodyText("Subject to payment of Fee, as applicable, Users are granted a limited, non-exclusive, non-transferable, non-sublicensable, revocable license to access and view the Content made available on the App during the Viewing Period, as applicable, solely for personal, non-commercial entertainment purposes through the App only in accordance with these Terms of Use."),
                  _sectionTitle("J) SUPPORT & GRIEVANCE REDRESSAL"),
                  _bodyText("If You have any complaints regarding the App, Your access to the App, please contact the App at support@chaishots.in. If You have any information, data, complaint, feedback regarding any of the Content of the App infringing upon any Applicable Laws, please reach out to us at nairmalya@chaishots.in."),
                  _bodyText("For any Content related concerns, complaints, issues or grievances (excluding App complaints) Grievance Redressal, the Grievance Officer is Ms. Nairmalya Suryadevara. Plot no. 206, House No.3, Kavuri Hills, Hyderabad, Telangana, India - 500033 IN."),
                  _sectionTitle("K) THIRD-PARTY LINKS"),
                  _bodyText("Certain services on the App may display, include or make available Content, data, information, applications, advertisements or promotions of various forms from third parties. By using the App, You agree that the App is not responsible for reviewing, verifying, or guaranteeing the accuracy, legality, quality, or reliability of any Third-Party Materials."),
                  _sectionTitle("L) DISCLAIMERS"),
                  _bodyText("The Company does not warrant that the App and its services will be uninterrupted, secure, or free of errors, defects, bugs, viruses, or other harmful components; any defects will be corrected; the App and its services will meet Your expectations or requirements; or the Content will be available in all Territory/ies, or at all times, or on all supported devices."),
                  _subTitle("LIMITATION OF LIABILITY"),
                  _bodyText("TO THE EXTENT NOT PROHIBITED BY APPLICABLE LAW, IN NO EVENT SHALL THE APP AND/OR COMPANY, ITS AFFILIATES, AGENTS, OR PRINCIPALS BE LIABLE FOR PERSONAL INJURY, OR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES WHATSOEVER..."),
                  _sectionTitle("M) NOTICE"),
                  _bodyText("For any notices to the Company, the communication must be sent to: Chai Shots Private Limited, Plot No. 206, House No.3, Kavuri Hills, Hyderabad. Email: support@chaishots.in"),
                  _sectionTitle("N) INDEMNITY"),
                  _bodyText("You agree to indemnify, defend and hold harmless the App and/ or Company from any claims, damages, liabilities, costs or expenses (including attorney fees) arising out of or in connection with Your use of the App."),
                  _sectionTitle("O) MODIFICATIONS"),
                  _bodyText("We may update or change these Terms of Use at any time. The revised Terms will take effect as soon as they are posted on the App. By continuing to use the App after changes are posted, You agree to the updated Terms."),
                  _sectionTitle("P) Miscellaneous"),
                  _point("21.1", "These Terms shall be governed by and construed in accordance with the laws of India and the courts at Hyderabad, Telangana, shall have exclusive jurisdiction."),
                  _point("21.2", "No Class or Representative Actions: Disputes shall be resolved only on an individual basis."),
                  _point("21.3", "You shall not assign any rights granted to You under these Terms to any third party."),
                  _point("21.4", "Each affiliate of the App is severally liable for its own obligations."),
                  _point("21.5", "Nothing herein contained shall be construed to create a partnership, joint venture, agency, or employment agreement."),
                  _point("21.6", "If any provision of these Terms is adjudged void or unenforceable, the remaining provisions shall remain in effect."),
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

  Widget _point(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
            ),
          ),
        ],
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
                  _bodyText("Chai Shots Private Limited (“we”, “our”, or “us”) operates the Chai Shots OTT platform (“App” or “Service”). We are committed to protecting your privacy and safeguarding your information in compliance with applicable Indian data protection laws, including the Information Technology Act, 2000 and the Information Technology (Reasonable Security Practices and Procedures and Sensitive Personal Data or Information) Rules, 2011."),
                  _sectionTitle("1. Consent"),
                  _bodyText("By registering for, accessing, or using the Chai Shots App, you expressly consent to the collection, use, processing, storage, and sharing of your personal data in accordance with this Privacy Policy. You also consent to the transfer of your data to trusted third-party service providers for the purposes outlined herein, and to the processing and storage of your data on servers located in India."),
                  _sectionTitle("2. Information We Collect"),
                  _bodyText("We collect the following categories of personal and usage information when you use the App:"),
                  _subTitle("a. Information You Provide"),
                  _bodyText("We may collect and store the following information when you use our App:"),
                  _bulletPoint("Name and mobile number"),
                  _bulletPoint("Login credentials and password"),
                  _bulletPoint("Subscription and payment details"),
                  _bulletPoint("Communications sent via in-app chat or email (e.g., support queries, feedback, or survey responses)"),
                  _bulletPoint("Any referral code used or promotional coupon redeemed"),
                  _subTitle("b. Information Collected Automatically"),
                  _bodyText("When you access or use the App, we automatically collect certain information to help us operate, secure, and improve the service. This includes:"),
                  _bulletPoint("Device and Technical Information, such as your IP address, device type, device ID, operating system version, app version, and network provider."),
                  _bulletPoint("Usage and Behavioral Data, including your watch history, search queries, time spent on videos, clickstream data, navigation patterns, and interaction metrics within the App."),
                  _bulletPoint("Location Data, such as your approximate geographic location, which may be inferred from your IP address or device settings."),
                  _bulletPoint("Crash Reports and Diagnostics, including system logs and performance data, to help us identify and fix technical issues."),
                  _sectionTitle("3. Use of Your Information"),
                  _bodyText("We use your information to provide, operate, and maintain the Chai Shots App and its associated services. This includes managing your account, enabling smooth access to content, marketing communications and ensuring the overall functionality of the platform. Your data is also used to process subscriptions and payments securely through our integrated payment partners. Based on your activity and preferences, we personalize your experience by offering tailored content recommendations and viewing suggestions. We may use your contact details to send important service-related communications, such as updates, announcements, and promotional offers, where applicable. Additionally, your information helps us respond to your queries and support requests, facilitated through our customer service platform, Intercom. We analyze usage patterns and interaction metrics to improve the App’s performance, user interface, and content strategy. Furthermore, your data plays a critical role in detecting and preventing fraud, enforcing our policies, and ensuring the security and integrity of the platform."),
                  _sectionTitle("4. Data Sharing and Disclosure"),
                  _bodyText("We do not sell or rent your personal data. However, in order to provide our services effectively and ensure seamless functionality of the Chai Shots App, we may share your information with the following categories of trusted third-party service providers:"),
                  _bulletPointWithTitle("Payment Processors (Razorpay, Setu UPI AutoPay):", "We share limited payment-related information with Razorpay and Setu UPI Autopay to securely process your subscription payments and transactions in compliance with applicable financial and data protection regulations."),
                  _bulletPointWithTitle("Content Delivery Networks (Google Media CDN):", "Your information, such as IP address and device type, may be shared with Google Media CDN to optimize content delivery, reduce buffering, and improve your overall streaming experience on the App."),
                  _bulletPointWithTitle("Analytics and Attribution Tools (Appsflyer, PostHog):", "We work with Appsflyer and PostHog to analyze how users engage with the App, measure campaign effectiveness, and identify areas of improvement."),
                  _bulletPointWithTitle("Customer Communication Platforms (Intercom, CleverTap):", "To manage engagement, support requests and maintain a responsive customer experience, we share relevant user details with Intercom and CleverTap."),
                  _bulletPointWithTitle("Advertising and Marketing Partners (Google Ads, Meta Ads):", "For promotional purposes, we may share anonymized or aggregated data with advertising platforms like Google Ads and Meta Ads. No personal identifiers are shared."),
                  _bodyText("All such partners are contractually required to follow strict confidentiality and data security standards."),
                  _bulletPointWithTitle("Corporate Transactions:", "In the event of a merger, acquisition, sale of assets, or other corporate restructuring, your personal data may be transferred to the new entity."),
                  _bulletPointWithTitle("Affiliates:", "We may share your information with our affiliated companies, who will process the data in a manner consistent with this Privacy Policy."),
                  _sectionTitle("5. Legal Basis and Consent"),
                  _bodyText("By registering for and using the Chai Shots App, you expressly consent to the collection, use, processing, and storage of your personal data in accordance with the terms outlined in this Privacy Policy. This includes your agreement to the processing of your data within India."),
                  _bodyText("You have the right to withdraw your consent at any time. This can be done through the in-app settings or by contacting our support team."),
                  _sectionTitle("6. User’s Rights"),
                  _bodyText("As a user of the Chai Shots App, you have certain rights in relation to your personal data. These include the right to access, request corrections, or request deletion of your personal information. You may also request a copy of your data in a commonly used, machine-readable format."),
                  _bodyText("All such requests can be made by contacting us through the in-app support feature or by writing to us at support@chaishots.in."),
                  _sectionTitle("7. Data Retention and Anonymization"),
                  _bodyText("We retain your personal data only for as long as necessary to fulfill the purposes outlined in this Privacy Policy. Account and billing-related information may be retained for up to five (5) years. watch history and interaction logs may be retained for up to two (2) years."),
                  _sectionTitle("8. Security of Information"),
                  _bodyText("We implement reasonable and industry-standard security practices to protect your personal data and ensure the safe operation of the Chai Shots App. These measures include encryption of data both in transit and at rest and strict access controls."),
                  _sectionTitle("9. Disclaimer"),
                  _bodyText("The App integrates with various third-party services like Razorpay and Appsflyer. These platforms may independently collect and process your information under their own privacy policies."),
                  _sectionTitle("10. International Access"),
                  _bodyText("International users acknowledge and agree that their personal data will be collected, transferred, processed, and stored in accordance with Indian laws, and may be hosted on servers located within India."),
                  _sectionTitle("11. Grievance Redressal Mechanism"),
                  _bodyText("As per the Information Technology Rules, 2021, we have appointed the following Grievance Officer:"),
                  _bulletPoint("Name: Ms. Nairmalya Suryadevara"),
                  _bulletPoint("Email: nairmalya@chaishots.in"),
                  _bulletPoint("Address: Plot no. 206, House No.3, Kavuri Hills, Hyderabad, Telangana, India - 500033 IN"),
                  _sectionTitle("12. Updates to This Privacy Policy"),
                  _bodyText("We may update this Privacy Policy periodically. Users will be notified of material changes through an in-app pop-up."),
                  _sectionTitle("13. Governing Law and Jurisdiction"),
                  _bodyText("This Policy is governed by the laws of India and subject to the exclusive jurisdiction of the competent courts of Hyderabad."),
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

  Widget _bodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
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

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletPointWithTitle(String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                children: [
                  TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  const TextSpan(text: " "),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
