import 'package:flutter/material.dart';
import 'enter_details.dart'; // Import the EnterDetails page
import '/../api/signup_data.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignIn = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _rememberMe = false;
  bool _termsAccepted = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;

  void _validateFields() {
    setState(() {
      _isEmailValid = _emailController.text.isNotEmpty;
      _isPasswordValid = _passwordController.text.isNotEmpty;

      if (!_isSignIn) {
        _isConfirmPasswordValid = _confirmPasswordController.text.isNotEmpty;

        if (_isEmailValid && _isPasswordValid && _isConfirmPasswordValid) {
          if (_passwordController.text != _confirmPasswordController.text) {
            _isConfirmPasswordValid = false;
          }
        }
      }
    });
  }

  void _handleSignUpOrSignIn() {
    _validateFields();

    if (_isSignIn) {
      if (_isEmailValid && _isPasswordValid) {
        print('Sign In Successful');
        // Add your sign in logic here
      }
    } else {
      if (_isEmailValid &&
          _isPasswordValid &&
          _isConfirmPasswordValid &&
          _termsAccepted) {
        SignupData signupData = SignupData()
          ..email = _emailController.text
          ..password = _passwordController.text
          ..confirmPassword = _confirmPasswordController.text;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnterDetails(signupData: signupData),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBFDFA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(left: 28, top: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/logotervist.png',
                        width: 129,
                        height: 47,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Main Container
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF1F8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSignIn = false;
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isSignIn
                                        ? Colors.white
                                        : const Color(0xFFEEF1F8),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: !_isSignIn
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Sign up',
                                      style: TextStyle(
                                        fontWeight: !_isSignIn
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: !_isSignIn
                                            ? Colors.black
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSignIn = true;
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isSignIn
                                        ? Colors.white
                                        : const Color(0xFFEEF1F8),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: _isSignIn
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Sign in',
                                      style: TextStyle(
                                        fontWeight: _isSignIn
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _isSignIn
                                            ? Colors.black
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email Field
                      Text(
                        'Email address',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: !_isEmailValid ? Colors.red : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isEmailValid
                                ? Colors.grey.shade300
                                : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'example@gmail.com',
                            hintStyle: TextStyle(
                                color: _isEmailValid ? Colors.grey : Colors.red,
                                fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                            suffixIcon: !_isEmailValid
                                ? const Icon(Icons.warning_amber_rounded,
                                    color: Colors.red)
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isEmailValid = value.isNotEmpty;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: !_isPasswordValid ? Colors.red : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isPasswordValid
                                ? Colors.grey.shade300
                                : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                                color:
                                    _isPasswordValid ? Colors.grey : Colors.red,
                                fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!_isPasswordValid)
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Colors.red),
                                IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isPasswordValid = value.isNotEmpty;
                            });
                          },
                        ),
                      ),

                      // Confirm Password - Only for Sign Up
                      if (!_isSignIn) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Confirm password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: !_isConfirmPasswordValid
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isConfirmPasswordValid
                                  ? Colors.grey.shade300
                                  : Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Repeat Password',
                              hintStyle: TextStyle(
                                  color: _isConfirmPasswordValid
                                      ? Colors.grey
                                      : Colors.red,
                                  fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: InputBorder.none,
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!_isConfirmPasswordValid)
                                    const Icon(Icons.warning_amber_rounded,
                                        color: Colors.red),
                                  IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _isConfirmPasswordValid = value.isNotEmpty;
                                if (_passwordController.text != value) {
                                  _isConfirmPasswordValid = false;
                                }
                              });
                            },
                          ),
                        ),
                      ],

                      // Remember Me & Forgot Password (Sign In)
                      if (_isSignIn)
                        Row(
                          children: [
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 0.9,
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember Me',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                // TODO: Implement forgot password
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Terms and Conditions (Sign Up)
                      if (!_isSignIn) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _termsAccepted,
                                  onChanged: (value) {
                                    setState(() {
                                      _termsAccepted = value ?? false;
                                    });
                                  },
                                  shape: const CircleBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: "I've read and agree with "),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(text: ' and our '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Sign Up/Sign In Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSignUpOrSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(double.infinity, 48),
                            elevation: 0,
                          ),
                          child: Text(
                            _isSignIn ? 'Sign in' : 'Sign up',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Divider and Social Sign In/Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 125,
                      child: Divider(color: Colors.black),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      child: Text(
                        _isSignIn ? 'or sign in with' : 'or Sign up with',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 125,
                      child: Divider(color: Colors.black),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Social Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton('assets/images/google.png'),
                    const SizedBox(width: 30),
                    _socialButton('assets/images/apple.png'),
                    const SizedBox(width: 30),
                    _socialButton('assets/images/facebook.png'),
                  ],
                ),

                const SizedBox(height: 20),

                // Sign Up/Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignIn
                          ? 'Don\'t have an account yet? '
                          : 'Already have an account? ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignIn = !_isSignIn;
                        });
                      },
                      child: Text(
                        _isSignIn ? 'Sign Up' : 'Sign in',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String iconAsset) {
    return Container(
      width: 80,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Image.asset(
          iconAsset,
          width: 24,
          height: 24,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
