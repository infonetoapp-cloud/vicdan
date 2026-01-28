# VİCDAN App - ProGuard Rules
# Production-ready obfuscation and optimization rules

## Flutter-specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.** { *; }

## Preserve Flutter engine native methods
-keepclassmembers class * {
    @io.flutter.embedding.engine.** *;
}

## Google Play Core (Fix for R8 compilation error)
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

## Google Play Services (if used in future)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

## Firebase (for future Crashlytics/Analytics)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

## Preserve line numbers for crash reports
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

## Preserve annotations
-keepattributes *Annotation*

## Preserve serialization
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

## Preserve native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Preserve enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

## Preserve Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

## Preserve Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

## Retrofit/OkHttp (if added in future for API calls)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

## Gson/JSON serialization (if used)
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

## SQLite/Room/Drift
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-dontwarn androidx.room.**

## Geolocation plugins
-keep class com.baseflow.geolocator.** { *; }
-keep class com.baseflow.geocoding.** { *; }
-dontwarn com.baseflow.**

## Notification plugins
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

## Permission handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

## Shared preferences
-keep class androidx.preference.** { *; }
-dontwarn androidx.preference.**

## Path provider
-keep class io.flutter.plugins.pathprovider.** { *; }

## Remove logging in release (optimization)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

## Optimization flags
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

## Allow obfuscation of app-specific classes
# -repackageclasses ''
# -allowaccessmodification

## Debugging: Uncomment to see what's being removed
# -whyareyoukeeping class com.vicdan.app.**
