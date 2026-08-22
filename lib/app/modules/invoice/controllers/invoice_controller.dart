import 'dart:convert';
import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InvoiceController extends GetxController {
  final StorageService _storage = StorageService();

  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // Display fields (all populated from the API — no hardcoded values)
  var customerName = 'User'.obs;
  var planTitle = ''.obs; // planName OR mainTitle, decided by status
  var date = '-'.obs;
  var paymentMode = 'UPI'.obs; // static — backend will add real mode later
  var transactionId = '-'.obs;
  var totalPaidAmount = '₹0'.obs; // actually charged so far (bottom "Total Paid")
  var priceAfterTrial = '₹0'.obs; // plan's regular price (Billing Summary line)
  var status = ''.obs; // raw backend status — used for internal logic
  var displayStatus = ''.obs; // user-friendly badge text (e.g. "PAID")

  @override
  void onInit() {
    super.onInit();
    fetchInvoiceData();
  }

  // Same pattern used elsewhere (PremiumController) — always returns a
  // fresh, valid Firebase ID token, force-refreshing if it's near expiry.
  Future<String?> _getFirebaseAuthToken({bool forceRefresh = false}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return _storage.getLoginToken() ?? _storage.getToken();
      }

      bool needsForceRefresh = forceRefresh;
      if (!needsForceRefresh) {
        try {
          final tokenResult = await user.getIdTokenResult(false);
          final expiry = tokenResult.expirationTime;
          if (expiry == null ||
              DateTime.now()
                  .isAfter(expiry.subtract(const Duration(minutes: 5)))) {
            needsForceRefresh = true;
          }
        } catch (_) {
          needsForceRefresh = true;
        }
      }

      final token = await user.getIdToken(needsForceRefresh);
      if (token != null && token.isNotEmpty) {
        await _storage.saveToken(token);
        await _storage.saveLoginToken(token);
      }
      return token;
    } catch (e) {
      print('❌ Error getting Firebase token: $e');
      return _storage.getLoginToken() ?? _storage.getToken();
    }
  }

  // Logged-in user's display name — from locally cached profile data
  // (saved by ProfileServiceController on profile create/update), since
  // the subscription API itself doesn't return the user's name.
  void _loadCustomerNameFromStorage() {
    final profileData = _storage.getProfileData();
    if (profileData != null) {
      final firstName = (profileData['firstName'] ?? '').toString();
      final lastName = (profileData['lastName'] ?? '').toString();
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        customerName.value = fullName;
        return;
      }
    }
    final phone = _storage.getPhoneNumber();
    customerName.value = (phone != null && phone.isNotEmpty) ? phone : 'User';
  }

  Future<void> fetchInvoiceData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      _loadCustomerNameFromStorage();

      var token = await _getFirebaseAuthToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login to view your invoice';
        return;
      }

      Future<http.Response> sendRequest(String t) {
        return http.get(
          Uri.parse('${ApiUrls.baseUrl}/v1/api/user-subscription/me'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
      }

      var response = await sendRequest(token);

      // 401 → force-refresh token, retry once
      if (response.statusCode == 401) {
        final freshToken = await _getFirebaseAuthToken(forceRefresh: true);
        if (freshToken != null && freshToken.isNotEmpty) {
          token = freshToken;
          response = await sendRequest(token);
        }
      }

      print('Invoice Response Status: ${response.statusCode}');
      print('Invoice Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];
          final plan = data['subscriptionPlan'];

          status.value = data['status'] ?? '';

          // 🔥 Agar full subscription amount actually charge ho chuka hai
          // (status active/charged) to planName dikhao. Agar abhi sirf
          // trial/authentication hui hai (status authenticated/created),
          // to mainTitle dikhao — kyunki real subscription abhi start
          // nahi hui.
          final bool isFullyPaid =
              status.value == 'active' || status.value == 'charged';

          if (plan != null) {
            planTitle.value = isFullyPaid
                ? (plan['planName'] ?? 'Premium')
                : (plan['mainTitle'] ?? 'Unlock Premium');

            // Billing Summary line always shows the plan's regular price
            // (what it costs per cycle), independent of what's actually
            // been charged so far.
            final priceAfterTrialRaw = plan['priceAfterTrial'];
            priceAfterTrial.value = (priceAfterTrialRaw != null &&
                    priceAfterTrialRaw.toString().isNotEmpty)
                ? '₹${priceAfterTrialRaw.toString()}'
                : '₹0';
          }

          // 🔥 Total Paid = jo ACTUALLY charge hua hai ab tak.
          // Status 'authenticated' matlab sirf trial/mandate-auth amount
          // (authAmount) charge hua hai, poora 'amount' nahi. Sirf
          // active/charged status par hi poora 'amount' dikhao.
          final int amountPaise = isFullyPaid
              ? (data['amount'] ?? 0)
              : (data['authAmount'] ?? 0);
          totalPaidAmount.value =
              '₹${(amountPaise / 100).toStringAsFixed(0)}';

          // 🔥 User-friendly badge — raw backend status ('authenticated',
          // 'created', etc.) kabhi seedha UI par mat dikhao.
          switch (status.value) {
            case 'authenticated':
            case 'active':
            case 'charged':
              displayStatus.value = 'PAID';
              break;
            case 'created':
              displayStatus.value = 'PENDING';
              break;
            case 'cancelled':
              displayStatus.value = 'CANCELLED';
              break;
            case 'failed':
              displayStatus.value = 'FAILED';
              break;
            default:
              displayStatus.value = status.value.toUpperCase();
          }

          transactionId.value = data['razorpayPaymentId'] ?? '-';
          date.value = data['updatedAt'] ?? '-';

          // Static for now — backend will add a real payment-mode field
          // later; switch this to read from `data['paymentMode']` once
          // that's available.
          paymentMode.value = 'UPI';
        } else {
          errorMessage.value = jsonData['message'] ?? 'No invoice data found';
        }
      } else if (response.statusCode == 404) {
        errorMessage.value = 'No subscription found';
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Error fetching invoice: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void retry() {
    fetchInvoiceData();
  }
}