import 'package:flutter/material.dart';

void main() {
  runApp(const NeonCApp());
}

class NeonCApp extends StatefulWidget {
  const NeonCApp({super.key});

  @override
  State<NeonCApp> createState() => _NeonCAppState();
}

class _NeonCAppState extends State<NeonCApp> {
  bool _isDark = true;

  ThemeData get _lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.cyan,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Orbitron',
        colorScheme: const ColorScheme.light(
          primary: Colors.cyan,
          secondary: Colors.pinkAccent,
        ),
      );

  ThemeData get _darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF181A20),
        fontFamily: 'Orbitron',
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.pinkAccent,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeonC Calculator',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: CalculatorScreen(
        isDark: _isDark,
        onToggleTheme: () {
          setState(() {
            _isDark = !_isDark;
          });
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const CalculatorScreen({super.key, required this.isDark, required this.onToggleTheme});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';

  final List<String> _buttons = [
    'C', '⌫', '%', '/',
    '7', '8', '9', 'x',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', '=',
  ];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        _calculateResult();
      } else {
        String toAdd = value == 'x' ? '*' : value;
        _expression += toAdd;
      }
    });
  }

  void _calculateResult() {
    String exp = _expression.replaceAll('x', '*');
    try {
      if (exp.isEmpty || !RegExp(r'^[0-9+\-*/%.]+').hasMatch(exp)) {
        _result = 'Error';
        return;
      }
      _result = _evaluateExpression(exp);
    } catch (e) {
      _result = 'Error';
    }
  }

  String _evaluateExpression(String exp) {
    try {
      exp = exp.replaceAll('--', '+');
      double res = _parse(exp);
      if (res % 1 == 0) {
        return res.toInt().toString();
      } else {
        // Remove trailing zeros and a possible trailing decimal point
        return res.toStringAsFixed(6).replaceFirst(RegExp(r'([.]?0+)\$'), '');
      }
    } catch (e) {
      return 'Error';
    }
  }

  double _parse(String exp) {
    List<String> tokens = [];
    String num = '';
    for (int i = 0; i < exp.length; i++) {
      String c = exp[i];
      if ('0123456789.'.contains(c)) {
        num += c;
      } else {
        if (num.isNotEmpty) {
          tokens.add(num);
          num = '';
        }
        tokens.add(c);
      }
    }
    if (num.isNotEmpty) tokens.add(num);
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*' || tokens[i] == '/' || tokens[i] == '%') {
        double a = double.parse(tokens[i - 1]);
        double b = double.parse(tokens[i + 1]);
        double r = 0;
        if (tokens[i] == '*') r = a * b;
        if (tokens[i] == '/') r = a / b;
        if (tokens[i] == '%') r = a % b;
        tokens[i - 1] = r.toString();
        tokens.removeAt(i);
        tokens.removeAt(i);
        i -= 1;
      }
    }
    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      double b = double.parse(tokens[i + 1]);
      if (op == '+') result += b;
      if (op == '-') result -= b;
    }
    return result;
  }

  Color _getButtonColor(String value) {
    if (value == 'C' || value == '⌫') {
      return widget.isDark ? Colors.pinkAccent : Colors.pink;
    } else if (value == '/' || value == 'x' || value == '-' || value == '+') {
      return widget.isDark ? Colors.cyanAccent : Colors.cyan;
    } else if (value == '=') {
      return widget.isDark ? Colors.greenAccent : Colors.green;
    } else {
      return widget.isDark ? Colors.white10 : Colors.black12;
    }
  }

  Color _getTextColor(String value) {
    if (value == 'C' || value == '⌫') {
      return Colors.white;
    } else if (value == '/' || value == 'x' || value == '-' || value == '+') {
      return Colors.white;
    } else if (value == '=') {
      return Colors.black;
    } else {
      return widget.isDark ? Colors.cyanAccent : Colors.black;
    }
  }

  BoxDecoration _neonBoxDecoration(Color color, {bool isActive = false}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        colors: [
          color.withOpacity(isActive ? 0.7 : 0.5),
          color.withOpacity(0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.7),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxHeight > constraints.maxWidth;
        final buttonHeight = isPortrait
            ? constraints.maxHeight * 0.09
            : constraints.maxHeight * 0.18;
        final buttonFont = isPortrait
            ? constraints.maxHeight * 0.035
            : constraints.maxHeight * 0.06;
        final displayFont = isPortrait
            ? constraints.maxHeight * 0.06
            : constraints.maxHeight * 0.10;
        final resultFont = isPortrait
            ? constraints.maxHeight * 0.09
            : constraints.maxHeight * 0.15;
        return Scaffold(
          appBar: AppBar(
            title: const Text('NeonC'),
            actions: [
              IconButton(
                icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Toggle Theme',
                onPressed: widget.onToggleTheme,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Display
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: widget.isDark
                          ? [const Color(0xFF23263A), Colors.black]
                          : [Colors.white, Colors.cyan.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isDark
                            ? Colors.cyanAccent.withOpacity(0.25)
                            : Colors.cyan.withOpacity(0.12),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _expression.isEmpty ? '0' : _expression,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: displayFont,
                            color: widget.isDark ? Colors.cyanAccent : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _result,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: resultFont,
                            color: widget.isDark ? Colors.greenAccent : Colors.green,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: widget.isDark
                                    ? Colors.greenAccent.withOpacity(0.7)
                                    : Colors.green.withOpacity(0.5),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Buttons
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: GridView.builder(
                      itemCount: _buttons.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (context, index) {
                        String value = _buttons[index];
                        final color = _getButtonColor(value);
                        final textColor = _getTextColor(value);
                        // Make 0 double width
                        if (value == '0') {
                          return GridTile(
                            footer: const SizedBox.shrink(),
                            child: LayoutBuilder(
                              builder: (context, box) {
                                return Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: GestureDetector(
                                        onTap: () => _onButtonPressed(value),
                                        child: Container(
                                          height: buttonHeight,
                                          decoration: _neonBoxDecoration(color),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 32),
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  fontFamily: 'Orbitron',
                                                  fontSize: buttonFont,
                                                  color: textColor,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1.5,
                                                  shadows: [
                                                    Shadow(
                                                      color: color.withOpacity(0.7),
                                                      blurRadius: 8,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(flex: 1),
                                  ],
                                );
                              },
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () => _onButtonPressed(value),
                          child: Container(
                            height: buttonHeight,
                            decoration: _neonBoxDecoration(color),
                            child: Center(
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: buttonFont,
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: color.withOpacity(0.7),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
