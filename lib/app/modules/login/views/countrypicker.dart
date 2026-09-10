import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void showCustomCountryPicker({
  required BuildContext context,
  required Function(Country country) onSelect,
}) {
  final List<Country> allCountries = CountryService().getAll();
  List<Country> filteredCountries = List.from(allCountries);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // ================= SHEET =================
                Padding(
                  padding: EdgeInsets.only(top: 28.h),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.78,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 24.h),

                        // ============ TITLE ============
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Select Your Country',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff222222),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // ============ SEARCH ============
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffF5F5F7),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                setModalState(() {
                                  filteredCountries = allCountries
                                      .where((c) => c.name
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                      .toList();
                                });
                              },
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: const Color(0xff555555),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search by your country name',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 12.5.sp,
                                  color: const Color(0xff9699A0),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: const Color(0xff9699A0),
                                  size: 20.sp,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14.h,
                                  horizontal: 8.w,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // ============ LIST ============
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            itemCount: filteredCountries.length,
                            itemBuilder: (context, index) {
                              final country = filteredCountries[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  onSelect(country);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  child: Row(
                                    children: [
                                      Text(
                                        country.flagEmoji,
                                        style: TextStyle(fontSize: 22.sp),
                                      ),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Text(
                                          country.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xff333333),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '+${country.phoneCode}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff9699A0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================ CLOSE BUTTON ================
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}