plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// подхватываем kotlin_version из android/gradle.properties
val kotlinVersion: String by project

android {
    namespace    = "com.taskoro.taskoro"
    compileSdk   = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.taskoro.taskoro"
        minSdk        = 23
        targetSdk     = flutter.targetSdkVersion
        versionCode   = flutter.versionCode
        versionName   = flutter.versionName
    }

    compileOptions {
        sourceCompatibility       = JavaVersion.VERSION_17
        targetCompatibility       = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // версия десугаринга ≥2.1.4
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // …другие implementation()/api()…
}
