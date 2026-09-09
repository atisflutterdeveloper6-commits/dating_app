import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';

import 'dart:io';

import '../../../custom_widget/custom_appbar.dart';
import '../controllers/invoice_controller.dart';

class InvoiceView extends GetView<InvoiceController> {
  const InvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Safety net — agar route navigation me InvoiceBinding attach nahi
    // hui (jaise Get.to() bina 'binding:' ke call hua), to controller
    // khud yahan register kar do taaki "Controller not found" error na aaye.
    if (!Get.isRegistered<InvoiceController>()) {
      Get.put(InvoiceController());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: const CustomAppBar(
        title: "Invoice",
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─────────────────────────────────────
          // Background Image
          // ─────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              "assets/images/LoginBack2.png",
              fit: BoxFit.cover,
            ),
          ),

          // ─────────────────────────────────────
          // White Opacity Overlay
          // No Blur
          // ─────────────────────────────────────
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.70),
            ),
          ),

          // ─────────────────────────────────────
          // Content
          // ─────────────────────────────────────
          Positioned.fill(
            child: SafeArea(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xffFF6B00),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.75),
                            width: 0.6.w,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60.sp,
                              color: Colors.grey.shade400,
                            ),

                            SizedBox(height: 16.h),

                            Text(
                              controller.errorMessage.value,
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontSize: 13.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 20.h),

                            ElevatedButton(
                              onPressed: controller.retry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffFF6B00),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                              ),
                              child: Text(
                                "Retry",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    16.h,
                    16.w,
                    40.h,
                  ),
                  child: Column(
                    children: [
                      // ─────────────────────────────
                      // Invoice Card
                      // ─────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.75),
                            width: 0.6.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xffFFF2E8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    color: const Color(0xffFF6B00),
                                    size: 26.sp,
                                  ),
                                ),

                                SizedBox(width: 14.w),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.planTitle.value,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      SizedBox(height: 4.h),

                                      Text(
                                        controller.transactionId.value,
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey.shade600,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius:
                                    BorderRadius.circular(30.r),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    controller.displayStatus.value,
                                    style: GoogleFonts.poppins(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 25.h),

                            _row(
                              "Customer",
                              controller.customerName.value,
                            ),

                            _row(
                              "Date",
                              controller.date.value,
                            ),

                            _row(
                              "Payment",
                              controller.paymentMode.value,
                            ),

                            _row(
                              "Transaction ID",
                              controller.transactionId.value,
                            ),

                            SizedBox(height: 20.h),

                            Divider(
                              color: Colors.grey.shade300,
                            ),

                            SizedBox(height: 20.h),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Billing Summary",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),

                            SizedBox(height: 15.h),

                            _priceRow(
                              controller.planTitle.value,
                              controller.priceAfterTrial.value,
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 15.h,
                              ),
                              child: Divider(
                                color: Colors.grey.shade300,
                              ),
                            ),

                            Row(
                              children: [
                                Text(
                                  "Total Paid",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  controller.totalPaidAmount.value,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xffFF6B00),
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // ─────────────────────────────
                      // Download Button
                      // ─────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _downloadInvoice(controller),
                          icon: const Icon(Icons.download),
                          label: Text(
                            "Download Invoice",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFF6B00),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(30.r),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15.h),

                      // ─────────────────────────────
                      // Share Button
                      // ─────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _shareInvoice(controller),
                          icon: const Icon(Icons.share),
                          label: Text(
                            "Share Invoice",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                            const Color(0xffFF6B00),
                            side: const BorderSide(
                              color: Color(0xffFF6B00),
                            ),
                            backgroundColor:
                            Colors.white.withOpacity(0.55),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(30.r),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DOWNLOAD INVOICE ====================

  // 🔥 Uses the native Android/iOS "Save As" dialog (via file_picker) so the
  // user picks a real, visible location (Downloads by default) — unlike
  // getExternalStorageDirectory(), which saves into a hidden app-private
  // folder that never shows up in the Files app.
  Future<void> _downloadInvoice(InvoiceController controller) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final pdf = await _generateInvoicePDF(controller);
      final bytes = await pdf.save();

      Get.back(); // close loading dialog before the native save dialog opens

      final fileName = "Invoice_${controller.transactionId.value}.pdf";

      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Invoice',
        fileName: fileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (savedPath != null) {
        CustomToast.success("Invoice saved successfully!");
      }
      // savedPath == null → user cancelled the save dialog, no toast needed
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      CustomToast.error("Failed to download invoice: $e");
    }
  }

  // ==================== SHARE INVOICE ====================

  Future<void> _shareInvoice(InvoiceController controller) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final pdf = await _generateInvoicePDF(controller);

      final output = await getTemporaryDirectory();
      final file = File(
          "${output.path}/Invoice_${controller.transactionId.value}.pdf");
      await file.writeAsBytes(await pdf.save());

      Get.back();

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "📄 Here is your invoice\n\n"
            "Customer: ${controller.customerName.value}\n"
            "Date: ${controller.date.value}\n"
            "Total Amount: ${controller.totalPaidAmount.value}\n"
            "Status: ${controller.displayStatus.value}",
        subject: "Invoice - ${controller.planTitle.value}",
      );
    } catch (e) {
      Get.back();
      CustomToast.error("Failed to share invoice: $e");
    }
  }

  // ==================== GENERATE PDF ====================

  Future<pw.Document> _generateInvoicePDF(InvoiceController controller) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.orange,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          controller.planTitle.value,
                          style: pw.TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green100,
                        borderRadius: pw.BorderRadius.circular(30),
                      ),
                      child: pw.Text(
                        controller.displayStatus.value,
                        style: pw.TextStyle(
                          color: PdfColors.green800,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Invoice Details
                pw.Container(
                  padding: pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      _pdfRow("Date", controller.date.value),
                      _pdfRow("Customer", controller.customerName.value),
                      _pdfRow("Payment", controller.paymentMode.value),
                      _pdfRow(
                          "Transaction ID", controller.transactionId.value),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Billing Summary
                pw.Text(
                  'Billing Summary',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 15),

                pw.Container(
                  padding: pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      _pdfPriceRow(controller.planTitle.value,
                          controller.priceAfterTrial.value),
                      pw.SizedBox(height: 15),
                      pw.Divider(color: PdfColors.grey400),
                      pw.SizedBox(height: 15),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total Paid',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            controller.totalPaidAmount.value,
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 40),

                // Footer
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Thank you for your purchase!',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'For any queries, contact us at support@datingapp.com',
                        style: pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'Generated on: ${DateTime.now().toString().split(' ').first}',
                        style: pw.TextStyle(
                          color: PdfColors.grey500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  // ==================== PDF HELPER WIDGETS ====================

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(color: PdfColors.grey700, fontSize: 14),
          ),
          pw.Text(value, style: pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  pw.Widget _pdfPriceRow(String label, String amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 14)),
          pw.Text(amount, style: pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _row(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

}