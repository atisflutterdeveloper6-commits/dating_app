import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../modules/bio/bindings/bio_binding.dart';
import '../modules/bio/views/bio_view.dart';
import '../modules/birthday/bindings/birthday_binding.dart';
import '../modules/birthday/views/birthday_view.dart';
import '../modules/blockuser/bindings/blockuser_binding.dart';
import '../modules/blockuser/views/blockuser_view.dart';
import '../modules/call/bindings/call_binding.dart';
import '../modules/call/views/call_view.dart';
import '../modules/cancelmembership/bindings/cancelmembership_binding.dart';
import '../modules/cancelmembership/views/cancelmembership_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/contactsupport/bindings/contactsupport_binding.dart';
import '../modules/contactsupport/views/contactsupport_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/dateofbirth/bindings/dateofbirth_binding.dart';
import '../modules/dateofbirth/views/dateofbirth_view.dart';
import '../modules/discover/bindings/discover_binding.dart';
import '../modules/discover/views/discover_view.dart';
import '../modules/editphoto/bindings/editphoto_binding.dart';
import '../modules/editphoto/views/editphoto_view.dart';
import '../modules/editprofile/bindings/editprofile_binding.dart';
import '../modules/editprofile/views/editprofile_view.dart';
import '../modules/favorite/bindings/favorite_binding.dart';
import '../modules/favorite/views/favorite_view.dart';
import '../modules/gender/bindings/gender_binding.dart';
import '../modules/gender/views/gender_view.dart';
import '../modules/height/bindings/height_binding.dart';
import '../modules/height/views/height_view.dart';
import '../modules/helpandsupport/bindings/helpandsupport_binding.dart';
import '../modules/helpandsupport/views/helpandsupport_view.dart';
import '../modules/homepage/bindings/homepage_binding.dart';
import '../modules/homepage/views/homepage_view.dart';
import '../modules/inbox/bindings/inbox_binding.dart';
import '../modules/inbox/views/inbox_view.dart';
import '../modules/intrestedin/bindings/intrestedin_binding.dart';
import '../modules/intrestedin/views/intrestedin_view.dart';
import '../modules/invoice/bindings/invoice_binding.dart';
import '../modules/invoice/views/invoice_view.dart';
import '../modules/like/bindings/like_binding.dart';
import '../modules/like/views/like_view.dart';
import '../modules/like2/bindings/like2_binding.dart';
import '../modules/like2/views/like2_view.dart';
import '../modules/location_permission/bindings/location_permission_binding.dart';
import '../modules/location_permission/views/location_permission_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/loginconfirmation/bindings/loginconfirmation_binding.dart';
import '../modules/loginconfirmation/views/loginconfirmation_view.dart';
import '../modules/lookingfor/bindings/lookingfor_binding.dart';
import '../modules/lookingfor/views/lookingfor_view.dart';
import '../modules/notificatoin/bindings/notificatoin_binding.dart';
import '../modules/notificatoin/views/notificatoin_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/otp/bindings/otp_binding.dart';
import '../modules/otp/views/otp_view.dart';
import '../modules/paymentoption/bindings/paymentoption_binding.dart';
import '../modules/paymentoption/views/paymentoption_view.dart';
import '../modules/paymentplan/bindings/paymentplan_binding.dart';
import '../modules/paymentplan/views/paymentplan_view.dart';
import '../modules/paymentsuccess/bindings/paymentsuccess_binding.dart';
import '../modules/paymentsuccess/views/paymentsuccess_view.dart';
import '../modules/position/bindings/position_binding.dart';
import '../modules/position/views/position_view.dart';
import '../modules/primiumplan/bindings/primiumplan_binding.dart';
import '../modules/primiumplan/views/primiumplan_view.dart';
import '../modules/privacypolicy/bindings/privacypolicy_binding.dart';
import '../modules/privacypolicy/views/privacypolicy_view.dart';
import '../modules/profilebio/bindings/profilebio_binding.dart';
import '../modules/profilebio/views/profilebio_view.dart';
import '../modules/profiledetail/bindings/profiledetail_binding.dart';
import '../modules/profiledetail/views/profiledetail_view.dart';
import '../modules/profilegender/bindings/profilegender_binding.dart';
import '../modules/profilegender/views/profilegender_view.dart';
import '../modules/profileintrests/bindings/profileintrests_binding.dart';
import '../modules/profileintrests/views/profileintrests_view.dart';
import '../modules/profilesetup/bindings/profilesetup_binding.dart';
import '../modules/profilesetup/views/profilesetup_view.dart';
import '../modules/safetyandpolicy/bindings/safetyandpolicy_binding.dart';
import '../modules/safetyandpolicy/views/safetyandpolicy_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/sexualorientaion/bindings/sexualorientaion_binding.dart';
import '../modules/sexualorientaion/views/sexualorientaion_view.dart';
import '../modules/snotifications/bindings/snotifications_binding.dart';
import '../modules/snotifications/views/snotifications_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/tellmeaboutyou/bindings/tellmeaboutyou_binding.dart';
import '../modules/tellmeaboutyou/views/tellmeaboutyou_view.dart';
import '../modules/termsandconditions/bindings/termsandconditions_binding.dart';
import '../modules/termsandconditions/views/termsandconditions_view.dart';
import '../modules/verification/bindings/verification_binding.dart';
import '../modules/verification/views/verification_view.dart';
import '../modules/weight/bindings/weight_binding.dart';
import '../modules/weight/views/weight_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () =>  SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.HOMEPAGE,
      page: () => HomepageView(),
      binding: HomepageBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: '/otp',
      page: () => const OtpView(
        verificationId: '', // Default values
        phoneNumber: '',
      ),
    ),
    GetPage(
      name: _Paths.LOGINCONFIRMATION,
      page: () {
        // 🔥 Get.arguments se phone number receive karo
        final String phoneNumber = Get.arguments as String? ?? '';
        return LoginconfirmationView(phoneNumber: phoneNumber);
      },
      binding: LoginconfirmationBinding(),
    ),
    GetPage(
      name: _Paths.LOCATION_PERMISSION,
      page: () => const LocationPermissionView(),
      binding: LocationPermissionBinding(),
    ),
    GetPage(
      name: _Paths.PROFILESETUP,
      page: () => const ProfilesetupView(),
      binding: ProfilesetupBinding(),
    ),
    GetPage(
      name: _Paths.TELLMEABOUTYOU,
      page: () => const TellmeaboutyouView(),
      binding: TellmeaboutyouBinding(),
    ),
    GetPage(
      name: _Paths.BIRTHDAY,
      page: () => BirthdayView(),
      binding: BirthdayBinding(),
    ),
    GetPage(
      name: _Paths.POSITION,
      page: () => const PositionView(),
      binding: PositionBinding(),
    ),
    GetPage(
      name: _Paths.GENDER,
      page: () => const GenderView(),
      binding: GenderBinding(),
    ),
    GetPage(
      name: _Paths.SEXUALORIENTAION,
      page: () => const SexualorientaionView(),
      binding: SexualorientaionBinding(),
    ),
    GetPage(
      name: _Paths.INTRESTEDIN,
      page: () => const IntrestedinView(),
      binding: IntrestedinBinding(),
    ),
    GetPage(
      name: _Paths.LOOKINGFOR,
      page: () => const LookingforView(),
      binding: LookingforBinding(),
    ),
    GetPage(
      name: _Paths.BIO,
      page: () => const BioView(),
      binding: BioBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.INBOX,
      page: () => InboxView(),
      binding: InboxBinding(),
    ),
    GetPage(
      name: _Paths.LIKE,
      page: () => const LikeView(),
      binding: LikeBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATOIN,
      page: () => NotificatoinView(),
      binding: NotificatoinBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.EDITPROFILE,
      page: () => EditprofileView(),
      binding: EditprofileBinding(),
    ),
    GetPage(
      name: _Paths.EDITPHOTO,
      page: () => const EditphotoView(),
      binding: EditphotoBinding(),
    ),
    GetPage(
      name: _Paths.DATEOFBIRTH,
      page: () => DateofbirthView(),
      binding: DateofbirthBinding(),
    ),
    GetPage(
      name: _Paths.HEIGHT,
      page: () => HeightView(),
      binding: HeightBinding(),
    ),
    GetPage(
      name: _Paths.WEIGHT,
      page: () => WeightView(),
      binding: WeightBinding(),
    ),
    GetPage(
      name: _Paths.PROFILEGENDER,
      page: () => ProfilegenderView(),
      binding: ProfilegenderBinding(),
    ),
    GetPage(
      name: _Paths.PROFILEBIO,
      page: () => ProfilebioView(),
      binding: ProfilebioBinding(),
    ),
    GetPage(
      name: _Paths.PROFILEINTRESTS,
      page: () => ProfileintrestsView(),
      binding: ProfileintrestsBinding(),
    ),
    GetPage(
      name: _Paths.LIKE2,
      page: () => Like2View(),
      binding: Like2Binding(),
    ),
    GetPage(
      name: _Paths.FAVORITE,
      page: () => FavoriteView(),
      binding: FavoriteBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.PROFILEDETAIL,
      page: () => const ProfiledetailView(),
      binding: ProfiledetailBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACYPOLICY,
      page: () => const PrivacypolicyView(),
      binding: PrivacypolicyBinding(),
    ),
    GetPage(
      name: _Paths.TERMSANDCONDITIONS,
      page: () => const TermsandconditionsView(),
      binding: TermsandconditionsBinding(),
    ),
    GetPage(
      name: _Paths.HELPANDSUPPORT,
      page: () => const HelpandsupportView(),
      binding: HelpandsupportBinding(),
    ),
    GetPage(
      name: _Paths.SAFETYANDPOLICY,
      page: () => const SafetyandpolicyView(),
      binding: SafetyandpolicyBinding(),
    ),
    GetPage(
      name: _Paths.SNOTIFICATIONS,
      page: () => const SnotificationsView(),
      binding: SnotificationsBinding(),
    ),
    GetPage(
      name: _Paths.VERIFICATION,
      page: () => const VerificationView(),
      binding: VerificationBinding(),
    ),
    GetPage(
      name: _Paths.BLOCKUSER,
      page: () => const BlockuserView(),
      binding: BlockuserBinding(),
    ),
    GetPage(
      name: _Paths.PRIMIUMPLAN,
      page: () => const PrimiumplanView(),
      binding: PrimiumplanBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENTPLAN,
      page: () => const PaymentplanView(),
      binding: PaymentplanBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENTSUCCESS,
      page: () => const PaymentsuccessView(),
      binding: PaymentsuccessBinding(),
    ),
    GetPage(
      name: _Paths.CANCELMEMBERSHIP,
      page: () => const CancelmembershipView(),
      binding: CancelmembershipBinding(),
    ),
    GetPage(
      name: _Paths.DISCOVER,
      page: () => const DiscoverView(),
      binding: DiscoverBinding(),
    ),
    GetPage(
      name: _Paths.CONTACTSUPPORT,
      page: () => const ContactsupportView(),
      binding: ContactsupportBinding(),
    ),
    GetPage(
      name: _Paths.INVOICE,
      page: () => const InvoiceView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENTOPTION,
      page: () => const PaymentoptionView(),
      binding: PaymentoptionBinding(),
    ),
    GetPage(
      name: _Paths.CALL,
      page: () => const CallView(),
      binding: CallBinding(),
    ),
  ];
}
