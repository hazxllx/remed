plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // ✅ Required for Firebase
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.remed"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.remed"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("path/to/your/keystore.jks")  // Replace with the path to your keystore
            storePassword = "your_keystore_password"  // Replace with your keystore password
            keyAlias = "your_key_alias"  // Replace with your key alias
            keyPassword = "your_key_password"  // Replace with your key password
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")  // Use the release signing config
        }
    }
}

flutter {
    source = "../.."
}

// ✅ Apply Google Services plugin at the BOTTOM
apply(plugin = "com.google.gms.google-services")
