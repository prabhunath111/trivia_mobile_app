# WorkManager & Room keep rules for R8 / Proguard obfuscation in release builds
 -keep class * extends androidx.room.RoomDatabase { *; }
 -keep class androidx.work.impl.WorkDatabase** { *; }
 -keep class androidx.work.impl.WorkDatabase_Impl { *; }
 -dontwarn androidx.work.impl.**
 # Google Mobile Ads (AdMob) keep rules
 -keep class com.google.android.gms.ads.** { *; }
 -keep class com.google.ads.** { *; }