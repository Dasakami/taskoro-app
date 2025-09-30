import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val kotlinVersion: String by project

android {
    namespace  = "com.taskoro.taskoro"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.taskoro.taskoro"
        minSdk        = 23
        targetSdk     = flutter.targetSdkVersion
        versionCode   = flutter.versionCode
        versionName   = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = file("C:/Users/acer/StudioProjects/taskoro/keystore.properties")
            if (!keystorePropertiesFile.exists()) {
                throw GradleException("keystore.properties file not found")
            }

            val props = Properties()
            FileInputStream(keystorePropertiesFile).use { props.load(it) }

            keyAlias = props.getProperty("keyAlias") ?: throw GradleException("keyAlias missing in keystore.properties")
            keyPassword = props.getProperty("keyPassword") ?: throw GradleException("keyPassword missing in keystore.properties")
            storePassword = props.getProperty("storePassword") ?: throw GradleException("storePassword missing in keystore.properties")

            val storePath = props.getProperty("storeFile") ?: throw GradleException("storeFile missing in keystore.properties")
            storeFile = file(storePath)
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
