import 'package:firebase_nexus/Profile/ShowProfile.dart';
import 'package:firebase_nexus/adminPages/adminHome.dart';
import 'package:firebase_nexus/appColors.dart';
import 'package:firebase_nexus/helpers/local_database_helper.dart';
import 'package:firebase_nexus/helpers/supabase_helper.dart';
import 'package:firebase_nexus/providers/userProvider.dart';
import 'package:firebase_nexus/tioPages/login.dart';
import 'package:firebase_nexus/tioPages/main.dart';
import 'package:firebase_nexus/widgets/admin_main_screen.dart';
import 'package:firebase_nexus/widgets/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';

import 'Register.dart';
import 'login.dart';
import 'splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final helper = SupabaseHelper();

// Example: check connection
  final connected = await helper.isConnected();
  print(connected ? "✅ Has something in it" : "❌ EMPTY AF");
  print(dotenv.env['SUPABASE_URL']);
  print(dotenv.env['SUPABASE_ANON_KEY']);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    Provider<SupabaseHelper>(create: (_) => SupabaseHelper()),
  ], child: MyApp()));
}

class MyRouteObserver extends NavigatorObserver {
  String? currentRoute;
  // final mainUser = FirebaseAuth.instance.currentUser;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute = route.settings.name;
    print(
        'FunctName: DidPush Current route: ${route.settings.name}'); // Debugging
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute = previousRoute?.settings.name;
    print('FunctName: DidPop Back to: ${route.settings.name}'); // Debugging
  }
}

final MyRouteObserver routeObserver = MyRouteObserver();

class MyApp extends StatefulWidget {
  // User? mainUser; // Pass mainUser to MyApp
  const MyApp({
    super.key,
    // required this.mainUser
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // User? mainUser; // Store mainUser locally

  @override
  void initState() {
    super.initState();
    // mainUser = widget.mainUser; // Assign the mainUser
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (!userProvider.isLoaded) {
      // userProvider.loadUser(context);
    }

    final user = userProvider.user;

    return MaterialApp(
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue), // Change to your desired color
        useMaterial3: true,

        // scaffoldBackgroundColor: Color(0xFFF4F4F4),
        scaffoldBackgroundColor: Colors.white,

        // ✨ Input field theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // background color
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 16),

          labelStyle: const TextStyle(
            color: Color(0xFFD4D0C2),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),

          prefixIconColor: const Color(0xFFD4D0C2),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFE4E4E4), // not focused
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFE27D19), // focused
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2,
            ),
          ),
        ),

        // textTheme: TextTheme(
        //   bodyMedium:
        //       GoogleFonts.rubik(fontSize: 14, color: AppColors.textPrimary),
        //   titleLarge:
        //       GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.bold),
        // ),
        fontFamily: 'Quicksand', // <-- global font
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => guardedRoute(context, settings.name),
        );
      },
    );
  }

  // Widget _routeGuard(
  //     String? routeName, Map<String, dynamic>? user, bool isLoaded) {
  //   final isPublicRoute =
  //       ['/', '/tioWelcome', '/tioLogin', '/register'].contains(routeName);

  //   if (isLoaded && user == null && !isPublicRoute) {
  //     print(routeName);
  //     print(isLoaded ? 'isLoaded' : 'not isLoaded');
  //     print(user != null ? 'user' : 'not user');
  //     print(!isPublicRoute ? '!isPublicRoute' : 'not !isPublicRoute');
  //     return const LoginScreen();
  //   }

  //   switch (routeName) {
  //     case '/':
  //       return const Splash();
  //     case '/tioWelcome':
  //       return const WelcomeScreen();
  //     case '/tioLogin':
  //       return const LoginScreen();
  //     case '/login':
  //       return const MainScreen();
  //     case '/register':
  //       return const Register();
  //     case '/home':
  //       return const MainScreen();
  //     case '/profile':
  //       return const ShowProfile();

  //     //Admin pages
  //     case '/adminHome':
  //       return const AdminMainScreen();

  //     case '/adminAnalytics':
  //       return const AdminMainScreen();

  //     case '/adminProducts':
  //       return const AdminMainScreen();

  //     case '/adminOrders':
  //       return const AdminMainScreen();

  //     default:
  //       return const Splash();
  //   }
  // }
}

final Map<String, WidgetBuilder> routes = {
  '/': (_) => const Splash(),
  '/tioWelcome': (_) => const WelcomeScreen(),
  '/tioLogin': (_) => const LoginScreen(),
  '/register': (_) => const Register(),
  '/home': (_) => const MainScreen(),
  '/profile': (_) => const ShowProfile(),
  '/adminHome': (_) => const AdminHome(),
};

Future<void> safeNavigate(BuildContext context, String route) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final isPublicRoute =
      ['/', '/tioWelcome', '/tioLogin', '/register'].contains(route);

  await userProvider.loadUser(context);

  if (!isPublicRoute && userProvider.user == null) {
    print('functname: safeNavigate');
    print('user: ${userProvider.user}');
    Navigator.pushNamedAndRemoveUntil(context, '/tioLogin', (r) => false);
  } else {
    Navigator.pushNamed(context, route);
  }
}

Widget guardedRoute(BuildContext context, String? routeName) {
  final userProvider = Provider.of<UserProvider>(context, listen: true);
  final user = userProvider.user;
  final isPublicRoute =
      ['/', '/tioWelcome', '/tioLogin', '/register'].contains(routeName);

  if (!userProvider.isLoaded) {
    userProvider.loadUser(context);
  }

  // Not logged in & not a public page → send to login
  if (user == null && !isPublicRoute) {
    print('triggered the not logged in guard!');
    print("user: ${user} ");
    return const LoginScreen();
  }

  // Logged in → if trying to go to login/welcome, redirect to home
  if (user != null && isPublicRoute) {
    if (user['role'] == 1) {
      return AdminHome();
    } else {
      return MainScreen();
    }
  }

  // Normal case: return the actual page (or fallback)
  final builder = routes[routeName] ?? (_) => const Splash();
  return builder(context);
}
