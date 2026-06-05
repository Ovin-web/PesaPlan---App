import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ REQUIRED for Firebase
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream().reader())
}

val flutterVersionCode =
    localProperties.getProperty("flutter.versionCode")?.toIntOrNull() ?: 1
val flutterVersionName =
    localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "KelvinKimani.com.pesaplan_new"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8

        // ✅ REQUIRED for flutter_local_notifications ^19+
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "KelvinKimani.com.pesaplan_new"
        minSdk = 26
        targetSdk = 34
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ✅ REQUIRED by flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
