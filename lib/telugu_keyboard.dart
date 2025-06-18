import 'package:flutter/material.dart';

class TeluguKeyboard extends StatefulWidget {
  final Function(String) onKeyTap;

  const TeluguKeyboard({Key? key, required this.onKeyTap}) : super(key: key);

  @override
  State<TeluguKeyboard> createState() => _TeluguKeyboardState();
}

class _TeluguKeyboardState extends State<TeluguKeyboard> {
  // A flag to track if we are in gunintham mode
  bool _showGuninthas = false;
  String? _selectedConsonant;

  // Vowels (స్వరాలు)
  static const List<String> _teluguVowels = [
    'అ', 'ఆ', 'ఇ', 'ఈ', 'ఉ', 'ఊ', 'ఋ', 'ౠ', 'ఎ', 'ఏ', 'ఐ', 'ఒ', 'ఓ', 'ఔ', 'అం', 'అః'
  ];

  // Consonants (హల్లులు)
  static const List<String> _teluguConsonants = [
    'క', 'ఖ', 'గ', 'ఘ', 'ఙ', 
    'చ', 'ఛ', 'జ', 'ఝ', 'ఞ',
    'ట', 'ఠ', 'డ', 'ఢ', 'ణ', 
    'త', 'థ', 'ద', 'ధ', 'న',
    'ప', 'ఫ', 'బ', 'భ', 'మ', 
    'య', 'ర', 'ల', 'వ', 'శ',
    'ష', 'స', 'హ', 'ళ', 'క్ష', 'ఱ'
  ];

  // Guninthas (vowel marks)
  static const List<String> _teluguGuninthas = [
    '', 'ా', 'ి', 'ీ', 'ు', 'ూ', 'ృ', 'ౄ', 'ె', 'ే', 'ై', 'ొ', 'ో', 'ౌ', 'ం', 'ః'
  ];

  // Group the keys for better organization
  static const List<List<String>> _defaultKeyRows = [
    // Vowels (స్వరాలు) - first row
    ['అ', 'ఆ', 'ఇ', 'ఈ', 'ఉ', 'ఊ', 'ఋ', 'ౠ'],
    // Vowels - second row
    ['ఎ', 'ఏ', 'ఐ', 'ఒ', 'ఓ', 'ఔ', 'అం', 'అః'],
    // Consonants (హల్లులు) - first row
    ['క', 'ఖ', 'గ', 'ఘ', 'ఙ', 'చ', 'ఛ', 'జ', 'ఝ', 'ఞ'],
    // Consonants - second row
    ['ట', 'ఠ', 'డ', 'ఢ', 'ణ', 'త', 'థ', 'ద', 'ధ', 'న'],
    // Consonants - third row
    ['ప', 'ఫ', 'బ', 'భ', 'మ', 'య', 'ర', 'ల', 'వ', 'శ'],
    // Consonants - fourth row
    ['ష', 'స', 'హ', 'ళ', 'క్ష', 'ఱ'],
    // Special characters and actions
    ['్', ' ', '⌫'],
  ];

  // Map to convert consonant + vowel mark to the combined character
  Map<String, String> getGuninthasForConsonant(String consonant) {
    Map<String, String> result = {};
    
    // Create all combinations for the current consonant
    for (int i = 0; i < _teluguVowels.length; i++) {
      if (i == 0) {
        // For 'అ', just use the consonant itself
        result[_teluguVowels[i]] = consonant;
      } else {
        // For other vowels, combine consonant with the vowel mark
        result[_teluguVowels[i]] = consonant + _teluguGuninthas[i];
      }
    }
    
    return result;
  }

  void _handleConsonantTap(String consonant) {
    setState(() {
      _showGuninthas = true;
      _selectedConsonant = consonant;
    });
  }

  void _handleGuninthaTap(String vowel) {
    if (_selectedConsonant != null) {
      final guninthas = getGuninthasForConsonant(_selectedConsonant!);
      final combinedChar = guninthas[vowel] ?? '';
      
      widget.onKeyTap(combinedChar);
      
      // Reset state
      setState(() {
        _showGuninthas = false;
        _selectedConsonant = null;
      });
    }
  }

  void _handleRegularKeyTap(String key) {
    widget.onKeyTap(key);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: _showGuninthas ? _buildGuninthaKeyboard() : _buildDefaultKeyboard(),
    );
  }

  Widget _buildDefaultKeyboard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _defaultKeyRows.map((keyRow) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: keyRow.map((key) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: SizedBox(
                  // Fixed width for most keys, with space and backspace being wider
                  width: key == ' ' ? 80.0 : (key == '⌫' ? 60.0 : 40.0),
                  height: 40.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(2.0),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: _teluguConsonants.contains(key) ? Colors.blue[100] : null,
                    ),
                    onPressed: () {
                      if (_teluguConsonants.contains(key)) {
                        _handleConsonantTap(key);
                      } else {
                        _handleRegularKeyTap(key);
                      }
                    },
                    child: Text(key == ' ' ? 'Space' : key),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGuninthaKeyboard() {
    // Display guninthas as a grid
    const int columnsPerRow = 4;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show which consonant is selected
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Adding vowel mark to: $_selectedConsonant',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // Build rows of guninthas
        for (int i = 0; i < _teluguVowels.length; i += columnsPerRow)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int j = i; j < i + columnsPerRow && j < _teluguVowels.length; j++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: SizedBox(
                      width: 60.0,
                      height: 40.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(2.0),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () => _handleGuninthaTap(_teluguVowels[j]),
                        child: Text(_teluguVowels[j]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // Back button
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
            ),
            onPressed: () {
              setState(() {
                _showGuninthas = false;
                _selectedConsonant = null;
              });
            },
            child: const Text('Back to Main Keyboard'),
          ),
        ),
      ],
    );
  }
}