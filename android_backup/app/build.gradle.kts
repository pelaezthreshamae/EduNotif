plugins {
    id "com.android.application"
    id "kotlin-android"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.example.edunotif"
    compileSdk flutter.compileSdkVersion
            ndkVersion flutter.ndkVersion

            compileOptions {
                sourceCompatibility JavaVersion.VERSION_17
                        targetCompatibility JavaVersion.VERSION_17
                        coreLibraryDesugaringEnabled true    // ✅ REQUIRED FIX
            }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId "com.example.edunotif"
        minSdk flutter.minSdkVersion
                targetSdk flutter.targetSdkVersion
                versionCode flutter.versionCode
                versionName flutter.versionName
    }

    buildTypes {
        release {
            // Signing with debug keys so `flutter run --release` works.
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source "../.."
}

dependencies {
    // ✅ REQUIRED FOR flutter_local_notifications
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
}
