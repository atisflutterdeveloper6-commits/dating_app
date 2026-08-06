import 'package:dating_app/app/custom_widget/location_controller.dart';
import 'package:dating_app/app/custom_widget/notification_services.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';

import 'package:dating_app/app/modules/chat/views/chat_service.dart';
import 'package:dating_app/app/modules/chat/views/upload_services.dart';

import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'app/routes/app_pages.dart';

// ✅ top-level (global) — main() ke bahar, taaki MyApp bhi access kar sake
final GlobalKey<NavigatorState> callNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBFaYJ2MrK0KkI4WjyhB8e_Y4mec_E-QPU',
      appId: '1:968762410313:android:049e10fe8e18e19b884698',
      messagingSenderId: '968762410313',
      projectId: 'datingappproject-ef535',
      storageBucket: 'datingappproject-ef535.firebasestorage.app',
    ),
  );

    // initCloudinary();

  Get.put(LocationController(), permanent: true);
  Get.put(ProfileServiceController());
  Get.put(DashboardController());
  Get.put(ChatService());
  Get.put(StorageService());
  Get.put<UploadService>(UploadService(), permanent: true);

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(callNavigatorKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: callNavigatorKey, // ✅ fixed: variable, not method name
      debugShowCheckedModeBanner: false,
      title: "Dating App",

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}