import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: create android/key.properties (git-ignored) with
// storeFile, storePassword, keyAlias and keyPassword. Without it, release
// builds fall back to the debug key so `flutter run --release` still works.
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

// Google's demo AdMob app ID, safe to ship in non-production builds.
val testAdmobAppId = "ca-app-pub-3940256099942544~3347511713"

android {
    namespace = "com.nextgenai.agentkhata"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.nextgenai.agentkhata"
        // Android 8.0+ (tech design, section 9).
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keyProperties.containsKey("storeFile")) {
            create("release") {
                storeFile = rootProject.file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appLabel"] = "Khata Dev"
            // Dev always uses Google's test AdMob app.
            manifestPlaceholders["admobAppId"] = testAdmobAppId
        }
        create("prod") {
            dimension = "env"
            manifestPlaceholders["appLabel"] = "Agent Khata"
            // The live AdMob app ID comes from the ADMOB_APP_ID environment
            // variable or a Gradle property; otherwise Google's test app.
            manifestPlaceholders["admobAppId"] =
                (System.getenv("ADMOB_APP_ID")
                    ?: (project.findProperty("ADMOB_APP_ID") as String?)
                    ?: testAdmobAppId)
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Theme.AppCompat is required by the biometric prompt (local_auth).
    implementation("androidx.appcompat:appcompat:1.7.0")
}

flutter {
    source = "../.."
}
