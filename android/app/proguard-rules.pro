# ProGuard / R8 правила.
#
# По умолчанию подключён `proguard-android-optimize.txt`. Здесь — только специфичные
# для наших зависимостей правила.

# Flutter сохраняет свои классы через стандартные правила Gradle Plugin.

# flutter_blue_plus использует JNI и reflection.
-keep class com.lib.flutter_blue_plus.** { *; }

# drift / sqlite3_flutter_libs — нативный код SQLite.
-keep class com.tekartik.sqflite.** { *; }
-keep class io.requery.android.database.** { *; }

# fl_chart использует canvas-операции через reflection.
-keep class com.github.fluttercommunity.workmanager.** { *; }

# flutter_local_notifications — broadcast receivers и сериализация.
-keep class com.dexterous.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.models.** { *; }
-dontwarn com.dexterous.**

# permission_handler — Android API reflection.
-keep class com.baseflow.permissionhandler.** { *; }

# Сохраняем источники строк для понятных stack trace'ов в crash-репортах.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
