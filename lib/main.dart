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
  import 'package:media_kit/media_kit.dart';
  import 'package:zego_uikit/zego_uikit.dart';
  import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

  import 'app/routes/app_pages.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  final GlobalKey<NavigatorState> callNavigatorKey = GlobalKey<NavigatorState>();

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
    await GetStorage.init();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyD7s8KYsDuyikhWDuRtSN7hBM3fo_QhczY',
      appId: '1:807100737568:android:12fff9e78d3df48cc9b445',
      messagingSenderId: '807100737568',
      projectId: 'dating-d7ec3',
      storageBucket: 'dating-d7ec3.firebasestorage.app',
    ),
  );

    // ✅ FIX: background handler ko Firebase init ke turant baad, top-level par register karo
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // ✅ FIX: NotificationService initialize karna zaroori hai — pehle ye call hi nahi ho raha tha
    await NotificationService.instance.initialize();

    // ✅ Token fetch/save/print karne ke liye
    await NotificationService.instance.saveFCMToken();

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
      return ScreenUtilInit(
        designSize: const Size(375, 812), // match your Figma/design frame size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            navigatorKey: callNavigatorKey,
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
        },
      );
    }
  }