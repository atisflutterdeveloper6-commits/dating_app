import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'dart:io';

import '../../../custom_widget/custom_appbar.dart';
import '../controllers/invoice_controller.dart';

class InvoiceView extends GetView<InvoiceController> {
  const InvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: const CustomAppBar(
        title: "Invoice",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: .5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [

                  /// Header
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Premium Membership",
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600, // w600 works
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Invoice #INV20260718001",
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: Colors.green.shade200,
                          ),
                        ),
                        child: Text(
                          "PAID",
                          style: GoogleFonts.poppins(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600, // w600 works
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 25.h),

                  _row("Customer", "Pavan Dhote"),
                  _row("Email", "pavan@gmail.com"),
                  _row("Date", "18 Jul 2026"),
                  _row("Payment", "UPI"),
                  _row("Transaction ID", "TXN948563728"),

                  SizedBox(height: 20.h),

                  Divider(color: Colors.grey.shade300),

                  SizedBox(height: 20.h),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Billing Summary",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, // w600 works
                        fontSize: 15.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  _priceRow("Premium Plan", "₹299.00"),
                  _priceRow("GST (18%)", "₹53.82"),
                  _priceRow("Discount", "- ₹20.00"),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: Divider(color: Colors.grey.shade300),
                  ),

                  Row(
                    children: [
                      Text(
                        "Total Paid",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, // w700 works
                          fontSize: 16.sp,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "₹332.82",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, // w700 works
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

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: _downloadInvoice,
                icon: const Icon(Icons.download),
                label: Text(
                  "Download Invoice",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, // w600 works
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF6B00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 15.h),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton.icon(
                onPressed: _shareInvoice,
                icon: const Icon(Icons.share),
                label: Text(
                  "Share Invoice",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, // w600 works
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xffFF6B00),
                  side: const BorderSide(
                    color: Color(0xffFF6B00),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== INVOICE DATA ====================
  
  Map<String, dynamic> get _invoiceData => {
    "invoiceNo": "INV20260718001",
    "date": "18 Jul 2026",
    "customer": "Pavan Dhote",
    "email": "pavan@gmail.com",
    "payment": "UPI",
    "transactionId": "TXN948563728",
    "items": [
      {"description": "Premium Plan", "amount": "₹299.00"},
      {"description": "GST (18%)", "amount": "₹53.82"},
      {"description": "Discount", "amount": "- ₹20.00"},
    ],
    "total": "₹332.82",
    "status": "PAID",
  };

  // ==================== DOWNLOAD INVOICE ====================
  
  Future<void> _downloadInvoice() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Generate PDF
      final pdf = await _generateInvoicePDF();
      
      // Save PDF
      final output = await getExternalStorageDirectory();
      final file = File("${output?.path}/Invoice_${_invoiceData["invoiceNo"]}.pdf");
      await file.writeAsBytes(await pdf.save());
      
      // Close loading dialog
      Get.back();
      
      // Show success message
      _showSnackBar(
        "Invoice downloaded successfully!",
        Colors.green,
        Icons.check_circle,
      );
      
    } catch (e) {
      Get.back();
      _showSnackBar(
        "Failed to download invoice: $e",
        Colors.red,
        Icons.error,
      );
    }
  }

  // ==================== SHARE INVOICE ====================
  
  Future<void> _shareInvoice() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Generate PDF
      final pdf = await _generateInvoicePDF();
      
      // Save temporary file
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/Invoice_${_invoiceData["invoiceNo"]}.pdf");
      await file.writeAsBytes(await pdf.save());
      
      // Close loading dialog
      Get.back();
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: "📄 Here is your invoice #${_invoiceData["invoiceNo"]}\n\n"
               "Customer: ${_invoiceData["customer"]}\n"
               "Date: ${_invoiceData["date"]}\n"
               "Total Amount: ${_invoiceData["total"]}\n"
               "Status: ${_invoiceData["status"]}",
        subject: "Invoice #${_invoiceData["invoiceNo"]}",
      );
      
    } catch (e) {
      Get.back();
      _showSnackBar(
        "Failed to share invoice: $e",
        Colors.red,
        Icons.error,
      );
    }
  }

  // ==================== GENERATE PDF ====================
  
  Future<pw.Document> _generateInvoicePDF() async {
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
                          'Dating App Premium Membership',
                          style: pw.TextStyle(
                            fontSize: 16,
                            // fontWeight: pw.FontWeight.w500, // w500 works in pdf package too
                          ),
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
                        'PAID',
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
                      _pdfRow("Invoice #", _invoiceData["invoiceNo"]),
                      _pdfRow("Date", _invoiceData["date"]),
                      _pdfRow("Customer", _invoiceData["customer"]),
                      _pdfRow("Email", _invoiceData["email"]),
                      _pdfRow("Payment", _invoiceData["payment"]),
                      _pdfRow("Transaction ID", _invoiceData["transactionId"]),
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
                      _pdfPriceRow("Premium Plan", "₹299.00"),
                      _pdfPriceRow("GST (18%)", "₹53.82"),
                      _pdfPriceRow("Discount", "- ₹20.00"),
                      
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
                            '₹332.82',
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
            style: pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 14,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              // fontWeight: pw.FontWeight.w500, // w500 works
              fontSize: 14,
            ),
          ),
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
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
            ),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(
              // fontWeight: pw.FontWeight.w500, // w500 works
              fontSize: 14,
            ),
          ),
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
              fontWeight: FontWeight.w400, // w400 is normal
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, // w500 is medium
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
              fontWeight: FontWeight.w400, // w400 is normal
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, // w500 is medium
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    Get.snackbar(
      "",
      "",
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500, // w500 works
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      isDismissible: true,
    );
  }
}