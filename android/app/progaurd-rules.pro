# Don’t warn about missing proguard.annotation.*
-dontwarn proguard.annotation.**

# Keep the annotation classes so R8 can resolve them
-keep class proguard.annotation.Keep { *; }
-keep @proguard.annotation.Keep class *
-keepclassmembers class * {
    @proguard.annotation.Keep *;
}
