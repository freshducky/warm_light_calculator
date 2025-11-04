import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/settings_model.dart';
import 'utils/number_formatter.dart';
import 'dart:ui' as ui;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WarmLightCalculatorApp());
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3), // Warm cream background
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Circular loading indicator around the logo
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF8B4513).withOpacity(0.8 * _pulseAnimation.value),
                    ),
                    strokeWidth: 4,
                  ),
                ),
                // Circular logo with pulse animation
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B4513).withOpacity(0.3 * _pulseAnimation.value),
                          blurRadius: 20 * _pulseAnimation.value,
                          spreadRadius: 5 * _pulseAnimation.value,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF8B4513),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/freshducky.jpg',
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 180,
                              height: 180,
                              color: const Color(0xFF8B4513),
                              child: const Icon(
                                Icons.calculate,
                                size: 100,
                                color: Color(0xFFF5E6D3),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WarmLightCalculatorApp extends StatefulWidget {
  const WarmLightCalculatorApp({super.key});

  @override
  State<WarmLightCalculatorApp> createState() => _WarmLightCalculatorAppState();
}

class _WarmLightCalculatorAppState extends State<WarmLightCalculatorApp> {
  final AppSettings _settings = AppSettings();
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settings.loadSettings();
    // Add a small delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _settingsLoaded = true;
      });
    }
  }

  ThemeData _getTheme() {
    // High contrast takes priority
    if (_settings.highContrast) {
      if (_settings.highContrastMode == 'dark') {
        // High contrast dark mode - black background, warm yellow/cream text
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: const Color(0xFFFFEAA7), // Warm yellow
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFEAA7),
            surface: Colors.black,
            background: Colors.black,
            onPrimary: Colors.black,
            onSurface: Color(0xFFFFEAA7),
            onBackground: Color(0xFFFFEAA7),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: Color(0xFFFFEAA7),
            ),
            displayMedium: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: Color(0xFFFFEAA7),
            ),
            headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFFEAA7),
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFFFFEAA7),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Color(0xFFFFEAA7),
            elevation: 0,
            centerTitle: true,
          ),
        );
      } else {
        // High contrast light mode - white background, black text
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.black,
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            surface: Colors.white,
            background: Colors.white,
            onPrimary: Colors.white,
            onSurface: Colors.black,
            onBackground: Colors.black,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
            displayMedium: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
            headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
          ),
        );
      }
    } else if (_settings.darkMode) {
      // Regular dark mode - warm dark theme
      return ThemeData(
        brightness: Brightness.dark,
        primarySwatch: MaterialColor(
          0xFF8B4513,
          <int, Color>{
            50: const Color(0xFF3D1F08),
            100: const Color(0xFF52290B),
            200: const Color(0xFF66330E),
            300: const Color(0xFF7A3D11),
            400: const Color(0xFF8B4513),
            500: const Color(0xFFBF5F1A),
            600: const Color(0xFFCA7C3A),
            700: const Color(0xFFD9A06D),
            800: const Color(0xFFE8C4A0),
            900: const Color(0xFFF5E6D3),
          },
        ),
        scaffoldBackgroundColor: const Color(0xFF2D1810),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF52290B),
          foregroundColor: Color(0xFFD9A06D),
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: Color(0xFFD9A06D),
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: Color(0xFFD9A06D),
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color(0xFFD9A06D),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFFD9A06D),
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B4513),
          secondary: Color(0xFFCA7C3A),
          surface: Color(0xFF3D1F08),
          background: Color(0xFF2D1810),
          onPrimary: Color(0xFFD9A06D),
          onSecondary: Color(0xFF2D1810),
          onSurface: Color(0xFFD9A06D),
          onBackground: Color(0xFFD9A06D),
        ),
      );
    } else {
      // Warm light theme (default)
      return ThemeData(
        primarySwatch: MaterialColor(
          0xFF8B4513,
          <int, Color>{
            50: const Color(0xFFF5E6D3),
            100: const Color(0xFFE8C4A0),
            200: const Color(0xFFD9A06D),
            300: const Color(0xFFCA7C3A),
            400: const Color(0xFFBF5F1A),
            500: const Color(0xFF8B4513),
            600: const Color(0xFF7A3D11),
            700: const Color(0xFF66330E),
            800: const Color(0xFF52290B),
            900: const Color(0xFF3D1F08),
          },
        ),
        scaffoldBackgroundColor: const Color(0xFFF5E6D3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B4513),
          foregroundColor: Color(0xFFF5E6D3),
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: Color(0xFF2D1810),
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2D1810),
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D1810),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2D1810),
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8B4513),
          secondary: Color(0xFFD9A06D),
          surface: Color(0xFFF5E6D3),
          background: Color(0xFFF5E6D3),
          onPrimary: Color(0xFFF5E6D3),
          onSecondary: Color(0xFF2D1810),
          onSurface: Color(0xFF2D1810),
          onBackground: Color(0xFF2D1810),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warm Light Calculator',
      theme: _getTheme(),
      home: _settingsLoaded
          ? CalculatorScreen(settings: _settings, onSettingsChanged: _loadSettings)
          : const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final AppSettings settings;
  final VoidCallback onSettingsChanged;

  const CalculatorScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  String _display = '0';
  String _previousValue = '';
  String _operation = '';
  bool _waitingForOperand = false;
  double _memory = 0.0;
  String? _tipBreakdown; // Stores tip amount for display
  String? _previousDisplay; // For undo functionality
  final FlutterTts _tts = FlutterTts();
  late AnimationController _buttonAnimationController;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Color _getButtonColor(bool isOperation, bool isSpecial, bool isEquals, bool isTip, ThemeData theme) {
    if (widget.settings.highContrast) {
      if (widget.settings.highContrastMode == 'dark') {
        if (isEquals || isSpecial) {
          return const Color(0xFFFFEAA7);
        }
        return Colors.grey[800]!;
      } else {
        if (isEquals || isSpecial) {
          return Colors.black;
        }
        return Colors.grey[300]!;
      }
    }

    // Warm light theme colors
    if (isEquals) {
      return const Color(0xFF8B4513);
    } else if (isTip) {
      return const Color(0xFFC49A6C); // Slightly different warm color for tips
    } else if (isOperation) {
      return const Color(0xFFCA7C3A);
    } else if (isSpecial) {
      return const Color(0xFFBF5F1A);
    } else {
      return const Color(0xFFD9A06D);
    }
  }

  Color _getButtonTextColor(bool isOperation, bool isSpecial, bool isEquals, ThemeData theme) {
    if (widget.settings.highContrast) {
      if (widget.settings.highContrastMode == 'dark') {
        return (isEquals || isSpecial) ? Colors.black : const Color(0xFFFFEAA7);
      } else {
        return (isEquals || isSpecial) ? Colors.white : Colors.black;
      }
    }

    return (isEquals || isSpecial) ? const Color(0xFFF5E6D3) : const Color(0xFF2D1810);
  }

  Color _getDisplayBackgroundColor(ThemeData theme) {
    if (widget.settings.highContrast) {
      if (widget.settings.highContrastMode == 'dark') {
        return Colors.grey[900]!;
      } else {
        return Colors.grey[200]!;
      }
    }
    return const Color(0xFFE8C4A0);
  }

  Color _getDisplayBorderColor(ThemeData theme) {
    if (widget.settings.highContrast) {
      if (widget.settings.highContrastMode == 'dark') {
        return const Color(0xFFFFEAA7);
      } else {
        return Colors.black;
      }
    }
    return const Color(0xFF8B4513);
  }

  Future<void> _playSound() async {
    if (widget.settings.soundEffects) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _speakText(String text) async {
    if (widget.settings.textToSpeech && text != 'Error') {
      await _tts.speak(text);
    }
  }

  Future<void> _copyToClipboard() async {
    if (_display != 'Error') {
      await Clipboard.setData(ClipboardData(text: _display));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _applyTip(double percentage) {
    if (_display == 'Error') return;
    
    try {
      final double value = double.parse(_display.replaceAll(',', ''));
      if (value == 0) return; // Don't calculate tip on zero
      
      _saveStateForUndo(); // Save state before tip calculation
      
      final double tip = value * (percentage / 100);
      final double result = value + tip;
      
      // Round to 2 decimal places (cents) for currency
      final double roundedTip = (tip * 100).round() / 100;
      final double roundedResult = (result * 100).round() / 100;
      
      setState(() {
        _display = _formatNumber(roundedResult);
        _tipBreakdown = 'Tip: ${_formatNumber(roundedTip)}';
        _waitingForOperand = true;
        _operation = ''; // Clear any pending operation
        _previousValue = ''; // Clear previous value
      });
      
      _playSound();
      _speakText(_display);
    } catch (e) {
      setState(() {
        _display = 'Error';
        _waitingForOperand = false;
        _tipBreakdown = null;
      });
      _speakText('Error');
    }
  }

  String _formatNumber(double number) {
    if (number.isNaN || number.isInfinite) return 'Error';
    
    final String numberStr = number % 1 == 0 
        ? number.toInt().toString() 
        : number.toString();
    
    return NumberFormatter.formatNumber(numberStr);
  }

  void _undo() {
    if (_previousDisplay != null) {
      setState(() {
        _display = _previousDisplay!;
        _previousDisplay = null; // Clear after undo so can't undo multiple times
      });
      _playSound();
    }
  }

  void _saveStateForUndo() {
    // Save current state before making changes
    if (_display != 'Error' && _display != '0') {
      _previousDisplay = _display;
    }
  }

  Future<void> _onButtonPressed(String value) async {
    await _playSound();
    
    // Handle undo separately
    if (value == '↶') {
      _undo();
      return;
    }
    
    // Save state before making changes (except for memory operations)
    if (!value.startsWith('M')) {
      _saveStateForUndo();
    }
    
    setState(() {
      if (value == 'C') {
        _display = '0';
        _previousValue = '';
        _operation = '';
        _waitingForOperand = false;
        _tipBreakdown = null;
      } else if (value == '⌫') {
        if (_display != 'Error' && _display.length > 1) {
          String newDisplay = _display.substring(0, _display.length - 1).replaceAll(',', '');
          _display = NumberFormatter.formatNumber(newDisplay);
        } else {
          _display = '0';
        }
      } else if (value == '=') {
        _tipBreakdown = null; // Clear tip breakdown on new calculation
        _calculate();
      } else if (['+', '-', '×', '÷'].contains(value)) {
        _tipBreakdown = null; // Clear tip breakdown on new operation
        if (_operation.isNotEmpty && !_waitingForOperand) {
          _calculate();
        }
        _previousValue = _display.replaceAll(',', '');
        _operation = value;
        _waitingForOperand = true;
      } else if (value.startsWith('M')) {
        _handleMemory(value);
      } else if (value == '.') {
        // Handle decimal point
        if (_waitingForOperand || _display == 'Error') {
          _display = '0.';
          _waitingForOperand = false;
        } else {
          String cleanDisplay = _display.replaceAll(',', '');
          // Only add decimal point if it doesn't already exist
          if (!cleanDisplay.contains('.')) {
            _display = cleanDisplay + '.';
          }
        }
      } else {
        if (_waitingForOperand || _display == 'Error') {
          _display = value;
          _waitingForOperand = false;
          _tipBreakdown = null; // Clear tip breakdown when entering new number
        } else {
          String cleanDisplay = _display.replaceAll(',', '');
          // If display ends with a decimal point, append the digit and format
          if (cleanDisplay.endsWith('.')) {
            _display = cleanDisplay + value;
            // Format only if it's a valid number (has digits before and after decimal)
            try {
              double.parse(_display);
              _display = NumberFormatter.formatNumber(_display);
            } catch (e) {
              // Keep as is if parsing fails
            }
          } else {
            _display = _display == '0' ? value : cleanDisplay + value;
            _display = NumberFormatter.formatNumber(_display);
          }
        }
      }
    });

    if (['+', '-', '×', '÷', '='].contains(value)) {
      await _speakText(value);
    } else if (value.length == 1 && RegExp(r'[0-9]').hasMatch(value)) {
      await _speakText(value);
    }
  }

  void _handleMemory(String operation) {
    try {
      final double currentValue = double.parse(_display.replaceAll(',', ''));
      
      switch (operation) {
        case 'M+':
          _memory += currentValue;
          break;
        case 'M-':
          _memory -= currentValue;
          break;
        case 'MR':
          setState(() {
            _display = _formatNumber(_memory);
            _waitingForOperand = true;
          });
          _speakText(_display);
          break;
        case 'MC':
          _memory = 0.0;
          break;
      }
      _playSound();
    } catch (e) {
      // Handle error silently
    }
  }

  void _calculate() {
    if (_operation.isEmpty || _previousValue.isEmpty) return;

    try {
      double prev = double.parse(_previousValue.replaceAll(',', ''));
      double current = double.parse(_display.replaceAll(',', ''));
      double result = 0;

      switch (_operation) {
        case '+':
          result = prev + current;
          break;
        case '-':
          result = prev - current;
          break;
        case '×':
          result = prev * current;
          break;
        case '÷':
          if (current != 0) {
            result = prev / current;
          } else {
            setState(() {
              _display = 'Error';
              _operation = '';
              _previousValue = '';
              _waitingForOperand = false;
            });
            _speakText('Error');
            return;
          }
          break;
      }

      setState(() {
        _display = _formatNumber(result);
        _operation = '';
        _previousValue = '';
        _waitingForOperand = true;
      });

      _speakText(_display);
    } catch (e) {
      setState(() {
        _display = 'Error';
        _operation = '';
        _previousValue = '';
        _waitingForOperand = false;
      });
      _speakText('Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Warm Light Calculator',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(settings: widget.settings),
                ),
              );
              widget.onSettingsChanged();
              setState(() {}); // Refresh UI
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 2,
              child: GestureDetector(
                onLongPress: _copyToClipboard,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getDisplayBackgroundColor(theme),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getDisplayBorderColor(theme),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_tipBreakdown != null)
                        Text(
                          _tipBreakdown!,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 18,
                            color: theme.textTheme.displayLarge?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.end,
                        ),
                      Text(
                        _display,
                        style: theme.textTheme.displayLarge,
                        textAlign: TextAlign.end,
                      ),
                      if (_operation.isNotEmpty && _previousValue.isNotEmpty)
                        Text(
                          '${NumberFormatter.formatNumber(_previousValue)} $_operation',
                          style: theme.textTheme.headlineLarge,
                          textAlign: TextAlign.end,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Tip buttons row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildTipButton('Tip 15%', 15, theme),
                  const SizedBox(width: 8),
                  _buildTipButton('Tip 20%', 20, theme),
                  const SizedBox(width: 8),
                  _buildTipButton('Tip 25%', 25, theme),
                ],
              ),
            ),
            // Buttons
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Row 1: Memory buttons (M+, M-, MR, MC)
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('M+', isSpecial: true, theme: theme),
                          _buildButton('M-', isSpecial: true, theme: theme),
                          _buildButton('MR', isSpecial: true, theme: theme),
                          _buildButton('MC', isSpecial: true, theme: theme),
                        ],
                      ),
                    ),
                    // Row 2: Clear, Backspace, Divide, Multiply
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('C', isSpecial: true, theme: theme),
                          _buildButton('⌫', isSpecial: true, theme: theme),
                          _buildButton('÷', isOperation: true, theme: theme),
                          _buildButton('×', isOperation: true, theme: theme),
                        ],
                      ),
                    ),
                    // Row 3: 7, 8, 9, Subtract
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('7', theme: theme),
                          _buildButton('8', theme: theme),
                          _buildButton('9', theme: theme),
                          _buildButton('-', isOperation: true, theme: theme),
                        ],
                      ),
                    ),
                    // Row 4: 4, 5, 6, Add
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('4', theme: theme),
                          _buildButton('5', theme: theme),
                          _buildButton('6', theme: theme),
                          _buildButton('+', isOperation: true, theme: theme),
                        ],
                      ),
                    ),
                    // Row 5: 1, 2, 3, Equals
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('1', theme: theme),
                          _buildButton('2', theme: theme),
                          _buildButton('3', theme: theme),
                          _buildButton('=', isOperation: true, isEquals: true, theme: theme),
                        ],
                      ),
                    ),
                    // Row 6: 0, Decimal, Undo
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('0', theme: theme),
                          _buildButton('.', theme: theme),
                          _buildButton('↶', isSpecial: true, theme: theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipButton(String label, double percentage, ThemeData theme) {
    final backgroundColor = _getButtonColor(false, false, false, true, theme);
    final textColor = _getButtonTextColor(false, false, false, theme);
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () => _applyTip(percentage),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            elevation: 2,
            minimumSize: const Size(0, 48), // Minimum touch target
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, {bool isOperation = false, bool isSpecial = false, bool isEquals = false, required ThemeData theme}) {
    final backgroundColor = _getButtonColor(isOperation, isSpecial, isEquals, false, theme);
    final textColor = _getButtonTextColor(isOperation, isSpecial, isEquals, theme);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _buttonAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_buttonAnimationController.value * 0.05),
              child: ElevatedButton(
                onPressed: () async {
                  _buttonAnimationController.forward().then((_) {
                    _buttonAnimationController.reverse();
                  });
                  await _onButtonPressed(text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: textColor,
                  elevation: 2,
                  minimumSize: const Size(0, 48), // Minimum touch target for accessibility
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(text),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _textToSpeech;
  late bool _highContrast;
  late bool _soundEffects;
  late String _highContrastMode;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _textToSpeech = widget.settings.textToSpeech;
    _highContrast = widget.settings.highContrast;
    _soundEffects = widget.settings.soundEffects;
    _highContrastMode = widget.settings.highContrastMode;
    _darkMode = widget.settings.darkMode;
  }

  Future<void> _saveSettings() async {
    widget.settings.textToSpeech = _textToSpeech;
    widget.settings.highContrast = _highContrast;
    widget.settings.soundEffects = _soundEffects;
    widget.settings.highContrastMode = _highContrastMode;
    widget.settings.darkMode = _darkMode;
    await widget.settings.saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Text-to-Speech'),
            subtitle: const Text('Speak numbers and operations'),
            value: _textToSpeech,
            onChanged: (value) {
              setState(() {
                _textToSpeech = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Warm dark theme'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                // Disable high contrast when dark mode is enabled
                if (value) {
                  _highContrast = false;
                }
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('High Contrast Mode'),
            subtitle: const Text('Enhanced visibility for accessibility'),
            value: _highContrast,
            onChanged: (value) {
              setState(() {
                _highContrast = value;
                // Disable dark mode when high contrast is enabled
                if (value) {
                  _darkMode = false;
                }
              });
              _saveSettings();
            },
          ),
          if (_highContrast)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('High Contrast Style'),
                  RadioListTile<String>(
                    title: const Text('Dark (Black background, Yellow text)'),
                    value: 'dark',
                    groupValue: _highContrastMode,
                    onChanged: (value) {
                      setState(() {
                        _highContrastMode = value!;
                      });
                      _saveSettings();
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Light (White background, Black text)'),
                    value: 'light',
                    groupValue: _highContrastMode,
                    onChanged: (value) {
                      setState(() {
                        _highContrastMode = value!;
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Haptic feedback on button press'),
            value: _soundEffects,
            onChanged: (value) {
              setState(() {
                _soundEffects = value;
              });
              _saveSettings();
            },
          ),
          const SizedBox(height: 24),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Long-press the display to copy the result to clipboard.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Privacy Policy',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Last Updated: 2025',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 24),
          Text(
            'Introduction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Warm Light Calculator ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we handle information when you use our calculator application.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          Text(
            'Information We Collect',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Warm Light Calculator does not collect, store, or transmit any personal information. All calculations are performed locally on your device. We do not:\n\n'
            '• Collect personal data\n'
            '• Track your usage\n'
            '• Store calculation history\n'
            '• Share information with third parties\n'
            '• Use analytics or tracking services',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          Text(
            'Local Storage',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'The app stores your preferences (such as text-to-speech settings, theme preferences, and accessibility options) locally on your device. This information never leaves your device and is not accessible to us or any third parties.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          Text(
            'Third-Party Services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Warm Light Calculator does not integrate with any third-party services that collect or share your information.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          Text(
            'Children\'s Privacy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Our app is safe for users of all ages. We do not knowingly collect information from children, and since we do not collect any information, children can use the app safely.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          Text(
            'Changes to This Privacy Policy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated revision date.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          Text(
            'Contact Us',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'If you have any questions about this Privacy Policy, please contact us through the app store listing or our developer profile.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
