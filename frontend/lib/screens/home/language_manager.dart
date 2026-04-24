import 'package:flutter/material.dart';

class LanguageManager {
  static final LanguageManager instance = LanguageManager._internal();

  LanguageManager._internal();

  final ValueNotifier<String> displayLanguage = ValueNotifier<String>("English");

  void changeLanguage(String newLang) {
    if (newLang == "తెలుగు" || newLang == "Telugu") {
      displayLanguage.value = "Telugu";
    } else if (newLang == "Tenglish") {
      displayLanguage.value = "Tenglish";
    } else {
      displayLanguage.value = "English";
    }
  }

  String get(String key) {
    final lang = displayLanguage.value;
    if (_translations[key] == null) return key;
    return _translations[key]![lang] ?? _translations[key]!["English"] ?? key;
  }

  final Map<String, Map<String, String>> _translations = {
    "Select Language": {
      "English": "Select Language",
      "Tenglish": "Language Select Chesukondi",
      "Telugu": "భాషను ఎంచుకోండి",
    },
    "Select content language": {
      "English": "Select content language",
      "Tenglish": "Content Language Select Chesukondi",
      "Telugu": "కంటెంట్ భాషను ఎంచుకోండి",
    },
    "Select display language": {
      "English": "Select display language",
      "Tenglish": "Display Language Select Chesukondi",
      "Telugu": "ప్రదర్శన భాషను ఎంచుకోండి",
    },
    "Save": {
      "English": "Save",
      "Tenglish": "Save",
      "Telugu": "సేవ్ చేయండి",
    },
    // ✅ Always English regardless of selected language (matches app design)
    "Coming Soon": {
      "English": "Coming Soon",
      "Tenglish": "Coming Soon",
      "Telugu": "Coming Soon",
    },
    "Trending Now": {
      "English": "Trending Now",
      "Tenglish": "Ippudu Trending",
      "Telugu": "ప్రస్తుతం ట్రెండింగ్లో ఉంది",
    },
    // ✅ FIX: "Trending" used for section header in home screen
    "Trending": {
      "English": "Trending",
      "Tenglish": "Trending",
      "Telugu": "ట్రెండింగ్",
    },
    "Popular Genres": {
      "English": "Popular Genres",
      "Tenglish": "Popular Genres",
      "Telugu": "పాపులర్ జానర్స్",
    },
    "All Shows": {
      "English": "All Shows",
      "Tenglish": "Anni Shows",
      "Telugu": "అన్ని షోలు",
    },
    "Free Episodes": {
      "English": "Free Episodes",
      "Tenglish": "Free Episodes",
      "Telugu": "ఉచిత ఎపిసోడ్లు",
    },
    "3 Free Episodes": {
      "English": "3 Free Episodes",
      "Tenglish": "3 Free Episodes",
      "Telugu": "3 ఉచిత ఎపిసోడ్లు",
    },
    // ✅ FIX: matches "నేడే చూడండి" banner in image 1
    "SHOWS OF THE WEEK": {
      "English": "SHOWS OF THE WEEK",
      "Tenglish": "WEEK SHOWS",
      "Telugu": "నేడే చూడండి",
    },
    "Drama": {
      "English": "Drama",
      "Tenglish": "Drama",
      "Telugu": "డ్రామా",
    },
    // ✅ FIX: image 6 shows "హాస్యం" for Comedy
    "Comedy": {
      "English": "Comedy",
      "Tenglish": "Comedy",
      "Telugu": "హాస్యం",
    },
    "Thriller": {
      "English": "Thriller",
      "Tenglish": "Thriller",
      "Telugu": "థ్రిల్లర్",
    },
    "Animation": {
      "English": "Animation",
      "Tenglish": "Animation",
      "Telugu": "యానిమేషన్",
    },
    "Notify": {
      "English": "Notify",
      "Tenglish": "Notify",
      "Telugu": "తెలియజేయండి",
    },
    "You will be notified": {
      "English": "You will be notified",
      "Tenglish": "Meeku details vasthai",
      "Telugu": "మీకు తెలియజేయబడుతుంది",
    },
    "Join Quiz & Win Cash!": {
      "English": "Join Quiz & Win Cash!",
      "Tenglish": "Quiz Join Avvandi & Cash Win Avvandi!",
      "Telugu": "క్విజ్లో చేరండి & నగదు గెలుచుకోండి!",
    },
    "Go Premium": {
      "English": "Go Premium",
      "Tenglish": "Go Premium",
      "Telugu": "ప్రీమియం పొందండి",
    },
    // ✅ Always English regardless of selected language (matches app design)
    "Join the quiz": {
      "English": "Join the quiz",
      "Tenglish": "Join the quiz",
      "Telugu": "Join the quiz",
    },
    "What is Chai Shots?": {
      "English": "What is Chai Shots?",
      "Tenglish": "Chai Shots ante Enti?",
      "Telugu": "చాయ్ షాట్స్ అంటే ఏమిటి?",
    },
    "Chai Shots description": {
      "English": "Chai Shots is India's first Microdrama OTT platform. We've bottled the thrill of long-form stories into a new format: Short Series.",
      "Tenglish": "Chai Shots India lo first Microdrama OTT platform. Ikkada short stories untayi.",
      "Telugu": "చాయ్ షాట్స్ భారతదేశపు మొట్టమొదటి మైక్రోడ్రామా OTT ప్లాట్ఫారమ్. మేము సుదీర్ఘ కథల థ్రిల్ను కొత్త ఫార్మాట్లో చేర్చాము: షార్ట్ సిరీస్.",
    },
    "Creator-First OTT": {
      "English": "Creator-First OTT",
      "Tenglish": "Creator-First OTT",
      "Telugu": "క్రియేటర్-ఫస్ట్ OTT",
    },
    "FAQs": {
      "English": "FAQs",
      "Tenglish": "FAQs",
      "Telugu": "తరచుగా అడిగే ప్రశ్నలు",
    },
    "How Chai Shots Works": {
      "English": "How Chai Shots Works",
      "Tenglish": "Chai Shots ela Panichesthundhi?",
      "Telugu": "చాయ్ షాట్స్ ఎలా పనిచేస్తుంది",
    },
    // ✅ FIX: Bottom nav labels matching screenshots
    "Home": {
      "English": "Home",
      "Tenglish": "Home",
      "Telugu": "హోమ్",
    },
    "Premium": {
      "English": "Premium",
      "Tenglish": "Premium",
      "Telugu": "ప్రీమియం",
    },
    // ✅ FIX: image shows "సెర్చ్" for Search
    "Search": {
      "English": "Search",
      "Tenglish": "Vethukandi",
      "Telugu": "సెర్చ్",
    },
    "Watch History": {
      "English": "Watch History",
      "Tenglish": "Choosina Avi",
      "Telugu": "చూసిన చరిత్ర",
    },
    "Unlock All Features": {
      "English": "Unlock All Features",
      "Tenglish": "Anni Features Unlock Cheyandi",
      "Telugu": "అన్ని ఫీచర్లను అన్లాక్ చేయండి",
    },
    "Subscribe": {
      "English": "Subscribe",
      "Tenglish": "Subscribe",
      "Telugu": "సబ్స్క్రయిబ్",
    },
    "Access to 100+ Shows": {
      "English": "Access to 100+ Shows",
      "Tenglish": "100+ Shows Choodandi",
      "Telugu": "100+ షోలకు యాక్సెస్",
    },
    "New Shows Every Week": {
      "English": "New Shows Every Week",
      "Tenglish": "Prathi Vaaram Kotha Shows",
      "Telugu": "ప్రతి వారం కొత్త షోలు",
    },
    "12 Months": {
      "English": "12 Months",
      "Tenglish": "12 Nelalu",
      "Telugu": "12 నెలలు",
    },
    "1 Month": {
      "English": "1 Month",
      "Tenglish": "1 Nela",
      "Telugu": "1 నెల",
    },
    "Super Saver": {
      "English": "Super Saver",
      "Tenglish": "Super Saver",
      "Telugu": "సూపర్ సేవర్",
    },
    "Save ₹689": {
      "English": "Save ₹689",
      "Tenglish": "₹689 Save Cheyandi",
      "Telugu": "₹689 ఆదా చేయండి",
    },
    "Just ₹42 /Month": {
      "English": "Just ₹42 /Month",
      "Tenglish": "Kevalam ₹42 /Month",
      "Telugu": "కేవలం నెలకు ₹42",
    },
    "Starter Plan": {
      "English": "Starter Plan",
      "Tenglish": "Starter Plan",
      "Telugu": "స్టార్టర్ ప్లాన్",
    },
    "Have a coupon code?": {
      "English": "Have a coupon code?",
      "Tenglish": "Coupon Code Unnadha?",
      "Telugu": "కూపన్ కోడ్ ఉందా?",
    },
    "Auto-renewal. Cancel anytime.": {
      "English": "Auto-renewal. Cancel anytime.",
      "Tenglish": "Auto-renewal. Eppudaina Cancel cheyachu.",
      "Telugu": "ఆటో-రిన్యూవల్. ఎప్పుడైనా రద్దు చేయవచ్చు.",
    },
    "All Time Blockbusters": {
      "English": "All Time Blockbusters",
      "Tenglish": "All Time Blockbusters",
      "Telugu": "ఆల్ టైమ్ బ్లాక్‌బస్టర్స్",
    },
    // ✅ FIX: image 4 shows "రోమ్-కామ్"
    "Rom-Com": {
      "English": "Rom-Com",
      "Tenglish": "Rom-Com",
      "Telugu": "రోమ్-కామ్",
    },
    // ✅ FIX: image 2 shows "కొత్తగా విడుదలైనవి"
    "New Releases": {
      "English": "New Releases",
      "Tenglish": "New Releases",
      "Telugu": "కొత్తగా విడుదలైనవి",
    },
    "18+": {
      "English": "18+",
      "Tenglish": "18+",
      "Telugu": "18+",
    },
    // ✅ FIX: image 2 shows "జెన్ జీ వైబ్స్"
    "GenZ Vibes": {
      "English": "GenZ Vibes",
      "Tenglish": "GenZ Vibes",
      "Telugu": "జెన్ జీ వైబ్స్",
    },
    // ✅ FIX: image 3 shows "30 నిమిషాల్లో చూసేయండి"
    "Binge in 30 Min": {
      "English": "Binge in 30 Min",
      "Tenglish": "Binge in 30 Min",
      "Telugu": "30 నిమిషాల్లో చూసేయండి",
    },
    // ✅ FIX: image 3 shows "సూక్ష్మ సీరియళ్లు"
    "Short Serials": {
      "English": "Short Serials",
      "Tenglish": "Short Serials",
      "Telugu": "సూక్ష్మ సీరియళ్లు",
    },
    "Discover": {
      "English": "Discover",
      "Tenglish": "Discover",
      "Telugu": "కనుగొనండి",
    },
    // ✅ FIX: bottom nav shows "షెల్ఫ్"
    "Shelf": {
      "English": "Shelf",
      "Tenglish": "Shelf",
      "Telugu": "షెల్ఫ్",
    },
    // ✅ FIX: bottom nav shows "ప్రొఫైల్"
    "Profile": {
      "English": "Profile",
      "Tenglish": "Profile",
      "Telugu": "ప్రొఫైల్",
    },
    // ✅ NEW: bottom nav "హాట్ అండ్ న్యూ" seen in screenshots
    "Hot & New": {
      "English": "Hot & New",
      "Tenglish": "Hot & New",
      "Telugu": "హాట్ అండ్ న్యూ",
    },
    // ✅ NEW: "డ్రామా" section label (image 4)
    "Drama Section": {
      "English": "Drama",
      "Tenglish": "Drama",
      "Telugu": "డ్రామా",
    },
    // ✅ NEW: "థ్రిల్లర్" section label (image 6)
    "Thriller Section": {
      "English": "Thriller",
      "Tenglish": "Thriller",
      "Telugu": "థ్రిల్లర్",
    },
    // ✅ NEW: "అన్ని షోలు" label (image 5)
    "All Shows Label": {
      "English": "All Shows",
      "Tenglish": "Anni Shows",
      "Telugu": "అన్ని షోలు",
    },
  };
}