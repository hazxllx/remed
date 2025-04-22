buildscript {
    dependencies {
        // ✅ Firebase plugin for Google Services
        classpath("com.google.gms:google-services:4.4.0")
    }

    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Customize the root build directory
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    project.evaluationDependsOn(":app")
}

// Custom clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
