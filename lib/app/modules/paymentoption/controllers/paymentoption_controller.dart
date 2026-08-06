// payment_option_controller.dart
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentoptionController extends GetxController {
  late Razorpay razorpay;
  late String title;
  late String price;
  late String oldPrice;
  late String trialPrice;
  late String trialDuration;
  RxBool isProcessing = false.obs;
  RxString totalAmount = "".obs;

  @override
  void onInit() {
    super.onInit();
    try {
      final args = Get.arguments;
      title = args["title"] ?? "Premium Plan";
      price = args["price"] ?? "299";
      oldPrice = args["oldPrice"] ?? "499";
      trialPrice = args["trialPrice"] ?? "0";
      trialDuration = args["trialDuration"] ?? "7";
      totalAmount.value = price;
      
      initializeRazorpay();
    } catch (e) {
      print("Error initializing payment controller: $e");
      CustomToast.error("Failed to initialize payment");
    }
  }

  void initializeRazorpay() {
    try {
      razorpay = Razorpay();
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e) {
      print("Error initializing Razorpay: $e");
      CustomToast.error("Payment service unavailable");
    }
  }

  @override
  void onClose() {
    try {
      if (razorpay != null) {
        razorpay.clear();
      }
    } catch (e) {
      print("Error closing Razorpay: $e");
    }
    super.onClose();
  }

  void openCheckout() {
    if (isProcessing.value) {
      return; // Prevent multiple taps
    }
    _getUserDataAndOpenPayment();
  }

  void _getUserDataAndOpenPayment() async {
    try {
      isProcessing.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final mobile = prefs.getString('mobile') ?? '9876543210';
      final email = prefs.getString('email') ?? 'user@example.com';
      
      // Calculate amount
      double amount = _calculateAmount();
      
      if (amount <= 0) {
        CustomToast.error("Invalid payment amount");
        isProcessing.value = false;
        return;
      }

      var options = {
        'key': 'rzp_test_TFlJuP5dNeFUjo', // Replace with your actual key
        'amount': (amount * 100).toInt(),
        'name': 'Sahajeevan',
        'description': title,
        'prefill': {
          'contact': mobile.toString(),
          'email': email,
        },
        'theme': {
          'color': '#FF6A00',
        },
        'modal': {
          'ondismiss': () {
            CustomToast.warning("Payment cancelled");
            isProcessing.value = false;
          }
        }
      };

      // Open Razorpay
      razorpay.open(options);
      isProcessing.value = false;
    } catch (e) {
      print("Razorpay error: $e");
      CustomToast.error("Payment initialization failed");
      isProcessing.value = false;
    }
  }

  double _calculateAmount() {
    try {
      String cleanPrice = price.replaceAll("₹", "").replaceAll(",", "").trim();
      double amount = double.parse(cleanPrice);
      
      // If it's a trial with ₹0, charge after trial amount
      if (trialPrice == "0") {
        String cleanOldPrice = oldPrice.replaceAll("₹", "").replaceAll(",", "").trim();
        amount = double.parse(cleanOldPrice);
      }
      
      return amount;
    } catch (e) {
      print("Error calculating amount: $e");
      return 0;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    try {
      print("Payment Success - ID: ${response.paymentId}");
      CustomToast.success("Payment Successful! 🎉");
      
      // Navigate to success screen
      Get.offNamed('/payment-success', arguments: {
        'paymentId': response.paymentId,
        'amount': price,
        'plan': title,
      });
    } catch (e) {
      print("Error handling payment success: $e");
      CustomToast.error("Payment completed but failed to navigate");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    try {
      print("Payment Error - Code: ${response.code}, Message: ${response.message}");
      String errorMessage = response.message ?? 'Please try again';
      
      // Handle specific error codes
      if (response.code == -1) {
        errorMessage = "Payment cancelled by user";
        CustomToast.warning(errorMessage);
      } else if (response.code == -2) {
        errorMessage = "Network error. Please check your connection";
        CustomToast.error(errorMessage);
      } else {
        CustomToast.error("Payment Failed: $errorMessage");
      }
    } catch (e) {
      print("Error handling payment error: $e");
      CustomToast.error("Payment failed. Please try again");
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    try {
      print("External Wallet: ${response.walletName}");
      CustomToast.info("Payment via ${response.walletName}");
    } catch (e) {
      print("Error handling external wallet: $e");
    }
  }

  String getDisplayPrice() {
    if (trialPrice == "0") {
      return "Start Trial - ₹${oldPrice}/month";
    } else {
      return "Pay ₹${price}";
    }
  }
}