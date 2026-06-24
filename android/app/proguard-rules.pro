# ── Flutter ────────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# ── Kotlin ─────────────────────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class kotlin.Metadata { public <methods>; }
-keepclassmembers class **$WhenMappings { <fields>; }
-keep interface kotlin.coroutines.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**
-keepclassmembernames class kotlinx.** { volatile <fields>; }

# ── Firebase Core / Analytics ──────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ── Firebase Firestore (uses gRPC + protobuf internally) ──────────────────────
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.firestore.** { *; }
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# ── Firebase Auth ──────────────────────────────────────────────────────────────
-keep class com.google.firebase.auth.** { *; }

# ── Google Play Services / Sign-In ─────────────────────────────────────────────
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class io.flutter.plugins.googlesignin.** { *; }

# ── AndroidX / WorkManager ─────────────────────────────────────────────────────
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# ── flutter_local_notifications ────────────────────────────────────────────────
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ── home_widget ────────────────────────────────────────────────────────────────
-keep class es.antonborri.home_widget.** { *; }

# ── connectivity_plus ──────────────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# ── share_plus ─────────────────────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.share.** { *; }

# ── Android components declared in Manifest ────────────────────────────────────
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.app.Service
-keep public class * extends android.app.Activity
-keep public class * extends android.appwidget.AppWidgetProvider

# ── Parcelables ────────────────────────────────────────────────────────────────
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# ── Gson (Firebase internal) ───────────────────────────────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-dontwarn sun.misc.**

# ── Preserve class names for debugging ────────────────────────────────────────
-keepattributes SourceFile,LineNumberTable
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-renamesourcefileattribute SourceFile
