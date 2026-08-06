import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../custom_widget/custom_appbar.dart';

class SnotificationsView extends StatefulWidget {
  const SnotificationsView({super.key});

  @override
  State<SnotificationsView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<SnotificationsView> {
  bool pauseAll = true;
  bool newMatches = true;
  bool vote = true;
  bool messages = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: const CustomAppBar(title: "Notification"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xffECECEC),
                  ),
                ),
              ),
              child: Text(
                "Stay in the loop with Flirt Fever notifications! Get alerts when you have a match, a new message, or when someone likes your profile.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xff7A7A7A),
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Manage Your Notifications",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Stay connected! Share your preferred contact information, ensuring seamless communication.",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xff7A7A7A),
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 18),

            _notificationTile(
              title: "Pause all",
              subtitle: "Temporarily pause notifications",
              value: pauseAll,
              onChanged: (v) {
                setState(() {
                  pauseAll = v;
                });
              },
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Other Notifications",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Never miss a chance to start a meaningful conversation and explore exciting possibilities.",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xff7A7A7A),
                  height: 1.6,
                ),
              ),
            ),

            _notificationTile(
              title: "Messages",
              subtitle: "Someone send you a new message.",
              value: messages,
              onChanged: (v) {
                setState(() {
                  messages = v;
                });
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _notificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xff7A7A7A),
                  ),
                ),
              ],
            ),
          ),
         Transform.scale(
  scale: 0.75,
  child: Switch(
    value: value,
    onChanged: onChanged,

    activeColor: Colors.white,
    activeTrackColor: const Color(0xffFF6A00),

    inactiveThumbColor: Colors.white,
    inactiveTrackColor: const Color(0xffE6E6E6),

    // Border remove
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    trackOutlineWidth: WidgetStateProperty.all(0),
  ),
),
        ],
      ),
    );
  }


}