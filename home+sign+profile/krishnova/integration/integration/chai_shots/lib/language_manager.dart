import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static final LanguageManager instance = LanguageManager._internal();
  LanguageManager._internal();

  final ValueNotifier<String> displayLanguage = ValueNotifier<String>("English");

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selected_language') ?? "English";
    displayLanguage.value = savedLang;
  }

  void changeLanguage(String newLang) async {
    String langToSet = (newLang == "తెలుగు" || newLang == "Telugu") ? "Telugu" : (newLang == "Tenglish" ? "Tenglish" : "English");
    displayLanguage.value = langToSet;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', langToSet);
  }

  String get(String key) {
    // Requirements: These terms must ALWAYS stay in English regardless of selected language
    const englishOnly = [
      "Go Premium",
      "Account",
      "Unlimited Binge",
      "No Ads",
      "1080p Quality"
    ];
    
    if (englishOnly.any((element) => element.toLowerCase() == key.toLowerCase())) {
      return key;
    }

    final lang = displayLanguage.value;
    if (_translations[key] == null) return key;
    return _translations[key]![lang] ?? _translations[key]!["English"] ?? key;
  }

  final Map<String, Map<String, String>> _translations = {
    // Navigation
    "Home": {"English": "Home", "Tenglish": "Home", "Telugu": "హోమ్"},
    "Search": {"English": "Search", "Tenglish": "Vethakandi", "Telugu": "సెర్చ్"},
    "Discover": {"English": "Discover", "Tenglish": "Discover", "Telugu": "కనుగొనండి"},
    "Shelf": {"English": "Shelf", "Tenglish": "Shelf", "Telugu": "షెల్ఫ్"},
    "Profile": {"English": "Profile", "Tenglish": "Profile", "Telugu": "ప్రొఫైల్"},

    // Signup & Auth
    "Sign Up": {"English": "Sign Up", "Tenglish": "Sign Up", "Telugu": "సైన్ అప్"},
    "Phone number": {"English": "Phone number", "Tenglish": "Phone number", "Telugu": "ఫోన్ నంబర్"},
    "Send OTP": {"English": "Send OTP", "Tenglish": "Send OTP", "Telugu": "OTP పంపండి"},
    "Skip": {"English": "Skip", "Tenglish": "Skip", "Telugu": "స్కిప్"},
    "Enter OTP": {"English": "Enter OTP", "Tenglish": "OTP Enter Cheyandi", "Telugu": "OTP నమోదు చేయండి"},
    "Verify OTP": {"English": "Verify OTP", "Tenglish": "Verify OTP", "Telugu": "OTPని ధృవీకరించండి"},
    "Resend in ": {"English": "Resend in ", "Tenglish": "Resend in ", "Telugu": "మళ్లీ పంపండి "},
    "Resend OTP": {"English": "Resend OTP", "Tenglish": "OTP Resend Cheyandi", "Telugu": "OTPని మళ్లీ పంపండి"},
    "By continuing, you accept our ": {"English": "By continuing, you accept our ", "Tenglish": "Continuing chesthe, meeru accept chestunnattu: ", "Telugu": "కొనసాగించడం ద్వారా, మీరు మా వాటిని అంగీకరిస్తున్నారు: "},
    "T&C": {"English": "T&C", "Tenglish": "T&C", "Telugu": "నిబంధనలు"},
    "and": {"English": "and", "Tenglish": "and", "Telugu": "మరియు"},
    "Privacy Policy": {"English": "Privacy Policy", "Tenglish": "Privacy Policy", "Telugu": "గోప్యతా విధానం"},

    // Profile Screen
    "Get Unlimited Access": {"English": "Get Unlimited Access", "Tenglish": "Unlimited Access Pondandi", "Telugu": "అపరిమిత యాక్సెస్ పొందండి"},
    "Transactions": {"English": "Transactions", "Tenglish": "Transactions", "Telugu": "లావాదేవీలు"},
    "Language Settings": {"English": "Language Settings", "Tenglish": "Language Settings", "Telugu": "భాషా సెట్టింగ్‌లు"},
    "Help & feedback": {"English": "Help & feedback", "Tenglish": "Help & feedback", "Telugu": "సహాయం & ఫీడ్‌బ్యాక్"},
    "Logout": {"English": "Logout", "Tenglish": "Logout", "Telugu": "లాగౌట్"},
    "Follow us": {"English": "Follow us", "Tenglish": "Follow us", "Telugu": "మమ్మల్ని అనుసరించండి"},
    "Leaving so soon?": {"English": "Leaving so soon?", "Tenglish": "Appudu vellipothunnara?", "Telugu": "అప్పుడే వెళ్లిపోతున్నారా?"},
    "You'll miss your fav shows and that cliffhanger ending 😁": {
      "English": "You'll miss your fav shows and that cliffhanger ending 😁",
      "Tenglish": "Mee favourite shows miss avtharu 😁",
      "Telugu": "మీరు మీ ఇష్టమైన షోలను మరియు ఆ క్లిఫ్హ్యాంగర్ ముగింపును కోల్పోతారు 😁"
    },
    "Nah, just kidding": {"English": "Nah, just kidding", "Tenglish": "Nah, just kidding", "Telugu": "లేదు, ఊరికే అన్నాను"},

    // Home Page & Sections
    "Trending": {"English": "Trending", "Tenglish": "Trending", "Telugu": "ట్రెండింగ్"},
    "Drama": {"English": "Drama", "Tenglish": "Drama", "Telugu": "డ్రామా"},
    "Rom-Com": {"English": "Rom-Com", "Tenglish": "Rom-Com", "Telugu": "రోమ్-కామ్"},
    "New Releases": {"English": "New Releases", "Tenglish": "New Releases", "Telugu": "కొత్తగా విడుదలైనవి"},
    "18+": {"English": "18+", "Tenglish": "18+", "Telugu": "18+"},
    "GenZ Vibes": {"English": "GenZ Vibes", "Tenglish": "GenZ Vibes", "Telugu": "జెన్ జీ వైబ్స్"},
    "Binge in 30 Min": {"English": "Binge in 30 Min", "Tenglish": "Binge in 30 Min", "Telugu": "30 నిమిషాల్లో చూసేయండి"},
    "Short Serials": {"English": "Short Serials", "Tenglish": "Short Serials", "Telugu": "సూక్ష్మ సీరియళ్లు"},
    "Thriller": {"English": "Thriller", "Tenglish": "Thriller", "Telugu": "థ్రిల్లర్"},
    "Comedy": {"English": "Comedy", "Tenglish": "Comedy", "Telugu": "హాస్యం"},
    "Popular Genres": {"English": "Popular Genres", "Tenglish": "Popular Genres", "Telugu": "పాపులర్ జానర్స్"},
    "All Shows": {"English": "All Shows", "Tenglish": "Anni Shows", "Telugu": "అన్ని షోలు"},
    "Free Episodes": {"English": "Free Episodes", "Tenglish": "Free Episodes", "Telugu": "ఉచిత ఎపిసోడ్లు"},
    "Coming Soon": {"English": "Coming Soon", "Tenglish": "Coming Soon", "Telugu": "Coming Soon"},
    "Notify": {"English": "Notify", "Tenglish": "Notify", "Telugu": "తెలియజేయండి"},
    "You will be notified": {"English": "You will be notified", "Tenglish": "Meeku details vasthai", "Telugu": "మీకు తెలియజేయబడుతుంది"},
    
    // Language Page
    "Select Language": {"English": "Select Language", "Tenglish": "Language Select Chesukondi", "Telugu": "భాషను ఎంచుకోండి"},
    "Select content language": {"English": "Select content language", "Tenglish": "Content Language Select", "Telugu": "కంటెంట్ భాషను ఎంచుకోండి"},
    "Select display language": {"English": "Select display language", "Tenglish": "Display Language Select", "Telugu": "ప్రదర్శన భాషను ఎంచుకోండి"},
    "Save": {"English": "Save", "Tenglish": "Save", "Telugu": "సేవ్ చేయండి"},
  };
}
