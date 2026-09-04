# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Play Integrity API (Phone Auth ke liye zaroori)
-keep class com.google.android.play.core.integrity.** { *; }
-dontwarn com.google.android.play.core.integrity.**

# reCAPTCHA / SafetyNet related
-keep class com.google.android.gms.safetynet.** { *; }

# Firebase Auth models (data classes safe rakhne ke liye)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.firebase.auth.** { *; }

# Flutter Firebase plugin classes
-keep class io.flutter.plugins.firebase.** { *; }