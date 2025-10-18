
import 'package:firebase_nexus/appColors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    // print(rootUser);
    // // final user = FirebaseAuth.instance.currentUser?.uid;
    // homeRoute = routeObserver.currentRoute;
    // // setUserData();
    // // print('user');
    // // // print(user);
    // if (rootUser != null){
    //   Navigator.pushNamed(context,'/home');
    // }

    // super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void loginNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome to Barangay Nexus!')),
    );
    Navigator.pushNamed(context, '/home');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(35.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    kToolbarHeight - // subtract AppBar height
                    MediaQuery.of(context).padding.top, // subtract status bar
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
                        const Text(
                          'Log In ',
                          style: TextStyle(
                            color: Color(0xFF3F4147),
                            fontSize: 24,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.60,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'Welcome back! Let’s get you signed in.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF797B81),
                            fontSize: 16,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w400,
                            height: 1.03,
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: "Enter email",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF797B81),
                                    size:
                                        22, // Change size here (default is 24)
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter an email!";
                                  } else if (!emailRegex.hasMatch(value)) {
                                    return "Please enter a valid email!";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                obscureText:
                                    _obscureText, // Toggle text visibility
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: "Enter password",
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF797B81),
                                    size: 22,
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8), // Adjust spacing here
                                    child: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF797B81),
                                        size: 22, // Adjusted size
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText =
                                              !_obscureText; // Toggle state
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a password!";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 25),
                              SizedBox(
                                width: double.infinity, // Takes full width
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.primary, // Button background
                                    foregroundColor: Colors.white, // Text color
                                    textStyle: const TextStyle(
                                        fontSize: 16), // Customize text style
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Rounded corners
                                    ),
                                  ),
                                  child: const Text('Login'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "or",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 170),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF8899AE)),
                        children: [
                          const TextSpan(text: "Don't have an account yet? "),
                          TextSpan(
                            text: "Create an account here",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/tioLogin');
                              },
                          ),
                        ],
                      ),
                    ),
 
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
