# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep the MainActivity
-keep class com.example.life_track.MainActivity { *; }

# Keep all classes that might be used by the plugins
-keep class * extends androidx.fragment.app.Fragment{}

# Keep FlutterPlugin classes
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin
-keep class * implements io.flutter.embedding.engine.plugins.activity.ActivityAware
-keep class * implements io.flutter.plugin.common.MethodChannel
-keep class * implements io.flutter.plugin.common.PluginRegistry

# Notifications plugin
-keep class com.dexterous.** { *; }

# Common Android libraries
-keep class androidx.** { *; }
-keep interface androidx.** { *; } 