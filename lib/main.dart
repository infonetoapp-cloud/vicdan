import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'features/social/data/repositories/social_repository_impl.dart';
import 'features/social/presentation/providers/social_providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize TZ
  timezone.initializeTimeZones();

  // Load Env
  await dotenv.load(fileName: "assets/.env");

  final prefs = await SharedPreferences.getInstance();
  final firestore = FirebaseFirestore.instance;

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        firestoreProvider.overrideWithValue(firestore),
        socialRepositoryProvider.overrideWithValue(
          SocialRepositoryImpl(firestore, prefs),
        ),
      ],
      child: const VicDanApp(),
    ),
  );
}
