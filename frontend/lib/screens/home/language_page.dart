import 'package:flutter/material.dart';
import 'language_manager.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selectedLanguage = "Telugu / తెలుగు";
  
  // Use local state for the UI, but update global state on Change/Save
  late String displayLanguage;

  @override
  void initState() {
    super.initState();
    displayLanguage = LanguageManager.instance.displayLanguage.value;
    if (displayLanguage == "Telugu") displayLanguage = "తెలుగు";
  }

  // ✅ LANGUAGE CARD (MATCHES DESIGN)
  Widget languageCard(String title, bool isSelected, bool isComingSoon) {
    return GestureDetector(
      onTap: () {
        if (!isComingSoon) {
          setState(() {
            selectedLanguage = title;
          });
        }
      },
      child: Container(
        height: 70, // 🔥 FIX HEIGHT
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.grey.shade800,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isComingSoon ? Colors.grey : Colors.white,
                fontSize: 14,
              ),
            ),
            if (isComingSoon) ...[
              const SizedBox(height: 4),
              Text(
                LanguageManager.instance.get("Coming Soon"),
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 11,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // ✅ DISPLAY LANGUAGE PILLS
  Widget buildLanguageOption(String lang) {
    bool isSelected = displayLanguage == lang;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            displayLanguage = lang;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent, // ❌ no yellow bg
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.yellow : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              lang,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.yellow : Colors.white, // ✅ text yellow
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(lm.get("Select Language")),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lm.get("Select content language"),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.6,
                    children: [
                      languageCard(
                        "Telugu / తెలుగు",
                        selectedLanguage == "Telugu / తెలుగు",
                        false,
                      ),
                      languageCard(
                        "Hindi / हिन्दी",
                        false,
                        true,
                      ),
                      languageCard(
                        "Tamil / தமிழ்",
                        false,
                        true,
                      ),
                      languageCard(
                        "Malayalam / മലയാളం",
                        false,
                        true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    lm.get("Select display language"),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        buildLanguageOption("English"),
                        buildLanguageOption("Tenglish"),
                        buildLanguageOption("తెలుగు"),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () {
                        // Apply changes globally
                        lm.changeLanguage(displayLanguage);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            lm.get("Save"),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}